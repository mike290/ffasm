\
\ *********************************************************************
\ Modified and extended version of:                                   *
\    Filename:      asm2.txt                                          *
\    Date:          20.03.2017                                        *
\    FF Version:    5.0                                               *
\    MCU:           Atmega                                            *
\    Copyright:     Mikael Nordman                                    *
\    Author:        Mikael Nordman                                    *
\ *********************************************************************
\  FlashForth is licensed according to the GNU General Public License *
\ *********************************************************************
\    Filename:      ffasm.frt                                         *
\    Date:          23.10.2017                                        *
\                                                                     *
\ Added instructions: bld bst sbrc sbrs rol lsl tst clr sei cli clc   *
\                     sec sleep wdr                                   *
\ Added indirection to ld & st for x, y  & z                          *
\ Amended addressing for in, out, cbi, sbi, sbic, sbis: Now need an   *
\ address in the range $20-$3f/5f. These are mapped to I/O registers  *
\ $0-$1f/3f. Allows for memory mapped referencing to registers using  *
\ forthtalk.py e.g. PORTB is always $25                               *
\ *********************************************************************
\ Table driven assembler for Atmega chips
\ Uses 1624 bytes on an Arduino
\
-as
marker -as
hex
: ar: ( n "name" -- ) create does> swap 2* 2* + ;
: ri! ( index n -- ) here swap - dup c@ rot 4 lshift or swap c! ;

flash ar: rules
\ d mask.shift, r mask.shift
[ 000.0 , 000.0 , ] \ 00 xxxx.xxxx.xxxx.xxxx ret sleep wdr
[ 1f0.4 , 007.0 , ] \ 01 xxxx.xxxd.dddd.0rrr bld bst sbrc sbrs
[ 0f8.3 , 007.0 , ] \ 02 xxxx.xxxx.dddd.dbbb cbi sbi sbic sbis I/O:$20-$3f*, bit:0-7
[ 1f0.4 , 00f.0 , ] \ 03 xxxx.xxxd.dddd.rrrr ld x+ -x y+ -y z+ -z x y z
[ 1f0.4 , 00f.0 , ] \ 04 xxxx.xxxd.dddd.rrrr st x+ -x y+ -y z+ -z x y z
[ 030.4 , 0cf.2 , ] \ 05 xxxx.xxxx.kkpp.kkkk adiw sbiw
[ 1f0.4 , 60f.5 , ] \ 06 xxxx.xaad.dddd.aaaa in Rx <- I/O($20-5f)*
[ 1f0.4 , 60f.5 , ] \ 07 xxxx.xaad.dddd.aaaa out I/O($20-5f)* <- Rx
[ 1f0.4 , 000.0 , ] \ 08 xxxx.xxxd.dddd.xxxx lds (2nd byte has addr)
[ 1f0.4 , 000.0 , ] \ 09 xxxx.xxxd.dddd.xxxx sts (2nd byte has addr)
[ 1f0.4 , 000.0 , ] \ 0a xxxx.xxxd.dddd.xxxx pop push com neg
                    \                        swap inc asr lsr ror dec
[ 0f0.4 , f0f.4 , ] \ 0b xxxx.kkkk.dddd.kkkk cpi sbci subi ori andi ldi (r16-32 only)
[ 0f0.4 , 00f.0 , ] \ 0c xxxx.xxxx.dddd.rrrr movw
[ 1f0.4 , 20f.5 , ] \ 0d xxxx.xxrd.dddd.rrrr rol lsl tst clr (Rd=Rr Only one reg reqd)
[ 1f0.4 , 20f.5 ,   \ 0e xxxx.xxrd.dddd.rrrr cpc cp sbc sub add adc cpse
                    \                        and eor or mov mul
                    \ Not implemented: ser bset bclr lpm spm
\ 000.0 , 000.0 ,   \ 0f if then begin until again
\ * I/O addresses $20-$3f/5f are mapped to I/O registers $0-$1f/3f

\ 126 opcodes opcode name ruleindex namelen
flash create opcodes
[ 9508 , ," ret"     0 4 ri! ]
[ 9588 , ," sleep"   0 6 ri! ]
[ 0000 , ," nop"     0 4 ri! ]
[ 94f8 , ," cli"     0 4 ri! ]
[ 9478 , ," sei"     0 4 ri! ]
[ 9488 , ," clc"     0 4 ri! ]
[ 9408 , ," sec"     0 4 ri! ]
[ 95a8 , ," wdr"     0 4 ri! ]
[ f800 , ," bld"     1 4 ri! ]
[ fa00 , ," bst"     1 4 ri! ]
[ fc00 , ," sbrc"    1 6 ri! ]
[ fe00 , ," sbrs"    1 6 ri! ]
[ 9800 , ," cbi"     2 4 ri! ]
[ 9a00 , ," sbi"     2 4 ri! ]
[ 9900 , ," sbic"    2 6 ri! ]
[ 9b00 , ," sbis"    2 6 ri! ]
[ 9000 , ," ld"      3 4 ri! ]
[ 9200 , ," st"      4 4 ri! ]
[ 9600 , ," adiw"    5 6 ri! ]
[ 9700 , ," sbiw"    5 6 ri! ]
[ b000 , ," in"      6 4 ri! ]
[ b800 , ," out"     7 4 ri! ]
[ 9000 , ," lds"     8 4 ri! ]
[ 9200 , ," sts"     9 4 ri! ]
[ 900f , ," pop"     a 4 ri! ]
[ 920f , ," push"    a 6 ri! ]
[ 9400 , ," com"     a 4 ri! ]
[ 9401 , ," neg"     a 4 ri! ]
[ 9402 , ," swap"    a 6 ri! ]
[ 9403 , ," inc"     a 4 ri! ]
[ 9405 , ," asr"     a 4 ri! ]
[ 9406 , ," lsr"     a 4 ri! ]
[ 9407 , ," ror"     a 4 ri! ]
[ 940a , ," dec"     a 4 ri! ]
[ 3000 , ," cpi"     b 4 ri! ]
[ 4000 , ," sbci"    b 6 ri! ]
[ 5000 , ," subi"    b 6 ri! ]
[ 6000 , ," ori"     b 4 ri! ]
[ 6000 , ," sbr"     b 4 ri! ]
[ 7000 , ," andi"    b 6 ri! ]
[ 7000 , ," cbr"     b 4 ri! ]
[ e000 , ," ldi"     b 4 ri! ]
[ 0100 , ," movw"    c 6 ri! ]
[ 0c00 , ," lsl"     d 4 ri! ]
[ 1c00 , ," rol"     d 4 ri! ]
[ 2000 , ," tst"     d 4 ri! ]
[ 2400 , ," clr"     d 4 ri! ]
[ 9c00 , ," mul"     e 4 ri! ]
[ 0400 , ," cpc"     e 4 ri! ]
[ 0800 , ," sbc"     e 4 ri! ]
[ 0c00 , ," add"     e 4 ri! ]
[ 1000 , ," cpse"    e 6 ri! ]
[ 1400 , ," cp"      e 4 ri! ]
[ 1800 , ," sub"     e 4 ri! ]
[ 1c00 , ," adc"     e 4 ri! ]
[ 2000 , ," and"     e 4 ri! ]
[ 2400 , ," eor"     e 4 ri! ]
[ 2800 , ," or"      e 4 ri! ]
[ 2c00 , ," mov"     e 4 ri! ]
[ 0000 , ," if"      f 4 ri! ]
[ 0002 , ," then"    f 6 ri! ]
[ 0004 , ," begin"   f 6 ri! ]
[ 0006 , ," until"   f 6 ri! ]
[ 0008 , ," again"   f 6 ri! ]
[ ffff ,
ram

flash create sy1
hex
[ 0 , ," z"  1 , ," z+" ]
[ 2 , ," -z" 8 , ," y"  ]
[ 9 , ," y+"  a , ," -y" ]
[ c , ," x"   d , ," x+" ]
[ e , ," -x"  $ffff ,
ram

flash create sy2
[ f400 , ," cs" ]
[ f400 , ," lo" ]
[ f401 , ," eq" ]
[ f402 , ," mi" ]
[ f403 , ," vs" ]
[ f404 , ," lt" ]
[ f405 , ," hs" ]
[ f406 , ," ts" ]
[ f407 , ," ie" ]
[ f000 , ," cc" ]
[ f000 , ," sh" ]
[ f001 , ," ne" ]
[ f002 , ," pl" ]
[ f003 , ," vc" ]
[ f004 , ," ge" ]
[ f005 , ," hc" ]
[ f006 , ," tc" ]
[ f007 , ," id" ]
[ ffff ,
ram
hex
\
: dsm  ( index -- shift mask ) @ dup f and swap 4 rshift ;
: msi ( code index -- code)   rules dsm >r lshift r> and ;
: split ( code index -- code )
  rules 2+ dsm >r over swap
  lshift fff0 and or r> and ;

: asm ( opc index d/b r/k/a/b -- asm )
  rot >r swap
  r@  msi                     \ dest shifted and masked
  swap r> split               \ resource splitted and masked
  or or ;                     \ opc n2 n1 combined

: sy? ( word table -- address )
  begin
    @+ 1+   \ Fetch from address and increment by 2 ( word table n+1 )
  while
    2dup n=  \ Compares word with table entries
    if   c@+ 7 and + aligned
    else nip 2- exit
    then
  repeat
  drop c@+ type ." ?" abort ;

: op? ( word table -- opc index ) sy? dup @ swap 2+ c@ 4 rshift ;

: bw bl word ;
: N# number? 1- 0= abort" ?" ;
: n# bw N# ;
: yz? dup 7 and 0=      \ y or z needs opcode
  if >r >r >r $efff and \ changed from $9xxx 
     r> r> r>           \ to $8xxx 
  then
;
: d# bw sy1 sy? @ yz? ; \ x, y or z
: r# bw dup 1+ dup c@ 4f - swap c! N# 1f and ;
: c# bw sy2 sy? @ ;

: as1 2+ - 2/ 3 lshift 3f8 and ;
:noname ;                                 \ again
:noname c# >r ihere as1 r> or i, ;        \ until
:noname ihere ;                           \ begin
:noname ihere over as1 over @ or swap ! ; \ then
:noname c# i, ihere 2- ;                  \ if
flash create ask , , , , , ram
:noname r# dup asm ;                \ rule d: rol lsl tst clr (Rd=Rr Only one reg reqd)
:noname r# 2/ r# 2/ asm ;           \ rule c: movw
:noname r# n# asm ;                 \ rule b: cpi sbci subi ori andi ldi (r16-32 only)
:noname r# false asm ;              \ rule a: one param: pop push com neg swap inc asr lsr ror dec
:noname n# >r r# false asm i, r> ;  \ rule 9: sts
:noname r# n# >r false asm i, r> ;  \ rule 8: lds
:noname n# $20 - r# swap asm ;      \ rule 7: out I/O($20-5f) <- Rx
:noname r# n# $20 - asm ;           \ rule 6: in Rx <- I/O($20-5f)
:noname r# 2/ n# asm ;              \ rule 5: adiw sbiw r24 r26 r28 r30 only
:noname d# r# swap asm ;            \ rule 4: st x+ -x y+ -y z+ -z Reg
:noname r# d# asm ;                 \ rule 3: ld Reg x+ -x y+ -y z+ -z
:noname n# $20 - n# asm ;           \ rule 2: cbi sbi sbic sbis I/O:20-3f, bit:0-7
:noname r# n# asm ;                 \ rule 1: bld bst sbrc sbrs R:0-31, bit:0-7
:noname drop ;                      \ rule 0: no params ret sleep wdr
flash create ass , , , , , , , , , , , , , , ram

: as: ( -- )
  bw opcodes op?
  dup f - 0= 
  if drop ask + @ex            \ handle flow control
  else
    dup $e <
    if   dup 2* ass + @ex
    else r# r# asm             \ two params
    then i,
  then
; immediate

decimal

