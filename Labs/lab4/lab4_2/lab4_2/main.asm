
.include "m2560def.inc"
.equ loop_count= 20000        ;initial the loop data
.def iH = r25                ;to let time delay is
.def iL = r24                ;exactly 1 second

.def temp=r21
.equ LCD_CTRL_PORT = PORTA
.equ LCD_CTRL_DDR = DDRA
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4
.def hundred = r23
.def ten = r18
.def unit = r17

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
.macro do_lcd_data_new
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

        jmp init
.org    INT0addr
        jmp EXT_INT0

.cseg

init:
		clr hundred
		clr ten
		clr unit

RESET:    ldi temp, (1 << ISC00) ; set INT0 as falling edge triggered interrupt
		ori temp, (1 << ISC01)
        sts EICRA, temp
        in temp, EIMSK; enable INT0
        ori temp, (1<<INT0)
        out EIMSK, temp
        sei; enable Global Interrupt
		ser r20
		out DDRC, r20
		clr r20
		ldi r16, (1<<WDCE)|(1<<WDE)
		sts WDTCSR, r16
		ldi r16, (1<<WDP2)|(1<<WDP1)
		sts WDTCSR, r16
		ldi r16, (1<<WDE)
		sts WDTCSR, r16
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
		do_lcd_data 'S'
		do_lcd_data 'p'
		do_lcd_data 'e'
		do_lcd_data 'e'
		do_lcd_data 'd'
		do_lcd_data ':'
		subi r23, -'0'
		subi r17, -'0'
		subi r18, -'0'
		do_lcd_data_new hundred	
		do_lcd_data_new ten
		do_lcd_data_new unit
		do_lcd_data '/'
		do_lcd_data 's'
		wdr
		
		clr r21
		clr r19
        jmp start

EXT_INT0:
		inc r19
		cpi r19, 4
		brne EXT_INT0
		clr r19
		inc r17
		cpi r17, 10
		breq ten1
		out PORTC, r17
		cli
		nop
		sei
		nop
		reti
ten1:
		clr r17
		inc r18
		cpi r18, 10
		breq hundred1
		reti

hundred1:
		clr r18
		inc r23
		reti              
start:                    ;load data and let LED lighten
        nop
        rjmp start

		.macro lcd_set
	sbi LCD_CTRL_PORT, @0
.endmacro
.macro lcd_clr
	cbi LCD_CTRL_PORT, @0
.endmacro

;
; Send a command to the LCD (r16)
;

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
