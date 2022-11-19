;*******************
; Título del proyecto
;
; Created: Poner aquí la fecha
; Author : Poner aquí el autor
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aquí pueden definirse)
;.def temporal=r19

;Palabras claves (aquí pueden definirse)
;.equ LCD_DAT=DDRC
;********************

.org 0x0000
;Comienza el vector de interrupciones...
jmp RESET ; Reset Handler
jmp EXT_INT0 ; IRQ0 Handler
jmp EXT_INT1 ; IRQ1 Handler
jmp TIM2_COMP ; Timer2 Compare Handler
jmp TIM2_OVF ; Timer2 Overflow Handler
jmp TIM1_CAPT ; Timer1 Capture Handler
jmp TIM1_COMPA ; Timer1 CompareA Handler
jmp TIM1_COMPB ; Timer1 CompareB Handler
jmp TIM1_OVF ; Timer1 Overflow Handler
jmp TIM0_OVF ; Timer0 Overflow Handler
jmp SPI_STC ; SPI Transfer Complete Handler
jmp USART_RXC ; USART RX Complete Handler
jmp USART_UDRE ; UDR Empty Handler
jmp USART_TXC ; USART TX Complete Handler
jmp ADC_COMP ; ADC Conversion Complete Handler
jmp EE_RDY ; EEPROM Ready Handler
jmp ANA_COMP ; Analog Comparator Handler
jmp TWSI ; Two-wire Serial Interface Handler
jmp EXT_INT2 ; IRQ2 Handler
jmp TIM0_COMP ; Timer0 Compare Handler
jmp SPM_RDY ; Store Program Memory Ready Handler

;**************
;Inicializar el Stack Pointer
;**************
Reset:
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 


;*********************************
;Aquí comienza el programa...
;No olvides configurar al inicio todo lo que utilizarás
;*********************************

ldi R16, 0b0000_0000	
out DDRA, R16
ldi R16, 0b0000_1111 //Resistencias
out PORTA, R16

ldi R16, 0b1111_1111 
out DDRC, R16

ldi R16, 0b0111_1111 //mostrar 0
out PORTC, R16

LEER:
	in R16, PINA
	cpi R16, 0
	breq CERO
	cpi R16, 1
	breq UNO
	cpi R16, 2 
	breq DOS
	cpi R16, 3 
	breq TRES
	cpi R16, 4 
	breq CUATRO
	cpi R16, 5 
	breq CINCO
	cpi R16, 6 
	breq SEIS
	cpi R16, 7 
	breq SIETE
	cpi R16, 8 
	breq OCHO
	cpi R16, 9 
	breq NUEVE 
	rjmp OTRO
	rjmp LEER

CERO:
	ldi R16, 0b0011_1111
	out PORTC, R16
	rjmp LEER
UNO:
	ldi R16, 0b0000_0110
	out PORTC, R16
	rjmp LEER

DOS:
	ldi R16, 0b0101_1011
	out PORTC, R16
	rjmp LEER

TRES:
	ldi R16, 0b0100_1111
	out PORTC, R16
	rjmp LEER

CUATRO:
	ldi R16, 0b0110_0110
	out PORTC, R16
	rjmp LEER

CINCO:
	ldi R16, 0b0110_1101
	out PORTC, R16
	rjmp LEER

SEIS:
	ldi R16, 0b0111_1101
	out PORTC, R16
	rjmp LEER

SIETE:
	ldi R16, 0b0000_0111
	out PORTC, R16
	rjmp LEER

OCHO:
	ldi R16, 0b0111_1111
	out PORTC, R16
	rjmp LEER

NUEVE:
	ldi R16, 0b0110_1111
	out PORTC, R16
	rjmp LEER

OTRO:
	ldi R16, 0b0000_0000
	out PORTC, R16
	rjmp LEER

;*********************************
;Aquí está el manejo de las interrupciones concretas
;*********************************
EXT_INT0: ; IRQ0 Handler
reti
EXT_INT1: 
reti ; IRQ1 Handler
TIM2_COMP: 
reti ; Timer2 Compare Handler
TIM2_OVF: 
reti ; Timer2 Overflow Handler
TIM1_CAPT: 
reti ; Timer1 Capture Handler
TIM1_COMPA: 
reti ; Timer1 CompareA Handler
TIM1_COMPB: 
reti ; Timer1 CompareB Handler
TIM1_OVF: 
reti ; Timer1 Overflow Handler
TIM0_OVF: 
reti ; Timer0 Overflow Handler
SPI_STC: 
reti ; SPI Transfer Complete Handler
USART_RXC: 
reti ; USART RX Complete Handler
USART_UDRE: 
reti ; UDR Empty Handler
USART_TXC: 
reti ; USART TX Complete Handler
ADC_COMP: 
reti ; ADC Conversion Complete Handler
EE_RDY: 
reti ; EEPROM Ready Handler
ANA_COMP: 
reti ; Analog Comparator Handler
TWSI: 
reti ; Two-wire Serial Interface Handler
EXT_INT2: 
reti ; IRQ2 Handler
TIM0_COMP: 
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler



