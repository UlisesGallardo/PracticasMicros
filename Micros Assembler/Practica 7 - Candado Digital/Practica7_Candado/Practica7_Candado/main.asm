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

.equ LCD_DAT= DDRD; 
.equ PORT_TEC= PORTA		;puerto del teclado
.equ DDR_TEC = DDRA			;Entrada/salida del teclado
.equ PIN_TEC= PINA			; pines del teclado

ldi R16, 0b1111_0000
out DDR_TEC, R16			;configuré el puerto del teclado SALIDAS:ENTRADAS

ldi R16, 0b1000_0001		;Salidas
out LCD_DAT,R16

ldi R16, 0b1000_0000        ;está al revés???????????????????
out PORTD, R16

ldi R20, 0b0000_0000		; contador
ldi R21, 1					; booleano (flag)
ldi R30, 0b0000_0000		; Desactivar
ldi R24, 0b0000_0000
ldi R25, 0b0000_0000

TECLADO:
	ldi R16, 0b1111_1111	; todo con unos
	out PORT_TEC, R16		; pongo 5V de salidas y pullups en las entradas
	cbi PORT_TEC, 4			;pone un 0 en el pin 4 del puerto del teclado
	
	;es en el pin 4 en adelante porque aquí es donde estará la tierra
	;en proteus cada pin a partir del 4 representa una columna
	;pero en fisico puede representar una fila


	;al presionar debo de checar si en los pines del 0 al 3 hay un 1
	;esto es porque en cada fila, respectivamente, significa que se presionó el botón 
	
	nop						; dar tiempo para que la energía llegué a todos los botones
	nop
	sbis PIN_TEC, 0
	rjmp D
	sbis PIN_TEC, 1
	rjmp C
	sbis PIN_TEC, 2
	rjmp B
	sbis PIN_TEC, 3
	rjmp A
	sbi PORT_TEC, 4		;Pongo 5 v en el pin 4 del puerto del teclado
	cbi PORT_TEC, 5		; pone un 0 en el pin 5 del puerto del teclado
	nop
	nop

	sbis PIN_TEC, 0
	rjmp GATO
	sbis PIN_TEC, 1
	rjmp NUEVE
	sbis PIN_TEC, 2
	rjmp SEIS
	sbis PIN_TEC, 3
	rjmp TRES

	sbi PORT_TEC, 5		; Pongo 5 v en el pin 6 del puerto del teclado
	cbi PORT_TEC, 6		; pone un 0 en el pin 7 del puerto del teclado

	nop
	nop

	sbis PIN_TEC, 0
	rjmp CERO
	sbis PIN_TEC, 1
	rjmp OCHO
	sbis PIN_TEC, 2
	rjmp CINCO
	sbis PIN_TEC, 3
	rjmp DOS
	
	sbi PORT_TEC, 6		 ;Pongo 5 v en el pin 6 del puerto del teclado
	cbi PORT_TEC, 7		 ; pone un 0 en el pin 7 del puerto del teclado
	
	nop
	nop
	
	sbis PIN_TEC, 0
	rjmp ASTERISCO
	sbis PIN_TEC, 1
	rjmp SIETE
	sbis PIN_TEC, 2
	rjmp CUATRO
	sbis PIN_TEC, 3
	rjmp UNO
	nop
	nop

rjmp TECLADO


UNO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_UNO:
		sbis PIN_TEC, 3
	rjmp TRABA_UNO
	rcall RETARDO50m

	;código al soltar
	ldi R16, 1
	rcall CLAVE
	rjmp TECLADO

DOS:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_DOS:
		sbis PIN_TEC, 3	;El dos entra igual por el 0
	rjmp TRABA_DOS
	rcall RETARDO50m
	;código al soltar
	ldi R16, 2
	rcall CLAVE
	rjmp TECLADO


TRES:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_TRES:
		sbis PIN_TEC, 3	;El dos entra igual por el 0
	rjmp TRABA_TRES
	rcall RETARDO50m
	;código al soltar
	ldi R16, 3
	rcall CLAVE
	rjmp TECLADO


A:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_A:
		sbis PIN_TEC, 3	;El dos entra igual por el 0
	rjmp TRABA_A
	rcall RETARDO50m
	;código al soltar
	rcall CLAVE
	rjmp TECLADO

CUATRO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CUATRO:
		sbis PIN_TEC, 2	;El dos entra igual por el 1
	rjmp TRABA_CUATRO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 4
	rcall CLAVE
	rjmp TECLADO

CINCO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CINCO:
		sbis PIN_TEC, 2	;El dos entra igual por el 1
	rjmp TRABA_CINCO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 5
	rcall CLAVE
	rjmp TECLADO

SEIS:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_SEIS:
		sbis PIN_TEC, 2	;El dos entra igual por el 1
	rjmp TRABA_SEIS
	rcall RETARDO50m
	;código al soltar
	ldi R16, 6
	rcall CLAVE
	rjmp TECLADO

B:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_B:
		sbis PIN_TEC, 2	;El dos entra igual por el 1
	rjmp TRABA_B
	rcall RETARDO50m
	;código al soltar
	rcall CLAVE
	rjmp TECLADO

SIETE:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_SIETE:
		sbis PIN_TEC, 1	;El dos entra igual por el 2
	rjmp TRABA_SIETE
	rcall RETARDO50m
	;código al soltar
	ldi R16, 7
	rcall CLAVE
	rjmp TECLADO


OCHO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_OCHO:
		sbis PIN_TEC, 1	;El dos entra igual por el 2
	rjmp TRABA_OCHO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 8
	rcall CLAVE
	rjmp TECLADO

NUEVE:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_NUEVE:
		sbis PIN_TEC, 1	;El dos entra igual por el 2
	rjmp TRABA_NUEVE
	rcall RETARDO50m
	;código al soltar
	ldi R16, 9
	rcall CLAVE
	rjmp TECLADO

C:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_C:
		sbis PIN_TEC, 1	;El dos entra igual por el 2
	rjmp TRABA_C
	rcall RETARDO50m
	;código al soltar
	rcall CLAVE
	rjmp TECLADO

ASTERISCO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_ASTERISCO:
		sbis PIN_TEC, 0	;El ASTERISCO entra igual por el 0
	rjmp TRABA_ASTERISCO
	rcall RETARDO50m
	;código al soltar
	rcall CLAVE
	rjmp TECLADO

CERO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CERO:
		sbis PIN_TEC, 0	;El CERO entra igual por el 0
	rjmp TRABA_CERO
	rcall RETARDO50m
	;código al soltar
	rcall CLAVE
	rjmp TECLADO

GATO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_GATO:
		sbis PIN_TEC, 0	;El GATO entra igual por el 0
	rjmp TRABA_GATO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 0
	rcall CLAVE
	rjmp TECLADO

D:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_D:
		sbis PIN_TEC, 0	;El D entra igual por el 0
	rjmp TRABA_D
	rcall RETARDO50m
	;código al soltar
	/*cpi R30, 1
	breq DESACTIVAR
	Se muere el programa, cuando no 
	*/
	sbis PIND, 0
	rjmp REINICIAR
	rjmp TECLADO

CLAVE:
	cpi R30, 1
	breq DESACTIVAR

	sbis PIND, 7 //o sbic
	breq REINICIAR

	cpi R20, 0
	breq Posicion1
	cpi R20, 1
	breq Posicion2
	cpi R20, 2
	breq Posicion3
	cpi R20, 3
	breq Posicion4

	rjmp REINICIAR

	SALIR:
	ldi R22,1
	add R20,R22		;incrementar contador
	ret

Posicion1:
	ldi R22,1 
	cpse R16,R22	;Si es diferente, hace la siguiente línea, sino se la salta
		ldi R21,0	
	rjmp SALIR

Posicion2: 
	ldi R22,5 
	cpse R16,R22
		ldi R21,0
	rjmp SALIR

Posicion3:
	ldi R22,7
	cpse R16,R22
		ldi R21,0	
	rjmp SALIR

Posicion4: 
	ldi R22,9
	cpse R16,R22
		ldi R21,0
	rjmp VERIFICAR

VERIFICAR:
	cpi R21,1
	breq ABRIR
	rjmp ALARMA

ABRIR:
	ldi R16, 0b0000_0000
	out PORTD, R16
	rjmp SALIR

ALARMA:
	ldi R16, 0b1000_0001
	out PORTD, R16
	ldi R30, 1
	rjmp SALIR

DESACTIVAR:
	mov R24, R25
	mov R25, R16

	ldi R26,0			;suma
	cpi R24, 2
	breq SUMA1
	REGRESO1:
	cpi R25, 3
	breq SUMA2
	REGRESO2:
	cpi R26, 2
	breq REINICIAR
	rjmp SALIR

SUMA1:
	ldi R16, 1
	add R26, R16
	rjmp REGRESO1
SUMA2:
	ldi R16, 1
	add R26, R16
	rjmp REGRESO2

REINICIAR:
	ldi R20, 0b0000_0000		; contador
	ldi R16, 0b1000_0000
	out PORTD, R16
	ldi R21, 1					; booleano (flag)
	ldi R30, 0					; Desactivar
	ldi R24, 0b0000_0000
	ldi R25, 0b0000_0000
	rjmp TECLADO

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



