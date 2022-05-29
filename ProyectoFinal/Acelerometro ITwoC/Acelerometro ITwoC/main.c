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

#include "MPU6050_res_define.h"							/* Include MPU6050 register define file */
#include "I2C_Master_H_file.h"							/* Include I2C Master header file */

#define DDRLCD DDRA
#define PORTLCD PORTA
#define PINLCD PINA

#define BAUD 9600
#define MYUBRR F_CPU/16/BAUD-1

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

void USART_Init(uint16_t ubrr);
void USART_Transmit_char(uint8_t data);
void UART_sendString(char *str);

float Acc_x,Acc_y,Acc_z,Temperature,Gyro_x,Gyro_y,Gyro_z;

void MPU6050_Init()										
{
	_delay_ms(150);										
	I2C_Start_Wait(0xD0);								
	I2C_Write(SMPLRT_DIV);								
	I2C_Write(0x07);									
	I2C_Stop();

	I2C_Start_Wait(0xD0);
	I2C_Write(PWR_MGMT_1);								
	I2C_Write(0x01);									
	I2C_Stop();

	I2C_Start_Wait(0xD0);
	I2C_Write(CONFIG);									
	I2C_Write(0x00);									
	I2C_Stop();

	I2C_Start_Wait(0xD0);
	I2C_Write(GYRO_CONFIG);								
	I2C_Write(0x18);									
	I2C_Stop();

	I2C_Start_Wait(0xD0);
	I2C_Write(INT_ENABLE);								
	I2C_Write(0x01);
	I2C_Stop();
}

void MPU_Start_Loc()
{
	I2C_Start_Wait(0xD0);								
	I2C_Write(ACCEL_XOUT_H);							
	I2C_Repeated_Start(0xD1);							
}

void Read_RawValue()
{
	MPU_Start_Loc();									
	Acc_x = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Acc_y = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Acc_z = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Temperature = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Gyro_x = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Gyro_y = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Ack());
	Gyro_z = (((int)I2C_Read_Ack()<<8) | (int)I2C_Read_Nack());
	I2C_Stop();
}


int main(void)
{
	char buffer[20], float_[10];
	float Xa,Ya,Za,t;
	float Xg=0,Yg=0,Zg=0;
	LCD_init();
	USART_Init(MYUBRR);
	I2C_Init();											
	MPU6050_Init();
	

	LCD_wr_instruction(0b10000000);
	LCD_wr_string("SENSANDO... ");
	while (1)
	{
		Read_RawValue();

		Xa = Acc_x/16384.0;								
		Ya = Acc_y/16384.0;
		Za = Acc_z/16384.0;
		
		Xg = Gyro_x/16.4;
		Yg = Gyro_y/16.4;
		Zg = Gyro_z/16.4;

		t = (Temperature/340.00)+36.53;					
		
		
		char value[3];
		dtostrf(Xa, 1, 2, value);
		LCD_wr_instruction(LCD_Cmd_Clear);
		LCD_wr_instruction(0b11000000);
		LCD_wr_string(value);
		
		if(Xa>=0.35){
			UART_sendString("IZQ");
			//LCD_wr_instruction(LCD_Cmd_Clear);
			LCD_wr_instruction(0b10000000);
			LCD_wr_string("Izq");
		}else if(Xa<=-0.35){
			UART_sendString("DER");
			//LCD_wr_instruction(LCD_Cmd_Clear);
			LCD_wr_instruction(0b10000000);
			LCD_wr_string("Der");
		}
		//_delay_ms(250);
		_delay_ms(1200);
	}
}

/*----------------------------------------------------Comunicacion Serial--------------------------------------------------------------*/

void USART_Init(uint16_t ubrr)
{
	DDRD |= 0b00000010;
	UBRRH = (uint8_t)(ubrr>>8);
	UBRRL = (uint8_t)ubrr;
	UCSRB |= (1 << RXEN) | (1 << TXEN);         
	UCSRC |= (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1); 
}

void USART_Transmit_char(uint8_t data)
{
	while (!(UCSRA&(1<<UDRE))) {}
	UDR = data;
}

void UART_sendString(char *str){
	unsigned char s=0;
	while (str[s]!=0){
		USART_Transmit_char(str[s]);    
		s++;
	}
}

/*----------------------------------------------------LCD--------------------------------------------------------------*/
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




