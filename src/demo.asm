.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
background_x: .res 1
background_y: .res 1
background_index: .res 1
sprite_x: .res 1
sprite_y: .res 1
sprite_index: .res 1



; ; "nes" linker config requires a STARTUP section, even if it's empty
; .segment "STARTUP"

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

; sprites:
;   ;1st sprite
;   CLC
;   LDA #$0F
;   STA sprite_y
;   LDA #$07
;   STA sprite_x
;   LDA #$01
;   STA sprite_index
;   LDX #$00 ; Initialize x-register with the zero value.
;   jsr writeSprites

;   ;2nd sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$0f
;   STA sprite_y
;   LDA #$1e
;   STA sprite_x
;   LDA #$21
;   STA sprite_index
;   jsr writeSprites

;   ;3rd sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$0f
;   STA sprite_y
;   LDA #$34
;   STA sprite_x
;   LDA #$41
;   STA sprite_index
;   jsr writeSprites

;   ;4th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$23
;   STA sprite_y
;   LDA #$07
;   STA sprite_x
;   LDA #$03
;   STA sprite_index
;   jsr writeSprites

;   ;5th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$23
;   STA sprite_y
;   LDA #$1e
;   STA sprite_x
;   LDA #$23
;   STA sprite_index
;   jsr writeSprites

;   ;6th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$23
;   STA sprite_y
;   LDA #$34
;   STA sprite_x
;   LDA #$43
;   STA sprite_index
;   jsr writeSprites

;   ;7th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$39
;   STA sprite_y
;   LDA #$07
;   STA sprite_x
;   LDA #$05
;   STA sprite_index
;   jsr writeSprites

;   ;8th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$39
;   STA sprite_y
;   LDA #$1e
;   STA sprite_x
;   LDA #$25
;   STA sprite_index
;   jsr writeSprites

;   ;9th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$39
;   STA sprite_y
;   LDA #$34
;   STA sprite_x
;   LDA #$45
;   STA sprite_index
;   jsr writeSprites

;   ;10th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$4f
;   STA sprite_y
;   LDA #$07
;   STA sprite_x
;   LDA #$07
;   STA sprite_index
;   jsr writeSprites

;   ;11th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$4f
;   STA sprite_y
;   LDA #$1e
;   STA sprite_x
;   LDA #$27
;   STA sprite_index
;   jsr writeSprites

;   ;12th sprite
;   TXA
;   ADC #$10
;   TAX
;   LDA #$4f
;   STA sprite_y
;   LDA #$34
;   STA sprite_x
;   LDA #$47
;   STA sprite_index
;   jsr writeSprites

;   jmp vblankwait

; writeSprites: ; takes parameters Y-coordinate, tile-index, attribute, and X-coordinate.
;   ; save registers
;   PHP
;   PHA
;   TXA
;   PHA
;   TYA
;   PHA

;   ; writing sprites parameters.
;   LDA PPUSTATUS ; draw top left
;   LDA sprite_y
;   STA $0200, x
;   LDA sprite_x
;   STA $0203, x
;   LDA sprite_index
;   STA $0201, x

;   LDA PPUSTATUS ; draw top right
;   LDA sprite_y
;   STA $0204, x
;   LDA sprite_x
;   ADC #$08
;   STA $0207, x
;   LDA sprite_index
;   ADC #$01
;   STA $0205, x

;   LDA PPUSTATUS ; draw bottom left
;   LDA sprite_y
;   ADC #$08
;   STA $0208, x
;   LDA sprite_x
;   STA $020B, x
;   LDA sprite_index
;   ADC #$10
;   STA $0209, x

;   LDA PPUSTATUS ; draw bottom right
;   LDA sprite_y
;   ADC #$08
;   STA $020C, x
;   LDA sprite_x
;   ADC #$08
;   STA $020F, x
;   LDA sprite_index
;   ADC #$11
;   STA $020D, x

;   ;write tile attributes for sprites, using palette 0.
;   LDA #$00
;   STA $0202, x
;   STA $0206, x
;   STA $020A, x
;   STA $020E, x

;   ; restore registers and return
;   PLA
;   TAY
;   PLA
;   TAX
;   PLA
;   PLP
;   RTS

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
  ;1st sprite
  CLC
  LDA #$0F
  STA sprite_y
  LDA #$07
  STA sprite_x
  LDA #$01
  STA sprite_index
  LDX #$00 ; Initialize x-register with the zero value.
  jsr writeSprites

  ;2nd sprite
  TXA
  ADC #$10
  TAX
  LDA #$0f
  STA sprite_y
  LDA #$1e
  STA sprite_x
  LDA #$21
  STA sprite_index
  jsr writeSprites

  ;3rd sprite
  TXA
  ADC #$10
  TAX
  LDA #$0f
  STA sprite_y
  LDA #$34
  STA sprite_x
  LDA #$41
  STA sprite_index
  jsr writeSprites

  ;4th sprite
  TXA
  ADC #$10
  TAX
  LDA #$23
  STA sprite_y
  LDA #$07
  STA sprite_x
  LDA #$03
  STA sprite_index
  jsr writeSprites

  ;5th sprite
  TXA
  ADC #$10
  TAX
  LDA #$23
  STA sprite_y
  LDA #$1e
  STA sprite_x
  LDA #$23
  STA sprite_index
  jsr writeSprites

  ;6th sprite
  TXA
  ADC #$10
  TAX
  LDA #$23
  STA sprite_y
  LDA #$34
  STA sprite_x
  LDA #$43
  STA sprite_index
  jsr writeSprites

  ;7th sprite
  TXA
  ADC #$10
  TAX
  LDA #$39
  STA sprite_y
  LDA #$07
  STA sprite_x
  LDA #$05
  STA sprite_index
  jsr writeSprites

  ;8th sprite
  TXA
  ADC #$10
  TAX
  LDA #$39
  STA sprite_y
  LDA #$1e
  STA sprite_x
  LDA #$25
  STA sprite_index
  jsr writeSprites

  ;9th sprite
  TXA
  ADC #$10
  TAX
  LDA #$39
  STA sprite_y
  LDA #$34
  STA sprite_x
  LDA #$45
  STA sprite_index
  jsr writeSprites

  ;10th sprite
  TXA
  ADC #$10
  TAX
  LDA #$4f
  STA sprite_y
  LDA #$07
  STA sprite_x
  LDA #$07
  STA sprite_index
  jsr writeSprites

  ;11th sprite
  TXA
  ADC #$10
  TAX
  LDA #$4f
  STA sprite_y
  LDA #$1e
  STA sprite_x
  LDA #$27
  STA sprite_index
  jsr writeSprites

  ;12th sprite
  TXA
  ADC #$10
  TAX
  LDA #$4f
  STA sprite_y
  LDA #$34
  STA sprite_x
  LDA #$47
  STA sprite_index
  jsr writeSprites

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
  STA $0201, x

  LDA PPUSTATUS ; draw top right
  LDA sprite_y
  STA $0204, x
  LDA sprite_x
  ADC #$08
  STA $0207, x
  LDA sprite_index
  ADC #$01
  STA $0205, x

  LDA PPUSTATUS ; draw bottom left
  LDA sprite_y
  ADC #$08
  STA $0208, x
  LDA sprite_x
  STA $020B, x
  LDA sprite_index
  ADC #$10
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