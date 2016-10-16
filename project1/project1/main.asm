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
.dseg						;		   __________________________
direction: .byte 1			;direction |_0_|__|__|__|__|__|__|__|
conduct: .byte 1			;			  3 hight bit: 000->down 001->stable 002->up
pos_X: .byte 2				;						4 direction bit: 0->West, 1->North, 2->East, 3->South 
pos_Y: .byte 2				;position x,y	2 bytes, 0 - 500 ==> 0 - 50.0 meter
pos_Z: .byte 1				;         z		1 bytes, 0 - 100 ==> 0 - 10.0 meter
speed: .byte 1				;speed 1 bytes, 1 - 10 m/s

TempCounter: .byte 1 ;count for one second
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
DEFAULT: reti ; no servic

RESET:
	ser temp1		
	out DDRC, temp1
	ldi temp1, 2
	sts direction, temp1			;initialized direction, position x y z and speed.
	clr temp1						;
	ldi temp2, 250					;			x = 0:250
	st2 temp1, temp2, pos_x			;			y = 0:250
	st2 temp1, temp2, pos_y			;			z = 0
	sts pos_z, temp1				;			speed = 0
	sts speed, temp1				;------------------------------------------------
	;-------------init interrput 0 and 1 (for adjust speed)--------
	ldi temp1, (1<<ISC10)|(1<<ISC00); set INT0 as falling edge triggered interrupt
	sts EICRA, temp1
	ldi temp1, (1<<INT0)|(1<<INT1)
	out EIMSK, temp1
	;---------start lcd----------;
	lcd_start
	rcall run_follow_keypad_conduct
	rjmp main

Timer0OVF: ; interrupt subroutine to Timer0
	rcall run_follow_keypad_conduct
	rcall update_position
	;rcall trans_position_to_direction

;---------intrrput every 0.1 second--------------------
	lds r24, TempCounter
	inc r24
	cpi r24, 100 ; Check if (r25:r24)=1000
	brne NotSecond
	Clear TempCounter ; Reset the temporary counter.
	rjmp EndIF
NotSecond:
	sts TempCounter,r24
EndIF:
	reti

main:
	Clear TempCounter ; Initialize the temporary counter to 0
	;Clear SecondCounter ; Initialize the second counter to 0
	ldi temp1, 0b00000000
	out TCCR0A, temp1
	ldi temp1, 0b00000011
	out TCCR0B, temp1 ; Prescaling value=64
	ldi temp1, 1<<TOIE0 ; =1024 microseconds
	sts TIMSK0, temp1 ; T/C0 interrupt enable
	sei ; Enable global interrupt

loop:
	rjmp loop


.include "caculate.asm"
.include "controll.asm"
.include "lcd.asm"
.include "keypad.asm"
