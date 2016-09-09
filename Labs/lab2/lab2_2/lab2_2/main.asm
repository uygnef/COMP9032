;
; lab2_2.asm
;
; Created: 2016/8/26 15:42:48
; Author : Yu Feng
;


; Replace with your application code
.def H_result = r18
.def L_result = r19
.def char = r17
.def temp = r20
clr r18
clr r19
clr r17
clr r20
clr r22
ldi r22, 10

.cseg 
string: 
.db "123456"


ldi r31, high(string<<1)
ldi r30, low(string<<1)
loop:
lpm temp,z+
cpi temp,48				;if the char not in the range of number
brlt end					;break
cpi temp,64
brge end
mov char,temp		;use temp to store current number(char)
subi char,48
mul char,r22
add L_result, r1			;add the new character to the result
adc H_result, r0
rjmp loop

end:
rjmp end