;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;----copy form http://webapps.cse.unsw.edu.au/webcms2/course/index.php?cid=2446&color=teal ;
;writer by professor in COMP9032
;modify by Feng Yu
; The program gets input from keypad and displays its ascii value on LEDs
; Port F is used for keypad, high 4 bits for column selection, low four bits for reading rows
; Port C is used to display the ASCII value of a key.
; Date: Aug 10, 2015

get_key:	
		ldi temp1, PORTFDIR			; columns are outputs, rows are inputs
		sts	DDRL, temp1
	
	keypad_main:
		ldi cmask, INITCOLMASK		; initial column mask
		clr	col						; initial column
	colloop:
		cpi col, 4
		breq none_press
		sts	PORTL, cmask				; set column to mask value (one column off)
		ldi temp1, 0xFF
	key_pad_delay:
		dec temp1
		brne key_pad_delay
		lds	temp1, PINL				; read PORTL
		andi temp1, ROWMASK
		cpi temp1, 0xF				; check if any rows are on
		breq nextcol
									; if yes, find which row is on
		ldi rmask, INITROWMASK		; initialise row check
		clr	row						; initial row

	rowloop:
		cpi row, 4
		breq nextcol
		mov temp2, temp1
		and temp2, rmask				; check masked bit
		breq convert 				; if bit is clear, convert the bitcode
		inc row						; else move to the next row
		lsl rmask					; shift the mask to the next bit
		jmp rowloop

	nextcol:
		lsl cmask					; else get new mask by shifting and 
		inc cmask
		inc col						; increment column value
		jmp colloop					; and check the next column

	convert:
		cpi col, 3					; if column is 3 we have a letter
		breq letters				
		cpi row, 3					; if row is 3 we have a symbol or 0
		breq symbols

		mov temp1, row				; otherwise we have a number in 1-9
		lsl temp1
		add temp1, row				; temp1 = row * 3
		add temp1, col				; add the column address to get the value
		subi temp1, -'1'			; add the value of character '0'
		jmp convert_end

	letters:
		ldi temp1, 'A'
		add temp1, row				; increment the character 'A' by the row value
		jmp convert_end

	symbols:
		cpi col, 0					; check if we have a star
		breq star
		cpi col, 1					; or if we have zero
		breq zero					
		ldi temp1, '#'				; if not we have hash
		jmp convert_end
	star:
		ldi temp1, '*'				; set to star
		jmp convert_end
	zero:
		ldi temp1, '0'				; set to zero
		jmp convert_end
	
	none_press:
		ldi temp1, '$'
		ret	
	convert_end:
		ret

have_got_key:	;make sure have press button
	rcall get_key
	cpi temp1, '$'
	brne store_key
	jmp have_got_key
	store_key:
		sts key_button, temp1
		rcall get_key
		cpi temp1, '$'
		brne store_key
		lds temp1, key_button
		ret

do_nothing_helper:
	jmp do_nothing

auto_poilt_helper:
	rcall auto_poilt

go_dst_start_helper:
	rcall go_dst_start

run_follow_keypad_conduct:	
	rcall get_key
	lds temp2, conduct
	cp temp1, temp2
	breq do_nothing_helper
	sts conduct, temp1
	cpi temp1, '$'
	breq do_nothing_helper
	ldi temp2, 0			; disable landing modle
	sts landing_flag, temp2
	cpi temp1, '*'
	breq hover_control
	cpi temp1, '#'
	breq take_off_judge
	cpi temp1, '2'
	breq up
	cpi temp1, '8'
	breq down
	cpi temp1, '4'
	breq left
	cpi temp1, '6'
	breq right
	jmp do_nothing
	hover_control:
		lds temp3, hover_speed
		cpi temp3, 0
		breq start_hover
		sts speed, temp3
		clr temp2
		sts hover_speed, temp2
		rcall trans_position_to_direction
		reti

		start_hover:
			lds temp3, speed
			sts hover_speed, temp3
			clr temp3
			sts speed, temp3
			rcall trans_position_to_direction
			reti  

	take_off_judge:
		ldi temp3, 1
		sts speed, temp3
		lds temp2, take_off_flag
		cpi temp2, 0
		breq up1
		ldi temp2, 0
		sts take_off_flag, temp2 
		rcall go_down
		rcall go_down
		ldi temp2, 1
		sts landing_flag, temp2		; enale landing modle
		rcall trans_position_to_direction
		reti
	
	up1:
		ldi temp2, 1
		sts take_off_flag, temp2
		rcall go_up
		rcall trans_position_to_direction
		reti

	up:
		rcall go_up
		rcall trans_position_to_direction
		reti
	down:
		rcall go_down
		rcall trans_position_to_direction
		reti
	left:
		rcall turn_left
		rcall trans_position_to_direction
		reti
	right:
		rcall turn_right
		rcall trans_position_to_direction	
		reti
	do_nothing:
		reti


trans_position_to_direction:
	first_line
	display_position pos_x
	do_lcd_data ' '
	display_position pos_y
	do_lcd_data ' '
	display_position pos_z
	do_lcd_data ' '
	do_lcd_data ' '

	lds temp1, direction
	andi temp1, 0b11110000
	cpi temp1, 0
	breq display_down
	cpi temp1, 0b00100000
	breq display_up
	lds temp1, direction
	andi temp1, 0b00001111
	cpi temp1, 0
	breq west
	cpi temp1, 1
	breq north
	cpi temp1, 2
	breq east
	cpi temp1, 3
	breq south
	out portc, temp1
	jmp trans_end
	east:
		do_lcd_data 'E'
		do_lcd_data ' '
		jmp trans_end
	west:
		do_lcd_data 'W'
		do_lcd_data ' '
		jmp trans_end
	north:
		do_lcd_data 'N'
		do_lcd_data ' '
		jmp trans_end
	south:
		do_lcd_data 'S'
		do_lcd_data ' '
		jmp trans_end
	display_up:
		do_lcd_data 'U'
		do_lcd_data ' '
		jmp trans_end
	display_down:
		do_lcd_data 'D'
		do_lcd_data ' '
		jmp trans_end
	trans_nothing:
		reti
	trans_end:
		do_lcd_data ' '
		do_lcd_data ' '
		lds temp1, speed
		subi temp1, -'0'
		do_lcd_data_reg temp1
		reti



	
		


		