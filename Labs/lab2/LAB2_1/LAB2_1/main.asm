;
; LAB2_1.asm
;
; Created: 2016/8/20 14:52:06
; Author :Yu Feng
;
/*
.set dividend=0 
.set divisor = dividend+8
.set ALL_SIZE = divisor + 8

.cseg 
input_value:
	.dw HWRD(3217)
	.dw LWRD(3217)
	.dw HWRD(16)
	.dw LWRD(16)
	*/
	.def Hbit_pst=r26
	.def Lbit_pst=r25
	.def Hdivisor=r20
	.def Ldivisor=r19
	.def Hdividend=r22
	.def Ldividend=r21			
	clr r16				 ; initialized all register
	clr r22

;r22:r21 / r20:r19 = r18:r17,
;initialize
.set temp=0
ldi r18, temp
ldi r17, temp
ldi r23,0
ldi r24,0

;.dseg
;first: .byte ALL_SIZE 
ldi Hbit_pst, 0
ldi Lbit_pst, 1
ldi Hdivisor, high(16)
ldi Ldivisor, low(16)
//ldi Hdividend, high(0)
//ldi Ldividend, low(0)
ldi Ldividend, low(3217)
ldi Hdividend, high(3217)
step1:		
	;lpm Hdividend,high(input_value<<1)
	;lpm Ldividend,low(input_value<<1);;;;;;;;un
	cp Ldivisor,Ldividend
	cpc Hdivisor,Hdividend	;judge if divisor<dividend
	brlt step2	;turn to step2
	rjmp step3	;else goto step3
step2:
	cpi Hdivisor,128	;check if the first digit of divisor is 1
	brlt step3  ;if it is 1, jump to step3
	lsl Ldivisor		;left shift divior 1 position
	rol Hdivisor
	lsl Lbit_pst ;left shift bit_pst
	rol Hbit_pst
	rjmp step1

step3_0:
	cpi Hbit_pst, 0
	breq step3
	rjmp step3_2

step3:
	cpi Lbit_pst,0	;if bit<0
	brlo step4
	rjmp step3_2
step3_2:	
	cp Ldivisor,Ldividend
	cpc Hdivisor,Hdividend
	brge step3_1
	cp r23, Lbit_pst
	cpc r24, Hbit_pst
	brge step4
	sub Ldividend,Ldivisor
	sbc Hdividend,Hdivisor
	add r17, Lbit_pst	;quotient + bit_pst
	adc r18,Hbit_pst
	rjmp step3_2

step3_1:
	lsr Hdivisor
	ror Ldivisor
	lsr Hbit_pst
 	ror Lbit_pst
	rjmp step3_0

step4:
	rjmp step4

		

	



 


	
	


