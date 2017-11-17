# ffasm
flashforth assembler based on asm2.text (oh2aun/flashforth) and example asm files.
Adds the following to asm2.txt:
1. Instructions: bld bst sbrc sbrs rol lsl tst clr sei cli clc sec 
   sleep wdr
2. Indirection to ld & st for x, y & z
3. Amended addressing for in, out, cbi, sbi, sbic, sbis: Now need
   an address in the range $20-$3f/5f. These are mapped to I/O
   registers $0-$1f/3f. Allows for memory mapped referencing to
   registers using forthtalk.py e.g. PORTB is always $25
4. k1# & k2# which allows instructions to consume parameters from
   the stack. Stack value is indicated by '^' e.g. ldi r24 ^
5. Implemented additional flow control structures: if-else-then
   begin-while-repeat & begin-repeat
See ffasm_guide.pdf for more information. Use 2004 bytes on an Arduino Uno
