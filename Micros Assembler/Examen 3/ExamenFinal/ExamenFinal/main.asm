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


/*

Tabla para revisión

Grados	OCR0  TiempoAlto	Rnago
0		 61		0.000496	0-9
20		 62		0.000504	10-29
40		 63		0.000512	30-49
60		 64		0.00052		50-69
80		 65		0.000528	70-89
100		 66		0.000536	90-99
	
*/



;Condiguracion de puertos
ldi R16, 0b0000_0111
out DDRA, R16
ldi R16, 0b1111_1111
out DDRC, R16
out DDRD, R16

ldi R16, 0
out PORTC, R16
out PORTD, R16

;Puertos OC0
ldi R16, 0b1111_1111
out DDRB, R16
ldi R16, 0
out PORTB, R16


;Configuracion PWM
ldi R16, 61
out OCR0, R16
ldi R16, 0b0110_1010
out TCCR0, R16

;---------------------

ldi R20, 0				;Posicion Actual
ldi R21, 0				;Unidades Display
ldi R22, 0				;Decenas Display
ldi R23, 0				;Unideades Valor 
ldi R24, 0				;Decenas Valor

TECLADO:
	ldi R16, 0b1111_1111	; todo con unos
	out PORTA, R16			; pongo 5V de salidas y pullups en las entradas
	cbi PORTA, 0			;pone un 0 en el pin 4 del puerto del teclado

	nop						
	nop
	sbis PINA, 3
	rjmp TRES
	sbis PINA, 4
	rjmp SEIS
	sbis PINA, 5
	rjmp NUEVE
	sbis PINA, 6
	rjmp NUMERAL
	sbi PORTA, 0	
	cbi PORTA, 1
		
	nop
	nop
	sbis PINA, 3
	rjmp DOS
	sbis PINA, 4
	rjmp CINCO
	sbis PINA, 5
	rjmp OCHO
	sbis PINA, 6
	rjmp CERO
	sbi PORTA, 1
	cbi PORTA, 2
	
	nop
	nop
	sbis PINA, 3
	rjmp UNO
	sbis PINA, 4
	rjmp CUATRO
	sbis PINA, 5
	rjmp SIETE
	sbis PINA, 6
	rjmp ASTERISCO
	nop
	nop

	rjmp TECLADO


UNO:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_1000
	ldi R30, 1
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_UNO:
		sbis PINA, 3
	rjmp TRABA_UNO
	rcall RETARDO50m

	rjmp TECLADO

DOS:
	ldi R16, 0b0000_0100
	ldi R30, 2
	rcall GUARDAR

	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_DOS:
		sbis PINA, 3
	rjmp TRABA_DOS
	rcall RETARDO50m
	;código al soltar
	
	rjmp TECLADO


TRES:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_1100
	ldi R30, 3
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_TRES:
		sbis PINA, 3
	rjmp TRABA_TRES
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO

CUATRO:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_0010
	ldi R30, 4
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_CUATRO:
		sbis PINA, 4
	rjmp TRABA_CUATRO
	rcall RETARDO50m
	;código al soltar
	
	rjmp TECLADO

CINCO:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_1010
	ldi R30, 5
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_CINCO:
		sbis PINA, 4
	rjmp TRABA_CINCO
	rcall RETARDO50m
	;código al soltar
	
	rjmp TECLADO

SEIS:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_0110
	ldi R30, 6
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_SEIS:
		sbis PINA, 4
	rjmp TRABA_SEIS
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO

SIETE:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_1110
	ldi R30, 7
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_SIETE:
		sbis PINA, 5
	rjmp TRABA_SIETE
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO


OCHO:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_0001
	ldi R30, 8
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_OCHO:
		sbis PINA, 5
	rjmp TRABA_OCHO
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO

NUEVE:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_1001
	ldi R30, 9
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_NUEVE:
		sbis PINA, 5
	rjmp TRABA_NUEVE
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO

ASTERISCO:
	;CODIGO AL PRESIONAR

	rcall FRECUENCIA

	rcall RETARDO50m
	TRABA_ASTERISCO:
		sbis PINA, 6
	rjmp TRABA_ASTERISCO
	rcall RETARDO50m
	;código al soltar
	rjmp TECLADO

CERO:
	;CODIGO AL PRESIONAR
	ldi R16, 0b0000_0000
	ldi R30, 0
	rcall GUARDAR

	rcall RETARDO50m
	TRABA_CERO:
		sbis PINA, 6
	rjmp TRABA_CERO
	rcall RETARDO50m
	;código al soltar
	
	rjmp TECLADO

NUMERAL:
	;CODIGO AL PRESIONAR
	ldi R16, 0
	out PORTC, R16
	out PORTD, R16


	ldi R16, 61
	out OCR0, R16
	ldi R16, 0b0110_1010
	out TCCR0, R16

	;---------------------

	ldi R20, 0				;Posicion Actual
	ldi R21, 0				;Unidades Display
	ldi R22, 0				;Decenas Display
	ldi R23, 0				;Unideades Valor 
	ldi R24, 0				;Decenas Valor

	rcall RETARDO50m
	TRABA_NUMERAL:
		sbis PINA, 6
	rjmp TRABA_NUMERAL
	rcall RETARDO50m
	;código al soltar
	
	rjmp TECLADO

GUARDAR:
	cpi R20, 0
	breq Posicion1
	cpi R20, 1
	breq Posicion2

	SALIR:
	inc R20
	ret

Posicion1:
	mov R21,R16
	mov R23, R30
	rcall MUESTRA
	rjmp SALIR

Posicion2:
	mov R22, R21
	mov R24, R23

	mov R21, R16
	mov R23, R30
	rcall MUESTRA
	rjmp SALIR


MUESTRA:
	out PORTC, R21
	out PORTD, R22
	ret

SUMA:
	ldi R16, 10

	AGREGA:
		inc R23
		dec R16
		cpi R16, 1
		brge AGREGA

	dec R24
	rjmp SEGUIR

FRECUENCIA:
	ldi R16, 65
	out OCR0, R16

	SEGUIR:
	cpi R24, 1
	brge SUMA
	
	;En R23 tengo el valor de los grados a colocar en el servomotor

	cpi R23, 10
	brlt Grado_0

	cpi R23, 30
	brlt Grado_20

	cpi R23, 50
	brlt Grado_40

	cpi R23, 70
	brlt Grado_60

	cpi R23, 90
	brlt Grado_80

	cpi R23, 100
	brlt Grado_100

	
	REGRESAR:
	ret


Grado_0:
	ldi R16, 61
	out OCR0, R16
	rjmp REGRESAR
Grado_20:
	ldi R16, 62
	out OCR0, R16
	rjmp REGRESAR

Grado_40:
	ldi R16, 63
	out OCR0, R16
	rjmp REGRESAR

Grado_60:
	ldi R16, 64
	out OCR0, R16
	rjmp REGRESAR

Grado_80:
	ldi R16, 65
	out OCR0, R16
	rjmp REGRESAR

Grado_100:
	ldi R16, 66
	out OCR0, R16
	rjmp REGRESAR


RETARDO50m:							
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
reti
SPM_RDY: 
reti ; Store Program Memory Ready Handler
