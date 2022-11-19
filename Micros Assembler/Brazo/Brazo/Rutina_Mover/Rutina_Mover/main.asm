;******************************************************
; Código base: Teclado
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

.def MP = R20			;Salida de motores de paso
ldi MP, 0
.def eX = R21			;Movimiento de motor de base
ldi eX, 0b0000_0001
.def eY = R22			;Movimiento de motoro de altura
ldi eY, 0b0001_0000

;TECLADO

.equ DDR_TEC = DDRA
.equ PORT_TEC = PORTA
.equ PIN_TEC = PINA

ldi R16, 0xF0			;0b1111_0000
out DDR_TEC, R16		;Configuré el puerto del teclado SALIDAS:ENTRADAS

;MOTORES DE PASO

.equ DDR_MP = DDRC
.equ PORT_MP = PORTC
.equ PIN_MP = PINC

ldi R16, 0xFF			;0b1111_1111
out DDR_MP, R16
ldi R16, 0b00
out PORT_MP, R16

;SERVOMOTORES

ldi R16, 0xFF
out DDRB, R16
out DDRD, R16
ldi R16, 0x00
out PORTB, R16
out PORTD, R16

ldi R16, 22
out OCR0, R16
ldi R16, 0b0110_1011 ;0b0110_1011
out TCCR0, R16

TECLADO:
	ldi R16, 0xFF		;0b1111_1111
	out PORT_TEC, R16	;5v en las salidas, PullUps en las entradas
	cbi PORT_TEC, 4		;Pone 0 en el pin 4 del puerto del teclado

	nop					;Pierde un ciclo de reloj
	nop					;Pierde un ciclo de reloj

	sbis PIN_TEC, 0		;Si tiene 0, hace la linea siguiente
	rjmp UNO			;Cerrar pinza
	sbis PIN_TEC, 1
	rjmp CUATRO			;Derecha
	sbis PIN_TEC, 2
	rjmp SIETE
	sbis PIN_TEC, 3
	rjmp ASTERISCO
	sbi PORT_TEC, 4		;5v en el pin 4 del puerto del teclado
	cbi PORT_TEC, 5		;0v en el pin 5 del puerto del teclado

	nop					;Pierde un ciclo de reloj
	nop					;Pierde un ciclo de reloj

	sbis PIN_TEC, 0		;Si tiene 0, hace la linea siguiente
	rjmp DOS			;Arriba
	sbis PIN_TEC, 1
	rjmp CINCO			;Automático
	sbis PIN_TEC, 2
	rjmp OCHO			;Abajo
	sbis PIN_TEC, 3
	rjmp CERO	
	sbi PORT_TEC, 5		;5v en el pin 5 del puerto del teclado
	cbi PORT_TEC, 6		;0v en el pin 6 del puerto del teclado

	nop					;Pierde un ciclo de reloj
	nop					;Pierde un ciclo de reloj

	sbis PIN_TEC, 0		;Si tiene 0, hace la linea siguiente
	rjmp TRES			;Abrir pinza
	sbis PIN_TEC, 1
	rjmp SEIS			;Izquierda
	sbis PIN_TEC, 2
	rjmp NUEVE
	sbis PIN_TEC, 3
	rjmp GATO
	sbi PORT_TEC, 6		;5v en el pin 6 del puerto del teclado
	cbi PORT_TEC, 7		;0v en el pin 7 del puerto del teclado

	nop					;Pierde un ciclo de reloj
	nop					;Pierde un ciclo de reloj

	sbis PIN_TEC, 0		;Si tiene 0, hace la linea siguiente
	rjmp A				;Posición inicial
	sbis PIN_TEC, 1
	rjmp B				;Posición agarrar
	sbis PIN_TEC, 2
	rjmp C				;Posición derecha
	sbis PIN_TEC, 3
	rjmp D				;Posición izquierda
	
	rjmp TECLADO

UNO:					;Cerrar pinza		
	;Código al presionar
	rcall RETARDO50M
	TRABA_UNO:
		sbis PIN_TEC,0
		rjmp TRABA_UNO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

DOS:					;Arriba
	;Código al presionar
	rcall RETARDO50M
	TRABA_DOS:
		rcall GIRA_ARR
		sbis PIN_TEC,0
		rjmp TRABA_DOS
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

TRES:					;Cerrar pinza
	;Código al presionar
	rcall RETARDO50M
	TRABA_TRES:
		sbis PIN_TEC,0
		rjmp TRABA_TRES
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

A:						;Posición inicial
	;Código al presionar
	ldi R16, 22
	out OCR0, R16

	rcall RETARDO50M
	TRABA_A:
		sbis PIN_TEC,0
		rjmp TRABA_A
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

CUATRO:					;Izquierda
	;Código al presionar
	rcall RETARDO50M
	TRABA_CUATRO:
		rcall GIRA_IZQ
		sbis PIN_TEC,1
		rjmp TRABA_CUATRO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

CINCO:					;Automático
	;Código al presionar
	rcall RETARDO50M
	TRABA_CINCO:
		sbis PIN_TEC,1
		rjmp TRABA_CINCO
	rcall RETARDO50M
	;Código al soltar
	nop
	rcall GIRA_DER
	rjmp TECLADO

GIRARAR_DERECHA:	
	; ============================= 
	;    delay loop generator 
	;     1 cycles:
	; ----------------------------- 
	; delaying 1 cycle
	rcall GIRA_DER
	; ============================= 
	
	ret

SEIS:					;Derecha
	rcall RETARDO50M
	TRABA_SEIS:
		rcall GIRA_DER
		sbis PIN_TEC, 1
		rjmp TRABA_SEIS
	rcall RETARDO50M
	rjmp TECLADO

	/*lsl eX
	COMPARA0:
		cpi eX, 0b0001_0000
		breq RESET0
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO10M
		sbis PIN_TEC,1
		rjmp SEIS
	rcall RETARDO50M
	rjmp TECLADO*/

	/*rcall RETARDO50M
	TRABA_SEIS:
		sbis PIN_TEC,1
		rjmp TRABA_SEIS
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO*/

/*RESET0:
	;ldi SALIDA, 0b1111_1110
	ldi eX, 0b0000_0001 
	rjmp COMPARA0*/

B:						;Posición agarrar
	;Código al presionar
	ldi R16, 38
	out OCR0, R16

	rcall RETARDO50M
	TRABA_B:
		sbis PIN_TEC,1
		rjmp TRABA_B
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

SIETE:					
	;Código al presionar
	rcall RETARDO50M
	TRABA_SIETE:
		sbis PIN_TEC,2
		rjmp TRABA_SIETE
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

OCHO:					;Abajo
	;Código al presionar
	rcall RETARDO50M
	TRABA_OCHO:
		rcall GIRA_ABA
		sbis PIN_TEC,2
		rjmp TRABA_OCHO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

NUEVE:					
	;Código al presionar
	rcall RETARDO50M
	TRABA_NUEVE:
		sbis PIN_TEC,2
		rjmp TRABA_NUEVE
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

C:						;Posición derecha
	;Código al presionar
	ldi R16, 7
	out OCR0, R16

	rcall RETARDO50M
	TRABA_C:
		sbis PIN_TEC,2
		rjmp TRABA_C
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

ASTERISCO:					
	;Código al presionar
	rcall RETARDO50M
	TRABA_ASTERISCO:
		sbis PIN_TEC,3
		rjmp TRABA_ASTERISCO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

CERO:					
	;Código al presionar
	rcall RETARDO50M
	TRABA_CERO:
		sbis PIN_TEC,3
		rjmp TRABA_CERO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

GATO:					
	;Código al presionar
	rcall RETARDO50M
	TRABA_GATO:
		sbis PIN_TEC,3
		rjmp TRABA_GATO
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

D:						;Posición izquierda
	;Código al presionar
	rcall RETARDO50M
	TRABA_D:
		sbis PIN_TEC,3
		rjmp TRABA_D
	rcall RETARDO50M
	;Código al soltar
	rjmp TECLADO

GIRA_ARR:
	rcall RETARDO5M
	ldi eY, 0b1100_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eY, 0b0110_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M
	
	ldi eY, 0b0011_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eY, 0b1001_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	
	ret

GIRA_ABA:
	rcall RETARDO5M
	ldi eY, 0b0011_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eY, 0b0110_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M
	
	ldi eY, 0b1100_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eY, 0b1001_0000
	andi MP, 0b0000_1111
	or MP, eY
	out PORT_MP, MP
	
	ret

GIRA_DER:
	rcall RETARDO5M
	ldi eX, 0b0000_1100
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eX, 0b0000_0110
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M
	
	ldi eX, 0b0000_0011
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eX, 0b0000_1001
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	
	rcall RETARDO5M

	ldi eX, 0b0000_1100
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	ret

GIRA_IZQ:
	rcall RETARDO5M
	ldi eX, 0b0000_0011
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eX, 0b0000_0110
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M
	
	ldi eX, 0b0000_1100
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	rcall RETARDO5M

	ldi eX, 0b0000_1001
	andi MP, 0b1111_0000
	or MP, eX
	out PORT_MP, MP
	
	ret

RETARDO10M:
	; ============================= 
	;    delay loop generator 
	;     10000 cycles:
	; ----------------------------- 
	; delaying 9999 cycles:
			  ldi  R17, $21
	WGLOOP00:  ldi  R18, $64
	WGLOOP10:  dec  R18
			  brne WGLOOP10
			  dec  R17
			  brne WGLOOP00
	; ----------------------------- 
	; delaying 1 cycle:
			  nop
	; ============================= 
	ret

RETARDO5M:
	; ============================= 
	;    delay loop generator 
	;     5000 cycles:
	; ----------------------------- 
	; delaying 4998 cycles:
			  ldi  R17, $07
	WGLOOP02:  ldi  R18, $ED
	WGLOOP12:  dec  R18
			  brne WGLOOP12
			  dec  R17
			  brne WGLOOP02
	; ----------------------------- 
	; delaying 2 cycles:
			  nop
			  nop
	; ============================= 
	ret

RETARDO100M:
	; ============================= 
	;    delay loop generator 
	;     100000 cycles:
	; ----------------------------- 
	; delaying 99990 cycles:
			  ldi  R17, $A5
	AA:  ldi  R18, $C9
	BB:  dec  R18
			  brne BB
			  dec  R17
			  brne AA
	; ----------------------------- 
	; delaying 9 cycles:
			  ldi  R17, $03
	CC:  dec  R17
			  brne CC
	; ----------------------------- 
	; delaying 1 cycle:
			  nop
	; ============================= 
	ret

RETARDO50M: ;50ms a 1Mh
	; ============================= 
	;    delay loop generator 
	;     50000 cycles:
	; ----------------------------- 
	; delaying 49995 cycles:
			  ldi  R16, $65
	WGLOOP01:  ldi  R18, $A4
	WGLOOP11:  dec  R18
			  brne WGLOOP11
			  dec  R16
			  brne WGLOOP01
	; ----------------------------- 
	; delaying 3 cycles:
			  ldi  R16, $01
	WGLOOP21:  dec  R16
			  brne WGLOOP21
	; ----------------------------- 
	; delaying 2 cycles:
			  nop
			  nop
	; ============================= 
	ret

/*RETARDO: ;8Mh
	; ============================= 
	;    delay loop generator 
	;     400000 cycles:
	; ----------------------------- 
	; delaying 399999 cycles:
			  ldi  R17, $97
	WGLOOP0:  ldi  R18, $06
	WGLOOP1:  ldi  R19, $92
	WGLOOP2:  dec  R19
			  brne WGLOOP2
			  dec  R18
			  brne WGLOOP1
			  dec  R17
			  brne WGLOOP0
	; ----------------------------- 
	; delaying 1 cycle:
			  nop
	; ============================= */

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
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler
