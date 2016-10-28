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
		reti

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
		reti

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
	do_lcd_command 0b00000001
	do_lcd_data 'D'
	do_lcd_data 'I'
	do_lcd_data 'S'
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
	rcall have_got_key
	cpi temp1, 'A'
	breq default_auto
	ldi r30, low(dst_x)	;passing address of dst_x
	ldi r31, high(dst_x)
	rcall get_dst_num
	ldi r30, low(dst_y)
	ldi r31, high(dst_y)
	rcall get_dst_num
	ldi r30, low(dst_z)
	ldi r31, high(dst_z)
	rcall get_dst_num
	rcall get_dst_speed
	ldi temp1, 1
	sts auto_poilt_flag, temp1
	ret
default_auto:		;if press A twice, the dst will be default value
	ldi temp1, 1
	sts speed, temp1
	ldi temp1, 1
	sts auto_poilt_flag, temp1
	ret

get_dst_speed:
	rcall have_got_key
	cpi temp1, '0'-1
	brlo get_dst_speed
	cpi temp1, '5'
	brsh get_dst_speed
	do_lcd_data_reg temp1
	subi temp1, '0'
	sts speed, temp1
	ret

get_dst_num:
	push r30		;store dst_x low bit address
	push r31		;high bits
	rcall have_got_key
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
	get_dst_one:
		rcall have_got_key
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
		st Z, r1
		std Z+1, r0
		do_lcd_data ' '
		ret
go_dst_start:
	lds temp3, auto_poilt_flag
	cpi temp3, 1
	breq go_dst_start1
	jmp return
	go_dst_start1:
		ld2 pos_x, r16, r17 
		ld2 dst_x, temp1, temp2 
		cp r17, temp2
		cpc r16, temp1
		breq go_dst_mid
		brlo auto_west
		jmp auto_east
go_dst_mid:
	ld2 pos_y, r16, r17 
	ld2 dst_y, temp1, temp2
	cp r17, temp2
	cpc r16, temp1
	breq go_dst_end
	brlo auto_south
	jmp auto_north
go_dst_end:
	ld2 pos_z, r16, r17 
	ld2 dst_z, temp1, temp2
	cpc r17, temp2
	breq landing_success_helper
	brlo auto_up
	jmp auto_down

landing_success_helper:
	jmp landing_success
auto_west:
	ldi temp1, 0b00010010
	sts direction, temp1
	ret
auto_east:
	ldi temp1, 0b00010000
	sts direction, temp1
	ret
auto_south:
	ldi temp1, 0b00010001
	sts direction, temp1
	ret
auto_north:
	ldi temp1, 0b00010011
	sts direction, temp1
	ret
auto_up:
	ldi temp1, 0b00100011
	sts direction, temp1
	ret
auto_down:
	ldi temp1, 0b00000011
	sts direction, temp1
	ret
return:
	ret

auto_poilt_jump:
	jmp auto_poilt
start_moodle:
	rcall have_got_key
	cpi temp1, 'A'
	breq auto_poilt_jump
	ret

