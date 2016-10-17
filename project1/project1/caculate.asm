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
	cpi temp1, 0
	breq jmp_help
	
	lds temp1, direction
	andi temp1, 0b11110000	;judge if go up or go down
	cpi temp1, 0
	breq jmp_help
	cpi temp1, 2
	breq jmp_help;TODO go up and down
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

	compare_end:
		cpi temp2, 0
		brne compare_50
		cpi temp1, 0
		breq crash
			
		compare_50:
			cpi temp1, 2
			brsh crash
			cpi temp1, 0
			breq update_done
			cpi temp2, low(500)
			brsh crash
	update_done:
		reti

crash:
	cli
	do_lcd_command 0b00000001
	display_position pos_x
	do_lcd_data ' '
	display_position pos_y
	do_lcd_data ' '
	lds temp1, speed
	subi temp1, -'0'
	do_lcd_data_reg temp1
	jmp crash_loop
	crash_loop:
		jmp crash_loop