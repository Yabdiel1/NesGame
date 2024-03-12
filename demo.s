.include "constants.inc"
.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
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
  LDA #$22
  STA $00
  LDA #$44
  STA $01
  LDA #$02
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$45
  STA $01
  LDA #$03
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$64
  STA $01
  LDA #$12
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$65
  STA $01
  LDA #$13
  STA $02
  jsr writeBackground

  ;second 16x16 tile
  LDA #$22
  STA $00
  LDA #$46
  STA $01
  LDA #$04
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$47
  STA $01
  LDA #$05
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$66
  STA $01
  LDA #$14
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$67
  STA $01
  LDA #$15
  STA $02
  jsr writeBackground

  ; third 16x16 tile
  LDA #$22
  STA $00
  LDA #$48
  STA $01
  LDA #$06
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$49
  STA $01
  LDA #$07
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$68
  STA $01
  LDA #$16
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$69
  STA $01
  LDA #$17
  STA $02
  jsr writeBackground

  ; fourth 16x16 tile
  LDA #$22
  STA $00
  LDA #$4a
  STA $01
  LDA #$08
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$4b
  STA $01
  LDA #$09
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6a
  STA $01
  LDA #$18
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6b
  STA $01
  LDA #$19
  STA $02
  jsr writeBackground

  ;fifth 16x16 tile
  LDA #$22
  STA $00
  LDA #$4c
  STA $01
  LDA #$0a
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$4d
  STA $01
  LDA #$0b
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6c
  STA $01
  LDA #$1a
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6d
  STA $01
  LDA #$1b
  STA $02
  jsr writeBackground

  ; sixth 16x16 tile
  LDA #$22
  STA $00
  LDA #$4e
  STA $01
  LDA #$0c
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$4f
  STA $01
  LDA #$0d
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6e
  STA $01
  LDA #$1c
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$6f
  STA $01
  LDA #$1d
  STA $02
  jsr writeBackground

  ; seventh 16x16 tile
  LDA #$22
  STA $00
  LDA #$50
  STA $01
  LDA #$0e
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$51
  STA $01
  LDA #$0f
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$70
  STA $01
  LDA #$1e
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$71
  STA $01
  LDA #$1f
  STA $02
  jsr writeBackground

  ; eight 16x16 tile

  LDA #$22
  STA $00
  LDA #$52
  STA $01
  LDA #$30
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$53
  STA $01
  LDA #$31
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$72
  STA $01
  LDA #$40
  STA $02
  jsr writeBackground

  LDA #$22
  STA $00
  LDA #$73
  STA $01
  LDA #$41
  STA $02
  jsr writeBackground



  jmp writeAttributeTables

writeBackground: ; takes a parameter X (high byte), Y(low byte) and index tile to write
; these parameters are saved in $00, $01, and $02 of the ram respectively
  LDA PPUSTATUS
  LDA $00
  STA PPUADDR
  LDA $01
  STA PPUADDR
  LDX $02
  STX PPUDATA
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



enable_rendering:
  lda #%10010000	; Enable NMI
  sta PPUCTRL
  lda #%00011010	; Enable sprites, background, and leftmost 8 bits for the background
  sta PPUMASK

forever:
  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
@loop:	lda hello, x 	; Load the hello message into SPR-RAM
  sta $2004
  inx
  cpx #$1c
  bne @loop
  rti

hello:
  .byte $00, $00, $00, $00 	; Why do I need these here?
  .byte $00, $00, $00, $00
  .byte $6c, $00, $00, $6c
  .byte $6c, $01, $00, $76
  .byte $6c, $02, $00, $80
  .byte $6c, $02, $00, $8A
  .byte $6c, $03, $00, $94

palettes:
  ; Background Palette
  .byte $0f, $17, $07, $19
  .byte $0f, $0c, $3d, $37
  .byte $0f, $31, $21, $20
  .byte $0f, $09, $1a, $2a

  ; Sprite Palette
  .byte $0f, $20, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

; Character memory
.segment "CHARS"
.incbin "tiles.chr"