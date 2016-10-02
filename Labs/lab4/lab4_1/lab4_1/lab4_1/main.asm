; The program gets input from keypad and displays its ascii value on the
; LED bar
.include "m2560def.inc"

.def row = r22 ; current row number
.def col = r17 ; current column number
.def rmask = r18 ; mask for current row during scan
.def cmask = r19 ; mask for current column during scan
.def temp1 = r20
.def temp2 = r21
.def times = r23
.def result = r25
.equ PORTFDIR = 0xF0 ; PF7-4: output, PF3-0, input
.equ INITCOLMASK = 0xEF ; scan from the leftmost column,
.equ INITROWMASK = 0x01 ; scan from the top row
.equ ROWMASK =0x0F ; for obtaining input from Port F
clr times

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
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.org 0
	jmp RESET


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

RESET:
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	clr times

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

	ldi temp1, PORTFDIR ; PF7:4/PF3:0, out/in
	sts DDRL, temp1
	ser temp1 ; PORTC is output
	out DDRC, temp1
inital_result:
	ldi result, 'F'
main:
	ldi cmask, INITCOLMASK ; initial column mask
	clr col ; initial column
colloop:
	cpi col, 4
	breq inital_result ; if all keys are scanned, repeat.
	sts PORTL, cmask ; otherwise, scan a column
	ldi temp1, 0xFF ; slow down the scan operation.
delay:
	dec temp1
	brne delay
	lds temp1, PINL ; read PORTF
	andi temp1, ROWMASK ; get the keypad output value
	cpi temp1, 0xF ; check if any row is low
	breq nextcol
	; if yes, find which row is low
	ldi rmask, INITROWMASK ; initialize for row check
	clr row ;
	jmp rowloop

rowloop:
	cpi row, 4
	breq nextcol ; the row scan is over.
	mov temp2, temp1
	and temp2, rmask ; check un-masked bit
	breq convert ; if bit is clear, the key is pressed
	inc row ; else move to the next row
	lsl rmask
	jmp rowloop
nextcol: ; if row scan is over
	lsl cmask
	inc col ; increase column value
	jmp colloop ; go to the next column
convert:
	cpi col, 3 ; If the pressed key is in col. 3
	breq letters ; we have a letter
	; If the key is not in col. 3 and
	cpi row, 3 ; if the key is in row3,
	breq symbols ; we have a symbol or 0
	mov temp1, row ; Otherwise we have a number in 1-9
	lsl temp1
	add temp1, row ;
	add temp1, col ; temp1 = row*3 + col
	subi temp1, -'1' ; Add the value of character ¡®1¡¯
	jmp convert_end
letters:
	ldi temp1, 'A'
	add temp1, row ; Get the ASCII value for the key
	jmp convert_end
symbols:
	cpi col, 0 ; Check if we have a star
	ldi temp1,'*'
	breq convert_end
	cpi col, 1 ; or if we have zero
	ldi temp1,'0'
	breq convert_end ; if not we have hash
	ldi temp1,'#'
	jmp convert_end

convert_end:
	
	cp result, temp1	;if the input does not change, do nothing and return to first step
	breq main
	mov result, temp1 ;use result as a flag, judge if input changed
	do_lcd_data temp1
	cpi times, 16
	breq new_line
	cpi times, 32
	breq clear_restart
	inc times
	out PORTC, times
	jmp main

new_line:
	inc times
	do_lcd_command 0b11000000
	do_lcd_data temp1
	jmp main

clear_restart:
	jmp reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display "hello" on LCD
;PortF for LCD data register
;Port A for LCD conctrol
; Written by Denial Daniel Murphy



