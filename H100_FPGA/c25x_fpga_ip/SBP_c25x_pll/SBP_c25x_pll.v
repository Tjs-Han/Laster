module SBP_c25x_pll (CLKI, CLKOP, CLKOS, CLKOS2) /* synthesis sbp_module */;
input wire  CLKI;
output wire  CLKOP;
output wire  CLKOS;
output wire  CLKOS2;

c25x_pll c25x_pll_inst(.CLKI(CLKI), .CLKOP(CLKOP), .CLKOS(CLKOS), .CLKOS2(CLKOS2)) ;
endmodule
