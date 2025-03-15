@echo off
tool\asm68k /k /p /o ae- /e asm68k=1 main.asm, program.bin >errors.log, , main.lst
pause