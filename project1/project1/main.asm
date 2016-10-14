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

;---------poistion register-----;
.dseg position:
	.byte 1

.def temp1 = r17
.def temp2 = r18

.cseg
.org 0
	jmp start

start:
ser temp1
out DDRC, temp1
ldi temp1, 2
sts position, temp1
lcd_start
first_line
;out portc, position
rcall turn_left
rcall turn_left
rcall turn_left
rcall turn_left
rcall turn_right
rcall go_up
rcall go_up
rcall go_up
rcall go_up
rcall go_down


lds temp1, position
out portc, temp1


loop:
	jmp loop

.include "controll.asm"
.include "lcd.asm"
