@echo off
:tool\asm68k /k /p /o ae- l. main.asm, program.bin >errors.log, , main.lst
tool\vasmm68k_psi-x -maxerrors=0 -noalign -altlocal -Fbin -start=0 -o program.bin -L main.lst -Lall main.asm 2> errors.log
pause