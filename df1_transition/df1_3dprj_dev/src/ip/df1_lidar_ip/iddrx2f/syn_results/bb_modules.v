`timescale 100 ps/100 ps
module DELAYG (
  A,
  Z
)
;
input A ;
output Z ;
endmodule /* DELAYG */

module IDDRX2F (
  D,
  SCLK,
  ECLK,
  RST,
  ALIGNWD,
  Q3,
  Q2,
  Q1,
  Q0
)
;
input D ;
input SCLK ;
input ECLK ;
input RST ;
input ALIGNWD ;
output Q3 ;
output Q2 ;
output Q1 ;
output Q0 ;
endmodule /* IDDRX2F */

module DLLDELD (
  A,
  DDRDEL,
  LOADN,
  MOVE,
  DIRECTION,
  Z,
  CFLAG
)
;
input A ;
input DDRDEL ;
input LOADN ;
input MOVE ;
input DIRECTION ;
output Z ;
output CFLAG ;
endmodule /* DLLDELD */

module DDRDLLA (
  CLK,
  RST,
  UDDCNTLN,
  FREEZE,
  DDRDEL,
  LOCK,
  DCNTL7,
  DCNTL6,
  DCNTL5,
  DCNTL4,
  DCNTL3,
  DCNTL2,
  DCNTL1,
  DCNTL0
)
;
input CLK ;
input RST ;
input UDDCNTLN ;
input FREEZE ;
output DDRDEL ;
output LOCK ;
output DCNTL7 ;
output DCNTL6 ;
output DCNTL5 ;
output DCNTL4 ;
output DCNTL3 ;
output DCNTL2 ;
output DCNTL1 ;
output DCNTL0 ;
endmodule /* DDRDLLA */

module ECLKSYNCB (
  ECLKI,
  STOP,
  ECLKO
)
;
input ECLKI ;
input STOP ;
output ECLKO ;
endmodule /* ECLKSYNCB */

module CLKDIVF (
  CLKI,
  RST,
  ALIGNWD,
  CDIVX
)
;
input CLKI ;
input RST ;
input ALIGNWD ;
output CDIVX ;
endmodule /* CLKDIVF */

