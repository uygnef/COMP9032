.include "macros.asm"

;------------init lcd commond----------;
.equ LCD_CTRL_PORT = PORTA
.equ LCD_CTRL_DDR = DDRA
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.equ LCD_DATA_PORT = PORTF
.equ LCD_DATA_DDR = DDRF
.equ LCD_DATA_PIN = PINF
;------------init keypad comoind-------;
.def row    =r16		; current row number
.def col    =r17		; current column number
.def rmask  =r18		; mask for current row
.def cmask	=r19		; mask for current column
.def temp1	=r20		
.def temp2  =r21

.equ PORTFDIR =0xF0			; use PortD for input/output from keypad: PF7-4, output, PF3-0, input
.equ INITCOLMASK = 0xEF		; scan from the leftmost column, the value to mask output
.equ INITROWMASK = 0x01		; scan from the bottom row
.equ ROWMASK  =0x0F			; low four bits are output from the keypad. This value mask the high 4 bits.

;---------poistion register-----;
.dseg position:
	.byte 1
.dseg conduct:
	.byte 1

.cseg
.org 0
	jmp start

start:
ser temp1
out DDRC, temp1
ldi temp1, 2
sts position, temp1
;out portc, temp1
lcd_start
first_line
;out portc, position
loop:
rcall run_follow_keypad_conduct
lds temp1, position
out portc, temp1
jmp loop






.include "controll.asm"
.include "lcd.asm"
.include "keypad.asm"
