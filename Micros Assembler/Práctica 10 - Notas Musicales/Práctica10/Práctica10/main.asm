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

ldi R16, 0b1111_1111
out DDRB, R16
;ldi R16, 0b0000_0000
out PORTB, R16

out DDRC, R16
out DDRD, R16
ldi R16, 0b1111_1111
out PORTC, R16
out PORTD, R16

;Timer a 4 Mhz
ldi R16, 1
out OCR0, R16
ldi R16,0
out TCNT0, R16

ldi R16, 0b0000_0011
out TIFR, R16
ldi R16, 0b0000_0010
out TIMSK, r16	

ldi R16, 0b0110_1000	;Modo CTC con Prescaler desactivado y 01 en OC0
out TCCR0,R16

;Programa

ldi R20,1				;Variable booleana

BOTONES:
	sbis PIND,0
	rjmp MARTINILLO
	rjmp BOTONES


MARTINILLO:
	rcall RETARDO50ms
	TRABAd0:
		sbis PIND,0
		rjmp TRABAd0
	rcall RETARDO50ms

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_RE
	rcall NEGRAS

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_RE
	rcall NEGRAS

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_FA
	rcall NEGRAS

	rcall NOTA_SOL
	rcall BLANCAS

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_FA
	rcall NEGRAS

	rcall NOTA_SOL
	rcall BLANCAS

	rcall NOTA_SOL
	rcall CORCHEA

	rcall NOTA_LA
	rcall CORCHEA

	rcall NOTA_SOL
	rcall CORCHEA

	rcall NOTA_FA
	rcall CORCHEA

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_SOL
	rcall CORCHEA

	rcall NOTA_LA
	rcall CORCHEA

	rcall NOTA_SOL
	rcall CORCHEA

	rcall NOTA_FA
	rcall CORCHEA

	rcall NOTA_MI
	rcall NEGRAS

	rcall NOTA_DO
	rcall NEGRAS

	rcall NOTA_RE
	rcall NEGRAS

	rcall NOTA_SOL
	rcall NEGRAS

	rcall NOTA_DO
	rcall BLANCAS

	rcall NOTA_RE
	rcall NEGRAS

	rcall NOTA_SOL
	rcall NEGRAS

	rcall NOTA_DO
	rcall BLANCAS

	;FIN
	ldi R16, 0b0110_1000	
	out TCCR0,R16
	cbi PORTB, 3
	rjmp BOTONES

RETARDO50ms:
	; ============================= 
	;    delay loop generator 
	;     50000 cycles:
	; ----------------------------- 
	; delaying 49995 cycles:
			  ldi  R17, $65
	WGLOOP0:  ldi  R18, $A4
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

;NOTAS

NOTA_DO:
	ldi R16, 29
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b0001_1011	
	out TCCR0,R16
	ret

NOTA_RE:	
	ldi R16, 26
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b0001_1011	
	out TCCR0,R16
	ret

NOTA_MI:
	ldi R16, 23
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b0001_1011	
	out TCCR0,R16
	ret

NOTA_FA:
	ldi R16, 21
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b0001_1011	
	out TCCR0,R16
	ret

NOTA_SOL:
	ldi R16, 19
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b0001_1011	
	out TCCR0,R16
	ret
	
NOTA_LA:
	ldi R16, 17
	out OCR0, R16
	ldi R16,0
	out TCNT0, R16

	ldi R16, 0b001_1011		;Modo CTC con Prescaler de 64 y 01 en OC0
	out TCCR0,R16
	ret

NEGRAS:
	; ============================= 
	;    delay loop generator 
	;     500000 cycles:
	; ----------------------------- 
	; delaying 499995 cycles:
			  ldi  R17, $0F
	WGLOOP0_NEGRA:  ldi  R18, $37
	WGLOOP1_NEGRA:  ldi  R19, $C9
	WGLOOP2_NEGRA:  dec  R19
			  brne WGLOOP2_NEGRA
			  dec  R18
			  brne WGLOOP1_NEGRA
			  dec  R17
			  brne WGLOOP0_NEGRA
	; ----------------------------- 
	; delaying 3 cycles:
			  ldi  R17, $01
	WGLOOP3_NEGRA:  dec  R17
			  brne WGLOOP3_NEGRA
	; ----------------------------- 
	; delaying 2 cycles:
			  nop
			  nop
	; ============================= 
	ret

BLANCAS:
	rcall NEGRAS
	rcall NEGRAS
	ret

CORCHEA:
	; ============================= 
	;    delay loop generator 
	;     250000 cycles:
	; ----------------------------- 
	; delaying 249999 cycles:
			  ldi  R17, $A7
	WGLOOP0_CORCHEA:  ldi  R18, $02
	WGLOOP1_CORCHEA:  ldi  R19, $F8
	WGLOOP2_CORCHEA:  dec  R19
			  brne WGLOOP2_CORCHEA
			  dec  R18
			  brne WGLOOP1_CORCHEA
			  dec  R17
			  brne WGLOOP0_CORCHEA
	; ----------------------------- 
	; delaying 1 cycle:
			  nop
	; ============================= 

	ret

NEGRA_PUNTILLO:
	rcall NEGRAS
	rcall CORCHEA
	ret

BLANCA_PUNTILLO:
	rcall BLANCAS
	rcall NEGRAS
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
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler



