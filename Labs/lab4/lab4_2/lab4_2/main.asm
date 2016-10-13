.include "m2560def.inc"

.equ pattern = 0b11110000
.def temp=r16
.def leds=r17

.equ LCD_CTRL_PORT = PORTA
.equ LCD_CTRL_DDR = DDRA
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4


.equ LCD_DATA_PORT = PORTF
.equ LCD_DATA_DDR = DDRF
.equ LCD_DATA_PIN = PINF

.macro STORE
.if @0 > 63
sts @0, @1
.else
out @0, @1
.endif
.endmacro

.macro LOAD
.if @1 > 63
lds @0, @1
.else
in @0, @1
.endif
.endmacro

.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro clear
	ldi r28, low(@0)
	ldi r29, high(@0)
	clr temp
	st y+, temp
	st y, temp
.endmacro

.macro lcd_set
	sbi LCD_CTRL_PORT, @0
.endmacro
.macro lcd_clr
	cbi LCD_CTRL_PORT, @0
.endmacro

.dseg
SecondCounter:
	.byte 2
TempCounter:
	.byte 2

.cseg	
.org 0x0000
	jmp reset


	
.org OVF1addr
	jmp Timer1OVF

.org INT0addr
    jmp EXT_INT0

default:
	reti
	
reset:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ser r16
	STORE LCD_DATA_DDR, r16
	STORE LCD_CTRL_DDR, r16
	clr r16
	STORE LCD_DATA_PORT, r16
	STORE LCD_CTRL_PORT, r16

	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink
	sei
	jmp main


Timer1OVF:
	in temp, SREG
	push temp
	push Yh
	push YL
	push r25
	push r24
	ldi r28, low(tempcounter)
	ldi r29, high(tempcounter)
	ld r24, y
	inc r24
	cpi r24, 4
	brne NotSecond
	
	com leds
	;out portc, leds
	clear TempCounter

/*	ldi r30, low(SecondCounter)
	ldi r31, high(SecondCounter)
	ld r24, z+
	ld r25, z
	adiw r25:r24, 1

	st z, r25
	st -z, r24
	out portc, r24*/
	rjmp EndIf

NotSecond:
	st y, r24
EndIf:
	pop	r24
	pop r25
	pop YL
	pop YH
	pop temp
	out SREG, temp
	reti

main:	
	clear TempCounter
	clear SecondCounter
	ldi temp, 0
	sts TCCR1A, temp
	ldi temp, 3
	sts TCCR1B, temp
	ldi temp, 1<<TOIE4
	sts TIMSK1, temp
	sei

loop:
	;inc leds
	;out portc, leds
	rjmp loop

EXT_INT0:
	ldi r30, low(SecondCounter)
	ldi r31, high(SecondCounter)
	ld r24, z+
	ld r25, z
	adiw r25:r24, 1
	st z, r25
	st -z, r24
	out portc, r25
	sei
	ret
	
lcd_command:
	STORE LCD_DATA_PORT, r16
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

lcd_wait:
	push r16
	clr r16
	STORE LCD_DATA_DDR, r16
	STORE LCD_DATA_PORT, r16
	lcd_set LCD_RW
lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	LOAD r16, LCD_DATA_PIN
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	STORE LCD_DATA_DDR, r16
	pop r16
	ret

	.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret