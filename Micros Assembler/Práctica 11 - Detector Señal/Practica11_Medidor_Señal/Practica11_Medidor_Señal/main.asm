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
out DDRB, R16
out DDRA, R16

ldi R16, 0b1111_1111
out DDRC, R16
ldi R16, 0b1111_1111
out PORTB, R16
out PORTA, R16
ldi R16, 0b0000_0000
out PORTC, R16

ldi R20, 0	//milisegundos de la señal
ldi R21, 0	//Contador para cuando haga un cambio de señal dos veces


;Timer
SEI
ldi R16, 124
out OCR0, R16
ldi R16, 0
out TCNT0, R16
ldi R16, 0b0000_1000	
out TCCR0,R16
ldi R16, 0b0000_0011
out TIFR, R16
ldi R16, 0b0000_0010
out TIMSK, r16	

ldi R16, 0b0000_0001
out PORTC, R16

BOTON:
	sbis PINB,0
	breq ENTRAR

	rjmp BOTON

ENTRAR:
	rcall CONTAR
	rcall RETARDO50ms
	TRABA:
		sbis PINB,0
		rjmp TRABA
	rcall RETARDO50ms

	rjmp BOTON

ESPERA_A:
	CEROS:				;esperar hasta que vuelva 0
		sbis PINA,0
		rjmp CEROS
	UNO:				;esperar hasta que vuelva 1
		sbic PINA,0
		rjmp UNO
	ret

ESPERA_B:
	UNO_B:				;esperar hasta que vuelva 1
		sbic PINA,0
		rjmp UNO_B
	ret

CONTAR:
	sbis PINA,0
	breq ESPERA_A

	sbic PINA,0
	breq ESPERA_B

	inc R21
	;iniciar el timer

	
	ret


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

AUMENTA:
	inc R21
	reti

MUESTRA:
	out PORTC, R20
	reti

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
	in R16, SREG
	
	inc R20
	sbis PINB,1
	breq AUMENTA

	cpi R21, 2
	breq MUESTRA

	out SREG, R16
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler
