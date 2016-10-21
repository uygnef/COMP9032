;----------update_position-------;
/*if speed == 0:
	return
if direction == 'N':
	postion_y ++
elif direction == 'S':
	.
	.
	.
if x,y>50 | z,x,y<0 | z>10:
	return crash*/

jmp_help:
	jmp update_done
update_position:
	lds temp1, speed
	breq jmp_help	
	lds temp3, speed
	ld2 distance, temp1, temp2 ; update distance
	add temp2, temp3
	clr temp3
	adc temp1, temp3
	st2 temp1, temp2, distance
	lds temp1, direction
	andi temp1, 0b11110000	;judge if go up or go down
	cpi temp1, 0
	breq update_down
	cpi temp1, 0b00100000
	breq update_up
	cpi temp1, 0
	;------------
	jmp N_S_W_E
	
	update_up:
		ld2 pos_Z, temp1, temp2
		lds temp3, speed
		add temp2, temp3
		st2 temp1, temp2, pos_z
		jmp up_down_done
	update_down:
		ld2 pos_Z, temp1, temp2
		lds temp3, speed
		sub temp2, temp3
		st2 temp1, temp2, pos_z
		jmp up_down_done
	up_down_done:
		cpi temp2, 100
		brsh crash_helper
		cpi temp2, 0
		brlo crash_helper
		jmp vaild_number
	crash_helper:
		jmp crash

	N_S_W_E:
		lds temp1, direction	;judge turn n e w s
		andi temp1, 0b00001111
		cpi temp1, 0
		breq up_west
		cpi temp1, 1
		breq up_north
		cpi temp1, 2
		breq up_east
		cpi temp1, 3
		breq up_south
	up_west:
		ld2 pos_x, temp1, temp2
		lds temp3, speed
		sub temp2, temp3
		sbci temp1, 0
		st2 temp1, temp2, pos_x
		jmp compare_end
	up_east:
		ld2 pos_x, temp1, temp2
		lds temp3, speed
		add temp2, temp3
		clr temp3
		adc temp1, temp3
		st2 temp1, temp2, pos_x
		jmp compare_end

	up_north:
		ld2 pos_y, temp1, temp2
		lds temp3, speed
		add temp2, temp3
		clr temp3
		adc temp1, temp3
		st2 temp1, temp2, pos_y
		jmp compare_end

	up_south:
		ld2 pos_y, temp1, temp2
		lds temp3, speed
		sub temp2, temp3
		sbci temp1, 0
		st2 temp1, temp2, pos_y
		jmp compare_end

	compare_end:;compare if less than 0m
		cpi temp2, 0
		brne compare_50
		cpi temp1, 0
		breq crash
			
		compare_50:;compare if greater than 50m(500)
			cpi temp1, 2
			brsh crash
			
			cpi temp1, 0
			breq vaild_number	
			cpi temp2, low(500)
			brsh crash
	vaild_number:
		
		lds temp1, display_counter
		cpi temp1, 5		; display every 0.5 second
		breq display_pos
		inc temp1
		sts display_counter, temp1
		jmp update_done
	display_pos:
		clr temp1
		sts display_counter, temp1
		rcall trans_position_to_direction
		ret
	update_done:
		ret

crash:
	cli
	lds temp1, landing_flag
	cpi temp1, 1
	breq landing_success
	ldi temp1, 0b11110000
	clr temp2
	rjmp crash_loop

landing_success:
	cli
	do_lcd_command 0b00000001
	do_lcd_data 'D'
	do_lcd_data 'I'
	do_lcd_data 'S'
	do_lcd_data 'T'
	do_lcd_data 'A'
	do_lcd_data 'N'
	do_lcd_data 'C'
	do_lcd_data 'E'
	do_lcd_data ':'
	display_position distance
	do_lcd_command 0b11000000
	do_lcd_data 'D'
	do_lcd_data 'U'
	do_lcd_data 'R'
	do_lcd_data 'A'
	do_lcd_data 'T'
	do_lcd_data 'I'
	do_lcd_data 'O'
	do_lcd_data 'N'
	do_lcd_data ':'
	display_position duration
	jmp landing_loop
	landing_loop:
		jmp landing_loop

	crash_loop:
		inc temp2
		rcall sleep_5ms
		cpi temp2, 0xFF
		brne crash_loop
		out portc, temp1
		clr temp2
		com temp1
		jmp crash_loop