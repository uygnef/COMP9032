; The program gets input from keypad and displays its ascii value on the
; LED bar
.include "m2560def.inc"
.equ loop_count= 20000
.def row = r16 ; current row number
.def col = r17 ; current column number
.def rmask = r18 ; mask for current row during scan
.def cmask = r19 ; mask for current column during scan
.def temp1 = r20
.def temp2 = r21
.def first_num = r22
.def second_num = r24
.def result = r25
.def ten = r26
.equ PORTFDIR = 0xF0 ; PF7-4: output, PF3-0, input
.equ INITCOLMASK = 0xEF ; scan from the leftmost column,
.equ INITROWMASK = 0x01 ; scan from the top row
.equ ROWMASK =0x0F ; for obtaining input from Port F
RESET:
	ldi ten,10
	clr first_num
	clr second_num
	ldi temp1, PORTFDIR ; PF7:4/PF3:0, out/in
	sts DDRL, temp1
	ser temp1 ; PORTC is output
	out DDRC, temp1
inital_result:
	ldi result, 'F'
main:
	ldi cmask, INITCOLMASK ; initial column mask
	clr col ; initial column
colloop:
	cpi col, 4
	breq inital_result ; if all keys are scanned, repeat.
	sts PORTL, cmask ; otherwise, scan a column
	ldi temp1, 0xFF ; slow down the scan operation.
delay:
	dec temp1
	brne delay
	lds temp1, PINL ; read PORTF
	andi temp1, ROWMASK ; get the keypad output value
	cpi temp1, 0xF ; check if any row is low
	breq nextcol
	; if yes, find which row is low
	ldi rmask, INITROWMASK ; initialize for row check
	clr row ;
	jmp rowloop

rowloop:
	cpi row, 4
	breq nextcol ; the row scan is over.
	mov temp2, temp1
	and temp2, rmask ; check un-masked bit
	breq convert ; if bit is clear, the key is pressed
	inc row ; else move to the next row
	lsl rmask
	jmp rowloop
nextcol: ; if row scan is over
	lsl cmask
	inc col ; increase column value
	jmp colloop ; go to the next column
convert:
	cpi col, 3 ; If the pressed key is in col. 3
	breq letters ; we have a letter
	; If the key is not in col. 3 and
	cpi row, 3 ; if the key is in row3,
	breq symbols ; we have a symbol or 0
	mov temp1, row ; Otherwise we have a number in 1-9
	lsl temp1
	add temp1, row ;
	add temp1, col ; temp1 = row*3 + col
	inc temp1
	jmp convert_end
letters:
	ldi temp1, 'A'
	add temp1, row ; Get the ASCII value for the key
	jmp over_flow_light
symbols:
	cpi col, 0 ; Check if we have a star
	ldi temp1,'*'
	breq read_second_number
	cpi col, 1 ; or if we have zero
	ldi temp1,0
	breq convert_end ; if not we have hash
	ldi temp1,'#'
	jmp caculate


convert_end:
	cp result, temp1	;if the input does not change, do nothing and return to first step
	breq main
	mov result, temp1 ;use result as a flag, judge if input changed
	mul second_num, ten
	clr col
	cp r1,col
	brne over_flow_light
	mov second_num, r0
	;out PORTC, second
	add second_num, temp1 ;new first number is old one *10 + temp1
	out PORTC, second_num
	jmp main

 read_second_number:
	cp result, temp1
	breq convert_end ;jmp to main through convert_end, because relative branch out of reach
	mov first_num, second_num
	clr second_num
	mov result, temp1
	jmp main

caculate:	
	;out PORTC, first_num
	cp result, temp1	;if the input does not change, do nothing and return to first step
	breq convert_end
	mov result, temp1
	mul first_num, second_num
	clr col
	cp r1,col
	brne over_flow_light
	out PORTC, r0 ; Write value to PORTC
	;mov result, temp1
	clr first_num
	clr second_num
	clr r0
	clr r1
	jmp  main; Restart main loop

.macro oneSecondDelay            ;useing two loop let LED delay one second
        ldi r21,0xD2   ;1
        ldi r22,7    ;1
        ldi r20, 0xF0
loop:                                ;loop takes 8 clock cycle
        cpi r22, 0    ;1            ;loop for 20000 times
        breq loop1        ;1,2
        subi r21,1
		sbci r22,0	    ;2
        nop                ;1
        rjmp loop        ;2
loop1:   
		cpi r20,0        ;1        loop1 takes 7 clock cycle
        breq done        ;1,2        loop for 0x64 times
        subi r20 ,1           ;1        
	    ldi r21,0xD2   ;1
        ldi r22,7   ;1
        rjmp loop        ;2                    
done:
.endmacro

over_flow_light:	
	inc r27
	ser ten
	out PORTC, ten
	oneSecondDelay 
	clr ten
	out PORTC, ten
	oneSecondDelay 
	cpi r27,3
	brne over_flow_light
	clr r27
	jmp reset




