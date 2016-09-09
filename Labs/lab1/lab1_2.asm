;.def sum = r16:r15
;.def a = r17
;.def i = r18
;.def n = r19
; a^n = r21:r20
.def a=r17
.def n=r19
.def i=r18
.def anH=r21
.def anl=r20
.def sumh=r16
.def suml=r15

	;ldi a,2
	ldi i,0
	mov anl,a
	ldi anH,0
	ldi n,4
loop:
	cp n,i
	breq end
	mul anl,a
	mov r5,r0
	mul anl,a
	add r5,r1	;r5,r4 is to store a^(n+1)
	mov r4,r0	;multiply an*a
	movw r21:r20,r5:r4
	
	
	add suml,r4
	adc sumh,r5
	inc i
	rjmp loop
end:
	rjmp end

