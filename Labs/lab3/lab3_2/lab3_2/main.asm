
.def temp = r16
.def output = r17
.def count = r18 ; number of interrupts
.equ PATTERN = 0b01010101
; set up interrupt vectors
jmp RESET
.org INT0addr ; defined in m2560def.inc
jmp EXT_INT0
RESET:
ser temp ; set Port C as output
out DDRC, temp
out PORTC, temp
ldi output, PATTERN
; continued
ldi temp, (3 << ISC00) ; set INT0 as falling edge triggered interrupt
sts EICRA, temp
in temp, EIMSK ; enable INT0
ori temp, (1<<INT0)
out EIMSK, temp
sei ; enable Global Interrupt
jmp main

; continued
; main -
main:
clr count
clr temp
loop:
inc temp ; a dummy task in main
cpi temp, 0xF ; the following section in red
breq reset_temp ; shows the need to save SREG
rjmp loop ; in the interrupt service routine
reset_temp:
clr temp
rjmp loop