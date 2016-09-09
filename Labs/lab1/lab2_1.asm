.set dividend=0 
.set divisor = dividend+8
.set ALL_SIZE = divisor + 8
.cseg 
start:
	ldi r31, high(postdiv<<1); store the address of postdiv 
	ldi r30, low(postdiv<<1) ; in register Z.
	ldi r29, high(divion); store the address of divion(dividend and divisor) 
	ldi r28, low(divion) ; in Y register.
	clr r16				 ; initialized all register
	clr r10
load:					 ; load all data to the register
	cpi r16, ALL_SIZE	 ; judge if dividend and divisor have been putted
	brge end 			 ; into the registers.
	;ldi r31, 5
	lpm r10, z+ 		 ; load postdiv value into r10
	st y+, r10 			 ; store r10's value into y, y's
	inc r16 
	rjmp load

end:
rjmp end

postdiv:	
	.dw HWRD(3217) 
	.dw LWRD(16)

if_dividended_bigger:
	cpi

.dseg 
divion: 
	.byte ALL_SIZE
