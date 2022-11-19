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


ldi R16, 0b0101_0101
out DDRA, R16
ldi R16, 0b1111_1111			;resistencias internas
out PORTA, R16

out DDRC, R16					;Salidas puerto C
ldi R16, 0b0000_0000
out PORTC, R16
ldi R20, 0						;Contador Rojo A
ldi R21, 0						;Contador Azul B

BOTONES:
	sbis PINA,0
	rjmp RESETA
	sbis PINA,2
	rjmp AUMENTAA
	sbis PINA,4
	rjmp RESETB	
	sbis PINA,6
	rjmp AUMENTAB
	rjmp BOTONES

RESETA:
	ldi R20, 0
	ldi R22, 0
	rcall SUMA
	rcall RETARDO50ms
	TRABA1:
		sbis PINA,0
		rjmp TRABA1
	rcall RETARDO50ms
	rjmp BOTONES

RESETB:
	rcall RETARDO50ms
	TRABA2:
		sbis PINA,4
		rjmp TRABA2
	rcall RETARDO50ms
	ldi R21, 0
	call SUMA
	rjmp BOTONES

AUMENTAA:
	inc R20
	mov R22,R20
	swap R22
	rcall SUMA

	rcall RETARDO50ms
	TRA:
		sbis PINA,2
		rjmp TRA
	rcall RETARDO50ms
	
	rjmp BOTONES	
		
AUMENTAB:
	rcall RETARDO50ms
	TRABA4:
		sbis PINA,6
		rjmp TRABA4
	rcall RETARDO50ms
	
	inc R21
	rcall SUMA	
	rjmp BOTONES

SUMA:
	COMPARA:
	cpi R20, 16
	breq CICLO
	cpi R21, 16
	breq CICLO2

	ldi R23, 0
	add R23, R22
	add R23, R21
	out PORTC,R23
	ret

RETARDO50ms:
	ldi  R17, $65
A:  
	ldi  R18, $A4
B:  
	dec  R18
	brne B
	dec  R17
	brne A
    ldi  R17, $01
C:  dec  R17
    brne C
	nop
	nop
	ret

CICLO:
	ldi R20, 0
	mov R22, R20
	swap R22
	rjmp COMPARA

CICLO2:
	LDI R21,0
	rjmp COMPARA

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



