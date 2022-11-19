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

;Configuracion de puertos
ldi R16, 0b0000_0000
out DDRA, R16
ldi R16, 0b1000_0001
out PORTA, R16

ldi R16, 0b1111_1111
out DDRC, R16
out DDRD, R16 
ldi R16, 0
out PORTC, R16
out PORTD, R16


;Configuracion de timer
ldi R16, 155			;tope
out OCR0, R16
ldi R16, 0b0000_0011
out TIFR, R16			;Activar las banderas antes de habilitar interrupciones
ldi R16, 0b0000_0010
out TIMSK, r16			;Habilitar interrupción por Comparación
ldi R16, 0				;Contador en 0
out TCNT0, R16
ldi R16, 0b0000_1000	;Modo CTC con Prescaler de 0 para evitar que empiece a contar
out TCCR0,R16
SEI						;activar interrupciones globales

;Programa
ldi R30, 1
ldi R31, 0


BOTONES:
	sbis PINA, 0
	rjmp INICIO
	sbis PINA, 7
	rjmp LIMPIAR
	rjmp BOTONES

INICIO:	
	ldi R16, 0
	out PORTC, R16
	out PORTD, R16

	ldi R22, 0				;contador auxiliar
	ldi R23, 0				;Unidades Segundos
	ldi R24, 0				;Decenas Segundos
	ldi R25, 0				;Minutos
					
	rcall RETARDO50ms
	TRABA:
		sbis PINA,0
		rjmp TRABA
	rcall RETARDO50ms

	ldi R16, 0b0000_1100	;Modo CTC con Prescaler de 256
	out TCCR0,R16

	rjmp BOTONES

LIMPIAR:
	rcall RETARDO50ms
	TRABA2:
		sbis PINA,7
		rjmp TRABA2
	rcall RETARDO50ms

	rjmp RESET
	rjmp BOTONES

MINUTOS:
	ldi R24,0
	inc R25
	reti

DECENAS:					
	ldi R23,-1
	inc R24
	reti

MOSTRAR:
	ldi R22,0					;Limpiar Contador del timer
	inc R23
	/*				
	cpi R23, 10				; lo hace pero no lo imprime, tarda mucho el ciclo de reloj
	breq DECENAS
	*/
	/*
	cpi R24,6				; lo hace pero no lo imprime, tarda mucho el ciclo de reloj
	breq MINUTOS
	*/
	mov R26, R24
	swap R26
	andi R26, 0b1111_0000
	or R26,R23
	out PORTC, R25
	out PORTD, R26
	reti						; por qué un reti y no un ret?

DETENER:
	ldi R16, 0b0000_1000	;Modo CTC con Prescaler de 256
	out TCCR0,R16
	reti

RETARDO50ms:
	; ============================= 
	;    delay loop generator 
	;     12500 cycles:
	; ----------------------------- 
	; delaying 12495 cycles:
			  ldi  R17, $11
	WGLOOP0:  ldi  R18, $F4
	WGLOOP1:  dec  R18
			  brne WGLOOP1
			  dec  R17
			  brne WGLOOP0
	; ----------------------------- 
	; delaying 3 cycles:
			  ldi  R17, $01
	WGLOOP2:  dec  R17
			  brne WGLOOP2
	; ----------------------------- 
	; delaying 2 cycles:
			  nop
			  nop
	; ============================= 
	ret

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
	in R21, SREG
	
	cpi R25, 5
	breq DETENER

	cpi R23, 9
	breq DECENAS

	cpi R24,6	
	breq MINUTOS

	inc R22
	cpi R22,100
	breq MOSTRAR
	
	out SREG, R21
	
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler



