#importonce

#import "screen.asm"

.var BG = List().add(
    "***************  ***************",
    "*    **       *  *     **      *",
    "*    **       ****     **      *",
    "*    **                        *",
    "*    ******                    *",
    "*    ******                    *",
    "*    **       ****          ****",
    "*             *  *          *   ",
    "*             ****          ****",
    "*                              *",
    "****                        ****",
    "****                        ****",
    "*                              *",
    "****          **               *",
    "   ***        **               *",
    "     *    ***********          *",
    "   ***    ***********          *",
    "****             **            *",
    "*                              *",
    "*                              *",
    "*                              *",
    "*                              *",
    "*                              *",
    "********************************");
.var BG_WIDTH = BG.get(0).size()
.var BG_HEIGHT = BG.size()

.const TOP_LEFT = $70
.const BOTTOM_RIGHT = $7d
.const BOTTOM_LEFT = $6d
.const TOP_RIGHT = $6e
.const VERTICAL = $5d

.function bg_char_at(x,y) {
    .if (x < 0 || x > BG_WIDTH-1 || y < 0 || y > BG_HEIGHT-1) {
        .return ' '
    } else {
        .return BG.get(y).charAt(x)
    }

}
.function bg_get_data(i) {
    .var x = mod(i,BG_WIDTH)
    .var y = floor(i/BG_WIDTH)
    .var c = BG.get(y).charAt(x)
    .var cr = bg_char_at(x+1,y)
    .var cl = bg_char_at(x-1,y)
    .var cd = bg_char_at(x,y+1)
    .var cu = bg_char_at(x,y-1)
    .var cdl = bg_char_at(x-1,y+1)
    .var cdr = bg_char_at(x+1,y+1)
    .var cur = bg_char_at(x+1,y-1)
    .var cul = bg_char_at(x-1,y-1)
    .if (c != '*') {
        .return c
    }
    .if ((cr == '*' && cd == '*' && cl == ' ' && cu == ' ') || 
         (cr == '*' && cd == '*' && cdr == ' ')) {
        .return TOP_LEFT
    } else .if ((cl == ' ' && cr == '*' && cu == '*' && cd == ' ') ||
                (cr == '*' && cu == '*' && cd == '*' && cur == ' ')) {
        .return BOTTOM_LEFT
    } else .if ((cl == '*' && cr == ' ' && cu == ' ' && cd == '*') ||
                (cl == '*' && cr == '*' && cu == ' ' && cd == '*' && cdl == ' ') ||
                (cl == '*' && cu == '*' && cd == '*' && cdl == ' ')) {
        .return TOP_RIGHT
    } else .if ((cl == '*' && cr == ' ' && cu == '*' && cd == ' ') ||
                (cl == '*' && cu == '*' && cd == '*' && cul == ' ')) {
        .return BOTTOM_RIGHT
    } else .if (((cl == ' ' || cr == ' ') && cu == '*' && cd == '*')) {
        .return VERTICAL
    } else .if (cl == '*' && cr == '*') {
        .return $43
    } else {
        .print("ERROR:" + cl + cr + cu + cd) + " at line " 
        .print y
        .return '*'
    }
}

bg: 
    .fill BG_WIDTH*BG_HEIGHT,bg_get_data(i)

level: {
    play:
        jsr screen.clear
        jsr draw_background
        rts

    draw_background:
        lda #BLUE
        ldx #0
    !:
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne !-

        ldy #BG_HEIGHT-1

        lda #<bg
        sta read_screen_pos
        lda #>bg
        sta read_screen_pos+1        

        lda #<SCREEN
        sta write_screen_pos
        lda #>SCREEN
        sta write_screen_pos+1

    !next_row:    
        ldx #BG_WIDTH-1
    !:
    
        lda read_screen_pos:$ffff,x
        sta write_screen_pos:$ffff,x
        dex
        bpl !-

        clc
        lda read_screen_pos
        adc #BG_WIDTH
        sta read_screen_pos
        bcc !+
        inc read_screen_pos+1
    !:
        clc
        lda write_screen_pos
        adc #40
        sta write_screen_pos
        bcc !+
        inc write_screen_pos+1
    !:        
        dey
        bpl !next_row-
        rts

}
