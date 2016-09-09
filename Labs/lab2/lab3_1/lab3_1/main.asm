.include"m2560def.Inc"

.equ loop_count= 20000        ;initial the loop data 
.def iH = r25                ;to let time delay is 
.def iL = r24                ;exactly 1 second

.def countH=r17    
.def countL=r16


.cseg
rjmp main
pattern:            ; store the pattern into the program memory
    .db 0x03, 0x0a, 0x50, 0xff ;wirte the pattern to the memory

main:
ldi ZH, high(pattern<<1)
ldi ZL, low(pattern<<1)

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
        
.macro wait                ;when user press butten 
    waiting:            ;the led stop changing
        sbis PIND,0
        rjmp waiting
        rjmp done
    done:
.endmacro

            
start:                    ;load data and let LED lighten 
        
        ser r18            ;just as the memory pattern
        out DDRC,r18    ;set to output modle
        load_pattern    
        
        out PORTC,r18    ;illuming the LED
        oneSecondDelay
        wait


        ser r18        
        load_pattern
        out PORTC,r18
        oneSecondDelay
        wait

        ser r18        
        load_pattern
        out PORTC,r18
        oneSecondDelay
        wait
        

        ser r18        
        load_pattern
        out PORTC,r18
        oneSecondDelay
        wait                    ;initialize pointer
        ldi ZH, high(pattern)    ;jump to the start
        ldi ZL, low(pattern)
        rjmp start            
    
