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
	;lds temp1, direction
	lds temp1, speed
	cpi temp1, 0
	breq jmp_help
	
	lds temp1, direction
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
		lds temp3, speed
		ld2 pos_x, temp1, temp2
		;lds temp2, postion_x
		sub temp2, temp3
		sbci temp1, 0
		st2 temp1, temp2, pos_x
		jmp compare_end
	up_east:
		lds temp3, speed
		ld2 pos_x, temp1, temp2
		add temp2, temp3
		clr temp3
		adc temp1, temp3
		st2 temp1, temp2, pos_x
		jmp compare_end

	up_north:
		lds temp3, speed
		ld2 pos_y, temp1, temp2
		add temp2, temp3
		clr temp3
		adc temp1, temp3
		st2 temp1, temp2, pos_y
		jmp compare_end

	up_south:
		lds temp3, speed
		ld2 pos_y, temp1, temp2
		sub temp2, temp3
		sbci temp1, 0
		st2 temp1, temp2, pos_y
		jmp compare_end

	compare_end:
		cpi temp2, 0
		brne compare_50
		cpi temp1, 0
		brne compare_50
		rcall crash
	
		compare_50:
			cpi temp1, 1
			brlt update_done
			cpi temp2, 0b11110100
			brlt update_done
			rcall crash
	update_done:
		reti

crash:
	cli
	do_lcd_command 0b00000001
	do_lcd_data 'C'
	do_lcd_data 'R'
	do_lcd_data 'A'
	jmp crash
