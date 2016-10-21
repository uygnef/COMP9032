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

.equ PATTERN=0b11110000
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
.def one = r23
.def ten = r24
.def hundred = r25
.dseg	
speed: .byte 1				;speed 1 bytes, 1 - 10 m/s
distance: .byte 2			;		   _________________________________
direction: .byte 1			;direction |_0_|_0_|_?_|_?_|_0_|_0_|_?_|_?_|
conduct: .byte 1			;			4 hight bit: 0000xxxx->down 0001xxxx->keep 0010xxxx->up
pos_X: .byte 2				;						    4 low bit:: xxxx0000->West, xxxx0001->North,							;									  xxxx0010->East, xxxx0011->South 
pos_Y: .byte 2				;position x,y	2 bytes, 0 ~ 500 ==> 0 ~ 50.0 meter
pos_Z: .byte 2				;         z		2 bytes, 0 ~ 100 ==> 0 ~ 10.0 meter

dst_x: .byte 2				; destination of the helicopter
dst_y: .byte 2
dst_z: .byte 2

temp_dst: .byte 1

display_counter: .byte 1		;
duration: .byte 1
show_distance:	.byte 2
TempCounter: .byte 1 ;count for one second
speed_flag: .byte 1
take_off_flag: .byte 1 ; 0 means did not take off now, 1 means have taken off
hover_speed: .byte 1 ; store speed before hover(in order to recover privious status)
landing_flag: .byte 1 ; to distinguish crash or landing
key_button: .byte 1; make sure only press one button once
auto_poilt_flag: .byte 1 ;judge if it in autopoilt model
.cseg
.org 0
	jmp reset
.org int0addr
	jmp speed_up
.org int1addr
	jmp speed_down
.org OVF0addr 
	jmp Timer0OVF ; Jump to the interrupt handler for Timer0 overflow.
	jmp DEFAULT ; default service for all other interrupts.
DEFAULT: reti 

RESET:
	cli
	ser temp1		
	out DDRC, temp1
	
	ldi temp1, high(250)			;
	ldi temp2, low(250)				;			x = 0:250
	st2 temp1, temp2, pos_y			;			z = 0
	st2 temp1, temp2, pos_x			;			y = 0:250
	clr temp1
	clr temp2
	st2 temp1, temp2, pos_z			;			speed = 0
	st2 temp1, temp1, distance
	sts display_counter, temp1
	sts speed, temp1				;------------------------------------------------
	sts duration, temp1
	sts landing_flag, temp1
	sts key_button, temp1
	sts auto_poilt_flag, temp1

	sts hover_speed, temp1
	sts take_off_flag, temp1
	ldi temp1, high(400)			; destination
	ldi temp2, low(400)
	st2 temp1, temp2, dst_x
	st2 temp1, temp2, dst_y
	clr temp1
	ldi temp2, 80
	st2 temp1, temp2, dst_z			

	ldi temp1, 1
	sts speed_flag, temp1
	ldi temp1, 0b00010000
	sts direction, temp1			;initialized direction, position x y z and speed.
	
	;-------------init interrput 0 and 1 (for adjust speed)--------
	ldi temp1, (2<<ISC10)|(2<<ISC00); set INT0 as falling edge triggered interrupt
	sts EICRA, temp1
	ldi temp1, (1<<INT0)|(1<<INT1)
	out EIMSK, temp1
	;---------start lcd----------;
	lcd_start
	choose_modle
	rcall start_moodle
	sei
	rjmp main

Timer0OVF: ; interrupt subroutine to Timer0
;---------intrrput every 0.1 second--------------------
	cli
	rcall run_follow_keypad_conduct
	lds r24, TempCounter
	inc r24
	cpi r24, 100 ; Check if 100 times
	push r24
	brne NotSecond
	; update all data
	ldi temp1, 1
	sts speed_flag, temp1
	lds temp1, duration
	inc temp1
	sts duration, temp1
	ld2 pos_x, temp1, temp2
	out portc, temp2
	rcall go_dst_start
	pop r24
	rcall update_position
	clr temp1
	sts TempCounter, temp1	
	rjmp EndIF
NotSecond:
	pop r24
	sts TempCounter,r24
EndIF:
	sei
	reti

main:
	clr temp1
	sts TempCounter, temp1 ; Initialize the temporary counter to 0
	ldi temp1, 0b00000000
	out TCCR0A, temp1
	ldi temp1, 0b00000011
	out TCCR0B, temp1 ; Prescaling value=64
	ldi temp1, 1<<TOIE0 ; =1024 microseconds
	sts TIMSK0, temp1 ; T/C0 interrupt enable
	sei ; Enable global interrupt
loop: 
	/*ser temp1
	out portc,temp1*/
	rjmp loop



.include "caculate.asm"
.include "controll.asm"
.include "lcd.asm"
.include "keypad.asm"
