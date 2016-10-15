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
.def temp3  =r22

.equ PORTFDIR =0xF0			; use PortD for input/output from keypad: PF7-4, output, PF3-0, input
.equ INITCOLMASK = 0xEF		; scan from the leftmost column, the value to mask output
.equ INITROWMASK = 0x01		; scan from the bottom row
.equ ROWMASK  =0x0F			; low four bits are output from the keypad. This value mask the high 4 bits.

;---------poistion register-----;
.dseg						;		   __________________________
direction: .byte 1			;direction |_0_|__|__|__|__|__|__|__|
conduct: .byte 1			;			  3 hight bit: 000->down 001->stable 002->up
pos_X: .byte 2				;						4 direction bit: 0->West, 1->North, 2->East, 3->South 
pos_Y: .byte 2				;position x,y	2 bytes, 0 - 500 ==> 0 - 50.0 meter
pos_Z: .byte 1				;         z		1 bytes, 0 - 100 ==> 0 - 10.0 meter
speed: .byte 1				;speed 1 bytes, 1 - 10 m/s

one_second_counter: .byte 1 ;count for one second
.cseg
.org 0
	jmp start

.org int0addr
	jmp speed_up
.org int1addr
	jmp speed_down
.org OVF0addr 
	jmp tenth_of_a_second
start:
	ser temp1		
	out DDRC, temp1
	ldi temp1, 2
	sts direction, temp1			;initialized direction, position x y z and speed.
	ldi temp1, 250					;
	clr temp2						;			x = 250
	st2 temp2, temp1, pos_x			;			y = 250
	st2 temp2, temp1, pos_y			;			z = 0
	clr temp1						;			speed = 0
	sts pos_z, temp1				;
	;ldi temp1, 1
	sts speed, temp1				;------------------------------------------------
	;-------------init interrput 0 and 1 (for adjust speed)--------
	ldi temp1, (1<<ISC10)|(1<<ISC00); set INT0 as falling edge triggered interrupt
	sts EICRA, temp1
	ldi temp1, (1<<INT0)|(1<<INT1)
	out EIMSK, temp1
	;-------------init OVF0addr(0.1 second)------;
	ldi temp1, 0b00000000
	out TCCR0A, temp1
	ldi temp1, 0b00000011
	out TCCR0B, temp1
	ldi temp1, 1<<TOIE0 ; =1024 microseconds
	sts TIMSK0, temp1 ; T/C0 interrupt enable
	clr temp1
	sts one_second_counter, temp1
	sei
	;---------start lcd----------;
	lcd_start
	rcall trans_position_to_direction
main:
	sei
	clr temp1
	out portc, temp1
	jmp main

tenth_of_a_second:	
	sei
	lds temp1, one_second_counter
	cpi temp1, 100
	brne not_tenth_of_a_second
	clr temp1
	sts one_second_counter, temp1
	ser temp1
	out portc, temp1
	sei
	reti

not_tenth_of_a_second:
	rcall run_follow_keypad_conduct
	rcall update_position
	lds temp1, one_second_counter
	inc temp1
	sts one_second_counter, temp1
	reti

.include "caculate.asm"
.include "controll.asm"
.include "lcd.asm"
.include "keypad.asm"