;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;----copy form http://webapps.cse.unsw.edu.au/webcms2/course/index.php?cid=2446&color=teal ;
;writer by professor in COMP9032
;modify by Feng Yu
; The program gets input from keypad and displays its ascii value on LEDs
; Port F is used for keypad, high 4 bits for column selection, low four bits for reading rows
; Port C is used to display the ASCII value of a key.
; Date: Aug 10, 2015

get_value_from_key_pad:	
		ldi temp1, PORTFDIR			; columns are outputs, rows are inputs
		sts	DDRL, temp1
		ser temp1
		out ddrc, temp1
	keypad_main:
		ldi cmask, INITCOLMASK		; initial column mask
		clr	col						; initial column
	colloop:
		cpi col, 4
		breq keypad_main
		sts	PORTL, cmask				; set column to mask value (one column off)
		ldi temp1, 0xFF
		out portc, temp1
	key_pad_delay:
		dec temp1
		brne key_pad_delay
		out portc, temp1
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
	
	no_push:
		jmp get_value_from_key_pad
	
	convert_end:
		ret		

