// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Tue Aug 09 09:27:46 2022
//
// Verilog Description of module C200_PLL
//

module C200_PLL (CLKI, CLKOP, CLKOS, CLKOS2) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(8[8:16])
    input CLKI;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(9[16:20])
    output CLKOP;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(10[17:22])
    output CLKOS;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(11[17:22])
    output CLKOS2;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(12[17:23])
    
    wire CLKI /* synthesis is_clock=1 */ ;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(9[16:20])
    wire CLKOP /* synthesis is_clock=1 */ ;   // c:/users/guoxiang/desktop/fpga/c200/program_formal/c200/c200_fpga_gp22_22080910/c200_fpga_gp22_22080910/c200_fpga/c200_pll/c200_pll.v(10[17:22])
    
    wire scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    EHXPLLL PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKOP), .PHASESEL0(scuba_vlo), 
            .PHASESEL1(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
            .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
            .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), 
            .ENCLKOS2(scuba_vlo), .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP), 
            .CLKOS(CLKOS), .CLKOS2(CLKOS2)) /* synthesis FREQUENCY_PIN_CLKOS2="100.000000", FREQUENCY_PIN_CLKOS="50.000000", FREQUENCY_PIN_CLKOP="25.000000", FREQUENCY_PIN_CLKI="50.000000", ICP_CURRENT="5", LPF_RESISTOR="16", syn_instantiated=1 */ ;
    defparam PLLInst_0.CLKI_DIV = 2;
    defparam PLLInst_0.CLKFB_DIV = 1;
    defparam PLLInst_0.CLKOP_DIV = 24;
    defparam PLLInst_0.CLKOS_DIV = 12;
    defparam PLLInst_0.CLKOS2_DIV = 6;
    defparam PLLInst_0.CLKOS3_DIV = 1;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS2_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS3_ENABLE = "DISABLED";
    defparam PLLInst_0.CLKOP_CPHASE = 23;
    defparam PLLInst_0.CLKOS_CPHASE = 11;
    defparam PLLInst_0.CLKOS2_CPHASE = 5;
    defparam PLLInst_0.CLKOS3_CPHASE = 0;
    defparam PLLInst_0.CLKOP_FPHASE = 0;
    defparam PLLInst_0.CLKOS_FPHASE = 0;
    defparam PLLInst_0.CLKOS2_FPHASE = 0;
    defparam PLLInst_0.CLKOS3_FPHASE = 0;
    defparam PLLInst_0.FEEDBK_PATH = "CLKOP";
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

