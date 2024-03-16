# NesGame
This repository corresponds to Architecture 2 NES game, worked upon Yamil and myself.

Commands needed to create .nes file:
ca65 src/demo.asm
ca65 src/reset.asm
ld65 src/reset.o src/demo.o -C nes.cfg -o demo.nes
