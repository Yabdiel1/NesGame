.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
background_x: .res 1
background_y: .res 1
background_index: .res 1
sprite_x: .res 1
sprite_y: .res 1
sprite_index: .res 1
walk_state: .res 1
walk_count: .res 1 ; slows down nmi
.exportzp walk_state, walk_count

; Main code segment for the program
.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

  jsr updateWalkState
  jsr sprites

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

backgrounds: ; sets parameters for writeBackground and calls it for each tile we want to write
  ;first 16x16 tile
  CLC
  LDA #$22
  STA background_y
  LDA #$44
  STA background_x
  LDA #$02
  STA background_index
  jsr writeBackground

  ;second 16x16 tile
  LDA #$22
  STA background_y
  LDA #$46
  STA background_x
  LDA #$04
  STA background_index
  jsr writeBackground

  ; third 16x16 tile
  LDA #$22
  STA background_y
  LDA #$48
  STA background_x
  LDA #$06
  STA background_index
  jsr writeBackground

  ; fourth 16x16 tile
  LDA #$22
  STA background_y
  LDA #$4a
  STA background_x
  LDA #$08
  STA background_index
  jsr writeBackground

  ;fifth 16x16 tile
  LDA #$22
  STA background_y
  LDA #$4c
  STA background_x
  LDA #$0a
  STA background_index
  jsr writeBackground

  ; sixth 16x16 tile
  LDA #$22
  STA background_y
  LDA #$4e
  STA background_x
  LDA #$0c
  STA background_index
  jsr writeBackground

  ; seventh 16x16 tile
  LDA #$22
  STA background_y
  LDA #$50
  STA background_x
  LDA #$0e
  STA background_index
  jsr writeBackground

  ; eight 16x16 tile

  LDA #$22
  STA background_y
  LDA #$52
  STA background_x
  LDA #$30
  STA background_index
  jsr writeBackground

  jmp writeAttributeTables

writeBackground: ; takes the parameters Y (high byte), X(low byte) and tile index to write
  LDA PPUSTATUS ; draw top left
  LDA background_y
  STA PPUADDR
  LDA background_x
  STA PPUADDR
  LDA background_index
  STA PPUDATA

  LDA PPUSTATUS ; draw top right
  LDA background_y
  STA PPUADDR
  LDA background_x
  ADC #$01
  STA PPUADDR
  LDA background_index
  ADC #$01
  STA PPUDATA

  LDA PPUSTATUS ; draw bottom left
  LDA background_y
  STA PPUADDR
  LDA background_x
  ADC #$20
  STA PPUADDR
  LDA background_index
  ADC #$10
  STA PPUDATA

  LDA PPUSTATUS ; draw bottom right
  LDA background_y
  STA PPUADDR
  LDA background_x
  ADC #$21
  STA PPUADDR
  LDA background_index
  ADC #$11
  STA PPUDATA
  rts

writeAttributeTables:
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e1
  STA PPUADDR
  LDA #%00000000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e2
  STA PPUADDR
  LDA #%10010000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e3
  STA PPUADDR
  LDA #%01110000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e4
  STA PPUADDR
  LDA #%10100000
  STA PPUDATA

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

.proc sprites 
  PHP ; save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00 ; Initialize x-register with the zero value. Allows writes to further bytes of the OAM.
  ; going south sprite
  CLC
  LDA #$21
  STA sprite_y
  LDA #$6a
  STA sprite_x
  LDA #$01
  STA sprite_index
  jsr writeSprites

  ; going north sprite
  TXA
  ADC #$10
  TAX
  LDA #$21
  STA sprite_y
  LDA #$79
  STA sprite_x
  LDA #$03
  STA sprite_index
  jsr writeSprites

  ; going east sprite
  TXA
  ADC #$10
  TAX
  LDA #$34
  STA sprite_y
  LDA #$6a
  STA sprite_x
  LDA #$05
  STA sprite_index
  jsr writeSprites

  ; going west sprite
  TXA
  ADC #$10
  TAX
  LDA #$34
  STA sprite_y
  LDA #$79
  STA sprite_x
  LDA #$07
  STA sprite_index
  jsr writeSprites

    ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc updateWalkState ; TODO(yabdiel): update to correct sequence of FSM
  PHP ; save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  lda walk_count
  cmp #$0a ; update sprite every 10 frames
  bne next ; if we haven't hit a 10th frame, do not update walk_state
  CLC ; do not know where the carry flag is being set; but it is being set nonetheless, and we don't want to add $21
  lda walk_state 
  ADC #$20 ; update walk_state now that we have hit the 10th frame
  sta walk_state
  lda #$00 ; reset walk_count to count up to 10 again
  sta walk_count

  next: ; could be given a better name
  lda walk_state
  cmp #$60 ; adding tile index (walk_state) by 20 each time; there is nothing at an offset of $60, so we want to reset it back to 0
  bne skip ; do not reset if we have not hit 60
  lda #$00
  sta walk_state

  skip: ; could be given a better name
  lda walk_count 
  adc #$01 ; increment walk_count to count up to 10
  sta walk_count
  
   ; restore registers and return
  PLA
  TAY
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
  LDA PPUSTATUS ; draw top left
  LDA sprite_y
  STA $0200, x
  LDA sprite_x
  STA $0203, x
  LDA sprite_index
  ADC walk_state ; walk_state also corresponds to tile offset
  STA $0201, x

  LDA PPUSTATUS ; draw top right
  LDA sprite_y
  STA $0204, x
  LDA sprite_x
  ADC #$08
  STA $0207, x
  LDA sprite_index
  ADC #$01
  ADC walk_state
  STA $0205, x

  LDA PPUSTATUS ; draw bottom left
  LDA sprite_y
  ADC #$08
  STA $0208, x
  LDA sprite_x
  STA $020B, x
  LDA sprite_index
  ADC #$10
  ADC walk_state
  STA $0209, x

  LDA PPUSTATUS ; draw bottom right
  LDA sprite_y
  ADC #$08
  STA $020C, x
  LDA sprite_x
  ADC #$08
  STA $020F, x
  LDA sprite_index
  ADC #$11
  ADC walk_state
  STA $020D, x

  ;write tile attributes for sprites, using palette 0.
  LDA #$00
  STA $0202, x
  STA $0206, x
  STA $020A, x
  STA $020E, x

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