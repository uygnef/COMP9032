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
		breq crash
			
		compare_50:
			cpi temp1, 2
			brsh crash
			cpi temp1, 0
			breq update_done
			cpi temp2, low(500)
			brsh crash
	update_done:
		;ld2 pos_y, temp1, temp2
		lds temp2, speed
		;out portc, temp2
		reti

crash:
	cli
	do_lcd_command 0b00000001
	display_position pos_x
	display_position pos_y


	;ld2 pos_y, temp1, temp2
	;ser temp3
	;sts DDRG, temp3
	;out portg, temp1
	;out portc, temp2	
	/*do_lcd_command 0b00000001
	display_position pos_x
	display_position pos_y*/
	jmp crash_loop
	crash_loop:
		;first_line
		
		jmp crash_loop

/*convert_digits:
	;temp1, temp2
	push temp1
	push temp2

	check_hundreds:
		cpi temp1, 0 
		brne hundred_digit
		cpi temp2, 100
		brne hundred_digit

	hundred_digit:*/
		


	