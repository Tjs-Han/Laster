// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Sun Nov 07 14:09:06 2021
//
// Verilog Description of module c25x_pll
//

module c25x_pll (CLKI, CLKOP, CLKOS, CLKOS2) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(8[8:16])
    input CLKI;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(9[16:20])
    output CLKOP;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(10[17:22])
    output CLKOS;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(11[17:22])
    output CLKOS2;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(12[17:23])
    
    wire CLKI /* synthesis is_clock=1 */ ;   // d:/programs/fpga/c252/c25x_21110116_encoder/c25x_fpga_ip/c25x_pll/c25x_pll.v(9[16:20])
    
    wire CLKFB_t, scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    EHXPLLL PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKFB_t), .PHASESEL0(scuba_vlo), 
            .PHASESEL1(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
            .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
            .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), 
            .ENCLKOS2(scuba_vlo), .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP), 
            .CLKOS(CLKOS), .CLKOS2(CLKOS2), .CLKINTFB(CLKFB_t)) /* synthesis FREQUENCY_PIN_CLKOS2="100.000000", FREQUENCY_PIN_CLKOS="50.000000", FREQUENCY_PIN_CLKOP="50.000000", FREQUENCY_PIN_CLKI="50.000000", ICP_CURRENT="12", LPF_RESISTOR="8", syn_instantiated=1 */ ;
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
    GSR GSR_INST (.GSR(VCC_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VHI i85 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

