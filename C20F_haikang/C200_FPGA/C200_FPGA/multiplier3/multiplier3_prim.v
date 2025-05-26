// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Mon Jul 12 11:39:23 2021
//
// Verilog Description of module multiplier3
//

module multiplier3 (Clock, ClkEn, Aclr, DataA, DataB, Result) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(8[8:19])
    input Clock;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(9[16:21])
    input ClkEn;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(10[16:21])
    input Aclr;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(11[16:20])
    input [7:0]DataA;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(12[22:27])
    input [7:0]DataB;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(13[22:27])
    output [15:0]Result;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(14[24:30])
    
    wire Clock /* synthesis is_clock=1, SET_AS_NETWORK=Clock */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(9[16:21])
    
    wire multiplier3_or2_0, multiplier3_or1_0, multiplier3_or2_1, multiplier3_or1_1, 
        multiplier3_or2_2, multiplier3_or1_2, multiplier3_or2_3, multiplier3_or1_3, 
        multiplier3_or2_4, multiplier3_or1_4, multiplier3_or2_5, multiplier3_or1_5, 
        multiplier3_or2_6, multiplier3_or1_6, multiplier3_or2_7, multiplier3_or1_7, 
        multiplier3_or2_8, multiplier3_or1_8, multiplier3_or2_9, multiplier3_or1_9, 
        multiplier3_or2_10, multiplier3_or1_10, multiplier3_or2_11, multiplier3_or1_11, 
        multiplier3_or2_12, multiplier3_or1_12, multiplier3_or2_13, multiplier3_or1_13, 
        multiplier3_or2_14, multiplier3_or1_14, multiplier3_or2_15, multiplier3_or1_15, 
        scuba_vhi, scuba_vlo;
    
    FD1P3DX FF_30 (.D(multiplier3_or2_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[1])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(73[13] 74[23])
    defparam FF_30.GSR = "ENABLED";
    FD1P3DX FF_29 (.D(multiplier3_or2_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[2])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(77[13] 78[23])
    defparam FF_29.GSR = "ENABLED";
    FD1P3DX FF_28 (.D(multiplier3_or2_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[3])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(81[13] 82[23])
    defparam FF_28.GSR = "ENABLED";
    FD1P3DX FF_27 (.D(multiplier3_or2_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[4])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(85[13] 86[23])
    defparam FF_27.GSR = "ENABLED";
    FD1P3DX FF_26 (.D(multiplier3_or2_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[5])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(89[13] 90[23])
    defparam FF_26.GSR = "ENABLED";
    FD1P3DX FF_25 (.D(multiplier3_or2_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[6])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(93[13] 94[23])
    defparam FF_25.GSR = "ENABLED";
    FD1P3DX FF_24 (.D(multiplier3_or2_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[7])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(97[13] 98[23])
    defparam FF_24.GSR = "ENABLED";
    FD1P3DX FF_23 (.D(multiplier3_or2_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[8])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(101[13] 102[23])
    defparam FF_23.GSR = "ENABLED";
    FD1P3DX FF_22 (.D(multiplier3_or2_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[9])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(105[13] 106[23])
    defparam FF_22.GSR = "ENABLED";
    FD1P3DX FF_21 (.D(multiplier3_or2_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[10])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(109[13] 110[24])
    defparam FF_21.GSR = "ENABLED";
    FD1P3DX FF_20 (.D(multiplier3_or2_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[11])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(113[13] 114[24])
    defparam FF_20.GSR = "ENABLED";
    FD1P3DX FF_19 (.D(multiplier3_or2_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[12])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(117[13] 118[24])
    defparam FF_19.GSR = "ENABLED";
    FD1P3DX FF_18 (.D(multiplier3_or2_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[13])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(121[13] 122[24])
    defparam FF_18.GSR = "ENABLED";
    FD1P3DX FF_17 (.D(multiplier3_or2_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[14])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(125[13] 126[24])
    defparam FF_17.GSR = "ENABLED";
    FD1P3DX FF_16 (.D(multiplier3_or2_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[15])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(129[13] 130[24])
    defparam FF_16.GSR = "ENABLED";
    FD1P3DX FF_15 (.D(multiplier3_or1_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_0)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(133[13] 134[31])
    defparam FF_15.GSR = "ENABLED";
    FD1P3DX FF_14 (.D(multiplier3_or1_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_1)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(137[13] 138[31])
    defparam FF_14.GSR = "ENABLED";
    FD1P3DX FF_13 (.D(multiplier3_or1_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_2)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(141[13] 142[31])
    defparam FF_13.GSR = "ENABLED";
    FD1P3DX FF_12 (.D(multiplier3_or1_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_3)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(145[13] 146[31])
    defparam FF_12.GSR = "ENABLED";
    FD1P3DX FF_11 (.D(multiplier3_or1_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_4)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(149[13] 150[31])
    defparam FF_11.GSR = "ENABLED";
    FD1P3DX FF_10 (.D(multiplier3_or1_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_5)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(153[13] 154[31])
    defparam FF_10.GSR = "ENABLED";
    FD1P3DX FF_9 (.D(multiplier3_or1_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_6)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(157[13] 158[31])
    defparam FF_9.GSR = "ENABLED";
    FD1P3DX FF_8 (.D(multiplier3_or1_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_7)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(161[13] 162[31])
    defparam FF_8.GSR = "ENABLED";
    FD1P3DX FF_7 (.D(multiplier3_or1_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_8)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(165[13] 166[31])
    defparam FF_7.GSR = "ENABLED";
    FD1P3DX FF_6 (.D(multiplier3_or1_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_9)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(169[13] 170[31])
    defparam FF_6.GSR = "ENABLED";
    FD1P3DX FF_5 (.D(multiplier3_or1_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_10)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(173[13] 174[32])
    defparam FF_5.GSR = "ENABLED";
    FD1P3DX FF_4 (.D(multiplier3_or1_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_11)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(177[13] 178[32])
    defparam FF_4.GSR = "ENABLED";
    FD1P3DX FF_3 (.D(multiplier3_or1_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_12)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(181[13] 182[32])
    defparam FF_3.GSR = "ENABLED";
    FD1P3DX FF_2 (.D(multiplier3_or1_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_13)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(185[13] 186[32])
    defparam FF_2.GSR = "ENABLED";
    FD1P3DX FF_1 (.D(multiplier3_or1_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_14)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(189[13] 190[32])
    defparam FF_1.GSR = "ENABLED";
    FD1P3DX FF_0 (.D(multiplier3_or1_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier3_or2_15)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(193[13] 194[32])
    defparam FF_0.GSR = "ENABLED";
    VHI scuba_vhi_inst (.Z(scuba_vhi));
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    MULT9X9D dsp_mult_0 (.A8(DataA[7]), .A7(DataA[6]), .A6(DataA[5]), 
            .A5(DataA[4]), .A4(DataA[3]), .A3(DataA[2]), .A2(DataA[1]), 
            .A1(DataA[0]), .A0(scuba_vlo), .B8(DataB[7]), .B7(DataB[6]), 
            .B6(DataB[5]), .B5(DataB[4]), .B4(DataB[3]), .B3(DataB[2]), 
            .B2(DataB[1]), .B1(DataB[0]), .B0(scuba_vlo), .C8(scuba_vlo), 
            .C7(scuba_vlo), .C6(scuba_vlo), .C5(scuba_vlo), .C4(scuba_vlo), 
            .C3(scuba_vlo), .C2(scuba_vlo), .C1(scuba_vlo), .C0(scuba_vlo), 
            .SIGNEDA(scuba_vlo), .SIGNEDB(scuba_vlo), .SOURCEA(scuba_vlo), 
            .SOURCEB(scuba_vlo), .CLK3(scuba_vlo), .CLK2(scuba_vlo), .CLK1(scuba_vlo), 
            .CLK0(Clock), .CE3(scuba_vhi), .CE2(scuba_vhi), .CE1(scuba_vhi), 
            .CE0(ClkEn), .RST3(scuba_vlo), .RST2(scuba_vlo), .RST1(scuba_vlo), 
            .RST0(Aclr), .SRIA8(scuba_vlo), .SRIA7(scuba_vlo), .SRIA6(scuba_vlo), 
            .SRIA5(scuba_vlo), .SRIA4(scuba_vlo), .SRIA3(scuba_vlo), .SRIA2(scuba_vlo), 
            .SRIA1(scuba_vlo), .SRIA0(scuba_vlo), .SRIB8(scuba_vlo), .SRIB7(scuba_vlo), 
            .SRIB6(scuba_vlo), .SRIB5(scuba_vlo), .SRIB4(scuba_vlo), .SRIB3(scuba_vlo), 
            .SRIB2(scuba_vlo), .SRIB1(scuba_vlo), .SRIB0(scuba_vlo), .P17(multiplier3_or1_15), 
            .P16(multiplier3_or1_14), .P15(multiplier3_or1_13), .P14(multiplier3_or1_12), 
            .P13(multiplier3_or1_11), .P12(multiplier3_or1_10), .P11(multiplier3_or1_9), 
            .P10(multiplier3_or1_8), .P9(multiplier3_or1_7), .P8(multiplier3_or1_6), 
            .P7(multiplier3_or1_5), .P6(multiplier3_or1_4), .P5(multiplier3_or1_3), 
            .P4(multiplier3_or1_2), .P3(multiplier3_or1_1), .P2(multiplier3_or1_0)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(226[14] 255[58])
    defparam dsp_mult_0.REG_INPUTA_CLK = "CLK0";
    defparam dsp_mult_0.REG_INPUTA_CE = "CE0";
    defparam dsp_mult_0.REG_INPUTA_RST = "RST0";
    defparam dsp_mult_0.REG_INPUTB_CLK = "CLK0";
    defparam dsp_mult_0.REG_INPUTB_CE = "CE0";
    defparam dsp_mult_0.REG_INPUTB_RST = "RST0";
    defparam dsp_mult_0.REG_INPUTC_CLK = "NONE";
    defparam dsp_mult_0.REG_INPUTC_CE = "CE0";
    defparam dsp_mult_0.REG_INPUTC_RST = "RST0";
    defparam dsp_mult_0.REG_PIPELINE_CLK = "CLK0";
    defparam dsp_mult_0.REG_PIPELINE_CE = "CE0";
    defparam dsp_mult_0.REG_PIPELINE_RST = "RST0";
    defparam dsp_mult_0.REG_OUTPUT_CLK = "CLK0";
    defparam dsp_mult_0.REG_OUTPUT_CE = "CE0";
    defparam dsp_mult_0.REG_OUTPUT_RST = "RST0";
    defparam dsp_mult_0.CLK0_DIV = "ENABLED";
    defparam dsp_mult_0.CLK1_DIV = "ENABLED";
    defparam dsp_mult_0.CLK2_DIV = "ENABLED";
    defparam dsp_mult_0.CLK3_DIV = "ENABLED";
    defparam dsp_mult_0.HIGHSPEED_CLK = "NONE";
    defparam dsp_mult_0.GSR = "ENABLED";
    defparam dsp_mult_0.CAS_MATCH_REG = "FALSE";
    defparam dsp_mult_0.SOURCEB_MODE = "B_SHIFT";
    defparam dsp_mult_0.MULT_BYPASS = "DISABLED";
    defparam dsp_mult_0.RESETMODE = "ASYNC";
    GSR GSR_INST (.GSR(scuba_vhi));
    FD1P3DX FF_31 (.D(multiplier3_or2_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[0])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier3/multiplier3.v(69[13] 70[23])
    defparam FF_31.GSR = "ENABLED";
    PUR PUR_INST (.PUR(scuba_vhi));
    defparam PUR_INST.RST_PULSE = 1;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

