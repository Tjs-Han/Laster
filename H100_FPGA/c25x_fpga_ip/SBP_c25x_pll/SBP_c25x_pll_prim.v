// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Tue Apr 29 17:07:31 2025
//
// Verilog Description of module SBP_c25x_pll
//

module SBP_c25x_pll (CLKI, CLKOP, CLKOS, CLKOS2) /* synthesis sbp_module=1, syn_module_defined=1 */ ;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(1[8:20])
    input CLKI;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(2[13:17])
    output CLKOP;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(3[14:19])
    output CLKOS;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(4[14:19])
    output CLKOS2;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(5[14:20])
    
    wire CLKI /* synthesis is_clock=1 */ ;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(2[13:17])
    
    wire GND_net, VCC_net;
    
    VHI i48 (.Z(VCC_net));
    GSR GSR_INST (.GSR(VCC_net));
    c25x_pll c25x_pll_inst (.CLKI(CLKI), .CLKOP(CLKOP), .CLKOS(CLKOS), 
            .CLKOS2(CLKOS2), .GND_net(GND_net)) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(7[10:83])
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VLO i4 (.Z(GND_net));
    
endmodule
//
// Verilog Description of module c25x_pll
//

module c25x_pll (CLKI, CLKOP, CLKOS, CLKOS2, GND_net) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;
    input CLKI;
    output CLKOP;
    output CLKOS;
    output CLKOS2;
    input GND_net;
    
    wire CLKI /* synthesis is_clock=1 */ ;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(2[13:17])
    
    wire CLKFB_t;
    
    EHXPLLL PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKFB_t), .PHASESEL0(GND_net), 
            .PHASESEL1(GND_net), .PHASEDIR(GND_net), .PHASESTEP(GND_net), 
            .PHASELOADREG(GND_net), .STDBY(GND_net), .PLLWAKESYNC(GND_net), 
            .RST(GND_net), .ENCLKOP(GND_net), .ENCLKOS(GND_net), .ENCLKOS2(GND_net), 
            .ENCLKOS3(GND_net), .CLKOP(CLKOP), .CLKOS(CLKOS), .CLKOS2(CLKOS2), 
            .CLKINTFB(CLKFB_t)) /* synthesis FREQUENCY_PIN_CLKOS2="100.000000", FREQUENCY_PIN_CLKOS="50.000000", FREQUENCY_PIN_CLKOP="50.000000", FREQUENCY_PIN_CLKI="50.000000", ICP_CURRENT="12", LPF_RESISTOR="8", syn_instantiated=1, LSE_LINE_FILE_ID=71, LSE_LCOL=10, LSE_RCOL=83, LSE_LLINE=7, LSE_RLINE=7 */ ;   // d:/project/h100_fpga/c25x_fpga_ip/sbp_c25x_pll/sbp_c25x_pll.v(7[10:83])
    defparam PLLInst_0.CLKI_DIV = 1;
    defparam PLLInst_0.CLKFB_DIV = 1;
    defparam PLLInst_0.CLKOP_DIV = 12;
    defparam PLLInst_0.CLKOS_DIV = 12;
    defparam PLLInst_0.CLKOS2_DIV = 6;
    defparam PLLInst_0.CLKOS3_DIV = 1;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS2_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS3_ENABLE = "DISABLED";
    defparam PLLInst_0.CLKOP_CPHASE = 11;
    defparam PLLInst_0.CLKOS_CPHASE = 14;
    defparam PLLInst_0.CLKOS2_CPHASE = 5;
    defparam PLLInst_0.CLKOS3_CPHASE = 0;
    defparam PLLInst_0.CLKOP_FPHASE = 0;
    defparam PLLInst_0.CLKOS_FPHASE = 0;
    defparam PLLInst_0.CLKOS2_FPHASE = 0;
    defparam PLLInst_0.CLKOS3_FPHASE = 0;
    defparam PLLInst_0.FEEDBK_PATH = "INT_OP";
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA";
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB";
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC";
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD";
    defparam PLLInst_0.PLL_LOCK_MODE = 0;
    defparam PLLInst_0.PLL_LOCK_DELAY = 200;
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED";
    defparam PLLInst_0.REFIN_RESET = "DISABLED";
    defparam PLLInst_0.SYNC_ENABLE = "DISABLED";
    defparam PLLInst_0.INT_LOCK_STICKY = "ENABLED";
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED";
    defparam PLLInst_0.PLLRST_ENA = "DISABLED";
    defparam PLLInst_0.INTFB_WAKE = "DISABLED";
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

