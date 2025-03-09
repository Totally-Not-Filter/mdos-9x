@echo off
tool\asm68k /k /p /o ae- main.asm, program.bin >errors.log, , main.lst
pause