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
.equ PIN_TEC= PINA			;pines del teclado

ldi R16, 0b1111_0000
out DDR_TEC, R16			;configuré el puerto del teclado SALIDAS:ENTRADAS

ldi	R16, 0b0000_0001		;Resistencias
out PORT_TEC, R16

ldi R16, 0b1111_1111		;Salidas
out DDRC,R16
out DDRB,R16
out DDRD,R16

ldi R16, 0b0000_0000
out PORTC, R16
out PORTD, R16
out PORTB, R16		

ldi R20, 1					;contador
ldi R21, 0					;decenas1
ldi R22, 0					;unidades1
ldi R23, 0					;decenas2
ldi R24, 0					;decenas2
ldi R25, 0					;operador
		

TECLADO:
	sbis PIN_TEC, 0
	rjmp REINICIAR

	ldi R16, 0b1111_1111	; todo con unos
	out PORT_TEC, R16		; pongo 5V de salidas y pullups en las entradas
	cbi PORT_TEC, 4			;pone un 0 en el pin 4 del puerto del teclado
	
	nop						
	nop
	sbis PIN_TEC, 1
	rjmp UNO
	sbis PIN_TEC, 2
	rjmp DOS
	sbis PIN_TEC, 3
	rjmp TRES
	sbi PORT_TEC, 4		
	cbi PORT_TEC, 5		
	nop
	nop

	sbis PIN_TEC, 1
	rjmp CUATRO
	sbis PIN_TEC, 2
	rjmp CINCO
	sbis PIN_TEC, 3
	rjmp SEIS
	sbi PORT_TEC, 5		
	cbi PORT_TEC, 6		
	nop
	nop

	sbis PIN_TEC, 1
	rjmp SIETE
	sbis PIN_TEC, 2
	rjmp OCHO
	sbis PIN_TEC, 3
	rjmp NUEVE
	sbi PORT_TEC, 6		 
	cbi PORT_TEC, 7		 
	nop
	nop
	
	sbis PIN_TEC, 1
	rjmp ASTERISCO
	sbis PIN_TEC, 2
	rjmp CERO
	sbis PIN_TEC, 3
	rjmp GATO
	nop
	nop

rjmp TECLADO

REINICIAR:
	ldi R16, 0b0000_0000
	out PORTC, R16
	out PORTD, R16
	out PORTB, R16		

	ldi R20, 1					;contador
	ldi R21, 0					;decenas1
	ldi R22, 0					;unidades1
	ldi R23, 0					;decenas2
	ldi R24, 0					;decenas2
	ldi R25, 0					;operador
	rjmp TECLADO


UNO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_UNO:
		sbis PIN_TEC, 1
	rjmp TRABA_UNO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 1
	rcall GUARDAR
	rjmp TECLADO

DOS:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_DOS:
		sbis PIN_TEC, 2
	rjmp TRABA_DOS
	rcall RETARDO50m
	;código al soltar
	ldi R16, 2
	rcall GUARDAR
	rjmp TECLADO


TRES:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_TRES:
		sbis PIN_TEC, 3
	rjmp TRABA_TRES
	rcall RETARDO50m
	;código al soltar
	ldi R16, 3
	rcall GUARDAR
	rjmp TECLADO

CUATRO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CUATRO:
		sbis PIN_TEC, 1
	rjmp TRABA_CUATRO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 4
	rcall GUARDAR
	rjmp TECLADO

CINCO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CINCO:
		sbis PIN_TEC, 2	
	rjmp TRABA_CINCO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 5
	rcall GUARDAR
	rjmp TECLADO

SEIS:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_SEIS:
		sbis PIN_TEC, 3
	rjmp TRABA_SEIS
	rcall RETARDO50m
	;código al soltar
	ldi R16, 6
	rcall GUARDAR
	rjmp TECLADO

SIETE:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_SIETE:
		sbis PIN_TEC, 1	
	rjmp TRABA_SIETE
	rcall RETARDO50m
	;código al soltar
	ldi R16, 7
	rcall GUARDAR
	rjmp TECLADO


OCHO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_OCHO:
		sbis PIN_TEC, 2
	rjmp TRABA_OCHO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 8
	rcall GUARDAR
	rjmp TECLADO

NUEVE:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_NUEVE:
		sbis PIN_TEC, 3
	rjmp TRABA_NUEVE
	rcall RETARDO50m
	;código al soltar
	ldi R16, 9
	rcall GUARDAR
	rjmp TECLADO

ASTERISCO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_ASTERISCO:
		sbis PIN_TEC, 1
	rjmp TRABA_ASTERISCO
	rcall RETARDO50m
	;código al soltar
	cpi R20, 3
	breq OPERADORSUMA
	rjmp TECLADO

CERO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_CERO:
		sbis PIN_TEC, 2
	rjmp TRABA_CERO
	rcall RETARDO50m
	;código al soltar
	ldi R16, 0
	rcall GUARDAR
	rjmp TECLADO

GATO:
	;CODIGO AL PRESIONAR
	rcall RETARDO50m
	TRABA_GATO:
		sbis PIN_TEC, 3
	rjmp TRABA_GATO
	rcall RETARDO50m
	;código al soltar
	cpi R20, 3
	breq OPERADORRESTA
	rjmp TECLADO

OPERADORSUMA:
	ldi R25, 1
	ldi R16,1
	add R20, R16
	rjmp TECLADO

OPERADORRESTA:
	ldi R25, 2
	ldi R16,1
	add R20, R16
	rjmp TECLADO

GUARDAR:
	cpi R20, 1
	breq Posicion1
	cpi R20, 2
	breq Posicion2
	cpi R20, 4
	breq Posicion4
	cpi R20, 5
	breq Posicion5
	ret
	SALIR:
	ldi R16,1
	add R20, R16
	ret

Posicion1:
	mov R21,R16
	rcall MUESTRA1
	rjmp SALIR

Posicion2:
	mov R22,R16
	rcall MUESTRA1
	rjmp SALIR

Posicion4:
	mov R23,R16
	rcall MUESTRA2
	rjmp SALIR

Posicion5:
	mov R24,R16
	rcall MUESTRA2
	rcall OPERACION
	rjmp SALIR

MUESTRA1:
	;Primero los bits menos significativos y luego los más significativos
	mov R30,R22
	swap R30
	ldi R31, 0b0000_0000
	or R31, R21
	or R31,R30
	out PORTC, R31 
	ret

MUESTRA2:
	;Primero los bits menos significativos y luego los más significativos
	mov R30,R24
	swap R30
	ldi R31, 0b0000_0000
	or R31, R23
	or R31,R30
	out PORTD, R31 
	ret

OPERACION:
	ldi R28, 1						;
	ldi R16, 10						;10
	ldi R30, 0						;contador auxiliar
	
	ldi R26, 0						;contador
	cpi R21, 0
	breq SIGUIENTE

	MULTIPLICACION1:
	add R26, R16
	add R30, R28
	cp R30, R21
	brlt MULTIPLICACION1

	SIGUIENTE:
	add R26, R22					;numero 1

	ldi R30, 0
	ldi R27, 0 
	cpi R23, 0
	breq SIGUIENTE2

	MULTIPLICACION2:
	add R27, R16
	add R30, R28
	cp R30, R23
	brlt MULTIPLICACION2

	SIGUIENTE2:
	add R27, R24					;numero 2
	
	;ldi R27, 0 
	;ldi R26, 0

	ldi R31, 0						;respuesta
	cpi R25, 1
	breq SUMA
	cpi R25, 2
	breq RESTA

	REGRESO:						
	ldi R30, 0
	mov R31, R26					;auxiliar
		
	cpi R31, 10						;mayor o igual a 10
	brlt MUESTRA4
	;muestra si el numero es menor a 10
	;de lo contrario obtener las decenas

	DIVISION: 
	add R30, R28
	sub R31, R16
	cpi R31, 10					;mayor o igual a 10
	brge DIVISION

	mov R26, R30
	mov R27, R31
	
	rcall MUESTRA3
	ret
SUMA:	
	add R26,R27
	rjmp REGRESO
RESTA:	
	sub R26,R27
	rjmp REGRESO

DECENAS:
	add R30, R28
	ldi R26, 0
	ret


MUESTRA3:
	;Primero los bits menos significativos y luego los más significativos
	mov R30,R27
	swap R30
	ldi R31, 0b0000_0000
	or R31,R26
	or R31,R30
	out PORTB, R31 
	ret

MUESTRA4:
	swap R26
	out PORTB, R26
	rjmp TECLADO

RETARDO50m:							//retardo
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



