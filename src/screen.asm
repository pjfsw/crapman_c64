#importonce 
    .const SCREEN=$0400

screen: {
clear:
    lda #0
    sta $d021
    sta $d020
    lda #32
    ldx #0
!:
    sta SCREEN,x
    sta SCREEN+$100,x
    sta SCREEN+$200,x
    sta SCREEN+$300,x
    inx
    bne !-
    rts    
}    