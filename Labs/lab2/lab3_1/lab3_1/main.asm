.equ loop_count= 20000        ;initial the loop data
.def iH = r25                ;to let time delay is
.def iL = r24                ;exactly 1 second

.def countH=r17   
.def countL=r16
.def temp=r21
.def flag = r22

        jmp RESET
.org    INT0addr
        jmp EXT_INT0

.cseg
pattern:            ; store the pattern into the program memory
    .db 0x01, 0x0a, 0x50, 0xff ;wirte the pattern to the memory

RESET:   
		clr flag 
		ldi temp, (1 << ISC00) ; set INT0 as falling edge triggered interrupt
        sts EICRA, temp
        in temp, EIMSK; enable INT0
        ori temp, (1<<INT0)
        out EIMSK, temp
        sei; enable Global Interrupt
        jmp start

EXT_INT0:
		cpi  flag, 0
		breq wait
		ldi flag,0
		jmp start

wait:
		ldi flag, 1
		ser r18    
		out DDRC,r18   
        ldi r18,4
		out PORTC,r18
        ldi r18,32
		out PORTC,r18
		jmp wait
        

.macro load_pattern                ;load pattern from memory
    lpm r18,Z+
.endmacro
.macro oneSecondDelay            ;useing two loop let LED delay one second
        ldi countL,low(loop_count)   ;1
        ldi countH,high(loop_count)    ;1
        clr r20
        clr iH    ;1
        clr iL    ;1
loop:                                ;loop takes 8 clock cycle
        cp iL,countL    ;1            ;loop for 20000 times
        cpc iH,countH    ;1
        brsh loop1        ;1,2
        adiw iH:iL,1    ;2
        nop                ;1
        rjmp loop        ;2
loop1:    cpi r20,0x64        ;1        loop1 takes 7 clock cycle
        brsh done        ;1,2        loop for 0x64 times
        inc r20            ;1       
        clr iH            ;1            total loop is (8*loop+11)*loop1+3
        clr iL        ;1                equal 16M times
        rjmp loop        ;2           

       
done:
.endmacro
        cbi DDRD,0
       


           
start:                    ;load data and let LED lighten
        ldi ZH, high(pattern<<1)
        ldi ZL, low(pattern<<1)
        ser r18            ;just as the memory pattern
        out DDRC,r18    ;set to output modle
        load_pattern   
       
        out PORTC,r18    ;illuming the LED
        oneSecondDelay
        


        ser r18       
        load_pattern
        out PORTC,r18
        oneSecondDelay
        

        ser r18       
        load_pattern
        out PORTC,r18
        oneSecondDelay
        
       

        ser r18       
        load_pattern
        out PORTC,r18
        oneSecondDelay
                           ;initialize pointer
        ldi ZH, high(pattern)    ;jump to the start
        ldi ZL, low(pattern)
        rjmp start         
