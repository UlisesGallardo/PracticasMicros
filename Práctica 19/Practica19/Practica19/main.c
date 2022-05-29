/*
 * Practica19.c
 *
 * Created: 17/05/2022 10:53:41 a. m.
 * Author : Vladimir
 */ 
#define F_CPU 4000000

#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdlib.h>

uint8_t convetir(uint8_t valor);

uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT)
{
	return (!(*LUGAR&(1<<BIT)));
}

void SPI_Master_Init()
{
	SPSR = 0b00000000;
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);	
	DDRB = (1<<5)|(1<<7)|(1<<4); /*El ss irá como salida pues solo tenemos 1 dispositivo*/
}

uint8_t Master_Transmit(uint8_t dir, uint8_t data)
{
	PORTB &= ~(1 << 4);
	SPDR = dir;
	while(cero_en_bit(&SPSR,SPIF));
	SPDR = data;
	while(cero_en_bit(&SPSR,SPIF));
	PORTB |= (1 << 4);

	return SPDR;
}

void MAX_7221_init(){
	Master_Transmit(0x09, 0x00);//modo decode
	Master_Transmit(0x0A, 0x0f); //MODO Intensidad luminoza , MAXIMA INTENSIDAD
	Master_Transmit(0x0B, 0X03); //LIMITE SCAN
	Master_Transmit(0x0C, 0X01); //SHUTDOWN	
	Master_Transmit(0X01, 0x00); //TEST REGISTER FORMAT
}


int main(void)
{	
	SPI_Master_Init();
	MAX_7221_init();
	
	int con = 1;
    while (1) 
    {
		_delay_ms(250);		
		int aux = con;
		//if(aux == 15)continue;		
		uint8_t pos = 4;
		while(1){
			Master_Transmit(pos, convetir(aux%10));
			aux/=10;
			if(aux == 0)break;
			pos--;	
		}
		con++;
    }
	
}

uint8_t convetir(uint8_t valor){
	if(valor == 0)return 0b00111111;
	else if(valor == 1)return 0b00000110;
	else if(valor == 2)return 0b01011011;
	else if(valor == 3)return 0b01001111;
	else if(valor == 4)return 0b01100110;
	else if(valor == 5)return 0b01101101;
	else if(valor == 6)return 0b01111101;
	else if(valor == 7)return 0b01000111;
	else if(valor == 8)return 0b01111111;
	else if(valor == 9)return 0b01100111;
	return 0b00000110;
}
