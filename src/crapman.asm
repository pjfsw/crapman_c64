    BasicUpstart2(main)
    
*=$0810
main:    
    jsr level.play
    jmp *

#import "level.asm"