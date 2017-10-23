\ flashforth ffasm implementation of 1w.reset and 1w.byte
\ Implementation of primitives for communicating with one wire devices
\ such as Maxim DS18B20
\ Expects register substitution of PORTB DDRB OWPIN PINB
\ with literals during upload e.g. by using forthtalk.py
\
\ AUTHORs of original assembler code
\   B. J. Rodriguez (MSP 430)
\   (c) 2012 Bradford J. Rodriguez for the 430 code and API
\   Matthias Trute (AVR Atmega)
\   (c) 2017 mike290 flashforth code for use with forthtalk shell
\
\
-wire
marker -wire

\ Converts uSecs to delay cycles based on processor frequency - Fcy
\ Min & max delay supported depends on processor speed
\ Min: >12MHz:1uS | 8MHz:2uS | 4MHz:3uS | 2Mhz:6uS | 1MHz:13uS
\ Max: 16MHz:4000uS | 8MHz:8000uS | 4MHz:16000uS
\ Example: uS = 6 Fcy = 16000 -> cycs = 22

: uS>cycs  ( uS -- cycs )
  Fcy #1000 */  \ # processor cycles
  dup 6 >       \ Min for overhead
  if
    7 -         \ Correct for overhead
  then          \ Makes short delays more accurate
  2 rshift      \ Unsigned 4/ for delay cycles
  1 max         \ Must be at least 1 cycle
;

\ Delay n cycles where actual delay will be:
\ ((n-1) * 4 + 13)/(Fcy/1000)uSecs [includes literal code]
\ Example:  n=22 Fcy = 16000 -> delay = 6.0625uSecs

: delay  ( n --   )
  
  as: begin
  as:   sbiw r24 1
  as: until eq
  as: ld r24 y+ \ Pop ToS
  as: ld r25 y+
; inlined

\ Resets the one wire device
: 1w.reset (   -- flag )

  as: st -y r25     \ Push ToS
  as: st -y r24     \ R25/R25 ready for flag
  as: sbi DDRB OWPIN
  as: cbi PORTB OWPIN
  [ #450 uS>cycs ] literal delay
  as: in r17 SREG
  as: cli
  as: sbi PORTB OWPIN
  as: cbi DDRB OWPIN
  [  #64 uS>cycs ] literal delay
  as: in r24 PINB
  as: sbrs r24 OWPIN
  as: ldi r25 $ff
  as: out SREG r17
  as: cbi DDRB OWPIN
  as: cbi PORTB OWPIN
  [ #416 uS>cycs ] literal delay
  as: mov r24 r25
;

\ Sends & receives one byte from a one wire device
: 1w.byte  ( c -- c' )

  8 for
    as: cbi PORTB OWPIN
    as: sbi DDRB OWPIN
    as: in r17 SREG
    as: cli
    [ 6 uS>cycs ] literal delay
    as: clc
    as: ror r24
    as: if cs
    as:   sbi PORTB OWPIN
    as:   cbi DDRB OWPIN
    as: then
    [ 9 uS>cycs ] literal delay
    as: in r16 PINB
    as: sbrc r16 OWPIN
    as: ori r24 $80
    [ #51 uS>cycs ] literal delay 
    as: sbi PORTB OWPIN
    as: cbi DDRB OWPIN
    [ 2 uS>cycs ] literal delay
    as: out SREG r17
  next
;

