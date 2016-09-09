.set dividend=0 
.set divisor = dividend+8
.set ALL_SIZE = divisor + 8
.cseg 
input_value:
	.dw HWRD(3217)
	.dw LWRD(3217)
	.dw HWRD(16)
	.dw LWRD(16)
	
	ldi r31, high(postdiv<<1); store the address of postdiv 
	ldi r30, low(postdiv<<1) ; in register Z.
	ldi r29, high(divion); store the address of divion(dividend and divisor) 
	ldi r28, low(divion) ; in Y register.
	ldi r25, 0			 ; r25 is bit_position
	clr r26
	.def Hbit_pst=r26
	.def Lbit_pst=r25
	.def Hdivisor=r20
	.def Ldivisor=r19
	.def Hdividend=r22
	.def Ldividend=r21			
	clr r16				 ; initialized all register
	clr r22

;r22:r21 / r20:r19 = r18:r17,
;
;initialize
ldi temp=0
;ldi Hdividend, high(3217)
;ldi Ldividend, low(3217)
ldi Hdivisor, high(16)
ldi Ldivisor, low(16)
ldi r18, temp
ldi r17, temp

step1:
		
	lpm Hdividend,high(input_value<<1)
	lpm Ldividend,low(input_value<<1);;;;;;;;un
	sub Ldividend,Ldivisor
	sbc Hdividend,Hdivisor	;judge if divisor<dividend
	brcc step2	;turn to step2
	rjmp step3	;else goto step3
step2:
	cpi Hdivisor,128	;check if the first digit of divisor is 1
	brlo step3  ;if it is 0, jump to step3
	lsl Ldividend		;left shift divior 1 position
	rol Hdividend
	lsl Lbit_pst ;left shift bit_pst
	rol Hbit_pst
step3:
	cpi bit_pst,0	;if bit<0
	brlt step4
	cp Ldividend,divisor
	cpc Hdividend,divisor
	brlt step3_1
	sub Ldividend,Ldivisor
	sbc Hdividend,Hdivisor
	add	Lbit_pst,r17	;quotient + bit_pst
	adc Hbit_pst,r18

step3_1:
	lsr Ldivisor
	ror Hdivisor
	lsr bit_pst
	ror bit_pst

step4:
	rjmp step4

		

	



 


	
	


