turn_left:
	lds temp1, direction
	lds temp2, direction
	andi temp2, 0b00001111 ;postion mask, indicate the last four bit(direction)
	cpi temp2, 0
	breq add_3
		dec temp1
		jmp left_done
	add_3:
		subi temp1, -3
	left_done:
		sts direction, temp1
		ret

turn_right:
	lds temp1, direction
	lds temp2, direction
	andi temp2, 0b00001111 ;postion mask, indicate the last four bit(direction)
	cpi temp2, 3
	breq sub_3
		inc temp1
		jmp right_done
	sub_3:
		subi temp1, 3
	right_done:
		sts direction, temp1
		ret

go_up:
	lds temp1, direction
	lds temp2, direction
	andi temp2, 0b11110000
	cpi temp2, 0b00100000
	breq up_done
	subi temp1, -0b00010000
	up_done:
		sts direction, temp1
		reti

go_down:
	lds temp1, direction
	lds temp2, direction
	andi temp2, 0b11110000
	cpi temp2, 0b00000000
	breq down_done
	subi temp1, 0b00010000
	down_done:
		sts direction, temp1
		reti

speed_up:
	cli
	lds temp1, speed_flag		;use flag to ensure only speed will change 1m/s each time
	cpi temp1, 0
	breq speed_nothing
	lds temp1, speed
	cpi temp1, 4
	breq speed_nothing
	inc temp1
	sts speed, temp1
	clr temp1
	sts speed_flag, temp1
	sei
	reti

speed_down:
	cli
	lds temp1, speed_flag
	cpi temp1, 0
	breq speed_nothing
	lds temp1, speed
	cpi temp1, 0
	breq speed_nothing
	dec temp1
	sts speed, temp1
	clr temp1
	sts speed_flag, temp1
	sei
	reti

speed_nothing:
	sei
	reti

auto_poilt:
	cli
	do_lcd_command 0b00000001
	do_lcd_data 'D'
	do_lcd_data 'I'
	do_lcd_data 'S'
	do_lcd_data 'R'
	do_lcd_data 'T'
	do_lcd_data 'I'
	do_lcd_data 'N'
	do_lcd_data 'A'
	do_lcd_data 'T'
	do_lcd_data 'I'
	do_lcd_data 'O'
	do_lcd_data 'N'
	do_lcd_data ':'
	do_lcd_command 0b11000000
	ldi r28, low(dst_x)	;passing address of dst_x
	ldi r29, high(dst_x)
	rcall get_dst_num
	;rcall get_dst_ten_y
	;rcall get_dst_ten_z
	;get_dst_ten pos_y
	;get_dst_ten pos_z ;TODO restrict height, let it less than 10m
	;rcall goto temp1
	;sei
	jmp auto_loop

auto_loop:
	jmp auto_loop
	
	
get_dst_num:
	push r28		;store dst_x low bit address
	push r29		;high bits

	rcall get_value_from_keypad
	cpi temp1, '0'-1
	brlo get_dst_num
	cpi temp1, '5'
	brsh get_dst_num
	do_lcd_data_reg temp1

	subi temp1, '0'
	ldi temp2, 10
	mul temp1, temp2
	mov temp1, r0
	push temp1
	get_dst_loop:
		rcall get_value_from_keypad
		cpi temp1, '$'
		brne get_dst_loop
	get_dst_one:
		rcall get_value_from_keypad
		cpi temp1, '0'-1
		brlo get_dst_one
		cpi temp1, '9'+1
		brsh get_dst_one
		do_lcd_data_reg temp1
		pop temp3
		subi temp1, '0'
		add temp3, temp1
		ldi temp1, 10
		mul temp1, temp3
		pop r29		;get address for dst_..
		pop r28
		st Y, r1
		std Y+1, r0
		ld2 dst_x, temp1, temp2
		out portc, temp2
		do_lcd_data ' '
		reti
/*	goto_x pos_x
	goto_y pos_y
	goto_z pos_z*/




