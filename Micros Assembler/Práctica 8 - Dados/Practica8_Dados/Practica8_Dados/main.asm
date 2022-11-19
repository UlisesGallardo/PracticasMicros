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

;Set global interrput Flag
sei								

;*********************************
;Aquí comienza el programa...
;No olvides configurar al inicio todo lo que utilizarás
;*********************************			
	cli
	ldi R16, 0b1111_1111
	out DDRA, R16
	ldi R16, 0b0000_0000
	out PORTA, R16
	out DDRD, R16
	ldi R16, 0b0000_0100
	out PORTD, R16	

;Configuración de interrupciones
	
	sei
	ldi R16, 0b0000_0010			;flanco de bajada para INT0 
	out MCUCR,R6					;MCU Control Register (MCUCR) página 66 datasheet, para confg de interrupciones 0 y 1
									;MCU Control and Status Registe(MCUCSR), página 67 para confg de la interrupción 2
						
	ldi R16, 0b1110_0000			;limpiar banderas en GIFR
	out GIFR, R16
	ldi R16, 0b0100_0000			
	out GICR, R16					;General Interrupt Control Register página 67

	ldi R16, 1
	ldi R20, 1
	
REINICIO:
	add R16, R20
	cpi R16, 8
	breq INICIO
	SIGUIENTE:	
	rcall RETARDO50m
	rjmp REINICIO

INICIO:
	ldi R16, 1
	rjmp SIGUIENTE

RETARDO50m:
	ldi  R17, $65
AA:  
	ldi  R18, $A4
BB:  
	dec  R18
	brne BB
	dec  R17
	brne AA
    ldi  R17, $01
CC:  dec  R17
    brne CC
	nop
	nop
	ret

UNO:
	ldi R22, 0b0000_1000
	out PORTA, R22
	ret

DOS:
	ldi R22, 0b0010_0010
	out PORTA, R22
	ret

TRES:
	ldi R22, 0b0100_1001
	out PORTA, R22
	ret

CUATRO:
	ldi R22, 0b0101_0101
	out PORTA, R22
	ret

CINCO:
	ldi R22, 0b0101_1101
	out PORTA, R22
	ret

SEIS:
	ldi R22, 0b0111_0111
	out PORTA, R22
	ret

SIETE:
	ldi R22, 0b0111_1111
	out PORTA, R22
	ret

MUESTRA:
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
	ret


;*********************************
;Aquí está el manejo de las interrupciones concretas
;*********************************
EXT_INT0: ; IRQ0 Handler
	in R21, SREG
	cli							;si no lo desactivo, en el retardo habrá rebote, por lo que volverá a entrar a la interrupción
	rcall RETARDO50m
	TRABA1:
		sbis PIND, 2
		rjmp TRABA1
	rcall RETARDO50m
	sei
	
	rcall MUESTRA

	out SREG, R21
	ldi R21, 0b1110_0000			;limpiar banderas en GIFR
	out GIFR, R21
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



