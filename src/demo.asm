.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_sprite_index: .res 1
player_dir: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
walk_state: .res 1
walk_count: .res 1 ; slows down nmi
prev_state: .res 1
.exportzp walk_state, walk_count, prev_state, player_x, player_y, player_sprite_index, pad1

; Main code segment for the program
.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

  ; read controller
  JSR read_controller1

  jsr updateWalkState
  jsr writeSprites

	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  lda #%10010000	; Enable NMI
  sta PPUCTRL
  lda #%00011110	; Enable sprites, background, and leftmost 8 bits for the background
  sta PPUMASK

forever:
  jmp forever
.endproc

.proc updateWalkState
  PHP ; save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  lda walk_count ; Load walk count value
  cmp #$0a ; update sprite every 10 frames
  bne skip ; If we haven't hit a 10th frame, do not update walk_state
  lda walk_state ; Load `walk_state` value
  cmp #$20 ; If walk_state == 20, call reset_zero
  beq reset_zero ; reset to zero and set previous to 20
  cmp #$40 ; If walk_state == 40, call reset_zero
  beq reset_zero ; reset to zero and set previous to 40
  cmp #$00 ; If walk_state == 0, call update_walk function
  beq update_walk ; This function assigns to walk_state the value 20 or 40 depending in the previous state

update_walk: ; Update (when `walk_state` equals zero) the `walk_state` depending on the `prev_state`
  lda prev_state ; Load previous state
  cmp #$20 ; Check if previous state equals to 20, if so call function `set_to_40`
  beq set_to_40
  cmp #$40 ; Check if previous state equals to 40, if so call function `set_to_20`
  beq set_to_20

reset_zero: ; Save current `walk_state` to `prev_state` and reset the `walk_state` to zero
  lda walk_state ; Load walk state value
  sta prev_state ; Save walk state value to previous state
  lda #$00 ; Load zero
  sta walk_state ; Save zero value to walk state
  jmp reset_walk_count ; Jump to `reset_walk_count`

reset_walk_count:
  lda #$00 ; Load zero
  sta walk_count ; reset walk count to zero
  jmp end_update ; Jump to `end_update`
  
set_to_40: ; Set the walk state value to `40`
  lda #$40 ; Load the value `40`
  sta walk_state ; Saving the value `40` to walk state
  jmp reset_walk_count ; Jump to `reset_walk_count`

set_to_20: ; Set the walk state value to `20`
  lda #$20 ; Load the value `20`
  sta walk_state ; Saving the value `20` to walk state
  jmp reset_walk_count ; Jump to `reset_walk_count`

skip: ; Skip walk count to be able to reach to the value `10`
  lda walk_count ; Load walk count
  adc #$01 ; increment walk_count to count up to 10
  sta walk_count ; Save the incremented number to walk_count

end_update: ; end of program
  jsr update_player
   ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player_x  ; If the branch is not taken, move player left
  LDA #$06 ; player_dir like walk_state also works as a tile offset
  STA player_dir ; going left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
  LDA #$04
  STA player_dir ; going right
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
  LDA #$02
  STA player_dir ; going up
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y ; 
  LDA #$00
  STA player_dir ; going down
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc writeSprites ; takes parameters Y-coordinate, tile-index, attribute, and X-coordinate.
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; writing sprites parameters.
  CLC
  LDA PPUSTATUS ; draw top left
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203
  LDA player_sprite_index
  ADC walk_state ; walk_state also corresponds to tile offset
  ADC player_dir
  STA $0201

  LDA PPUSTATUS ; draw top right
  LDA player_y
  STA $0204
  LDA player_x
  ADC #$08
  STA $0207
  LDA player_sprite_index
  ADC #$01
  ADC walk_state
  ADC player_dir
  STA $0205

  LDA PPUSTATUS ; draw bottom left
  LDA player_y
  ADC #$08
  STA $0208
  LDA player_x
  STA $020B
  LDA player_sprite_index
  ADC #$10
  ADC walk_state
  ADC player_dir
  STA $0209

  LDA PPUSTATUS ; draw bottom right
  LDA player_y
  ADC #$08
  STA $020C
  LDA player_x
  ADC #$08
  STA $020F
  LDA player_sprite_index
  ADC #$11
  ADC walk_state
  ADC player_dir
  STA $020D

  ;write tile attributes for sprites, using palette 0.
  LDA #$00
  STA $0202
  STA $0206
  STA $020A
  STA $020E

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"

palettes:
  ; Background Palette
  .byte $0f, $17, $07, $19
  .byte $0f, $0c, $3d, $37
  .byte $0f, $31, $21, $20
  .byte $0f, $09, $1a, $2a

  ; Sprite Palette
  .byte $0f, $0B, $2a, $37
  .byte $0f, $0C, $2C, $37
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

; Character memory
.segment "CHR"
.incbin "tiles.chr"