@echo off
..\tool\vasmz80_psi-x -maxerrors=0 -noalign -altlocal -Fbin -start=0 -o zilogdriver.bin -L zilogdriver.lst -Lall zilogdriver.asm 2> errors.log
pause