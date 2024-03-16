.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
background_x: .res 1
background_y: .res 1
background_index: .res 1



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

LDX #00 ; write sprite data
load_sprites:	lda hello, X 	; Load the hello message into SPR-RAM
  sta $0200, X
  inx
  cpx #$c0
  bne load_sprites

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

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
hello:
  ; .byte $00, $00, $00, $00 	; Why do I need these here?
  ; .byte $00, $00, $00, $00

  ;first set of sprite (down)
  .byte $0F, $01, $00, $07
  .byte $0F, $02, $00, $0F
  .byte $17, $11, $00, $07
  .byte $17, $12, $00, $0F

  .byte $0F, $21, $00, $1e
  .byte $0F, $22, $00, $26
  .byte $17, $31, $00, $1e
  .byte $17, $32, $00, $26

  .byte $0F, $41, $00, $34
  .byte $0F, $42, $00, $3c
  .byte $17, $51, $00, $34 
  .byte $17, $52, $00, $3c

  ;second set of sprite (up)
  .byte $23, $03, $00, $07
  .byte $23, $04, $00, $0f
  .byte $2b, $13, $00, $07
  .byte $2b, $14, $00, $0f

  .byte $23, $23, $00, $1e
  .byte $23, $24, $00, $26
  .byte $2b, $33, $00, $1e
  .byte $2b, $34, $00, $26

  .byte $23, $43, $00, $34
  .byte $23, $44, $00, $3c
  .byte $2b, $53, $00, $34
  .byte $2b, $54, $00, $3c

  ;third set of sprite (right)
  .byte $39, $05, $00, $07
  .byte $39, $06, $00, $0F
  .byte $41, $15, $00, $07
  .byte $41, $16, $00, $0F

  .byte $39, $25, $00, $1e
  .byte $39, $26, $00, $26
  .byte $41, $35, $00, $1e
  .byte $41, $36, $00, $26

  .byte $39, $45, $00, $34
  .byte $39, $46, $00, $3c
  .byte $41, $55, $00, $34 
  .byte $41, $56, $00, $3c

  ;fourth set of sprite (left)
  .byte $4f, $07, $00, $07
  .byte $4f, $08, $00, $0F
  .byte $57, $17, $00, $07
  .byte $57, $18, $00, $0F

  .byte $4f, $27, $00, $1e
  .byte $4f, $28, $00, $26
  .byte $57, $37, $00, $1e
  .byte $57, $38, $00, $26

  .byte $4f, $47, $00, $34
  .byte $4f, $48, $00, $3c
  .byte $57, $57, $00, $34 
  .byte $57, $58, $00, $3c

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