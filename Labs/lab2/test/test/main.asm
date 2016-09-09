;
; test.asm
;
; Created: 2016/8/28 16:55:11
; Author : uygne
;


; Replace with your application code
.cseg 
AA:
	.dw 12345

	ldi r16,1
.macro clear
	loop:
		cpi r16,2
		brge loop
		ldi r16,3
.endmacro
	
clear
ldi  r20,1
