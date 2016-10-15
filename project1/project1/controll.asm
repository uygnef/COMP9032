turn_left:
	lds temp1, direction
	;out portc, temp
	lds temp2, direction
	andi temp2, 0b00001111 ;postion mask, indicate the last four bit(direction)
	;out portc, temp
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
	;out portc, temp
	lds temp2, direction
	andi temp2, 0b00001111 ;postion mask, indicate the last four bit(direction)
	;out portc, temp
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
	