;******************************************************
; T�tulo del proyecto
;
; Fecha: Poner aqu� la fecha
; Autor: Poner aqu� el autor
;******************************************************

.include "m16adef.inc"     
   
;******************************************************
;Registros (aqu� pueden definirse)
;.def temporal=r19

;Palabras claves (aqu� pueden definirse)
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
;Aqu� comenzar� el programa
;******************************************************
Reset:
;Primero inicializamos el stack pointer...
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 


;******************************************************
;No olvides configurar al inicio los puertos que utilizar�s
;Tambi�n debes configurar si habr� o no pull ups en las entradas
;Para las salidas deber�s indicar cu�l es la salida inicial
;Los registros que vayas a utilizar inicializalos si es necesario
;******************************************************

ldi R16, 0b0000_0000		
out DDRA, R16					//configuro el puerto A de entrada

ldi R16, 0b1111_1111
out PORTA, R16					//activo las resistencias del Pull up en A

;ldi R16, 0b1111_1111			; ya no es necesario pues R16 ya ten�a 1s
out DDRC, R16					//confirguro el puerto C como salida

ldi R16, 0b0000_0000			// Apago todos los LEDs del puerto C
out PORTC, R16


LEER:
//siempre leer el PIN y no el PORT
in R16, PINA					;en R16 queda lo que est� en los botones en ese momento
out PORTC, R16					;saco lo le�do por el puerto C
rjmp LEER						;


;******************************************************
;Aqu� est�n las rutinas para el manejo de las interrupciones concretas
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



