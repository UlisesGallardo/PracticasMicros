;******************************************************
; Título del proyecto
;
; Fecha: Poner aquí la fecha
; Autor: Poner aquí el autor
;******************************************************

.include "m16adef.inc"     
   
;******************************************************
;Registros (aquí pueden definirse)
;.def temporal=r19

;Palabras claves (aquí pueden definirse)
;.equ LCD_DAT=DDRC
;******************************************************

.org 0x0000
;Comienza el vector de interrupciones.
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
; Termina el vector de interrupciones.

;******************************************************
;Aquí comenzará el programa
;******************************************************
Reset:
;Primero inicializamos el stack pointer...
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 

;******************************************************
;No olvides configurar al inicio los puertos que utilizarás
;También debes configurar si habrá o no pull ups en las entradas
;Para las salidas deberás indicar cuál es la salida inicial
;Los registros que vayas a utilizar inicializalos si es necesario
;******************************************************

sei

.def CONTADORD = R20
ldi CONTADORD, 0
.def CONTADORU = R21
ldi CONTADORU, 0
.def VALIDAR = R22
ldi VALIDAR, 0

ldi R16, 0b1111_1111
out DDRC, R16
ldi R16, 0b0000_0000
out PORTC, R16
out DDRA, R16
out PORTA, R16
out DDRB, R16
ldi R16, 0b1111_1111
out PORTB, R16

;Configuración del timer

ldi R16, 124
out OCR0, R16
ldi R16, 0b0000_1000
out TCCR0, R16
ldi R16, 0b0000_0000
out TCNT0, R16
ldi R16, 0b0000_0010
out TIMSK, R16
ldi R16, 0b0000_0011
out TIFR, R16

BOTON:
	sbis PINB, 0
	rjmp BUSCAR
	rjmp BOTON

BUSCAR:
	rcall RETARDO
	TRABA:
		sbis PINB, 0
		rjmp TRABA
	rcall RETARDO
	sbis PINA, 0
	rjmp CERO
	sbic PINA, 0
	rjmp UNO
	rjmp BOTON

CERO:
	sbic PINA, 0
	rjmp UNO
	rjmp CERO

UNO:
	sbis PINA, 0
	rjmp INICIAR
	rjmp UNO

INICIAR:
	cpi VALIDAR, 1
	breq DETENER
	inc VALIDAR
	ldi R16, 0b0000_1010
	out TCCR0, R16
	rjmp CERO
	;rjmp UNO

DETENER:
	swap CONTADORD
	or CONTADORD, CONTADORU
	out PORTC, CONTADORD
	ldi R16, 0b0000_1000
	out TCCR0, R16
	ldi R16, 0b0000_0000
	out TCNT0, R16
	ldi CONTADORU, 0
	ldi CONTADORD, 0
	ldi VALIDAR, 0
	rjmp BOTON

RETARDO: ;1Mh
	; ============================= 
	;    delay loop generator 
	;     50000 cycles:
	; ----------------------------- 
	; delaying 49995 cycles:
			  ldi  R16, $65
	WGLOOP0:  ldi  R18, $A4
	WGLOOP1:  dec  R18
			  brne WGLOOP1
			  dec  R16
			  brne WGLOOP0
	; ----------------------------- 
	; delaying 3 cycles:
			  ldi  R16, $01
	WGLOOP2:  dec  R16
			  brne WGLOOP2
	; ----------------------------- 
	; delaying 2 cycles:
			  nop
			  nop
	; ============================= 
	ret

;******************************************************
;Aquí están las rutinas para el manejo de las interrupciones concretas
;******************************************************
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
    inc CONTADORU
	cpi CONTADORU, 10
	breq AUMENTARD
	CONTIUNAR:
    out SREG, R16
	reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler

AUMENTARD:
	inc CONTADORD
	ldi CONTADORU, 0
	rjmp CONTIUNAR