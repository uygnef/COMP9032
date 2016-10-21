;-----------macros----------;
;store all macros
.macro st2				;-----store 2 bytes in data memory-------;
	ldi r31, high(@2)
	ldi r30, low(@2)
	st z+, @0			; st2 register1 ==> data memory1
	st z, @1			;	  register2 ==> data memory2
.endmacro

.macro ld2				;-----load 2 bytes from data memory to 2 register
	ldi r31, high(@0)
	ldi r30, low(@0)	;	data memory => register1, register2
	ld @1, z+
	ld @2, z
.endmacro

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

.macro do_lcd_data_reg
	mov r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro lcd_set
	sbi LCD_CTRL_PORT, @0
.endmacro
.macro lcd_clr
	cbi LCD_CTRL_PORT, @0
.endmacro

.macro lcd_start
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
.endmacro	

.macro first_line
	do_lcd_command 0b00000001
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data 'P'
	do_lcd_data 'O'
	do_lcd_data 'S'
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data 'D'
	do_lcd_data 'I'
	do_lcd_data 'R'
	do_lcd_data ' '
	do_lcd_data 'S'
	do_lcd_data 'P'
	do_lcd_data 'D'
	do_lcd_command 0b11000000
.endmacro

.macro	display_position		;use to display position on LCD
	ld2 @0, temp1, temp2
	clr ten
	clr one
	clr hundred
	
	start_convert:
		cpi temp1, 0
		brne convert_100
		cpi temp2, 100
		brsh convert_100
		cpi temp2, 10
		brsh convert_10
		cpi temp2, 0 
		brne convert_1
		jmp convert_end

	convert_100:
		subi temp2, 100 
		sbci temp1, 0
		inc hundred
		jmp start_convert
	convert_10:
		subi temp2, 10
		inc ten
		jmp start_convert
	convert_1:
		dec temp2
		inc one
		jmp start_convert
	
	convert_end:
		subi hundred, -'0'
		subi ten, -'0'
		subi one, -'0'
		do_lcd_data_reg hundred
		do_lcd_data_reg ten
.endmacro


/*.macro	display_time		;use to display position on LCD
	clr ten
	clr one
	clr hundred
	
	start_convert:
		cpi @0, 100
		brsh convert_100
		cpi @0, 10
		brsh convert_10
		cpi @0, 0 
		brne convert_1
		jmp convert_end

	convert_100:
		subi @0, 100 
		inc hundred
		jmp start_convert
	convert_10:
		subi @0, 10
		inc ten
		jmp start_convert
	convert_1:
		dec @0
		inc one
		jmp start_convert
	
	convert_end:
		subi hundred, -'0'
		subi ten, -'0'
		subi one, -'0'
		do_lcd_data_reg hundred
		do_lcd_data_reg ten
.endmacro	*/

.macro choose_modle
	do_lcd_data 'S'
	do_lcd_data 'T'
	do_lcd_data 'A'
	do_lcd_data 'R'
	do_lcd_data 'T'
	do_lcd_data ':'
	do_lcd_data '('
	do_lcd_data 'M'
	do_lcd_data ')'
.endmacro

