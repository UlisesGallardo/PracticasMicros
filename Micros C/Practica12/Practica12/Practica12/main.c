/*
 * Practica12.c
 *
 * Created: 20/3/2022 16:02:58
 * Author : Vladimir
 */ 

#define F_CPU 1000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdlib.h>
#include <avr/interrupt.h>

#define PINT PIND
#define PORTT PORTD
#define DDRT DDRD

#define DDRLCD DDRC
#define PORTLCD PORTC
#define PINLCD PINC

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

uint8_t hasta_tecla()
{
	/* //Para Proteus
	uint8_t regreso[4][4] = {
	{7,8,9,12},
	{4,5,5,13},
	{1,2,3,14},
	{10,0,11,15}};
	*/
	//Para teclado físico
	uint8_t regreso[4][4] = {
		{1,2,3,12},
		{4,5,5,13},
		{7,8,9,14},
		{10,0,11,15}};
	while(1)
	{
		for(int i=0;i<4;i++)
		{
			PORTT = ~(1<<i);
			asm("nop");
			if(cero_en_bit(&PINT,4))
			{
				_delay_ms(50);
				while(cero_en_bit(&PINT,4)){}
				_delay_ms(50);
				return regreso[i][0];
			}
			if(cero_en_bit(&PINT,5))
			{
				_delay_ms(50);
				while(cero_en_bit(&PINT,5)){}
				_delay_ms(50);
				return regreso[i][1];
			}
			if(cero_en_bit(&PINT,6))
			{
				_delay_ms(50);
				while(cero_en_bit(&PINT,6)){}
				_delay_ms(50);
				return regreso[i][2];
			}
			if(cero_en_bit(&PINT,7))
			{
				_delay_ms(50);
				while(cero_en_bit(&PINT,7)){}
				_delay_ms(50);
				return regreso[i][3];
			}
		}
	}
	return 0;
}

uint16_t posicion_actual = 0;				//0 a 511 EEPROM 
uint16_t maxima_posicion = 0;

void EEPROM_Write(uint16_t dir, uint8_t data)
{
	while(uno_en_bit(&EECR,EEWE)){}
	EEAR = dir;
	EEDR = data;
	cli();
	EECR |= (1<<EEMWE);
	EECR |= (1<<EEWE);
	sei();
}

uint8_t EEPROM_Read(uint16_t dir)
{
	while(uno_en_bit(&EECR,EEWE)){}
	EEAR = dir;
	EECR |= (1<<EERE);
	return EEDR;
}

uint8_t flag = 1;

ISR(ADC_vect){
	uint8_t res = ADCH;
	MostrarPosicion();
	if(posicion_actual<=511){
		EEPROM_Write(posicion_actual,res);
		posicion_actual++;
	}else{
		if(flag){
			LCD_wr_instruction(LCD_Cmd_Clear);
			flag = 0;
			LCD_wr_instruction(0b10000000);
			LCD_wr_string("EEPROM llena! ");
			MostrarPosicion();
		}
	}
}

ISR(TIMER0_COMP_vect){
	
}


void MostrarPosicion(){
	uint8_t u  = posicion_actual%10;
	uint8_t d  = (posicion_actual/10)%10;
	uint8_t c  = (posicion_actual/100)%10;
	LCD_wr_instruction(0b11000111);
	LCD_wr_char(c+48);
	LCD_wr_char(d+48);
	LCD_wr_char(u+48);
}

void MostrarLecutra(){
	float res = ((uint16_t)EEPROM_Read(posicion_actual) * 5)/255.0;
	uint8_t v = (uint8_t)res;
	LCD_wr_instruction(0b11000000);
	LCD_wr_char(v+48);
	
	LCD_wr_instruction(0b11000001);
	LCD_wr_char('.');
	
	//decimal 1
	uint8_t decimal1 = (res*10.0);
	decimal1 -= (v*10);
	LCD_wr_instruction(0b11000010);
	LCD_wr_char(decimal1+48);
	//decimal 2
	uint8_t decimal2 = (uint8_t)(res*100) - (v*100) - (decimal1*10);
	LCD_wr_instruction(0b11000011);
	LCD_wr_char(decimal2+48);
}

int main(void)
{
	LCD_init(); 
	//Importa el orden de configuración, primero el ADC y luego el Timer

	/*Configuracion ADC*/
	SFIOR  = 0b01100000;	/*Con interrupción del Timer0*/
	ADMUX  = 0b01100000;
	ADCSRA = 0b10101011;	/*Trigger Activado, factor de conversión: 8 a 1 mhz*/
	
	/*Timer0*/
	//Se reinicia si se habilita la interrupcion
	TIFR  = 0b00000011;
	TIMSK = 0b00000010;		//Importante quitar la interrupcion del Timer0
	TCNT0 = 0;
	OCR0  = 243;
	TCCR0 = 0b00001101;		//Prescaler 1024 en modo CTC
	
	/*Puertos*/
	DDRT  = 0b00001111;
	PORTT = 0b11111111;
	
	DDRA  = 0b00000000;
	PORTA = 0b00000000;

	LCD_wr_instruction(0b10000000);
	LCD_wr_string("SENSANDO... ");	
	
	sei();					//Importante primero inicializar el LCD antes de agregas las interrupciones

	while (1)
	{
		uint8_t tecla = hasta_tecla();
		//apagar timer
		
		if(tecla == 14 && (TCCR0 & (1<<0))){
			TCCR0 = 0b00001000;
			posicion_actual--;
			maxima_posicion = posicion_actual;
			LCD_wr_instruction(LCD_Cmd_Clear);
			_delay_ms(10);
			LCD_wr_instruction(0b10000000);
			LCD_wr_string("ULTIMOS VAL.");
			MostrarPosicion();
			MostrarLecutra();
		}
		else{
			if(tecla == 12 && posicion_actual+1 <= maxima_posicion){
				posicion_actual+=1;
				MostrarLecutra();
				MostrarPosicion();
			}else if(tecla == 13 && posicion_actual > 0){
				posicion_actual-=1;
				MostrarLecutra();
				MostrarPosicion();
			}else if(tecla == 14){ //reiniciar
				LCD_wr_instruction(LCD_Cmd_Clear);
				_delay_ms(10);
				LCD_wr_instruction(0b10000000);
				LCD_wr_string("SENSANDO... ");
				posicion_actual = 0;
				TCCR0 = 0b00001101;
			}
		}
	
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




