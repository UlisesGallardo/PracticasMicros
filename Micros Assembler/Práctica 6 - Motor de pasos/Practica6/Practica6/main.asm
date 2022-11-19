;*******************
; T�tulo del proyecto
;
; Created: Poner aqu� la fecha
; Author : Poner aqu� el autor
;*******************

.include "m16adef.inc"     
   
;*******************
;Registros (aqu� pueden definirse)
;.def temporal=r19

;Palabras claves (aqu� pueden definirse)
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
;Aqu� comienza el programa...
;No olvides configurar al inicio todo lo que utilizar�s
;*********************************

ldi R16, 0b0000_0000
out DDRB, R16
ldi R16, 0b0000_0011
out PORTB, R16

ldi R16, 0b0000_1111
out DDRA, R16

BOTONES:
	sbis PINB, 0
	rjmp BOTONA
	sbis PINB, 1
	rjmp BOTONB
	rjmp BOTONES

BOTONA:
	rcall RETARDO50ms
	TRABA1:
		rcall GIRA_DER /*Importante, poner rcall con ret y no rjmp con ret */
		sbis PINB,0
		rjmp TRABA1
	rcall RETARDO50ms
	rjmp BOTONES

BOTONB:
	rcall RETARDO50ms
	TRABA2:
		rcall GIRA_IZQ /*Importante, poner rcall con ret y no rjmp con ret */
		sbis PINB,1
		rjmp TRABA2
	rcall RETARDO50ms
	rjmp BOTONES

GIRA_DER:
	rcall RETARDO10ms
	ldi R16, 0b0000_1100
	out PORTA, R16
	rcall RETARDO10ms

	ldi R16, 0b0000_0110
	out PORTA, R16
	rcall RETARDO10ms
	
	ldi R16, 0b0000_0011
	out PORTA, R16
	rcall RETARDO10ms

	ldi R16, 0b0000_1001
	out PORTA, R16	
	
	ret

GIRA_IZQ:
	rcall RETARDO10ms
	ldi R16, 0b0000_0011
	out PORTA, R16
	rcall RETARDO10ms

	ldi R16, 0b0000_0110
	out PORTA, R16
	rcall RETARDO10ms
	
	ldi R16, 0b0000_1100
	out PORTA, R16
	rcall RETARDO10ms

	ldi R16, 0b0000_1001
	out PORTA, R16	
	
	ret

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


RETARDO10ms:
; ============================= 
;    delay loop generator 
;     100000 cycles:
; ----------------------------- 
; delaying 99990 cycles:
          ldi  R17, $A5
A:  ldi  R18, $C9
B:  dec  R18
          brne B
          dec  R17
          brne A
; ----------------------------- 
; delaying 9 cycles:
          ldi  R17, $03
C:  dec  R17
          brne C
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
		ret


;*********************************
;Aqu� est� el manejo de las interrupciones concretas
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