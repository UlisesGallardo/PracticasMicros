/*
 * Reloj.c
 *
 * Created: 13/06/2022 02:33:44 p. m.
 * Author : Vladimir
 */ 
#define F_CPU 1000000
#include <avr/io.h>

#include <util/delay.h>
#include <stdint.h>
#include <stdlib.h>
#include <avr/interrupt.h>
#include <util/twi.h> /*Importante*/


#define DDRLCD DDRA
#define PORTLCD PORTA
#define PINLCD PINA

#define RS 4
#define RW 5
#define E 6
#define BF 3
#define LCD_Cmd_Clear      0b00000001
#define LCD_Cmd_Home       0b00000010
//#define LCD_Cmd_Mode     0b000001 ID  S
#define LCD_Cmd_ModeDnS	   0b00000110 //sin shift cursor a la derecha
#define LCD_Cmd_ModeInS	   0b00000100 //sin shift cursor a la izquierda
#define LCD_Cmd_ModeIcS	   0b00000111 //con shift desplazamiento a la izquierda
#define LCD_Cmd_ModeDcS	   0b00000101 //con shift desplazamiento a la derecha
//#define LCD_Cmd_OnOff    0b00001 D C B
#define LCD_Cmd_Off		   0b00001000
#define LCD_Cmd_OnsCsB	   0b00001100
#define LCD_Cmd_OncCsB     0b00001110
#define LCD_Cmd_OncCcB     0b00001111
//#define LCD_Cmd_Shift    0b0001 SC  RL 00
//#define LCD_Cmd_Function 0b001 DL  N  F  00
#define LCD_Cmd_Func2Lin   0b00101000
#define LCD_Cmd_Func1LinCh 0b00100000
#define LCD_Cmd_Func1LinG  0b00100100
//#define LCD_Cmd_DDRAM    0b1xxxxxxx

uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT);
void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT);
void LCD_wr_inst_ini(uint8_t instruccion);
void LCD_wr_char(uint8_t data);
void LCD_wr_instruction(uint8_t instruccion);
void LCD_wait_flag(void);
void LCD_init(void);
void LCD_wr_string(volatile uint8_t *s);

/*Reloj*/
#define DS3231_ReadMode_U8    (0xD1) /*1101 0001*/
#define DS3231_WriteMode_U8   (0xD0) /*1101 0000*/
#define DS3231_REG_Seconds    (0x00)
#define SCL_CLOCK  100000

#define MASK_SEC  0b011111111;
#define MASK_MIN  0b011111111;
#define MASK_HORA 0b001111111;

/*I2C*/

typedef struct
{
	uint8_t sec;
	uint8_t min;
	uint8_t hour;
	uint8_t weekDay;
	uint8_t date;
	uint8_t month;
	uint8_t year;
}rtc_t;

void init_i2c(void)
{
	/* initialize TWI clock: 100 kHz clock, TWPS = 0 => prescaler = 1 */
	
	                      
	TWBR = ((F_CPU/SCL_CLOCK)-16)/2;  /* must be > 10 for stable operation */
	TWSR = 0;   /* no prescaler */
	TWCR = (1<<TWINT) | (1<<TWSTA) | (1<<TWEN); /*master transmisor*/
}

uint8_t i2c_readAck(void)
{
	TWCR = (1<<TWINT) | (1<<TWEN) | (1<<TWEA);
	while(!(TWCR & (1<<TWINT)));

	return TWDR;
}

uint8_t i2c_readNack(void)
{
	TWCR = (1<<TWINT) | (1<<TWEN);
	while(!(TWCR & (1<<TWINT)));
	
	return TWDR;
}

void i2c_stop(void)
{
	/* send stop condition */
	TWCR = (1<<TWINT) | (1<<TWEN) | (1<<TWSTO);
	while(TWCR & (1<<TWSTO)); // wait until stop condition is executed and bus released
}

uint8_t i2c_write(uint8_t byte_data)
{
	uint8_t   twst;
	
	// send data to the previously addressed device
	TWDR = byte_data;
	TWCR = (1<<TWINT) | (1<<TWEN);

	// wait until transmission completed
	while(!(TWCR & (1<<TWINT)));

	// check value of TWI Status Register. Mask prescaler bits
	twst = TW_STATUS & 0xF8;
	if( twst != TW_MT_DATA_ACK) return 1;
	return 0;
}

uint8_t i2c_start(uint8_t addr)
{
	uint8_t   twst;
	TWCR = (1<<TWINT) | (1<<TWSTA) | (1<<TWEN);
	while(!(TWCR & (1<<TWINT)));                    // wait until transmission completet
	twst = TW_STATUS & 0xF8;                    // check value of TWI Status Register. Mask prescaler bits.
	if ( (twst != TW_START) && (twst != TW_REP_START)) return 1;
	TWDR = addr;                             // send device address
	TWCR = (1<<TWINT) | (1<<TWEN);
	while(!(TWCR & (1<<TWINT)));            // wail until transmission completed and ACK/NACK has been received
	twst = TW_STATUS & 0xF8;               // check value of TWI Status Register. Mask prescaler bits.
	if ( (twst != TW_MT_SLA_ACK) && (twst != TW_MR_SLA_ACK) ) return 1;
	return 0;
}

void i2c_start1()
{
	TWCR = (1<<TWINT) | (1<<TWSTA) | (1<<TWEN);
	while(!(TWCR & (1<<TWINT)));
}


uint8_t DS3231_Bin_Bcd(uint8_t binary_value)
{
	uint8_t temp;
	uint8_t retval;
	temp = binary_value;
	retval = 0;
	while(1)
	{
		if(temp >= 10){
			temp -= 10;
			retval += 0x10;
			}else{
			retval += temp;
			break;
		}
	}
	return(retval);
}

void DS3231_Set_Date_Time(uint8_t hr, uint8_t mn, uint8_t sc)
{	
	i2c_start1();  
	i2c_write(DS3231_WriteMode_U8);        // connect to ds3231 by sending its ID on I2c Bus
	i2c_write(DS3231_REG_Seconds);
	i2c_write(sc);
	i2c_write(mn);
	i2c_write(hr);
	i2c_stop();   
}

void ds3231_GetDateTime(rtc_t *rtc)
{
	i2c_start1();                            // Start I2C communication
	i2c_write(DS3231_WriteMode_U8);        // connect to ds3231 by sending its ID on I2c Bus
	i2c_write(DS3231_REG_Seconds);         // Request Sec RAM address at 00H
	i2c_stop();                            // Stop I2C communication after selecting Sec Register

	i2c_start1();                            // Start I2C communication
	i2c_write(DS3231_ReadMode_U8);            // connect to ds3231(Read mode) by sending its ID

	rtc->sec = i2c_readAck() ;                // read second and return Positive ACK
	rtc->min = i2c_readAck() ;                 // read minute and return Positive ACK
	rtc->hour= i2c_readAck() ;               // read hour and return Negative/No ACK
	rtc->weekDay = i2c_readAck();           // read weekDay and return Positive ACK
	rtc->date= i2c_readAck();              // read Date and return Positive ACK
	rtc->month=i2c_readAck();            // read Month and return Positive ACK
	rtc->year =i2c_readNack();             // read Year and return Negative/No ACK

	i2c_stop();                              // Stop I2C communication after reading the Date
}


void LCD_printTime(rtc_t rtc){
	uint16_t c[16];
	sprintf(c,"hora %d:%d,%d", rtc.hour, rtc.min, rtc.sec);
	LCD_wr_instruction(0b10000000);
	LCD_wr_string(c);
}

int main(void)
{
	LCD_init();
	init_i2c();
	DS3231_Set_Date_Time(18,0,0);
	rtc_t rn;
    while (1) 
    {
		ds3231_GetDateTime(&rn);
		LCD_printTime(rn);
    }
}


void LCD_wr_string(volatile uint8_t *s){
	uint8_t c;
	while((c=*s++)){
		LCD_wr_char(c);
	}
}

void LCD_init(void){
	DDRLCD=(15<<0)|(1<<RS)|(1<<RW)|(1<<E); //DDRLCD=DDRLCD|(0B01111111)
	_delay_ms(15);
	LCD_wr_inst_ini(0b00000011);
	_delay_ms(5);
	LCD_wr_inst_ini(0b00000011);
	_delay_us(100);
	LCD_wr_inst_ini(0b00000011);
	_delay_us(100);
	LCD_wr_inst_ini(0b00000010);
	_delay_us(100);
	LCD_wr_instruction(LCD_Cmd_Func2Lin); //4 Bits, número de líneas y tipo de letra
	LCD_wr_instruction(LCD_Cmd_Off); //apaga el display
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_instruction(LCD_Cmd_ModeDnS); //Entry mode set ID S
	LCD_wr_instruction(LCD_Cmd_OnsCsB); //Enciende el display
}

void LCD_wr_char(uint8_t data){
	//saco la parte más significativa del dato
	PORTLCD=data>>4; //Saco el dato y le digo que escribiré un dato
	saca_uno(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//saco la parte menos significativa del dato
	PORTLCD=data&0b00001111; //Saco el dato y le digo que escribiré un dato
	saca_uno(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	saca_cero(&PORTLCD,RS);
	LCD_wait_flag();
	
}

void LCD_wr_inst_ini(uint8_t instruccion){
	PORTLCD=instruccion; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
}

void LCD_wr_instruction(uint8_t instruccion){
	//saco la parte más significativa de la instrucción
	PORTLCD=instruccion>>4; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//saco la parte menos significativa de la instrucción
	PORTLCD=instruccion&0b00001111; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	LCD_wait_flag();
}


void LCD_wait_flag(void){
	//	_delay_ms(100);
	DDRLCD&=0b11110000; //Para poner el pin BF como entrada para leer la bandera lo demás salida
	saca_cero(&PORTLCD,RS);// Instrucción
	saca_uno(&PORTLCD,RW); // Leer
	while(1){
		saca_uno(&PORTLCD,E); //pregunto por el primer nibble
		_delay_ms(10);
		saca_cero(&PORTLCD,E);
		if(uno_en_bit(&PINLCD,BF)) {break;} //uno_en_bit para protues, 0 para la vida real
		_delay_us(10);
		saca_uno(&PORTLCD,E); //pregunto por el segundo nibble
		_delay_ms(10);
		saca_cero(&PORTLCD,E);
	}
	saca_uno(&PORTLCD,E); //pregunto por el segundo nibble
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//entonces cuando tenga cero puede continuar con esto...
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	DDRLCD|=(15<<0)|(1<<RS)|(1<<RW)|(1<<E);
}


uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT){
	return (!(*LUGAR&(1<<BIT)));
}

uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT){
	return (*LUGAR&(1<<BIT));
}
void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT){
	*LUGAR=*LUGAR|(1<<BIT);
}

void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT){
	*LUGAR=*LUGAR&~(1<<BIT);
}



