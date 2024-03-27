.include "constants.inc"

.segment "ZEROPAGE"
.importzp walk_state, walk_count, player_y, player_x, player_sprite_index

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
  BIT $2002
vblankwait:
  BIT $2002
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

  ; initialize zero-page values
  LDA #$20
  STA walk_state
  LDA #$00
  STA walk_count
  LDA #$21
  STA player_y
  LDA #$6a
  STA player_x
  LDA #$01
  STA player_sprite_index

vblankwait2:
  BIT $2002
  BPL vblankwait2
  JMP main
.endproc