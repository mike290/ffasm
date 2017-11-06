\ Simple example using 1w.reset & 1w.byte
\ Retrieves temperature from a *single* DS18B20 and prints
\ the temperature
\ Some code marked [c] COPYRIGHT 2012 Bradford J. Rodriguez.
\ See 1wire.frt in Amforth library: /common/lib
\
\ This version modified for flashforth
\ Needs */ from math.txt
\
\ One wire communications (needs ffasm.frt and one_wire.frt to be loaded first)
: c!1w ( send_c -- ) 1w.byte drop ;    \ Send a byte - drop the received byte
: c@1w ( -- recv_c ) $ff 1w.byte ;     \ Receive a byte 

\ Instructs the sensor to accept any command as there is only a single 1-wire device attached. [c]
\ Function commands such as 1w.convert & 1w.getscratch that address a single device require a
\ 1w.skiprom to talk to the only device present on the bus.
: 1w.skiprom ( -- )
   1w.reset if
      $cc c!1w
   then
;

\ Get the contents of the scratchpad onto stack - CRC is ToS. Single sensor only.
: 1w.getscratch 
    ( -- c0 c1 c2 c3 c4 c5 c6 c7 crc ) \ c1 & c0 contain temperature data.
    1w.skiprom
    $be c!1w
    c@1w c@1w c@1w c@1w
    c@1w c@1w c@1w c@1w 
    c@1w 
;

\ Send start conversion code to DS18B20 and wait for maximum time. Single sensor only.
: 1w.convert
    (   --   )
    1w.skiprom
    $44 c!1w           \  Maximum 12 bit conversion delay should be 750mS however
    #780 ms  \  wait 780mS to allow for timing errors e.g. non-crystal clock
;
    
\ Convert c1 & c0 into a single 16 bit number representing hundredths of a degree
\ Note: DS18B20 provides resolution to 0.0625 degC however datasheet
\ specifies device accuracy as only +-0.5degC
: ds18b20.decode
    ( c0 c1  -- T_hundredths)
    8 lshift + \ Combine the two bytes into a single 16 bit cell
    #100 #16 */  \ Convert to hundredths
;

\ Get the temperature in hundredths of a degC (no CRC check)
: temp.get
    (   --  T_hundredths )
    1w.convert 1w.getscratch
    7 for drop next \ Drop CRC and c2 - c7
    ds18b20.decode
;

\ Print a signed number n with two digits after the decimal point
\ right justifed by r places e.g 25 5 .2dr | 0.25   -12 7 2d.r |  -0.12
: .2dr 
    ( n r --   )
    >r s>d \ Save justification & convert to double
    swap over dabs \ Save sign & convert to absolute
    <# # # [char] . hold  #s rot sign #> \ Convert 2 digits, insert "." and convert rest & sign
    r> over - spaces type  \ Recover justification and print
;

\ Print the temperature in decimal format e.g. 14.25 degC
: .temp
     (  --  )
    temp.get 7 .2dr ."  degC"  \ Print temperature justified right 7 places
;

