// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Mon Jul 12 11:26:59 2021
//
// Verilog Description of module multiplier2
//

module multiplier2 (Clock, ClkEn, Aclr, DataA, DataB, Result) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(8[8:19])
    input Clock;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(9[16:21])
    input ClkEn;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(10[16:21])
    input Aclr;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(11[16:20])
    input [23:0]DataA;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(12[23:28])
    input [15:0]DataB;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(13[23:28])
    output [39:0]Result;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(14[24:30])
    
    
    wire multiplier2_mult_out_rob_0_17, multiplier2_mult_out_roa_0_17, multiplier2_mult_out_rob_0_16, 
        multiplier2_mult_out_roa_0_16, multiplier2_mult_out_rob_0_15, multiplier2_mult_out_roa_0_15, 
        multiplier2_mult_out_rob_0_14, multiplier2_mult_out_roa_0_14, multiplier2_mult_out_rob_0_13, 
        multiplier2_mult_out_roa_0_13, multiplier2_mult_out_rob_0_12, multiplier2_mult_out_roa_0_12, 
        multiplier2_mult_out_rob_0_11, multiplier2_mult_out_roa_0_11, multiplier2_mult_out_rob_0_10, 
        multiplier2_mult_out_roa_0_10, multiplier2_mult_out_rob_0_9, multiplier2_mult_out_roa_0_9, 
        multiplier2_mult_out_rob_0_8, multiplier2_mult_out_roa_0_8, multiplier2_mult_out_rob_0_7, 
        multiplier2_mult_out_roa_0_7, multiplier2_mult_out_rob_0_6, multiplier2_mult_out_roa_0_6, 
        multiplier2_mult_out_rob_0_5, multiplier2_mult_out_roa_0_5, multiplier2_mult_out_rob_0_4, 
        multiplier2_mult_out_roa_0_4, multiplier2_mult_out_rob_0_3, multiplier2_mult_out_roa_0_3, 
        multiplier2_mult_out_rob_0_2, multiplier2_mult_out_roa_0_2, multiplier2_mult_out_rob_0_1, 
        multiplier2_mult_out_roa_0_1, multiplier2_mult_out_rob_0_0, multiplier2_mult_out_roa_0_0, 
        multiplier2_mult_out_p_0_35, multiplier2_mult_out_p_0_34, multiplier2_mult_out_p_0_33, 
        multiplier2_mult_out_p_0_32, multiplier2_mult_out_p_0_31, multiplier2_mult_out_p_0_30, 
        multiplier2_mult_out_p_0_29, multiplier2_mult_out_p_0_28, multiplier2_mult_out_p_0_27, 
        multiplier2_mult_out_p_0_26, multiplier2_mult_out_p_0_25, multiplier2_mult_out_p_0_24, 
        multiplier2_mult_out_p_0_23, multiplier2_mult_out_p_0_22, multiplier2_mult_out_p_0_21, 
        multiplier2_mult_out_p_0_20, multiplier2_mult_out_p_0_19, multiplier2_mult_out_p_0_18, 
        multiplier2_mult_out_p_0_17, multiplier2_mult_out_p_0_16, multiplier2_mult_out_p_0_15, 
        multiplier2_mult_out_p_0_14, multiplier2_mult_out_p_0_13, multiplier2_mult_out_p_0_12, 
        multiplier2_mult_out_p_0_11, multiplier2_mult_out_p_0_10, multiplier2_mult_out_p_0_9, 
        multiplier2_mult_out_p_0_8, multiplier2_mult_out_p_0_7, multiplier2_mult_out_p_0_6, 
        multiplier2_mult_out_p_0_5, multiplier2_mult_out_p_0_4, multiplier2_mult_out_p_0_3, 
        multiplier2_mult_out_p_0_2, multiplier2_mult_out_p_0_1, multiplier2_mult_out_p_0_0, 
        multiplier2_mult_out_signedp_0, multiplier2_mult_out_rob_1_17, multiplier2_mult_out_roa_1_17, 
        multiplier2_mult_out_rob_1_16, multiplier2_mult_out_roa_1_16, multiplier2_mult_out_rob_1_15, 
        multiplier2_mult_out_roa_1_15, multiplier2_mult_out_rob_1_14, multiplier2_mult_out_roa_1_14, 
        multiplier2_mult_out_rob_1_13, multiplier2_mult_out_roa_1_13, multiplier2_mult_out_rob_1_12, 
        multiplier2_mult_out_roa_1_12, multiplier2_mult_out_rob_1_11, multiplier2_mult_out_roa_1_11, 
        multiplier2_mult_out_rob_1_10, multiplier2_mult_out_roa_1_10, multiplier2_mult_out_rob_1_9, 
        multiplier2_mult_out_roa_1_9, multiplier2_mult_out_rob_1_8, multiplier2_mult_out_roa_1_8, 
        multiplier2_mult_out_rob_1_7, multiplier2_mult_out_roa_1_7, multiplier2_mult_out_rob_1_6, 
        multiplier2_mult_out_roa_1_6, multiplier2_mult_out_rob_1_5, multiplier2_mult_out_roa_1_5, 
        multiplier2_mult_out_rob_1_4, multiplier2_mult_out_roa_1_4, multiplier2_mult_out_rob_1_3, 
        multiplier2_mult_out_roa_1_3, multiplier2_mult_out_rob_1_2, multiplier2_mult_out_roa_1_2, 
        multiplier2_mult_out_rob_1_1, multiplier2_mult_out_roa_1_1, multiplier2_mult_out_rob_1_0, 
        multiplier2_mult_out_roa_1_0, multiplier2_mult_out_p_1_35, multiplier2_mult_out_p_1_34, 
        multiplier2_mult_out_p_1_33, multiplier2_mult_out_p_1_32, multiplier2_mult_out_p_1_31, 
        multiplier2_mult_out_p_1_30, multiplier2_mult_out_p_1_29, multiplier2_mult_out_p_1_28, 
        multiplier2_mult_out_p_1_27, multiplier2_mult_out_p_1_26, multiplier2_mult_out_p_1_25, 
        multiplier2_mult_out_p_1_24, multiplier2_mult_out_p_1_23, multiplier2_mult_out_p_1_22, 
        multiplier2_mult_out_p_1_21, multiplier2_mult_out_p_1_20, multiplier2_mult_out_p_1_19, 
        multiplier2_mult_out_p_1_18, multiplier2_mult_out_p_1_17, multiplier2_mult_out_p_1_16, 
        multiplier2_mult_out_p_1_15, multiplier2_mult_out_p_1_14, multiplier2_mult_out_p_1_13, 
        multiplier2_mult_out_p_1_12, multiplier2_mult_out_p_1_11, multiplier2_mult_out_p_1_10, 
        multiplier2_mult_out_p_1_9, multiplier2_mult_out_p_1_8, multiplier2_mult_out_p_1_7, 
        multiplier2_mult_out_p_1_6, multiplier2_mult_out_p_1_5, multiplier2_mult_out_p_1_4, 
        multiplier2_mult_out_p_1_3, multiplier2_mult_out_p_1_2, multiplier2_mult_out_p_1_1, 
        multiplier2_mult_out_p_1_0, multiplier2_mult_out_signedp_1, scuba_vlo, 
        VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    MULT18X18D dsp_mult_0 (.A17(DataA[23]), .A16(DataA[22]), .A15(DataA[21]), 
            .A14(DataA[20]), .A13(DataA[19]), .A12(DataA[18]), .A11(DataA[17]), 
            .A10(DataA[16]), .A9(DataA[15]), .A8(DataA[14]), .A7(DataA[13]), 
            .A6(DataA[12]), .A5(DataA[11]), .A4(DataA[10]), .A3(DataA[9]), 
            .A2(DataA[8]), .A1(DataA[7]), .A0(DataA[6]), .B17(DataB[15]), 
            .B16(DataB[14]), .B15(DataB[13]), .B14(DataB[12]), .B13(DataB[11]), 
            .B12(DataB[10]), .B11(DataB[9]), .B10(DataB[8]), .B9(DataB[7]), 
            .B8(DataB[6]), .B7(DataB[5]), .B6(DataB[4]), .B5(DataB[3]), 
            .B4(DataB[2]), .B3(DataB[1]), .B2(DataB[0]), .B1(scuba_vlo), 
            .B0(scuba_vlo), .C17(scuba_vlo), .C16(scuba_vlo), .C15(scuba_vlo), 
            .C14(scuba_vlo), .C13(scuba_vlo), .C12(scuba_vlo), .C11(scuba_vlo), 
            .C10(scuba_vlo), .C9(scuba_vlo), .C8(scuba_vlo), .C7(scuba_vlo), 
            .C6(scuba_vlo), .C5(scuba_vlo), .C4(scuba_vlo), .C3(scuba_vlo), 
            .C2(scuba_vlo), .C1(scuba_vlo), .C0(scuba_vlo), .SIGNEDA(scuba_vlo), 
            .SIGNEDB(scuba_vlo), .SOURCEA(scuba_vlo), .SOURCEB(scuba_vlo), 
            .CLK3(scuba_vlo), .CLK2(scuba_vlo), .CLK1(scuba_vlo), .CLK0(Clock), 
            .CE3(VCC_net), .CE2(VCC_net), .CE1(VCC_net), .CE0(ClkEn), 
            .RST3(scuba_vlo), .RST2(scuba_vlo), .RST1(scuba_vlo), .RST0(Aclr), 
            .SRIA17(scuba_vlo), .SRIA16(scuba_vlo), .SRIA15(scuba_vlo), 
            .SRIA14(scuba_vlo), .SRIA13(scuba_vlo), .SRIA12(scuba_vlo), 
            .SRIA11(scuba_vlo), .SRIA10(scuba_vlo), .SRIA9(scuba_vlo), 
            .SRIA8(scuba_vlo), .SRIA7(scuba_vlo), .SRIA6(scuba_vlo), .SRIA5(scuba_vlo), 
            .SRIA4(scuba_vlo), .SRIA3(scuba_vlo), .SRIA2(scuba_vlo), .SRIA1(scuba_vlo), 
            .SRIA0(scuba_vlo), .SRIB17(scuba_vlo), .SRIB16(scuba_vlo), 
            .SRIB15(scuba_vlo), .SRIB14(scuba_vlo), .SRIB13(scuba_vlo), 
            .SRIB12(scuba_vlo), .SRIB11(scuba_vlo), .SRIB10(scuba_vlo), 
            .SRIB9(scuba_vlo), .SRIB8(scuba_vlo), .SRIB7(scuba_vlo), .SRIB6(scuba_vlo), 
            .SRIB5(scuba_vlo), .SRIB4(scuba_vlo), .SRIB3(scuba_vlo), .SRIB2(scuba_vlo), 
            .SRIB1(scuba_vlo), .SRIB0(scuba_vlo), .ROA17(multiplier2_mult_out_roa_1_17), 
            .ROA16(multiplier2_mult_out_roa_1_16), .ROA15(multiplier2_mult_out_roa_1_15), 
            .ROA14(multiplier2_mult_out_roa_1_14), .ROA13(multiplier2_mult_out_roa_1_13), 
            .ROA12(multiplier2_mult_out_roa_1_12), .ROA11(multiplier2_mult_out_roa_1_11), 
            .ROA10(multiplier2_mult_out_roa_1_10), .ROA9(multiplier2_mult_out_roa_1_9), 
            .ROA8(multiplier2_mult_out_roa_1_8), .ROA7(multiplier2_mult_out_roa_1_7), 
            .ROA6(multiplier2_mult_out_roa_1_6), .ROA5(multiplier2_mult_out_roa_1_5), 
            .ROA4(multiplier2_mult_out_roa_1_4), .ROA3(multiplier2_mult_out_roa_1_3), 
            .ROA2(multiplier2_mult_out_roa_1_2), .ROA1(multiplier2_mult_out_roa_1_1), 
            .ROA0(multiplier2_mult_out_roa_1_0), .ROB17(multiplier2_mult_out_rob_1_17), 
            .ROB16(multiplier2_mult_out_rob_1_16), .ROB15(multiplier2_mult_out_rob_1_15), 
            .ROB14(multiplier2_mult_out_rob_1_14), .ROB13(multiplier2_mult_out_rob_1_13), 
            .ROB12(multiplier2_mult_out_rob_1_12), .ROB11(multiplier2_mult_out_rob_1_11), 
            .ROB10(multiplier2_mult_out_rob_1_10), .ROB9(multiplier2_mult_out_rob_1_9), 
            .ROB8(multiplier2_mult_out_rob_1_8), .ROB7(multiplier2_mult_out_rob_1_7), 
            .ROB6(multiplier2_mult_out_rob_1_6), .ROB5(multiplier2_mult_out_rob_1_5), 
            .ROB4(multiplier2_mult_out_rob_1_4), .ROB3(multiplier2_mult_out_rob_1_3), 
            .ROB2(multiplier2_mult_out_rob_1_2), .ROB1(multiplier2_mult_out_rob_1_1), 
            .ROB0(multiplier2_mult_out_rob_1_0), .P35(multiplier2_mult_out_p_1_35), 
            .P34(multiplier2_mult_out_p_1_34), .P33(multiplier2_mult_out_p_1_33), 
            .P32(multiplier2_mult_out_p_1_32), .P31(multiplier2_mult_out_p_1_31), 
            .P30(multiplier2_mult_out_p_1_30), .P29(multiplier2_mult_out_p_1_29), 
            .P28(multiplier2_mult_out_p_1_28), .P27(multiplier2_mult_out_p_1_27), 
            .P26(multiplier2_mult_out_p_1_26), .P25(multiplier2_mult_out_p_1_25), 
            .P24(multiplier2_mult_out_p_1_24), .P23(multiplier2_mult_out_p_1_23), 
            .P22(multiplier2_mult_out_p_1_22), .P21(multiplier2_mult_out_p_1_21), 
            .P20(multiplier2_mult_out_p_1_20), .P19(multiplier2_mult_out_p_1_19), 
            .P18(multiplier2_mult_out_p_1_18), .P17(multiplier2_mult_out_p_1_17), 
            .P16(multiplier2_mult_out_p_1_16), .P15(multiplier2_mult_out_p_1_15), 
            .P14(multiplier2_mult_out_p_1_14), .P13(multiplier2_mult_out_p_1_13), 
            .P12(multiplier2_mult_out_p_1_12), .P11(multiplier2_mult_out_p_1_11), 
            .P10(multiplier2_mult_out_p_1_10), .P9(multiplier2_mult_out_p_1_9), 
            .P8(multiplier2_mult_out_p_1_8), .P7(multiplier2_mult_out_p_1_7), 
            .P6(multiplier2_mult_out_p_1_6), .P5(multiplier2_mult_out_p_1_5), 
            .P4(multiplier2_mult_out_p_1_4), .P3(multiplier2_mult_out_p_1_3), 
            .P2(multiplier2_mult_out_p_1_2), .P1(multiplier2_mult_out_p_1_1), 
            .P0(multiplier2_mult_out_p_1_0), .SIGNEDP(multiplier2_mult_out_signedp_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(616[16] 686[50])
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
    defparam dsp_mult_0.REG_OUTPUT_CLK = "NONE";
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
    ALU54B dsp_alu_0 (.CE3(VCC_net), .CE2(VCC_net), .CE1(VCC_net), .CE0(ClkEn), 
           .CLK3(scuba_vlo), .CLK2(scuba_vlo), .CLK1(Clock), .CLK0(Clock), 
           .RST3(scuba_vlo), .RST2(scuba_vlo), .RST1(scuba_vlo), .RST0(Aclr), 
           .SIGNEDIA(multiplier2_mult_out_signedp_0), .SIGNEDIB(multiplier2_mult_out_signedp_1), 
           .SIGNEDCIN(scuba_vlo), .A35(multiplier2_mult_out_rob_0_17), .A34(multiplier2_mult_out_rob_0_16), 
           .A33(multiplier2_mult_out_rob_0_15), .A32(multiplier2_mult_out_rob_0_14), 
           .A31(multiplier2_mult_out_rob_0_13), .A30(multiplier2_mult_out_rob_0_12), 
           .A29(multiplier2_mult_out_rob_0_11), .A28(multiplier2_mult_out_rob_0_10), 
           .A27(multiplier2_mult_out_rob_0_9), .A26(multiplier2_mult_out_rob_0_8), 
           .A25(multiplier2_mult_out_rob_0_7), .A24(multiplier2_mult_out_rob_0_6), 
           .A23(multiplier2_mult_out_rob_0_5), .A22(multiplier2_mult_out_rob_0_4), 
           .A21(multiplier2_mult_out_rob_0_3), .A20(multiplier2_mult_out_rob_0_2), 
           .A19(multiplier2_mult_out_rob_0_1), .A18(multiplier2_mult_out_rob_0_0), 
           .A17(multiplier2_mult_out_roa_0_17), .A16(multiplier2_mult_out_roa_0_16), 
           .A15(multiplier2_mult_out_roa_0_15), .A14(multiplier2_mult_out_roa_0_14), 
           .A13(multiplier2_mult_out_roa_0_13), .A12(multiplier2_mult_out_roa_0_12), 
           .A11(multiplier2_mult_out_roa_0_11), .A10(multiplier2_mult_out_roa_0_10), 
           .A9(multiplier2_mult_out_roa_0_9), .A8(multiplier2_mult_out_roa_0_8), 
           .A7(multiplier2_mult_out_roa_0_7), .A6(multiplier2_mult_out_roa_0_6), 
           .A5(multiplier2_mult_out_roa_0_5), .A4(multiplier2_mult_out_roa_0_4), 
           .A3(multiplier2_mult_out_roa_0_3), .A2(multiplier2_mult_out_roa_0_2), 
           .A1(multiplier2_mult_out_roa_0_1), .A0(multiplier2_mult_out_roa_0_0), 
           .B35(multiplier2_mult_out_rob_1_17), .B34(multiplier2_mult_out_rob_1_16), 
           .B33(multiplier2_mult_out_rob_1_15), .B32(multiplier2_mult_out_rob_1_14), 
           .B31(multiplier2_mult_out_rob_1_13), .B30(multiplier2_mult_out_rob_1_12), 
           .B29(multiplier2_mult_out_rob_1_11), .B28(multiplier2_mult_out_rob_1_10), 
           .B27(multiplier2_mult_out_rob_1_9), .B26(multiplier2_mult_out_rob_1_8), 
           .B25(multiplier2_mult_out_rob_1_7), .B24(multiplier2_mult_out_rob_1_6), 
           .B23(multiplier2_mult_out_rob_1_5), .B22(multiplier2_mult_out_rob_1_4), 
           .B21(multiplier2_mult_out_rob_1_3), .B20(multiplier2_mult_out_rob_1_2), 
           .B19(multiplier2_mult_out_rob_1_1), .B18(multiplier2_mult_out_rob_1_0), 
           .B17(multiplier2_mult_out_roa_1_17), .B16(multiplier2_mult_out_roa_1_16), 
           .B15(multiplier2_mult_out_roa_1_15), .B14(multiplier2_mult_out_roa_1_14), 
           .B13(multiplier2_mult_out_roa_1_13), .B12(multiplier2_mult_out_roa_1_12), 
           .B11(multiplier2_mult_out_roa_1_11), .B10(multiplier2_mult_out_roa_1_10), 
           .B9(multiplier2_mult_out_roa_1_9), .B8(multiplier2_mult_out_roa_1_8), 
           .B7(multiplier2_mult_out_roa_1_7), .B6(multiplier2_mult_out_roa_1_6), 
           .B5(multiplier2_mult_out_roa_1_5), .B4(multiplier2_mult_out_roa_1_4), 
           .B3(multiplier2_mult_out_roa_1_3), .B2(multiplier2_mult_out_roa_1_2), 
           .B1(multiplier2_mult_out_roa_1_1), .B0(multiplier2_mult_out_roa_1_0), 
           .C53(scuba_vlo), .C52(scuba_vlo), .C51(scuba_vlo), .C50(scuba_vlo), 
           .C49(scuba_vlo), .C48(scuba_vlo), .C47(scuba_vlo), .C46(scuba_vlo), 
           .C45(scuba_vlo), .C44(scuba_vlo), .C43(scuba_vlo), .C42(scuba_vlo), 
           .C41(scuba_vlo), .C40(scuba_vlo), .C39(scuba_vlo), .C38(scuba_vlo), 
           .C37(scuba_vlo), .C36(scuba_vlo), .C35(scuba_vlo), .C34(scuba_vlo), 
           .C33(scuba_vlo), .C32(scuba_vlo), .C31(scuba_vlo), .C30(scuba_vlo), 
           .C29(scuba_vlo), .C28(scuba_vlo), .C27(scuba_vlo), .C26(scuba_vlo), 
           .C25(scuba_vlo), .C24(scuba_vlo), .C23(scuba_vlo), .C22(scuba_vlo), 
           .C21(scuba_vlo), .C20(scuba_vlo), .C19(scuba_vlo), .C18(scuba_vlo), 
           .C17(scuba_vlo), .C16(scuba_vlo), .C15(scuba_vlo), .C14(scuba_vlo), 
           .C13(scuba_vlo), .C12(scuba_vlo), .C11(scuba_vlo), .C10(scuba_vlo), 
           .C9(scuba_vlo), .C8(scuba_vlo), .C7(scuba_vlo), .C6(scuba_vlo), 
           .C5(scuba_vlo), .C4(scuba_vlo), .C3(scuba_vlo), .C2(scuba_vlo), 
           .C1(scuba_vlo), .C0(scuba_vlo), .CFB53(scuba_vlo), .CFB52(scuba_vlo), 
           .CFB51(scuba_vlo), .CFB50(scuba_vlo), .CFB49(scuba_vlo), .CFB48(scuba_vlo), 
           .CFB47(scuba_vlo), .CFB46(scuba_vlo), .CFB45(scuba_vlo), .CFB44(scuba_vlo), 
           .CFB43(scuba_vlo), .CFB42(scuba_vlo), .CFB41(scuba_vlo), .CFB40(scuba_vlo), 
           .CFB39(scuba_vlo), .CFB38(scuba_vlo), .CFB37(scuba_vlo), .CFB36(scuba_vlo), 
           .CFB35(scuba_vlo), .CFB34(scuba_vlo), .CFB33(scuba_vlo), .CFB32(scuba_vlo), 
           .CFB31(scuba_vlo), .CFB30(scuba_vlo), .CFB29(scuba_vlo), .CFB28(scuba_vlo), 
           .CFB27(scuba_vlo), .CFB26(scuba_vlo), .CFB25(scuba_vlo), .CFB24(scuba_vlo), 
           .CFB23(scuba_vlo), .CFB22(scuba_vlo), .CFB21(scuba_vlo), .CFB20(scuba_vlo), 
           .CFB19(scuba_vlo), .CFB18(scuba_vlo), .CFB17(scuba_vlo), .CFB16(scuba_vlo), 
           .CFB15(scuba_vlo), .CFB14(scuba_vlo), .CFB13(scuba_vlo), .CFB12(scuba_vlo), 
           .CFB11(scuba_vlo), .CFB10(scuba_vlo), .CFB9(scuba_vlo), .CFB8(scuba_vlo), 
           .CFB7(scuba_vlo), .CFB6(scuba_vlo), .CFB5(scuba_vlo), .CFB4(scuba_vlo), 
           .CFB3(scuba_vlo), .CFB2(scuba_vlo), .CFB1(scuba_vlo), .CFB0(scuba_vlo), 
           .MA35(multiplier2_mult_out_p_0_35), .MA34(multiplier2_mult_out_p_0_34), 
           .MA33(multiplier2_mult_out_p_0_33), .MA32(multiplier2_mult_out_p_0_32), 
           .MA31(multiplier2_mult_out_p_0_31), .MA30(multiplier2_mult_out_p_0_30), 
           .MA29(multiplier2_mult_out_p_0_29), .MA28(multiplier2_mult_out_p_0_28), 
           .MA27(multiplier2_mult_out_p_0_27), .MA26(multiplier2_mult_out_p_0_26), 
           .MA25(multiplier2_mult_out_p_0_25), .MA24(multiplier2_mult_out_p_0_24), 
           .MA23(multiplier2_mult_out_p_0_23), .MA22(multiplier2_mult_out_p_0_22), 
           .MA21(multiplier2_mult_out_p_0_21), .MA20(multiplier2_mult_out_p_0_20), 
           .MA19(multiplier2_mult_out_p_0_19), .MA18(multiplier2_mult_out_p_0_18), 
           .MA17(multiplier2_mult_out_p_0_17), .MA16(multiplier2_mult_out_p_0_16), 
           .MA15(multiplier2_mult_out_p_0_15), .MA14(multiplier2_mult_out_p_0_14), 
           .MA13(multiplier2_mult_out_p_0_13), .MA12(multiplier2_mult_out_p_0_12), 
           .MA11(multiplier2_mult_out_p_0_11), .MA10(multiplier2_mult_out_p_0_10), 
           .MA9(multiplier2_mult_out_p_0_9), .MA8(multiplier2_mult_out_p_0_8), 
           .MA7(multiplier2_mult_out_p_0_7), .MA6(multiplier2_mult_out_p_0_6), 
           .MA5(multiplier2_mult_out_p_0_5), .MA4(multiplier2_mult_out_p_0_4), 
           .MA3(multiplier2_mult_out_p_0_3), .MA2(multiplier2_mult_out_p_0_2), 
           .MA1(multiplier2_mult_out_p_0_1), .MA0(multiplier2_mult_out_p_0_0), 
           .MB35(multiplier2_mult_out_p_1_35), .MB34(multiplier2_mult_out_p_1_34), 
           .MB33(multiplier2_mult_out_p_1_33), .MB32(multiplier2_mult_out_p_1_32), 
           .MB31(multiplier2_mult_out_p_1_31), .MB30(multiplier2_mult_out_p_1_30), 
           .MB29(multiplier2_mult_out_p_1_29), .MB28(multiplier2_mult_out_p_1_28), 
           .MB27(multiplier2_mult_out_p_1_27), .MB26(multiplier2_mult_out_p_1_26), 
           .MB25(multiplier2_mult_out_p_1_25), .MB24(multiplier2_mult_out_p_1_24), 
           .MB23(multiplier2_mult_out_p_1_23), .MB22(multiplier2_mult_out_p_1_22), 
           .MB21(multiplier2_mult_out_p_1_21), .MB20(multiplier2_mult_out_p_1_20), 
           .MB19(multiplier2_mult_out_p_1_19), .MB18(multiplier2_mult_out_p_1_18), 
           .MB17(multiplier2_mult_out_p_1_17), .MB16(multiplier2_mult_out_p_1_16), 
           .MB15(multiplier2_mult_out_p_1_15), .MB14(multiplier2_mult_out_p_1_14), 
           .MB13(multiplier2_mult_out_p_1_13), .MB12(multiplier2_mult_out_p_1_12), 
           .MB11(multiplier2_mult_out_p_1_11), .MB10(multiplier2_mult_out_p_1_10), 
           .MB9(multiplier2_mult_out_p_1_9), .MB8(multiplier2_mult_out_p_1_8), 
           .MB7(multiplier2_mult_out_p_1_7), .MB6(multiplier2_mult_out_p_1_6), 
           .MB5(multiplier2_mult_out_p_1_5), .MB4(multiplier2_mult_out_p_1_4), 
           .MB3(multiplier2_mult_out_p_1_3), .MB2(multiplier2_mult_out_p_1_2), 
           .MB1(multiplier2_mult_out_p_1_1), .MB0(multiplier2_mult_out_p_1_0), 
           .CIN53(scuba_vlo), .CIN52(scuba_vlo), .CIN51(scuba_vlo), .CIN50(scuba_vlo), 
           .CIN49(scuba_vlo), .CIN48(scuba_vlo), .CIN47(scuba_vlo), .CIN46(scuba_vlo), 
           .CIN45(scuba_vlo), .CIN44(scuba_vlo), .CIN43(scuba_vlo), .CIN42(scuba_vlo), 
           .CIN41(scuba_vlo), .CIN40(scuba_vlo), .CIN39(scuba_vlo), .CIN38(scuba_vlo), 
           .CIN37(scuba_vlo), .CIN36(scuba_vlo), .CIN35(scuba_vlo), .CIN34(scuba_vlo), 
           .CIN33(scuba_vlo), .CIN32(scuba_vlo), .CIN31(scuba_vlo), .CIN30(scuba_vlo), 
           .CIN29(scuba_vlo), .CIN28(scuba_vlo), .CIN27(scuba_vlo), .CIN26(scuba_vlo), 
           .CIN25(scuba_vlo), .CIN24(scuba_vlo), .CIN23(scuba_vlo), .CIN22(scuba_vlo), 
           .CIN21(scuba_vlo), .CIN20(scuba_vlo), .CIN19(scuba_vlo), .CIN18(scuba_vlo), 
           .CIN17(scuba_vlo), .CIN16(scuba_vlo), .CIN15(scuba_vlo), .CIN14(scuba_vlo), 
           .CIN13(scuba_vlo), .CIN12(scuba_vlo), .CIN11(scuba_vlo), .CIN10(scuba_vlo), 
           .CIN9(scuba_vlo), .CIN8(scuba_vlo), .CIN7(scuba_vlo), .CIN6(scuba_vlo), 
           .CIN5(scuba_vlo), .CIN4(scuba_vlo), .CIN3(scuba_vlo), .CIN2(scuba_vlo), 
           .CIN1(scuba_vlo), .CIN0(scuba_vlo), .OP10(scuba_vlo), .OP9(VCC_net), 
           .OP8(scuba_vlo), .OP7(scuba_vlo), .OP6(scuba_vlo), .OP5(scuba_vlo), 
           .OP4(scuba_vlo), .OP3(scuba_vlo), .OP2(scuba_vlo), .OP1(scuba_vlo), 
           .OP0(VCC_net), .R53(Result[39]), .R52(Result[38]), .R51(Result[37]), 
           .R50(Result[36]), .R49(Result[35]), .R48(Result[34]), .R47(Result[33]), 
           .R46(Result[32]), .R45(Result[31]), .R44(Result[30]), .R43(Result[29]), 
           .R42(Result[28]), .R41(Result[27]), .R40(Result[26]), .R39(Result[25]), 
           .R38(Result[24]), .R37(Result[23]), .R36(Result[22]), .R35(Result[21]), 
           .R34(Result[20]), .R33(Result[19]), .R32(Result[18]), .R31(Result[17]), 
           .R30(Result[16]), .R29(Result[15]), .R28(Result[14]), .R27(Result[13]), 
           .R26(Result[12]), .R25(Result[11]), .R24(Result[10]), .R23(Result[9]), 
           .R22(Result[8]), .R21(Result[7]), .R20(Result[6]), .R19(Result[5]), 
           .R18(Result[4]), .R17(Result[3]), .R16(Result[2]), .R15(Result[1]), 
           .R14(Result[0])) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(321[12] 488[110])
    defparam dsp_alu_0.REG_INPUTC0_CLK = "NONE";
    defparam dsp_alu_0.REG_INPUTC0_CE = "CE0";
    defparam dsp_alu_0.REG_INPUTC0_RST = "RST0";
    defparam dsp_alu_0.REG_INPUTC1_CLK = "NONE";
    defparam dsp_alu_0.REG_INPUTC1_CE = "CE0";
    defparam dsp_alu_0.REG_INPUTC1_RST = "RST0";
    defparam dsp_alu_0.REG_OPCODEOP0_0_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEOP0_0_CE = "CE0";
    defparam dsp_alu_0.REG_OPCODEOP0_0_RST = "RST0";
    defparam dsp_alu_0.REG_OPCODEOP1_0_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEOP0_1_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEOP0_1_CE = "CE0";
    defparam dsp_alu_0.REG_OPCODEOP0_1_RST = "RST0";
    defparam dsp_alu_0.REG_OPCODEOP1_1_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEIN_0_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEIN_0_CE = "CE0";
    defparam dsp_alu_0.REG_OPCODEIN_0_RST = "RST0";
    defparam dsp_alu_0.REG_OPCODEIN_1_CLK = "NONE";
    defparam dsp_alu_0.REG_OPCODEIN_1_CE = "CE0";
    defparam dsp_alu_0.REG_OPCODEIN_1_RST = "RST0";
    defparam dsp_alu_0.REG_OUTPUT0_CLK = "CLK0";
    defparam dsp_alu_0.REG_OUTPUT0_CE = "CE0";
    defparam dsp_alu_0.REG_OUTPUT0_RST = "RST0";
    defparam dsp_alu_0.REG_OUTPUT1_CLK = "CLK0";
    defparam dsp_alu_0.REG_OUTPUT1_CE = "CE0";
    defparam dsp_alu_0.REG_OUTPUT1_RST = "RST0";
    defparam dsp_alu_0.REG_FLAG_CLK = "NONE";
    defparam dsp_alu_0.REG_FLAG_CE = "CE0";
    defparam dsp_alu_0.REG_FLAG_RST = "RST0";
    defparam dsp_alu_0.MCPAT_SOURCE = "STATIC";
    defparam dsp_alu_0.MASKPAT_SOURCE = "STATIC";
    defparam dsp_alu_0.MASK01 = "0x00000000000000";
    defparam dsp_alu_0.REG_INPUTCFB_CLK = "NONE";
    defparam dsp_alu_0.REG_INPUTCFB_CE = "CE0";
    defparam dsp_alu_0.REG_INPUTCFB_RST = "RST0";
    defparam dsp_alu_0.CLK0_DIV = "ENABLED";
    defparam dsp_alu_0.CLK1_DIV = "ENABLED";
    defparam dsp_alu_0.CLK2_DIV = "ENABLED";
    defparam dsp_alu_0.CLK3_DIV = "ENABLED";
    defparam dsp_alu_0.MCPAT = "0x00000000000000";
    defparam dsp_alu_0.MASKPAT = "0x00000000000000";
    defparam dsp_alu_0.RNDPAT = "0x00000000000000";
    defparam dsp_alu_0.GSR = "ENABLED";
    defparam dsp_alu_0.RESETMODE = "ASYNC";
    defparam dsp_alu_0.MULT9_MODE = "DISABLED";
    defparam dsp_alu_0.LEGACY = "DISABLED";
    MULT18X18D dsp_mult_1 (.A17(DataA[5]), .A16(DataA[4]), .A15(DataA[3]), 
            .A14(DataA[2]), .A13(DataA[1]), .A12(DataA[0]), .A11(scuba_vlo), 
            .A10(scuba_vlo), .A9(scuba_vlo), .A8(scuba_vlo), .A7(scuba_vlo), 
            .A6(scuba_vlo), .A5(scuba_vlo), .A4(scuba_vlo), .A3(scuba_vlo), 
            .A2(scuba_vlo), .A1(scuba_vlo), .A0(scuba_vlo), .B17(DataB[15]), 
            .B16(DataB[14]), .B15(DataB[13]), .B14(DataB[12]), .B13(DataB[11]), 
            .B12(DataB[10]), .B11(DataB[9]), .B10(DataB[8]), .B9(DataB[7]), 
            .B8(DataB[6]), .B7(DataB[5]), .B6(DataB[4]), .B5(DataB[3]), 
            .B4(DataB[2]), .B3(DataB[1]), .B2(DataB[0]), .B1(scuba_vlo), 
            .B0(scuba_vlo), .C17(scuba_vlo), .C16(scuba_vlo), .C15(scuba_vlo), 
            .C14(scuba_vlo), .C13(scuba_vlo), .C12(scuba_vlo), .C11(scuba_vlo), 
            .C10(scuba_vlo), .C9(scuba_vlo), .C8(scuba_vlo), .C7(scuba_vlo), 
            .C6(scuba_vlo), .C5(scuba_vlo), .C4(scuba_vlo), .C3(scuba_vlo), 
            .C2(scuba_vlo), .C1(scuba_vlo), .C0(scuba_vlo), .SIGNEDA(scuba_vlo), 
            .SIGNEDB(scuba_vlo), .SOURCEA(scuba_vlo), .SOURCEB(scuba_vlo), 
            .CLK3(scuba_vlo), .CLK2(scuba_vlo), .CLK1(scuba_vlo), .CLK0(Clock), 
            .CE3(VCC_net), .CE2(VCC_net), .CE1(VCC_net), .CE0(ClkEn), 
            .RST3(scuba_vlo), .RST2(scuba_vlo), .RST1(scuba_vlo), .RST0(Aclr), 
            .SRIA17(scuba_vlo), .SRIA16(scuba_vlo), .SRIA15(scuba_vlo), 
            .SRIA14(scuba_vlo), .SRIA13(scuba_vlo), .SRIA12(scuba_vlo), 
            .SRIA11(scuba_vlo), .SRIA10(scuba_vlo), .SRIA9(scuba_vlo), 
            .SRIA8(scuba_vlo), .SRIA7(scuba_vlo), .SRIA6(scuba_vlo), .SRIA5(scuba_vlo), 
            .SRIA4(scuba_vlo), .SRIA3(scuba_vlo), .SRIA2(scuba_vlo), .SRIA1(scuba_vlo), 
            .SRIA0(scuba_vlo), .SRIB17(scuba_vlo), .SRIB16(scuba_vlo), 
            .SRIB15(scuba_vlo), .SRIB14(scuba_vlo), .SRIB13(scuba_vlo), 
            .SRIB12(scuba_vlo), .SRIB11(scuba_vlo), .SRIB10(scuba_vlo), 
            .SRIB9(scuba_vlo), .SRIB8(scuba_vlo), .SRIB7(scuba_vlo), .SRIB6(scuba_vlo), 
            .SRIB5(scuba_vlo), .SRIB4(scuba_vlo), .SRIB3(scuba_vlo), .SRIB2(scuba_vlo), 
            .SRIB1(scuba_vlo), .SRIB0(scuba_vlo), .ROA17(multiplier2_mult_out_roa_0_17), 
            .ROA16(multiplier2_mult_out_roa_0_16), .ROA15(multiplier2_mult_out_roa_0_15), 
            .ROA14(multiplier2_mult_out_roa_0_14), .ROA13(multiplier2_mult_out_roa_0_13), 
            .ROA12(multiplier2_mult_out_roa_0_12), .ROA11(multiplier2_mult_out_roa_0_11), 
            .ROA10(multiplier2_mult_out_roa_0_10), .ROA9(multiplier2_mult_out_roa_0_9), 
            .ROA8(multiplier2_mult_out_roa_0_8), .ROA7(multiplier2_mult_out_roa_0_7), 
            .ROA6(multiplier2_mult_out_roa_0_6), .ROA5(multiplier2_mult_out_roa_0_5), 
            .ROA4(multiplier2_mult_out_roa_0_4), .ROA3(multiplier2_mult_out_roa_0_3), 
            .ROA2(multiplier2_mult_out_roa_0_2), .ROA1(multiplier2_mult_out_roa_0_1), 
            .ROA0(multiplier2_mult_out_roa_0_0), .ROB17(multiplier2_mult_out_rob_0_17), 
            .ROB16(multiplier2_mult_out_rob_0_16), .ROB15(multiplier2_mult_out_rob_0_15), 
            .ROB14(multiplier2_mult_out_rob_0_14), .ROB13(multiplier2_mult_out_rob_0_13), 
            .ROB12(multiplier2_mult_out_rob_0_12), .ROB11(multiplier2_mult_out_rob_0_11), 
            .ROB10(multiplier2_mult_out_rob_0_10), .ROB9(multiplier2_mult_out_rob_0_9), 
            .ROB8(multiplier2_mult_out_rob_0_8), .ROB7(multiplier2_mult_out_rob_0_7), 
            .ROB6(multiplier2_mult_out_rob_0_6), .ROB5(multiplier2_mult_out_rob_0_5), 
            .ROB4(multiplier2_mult_out_rob_0_4), .ROB3(multiplier2_mult_out_rob_0_3), 
            .ROB2(multiplier2_mult_out_rob_0_2), .ROB1(multiplier2_mult_out_rob_0_1), 
            .ROB0(multiplier2_mult_out_rob_0_0), .P35(multiplier2_mult_out_p_0_35), 
            .P34(multiplier2_mult_out_p_0_34), .P33(multiplier2_mult_out_p_0_33), 
            .P32(multiplier2_mult_out_p_0_32), .P31(multiplier2_mult_out_p_0_31), 
            .P30(multiplier2_mult_out_p_0_30), .P29(multiplier2_mult_out_p_0_29), 
            .P28(multiplier2_mult_out_p_0_28), .P27(multiplier2_mult_out_p_0_27), 
            .P26(multiplier2_mult_out_p_0_26), .P25(multiplier2_mult_out_p_0_25), 
            .P24(multiplier2_mult_out_p_0_24), .P23(multiplier2_mult_out_p_0_23), 
            .P22(multiplier2_mult_out_p_0_22), .P21(multiplier2_mult_out_p_0_21), 
            .P20(multiplier2_mult_out_p_0_20), .P19(multiplier2_mult_out_p_0_19), 
            .P18(multiplier2_mult_out_p_0_18), .P17(multiplier2_mult_out_p_0_17), 
            .P16(multiplier2_mult_out_p_0_16), .P15(multiplier2_mult_out_p_0_15), 
            .P14(multiplier2_mult_out_p_0_14), .P13(multiplier2_mult_out_p_0_13), 
            .P12(multiplier2_mult_out_p_0_12), .P11(multiplier2_mult_out_p_0_11), 
            .P10(multiplier2_mult_out_p_0_10), .P9(multiplier2_mult_out_p_0_9), 
            .P8(multiplier2_mult_out_p_0_8), .P7(multiplier2_mult_out_p_0_7), 
            .P6(multiplier2_mult_out_p_0_6), .P5(multiplier2_mult_out_p_0_5), 
            .P4(multiplier2_mult_out_p_0_4), .P3(multiplier2_mult_out_p_0_3), 
            .P2(multiplier2_mult_out_p_0_2), .P1(multiplier2_mult_out_p_0_1), 
            .P0(multiplier2_mult_out_p_0_0), .SIGNEDP(multiplier2_mult_out_signedp_0)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga_ms1004/c200_fpga_ms1004_20210712/c200_fpga/multiplier2/multiplier2.v(515[16] 585[50])
    defparam dsp_mult_1.REG_INPUTA_CLK = "CLK0";
    defparam dsp_mult_1.REG_INPUTA_CE = "CE0";
    defparam dsp_mult_1.REG_INPUTA_RST = "RST0";
    defparam dsp_mult_1.REG_INPUTB_CLK = "CLK0";
    defparam dsp_mult_1.REG_INPUTB_CE = "CE0";
    defparam dsp_mult_1.REG_INPUTB_RST = "RST0";
    defparam dsp_mult_1.REG_INPUTC_CLK = "NONE";
    defparam dsp_mult_1.REG_INPUTC_CE = "CE0";
    defparam dsp_mult_1.REG_INPUTC_RST = "RST0";
    defparam dsp_mult_1.REG_PIPELINE_CLK = "CLK0";
    defparam dsp_mult_1.REG_PIPELINE_CE = "CE0";
    defparam dsp_mult_1.REG_PIPELINE_RST = "RST0";
    defparam dsp_mult_1.REG_OUTPUT_CLK = "NONE";
    defparam dsp_mult_1.REG_OUTPUT_CE = "CE0";
    defparam dsp_mult_1.REG_OUTPUT_RST = "RST0";
    defparam dsp_mult_1.CLK0_DIV = "ENABLED";
    defparam dsp_mult_1.CLK1_DIV = "ENABLED";
    defparam dsp_mult_1.CLK2_DIV = "ENABLED";
    defparam dsp_mult_1.CLK3_DIV = "ENABLED";
    defparam dsp_mult_1.HIGHSPEED_CLK = "NONE";
    defparam dsp_mult_1.GSR = "ENABLED";
    defparam dsp_mult_1.CAS_MATCH_REG = "FALSE";
    defparam dsp_mult_1.SOURCEB_MODE = "B_SHIFT";
    defparam dsp_mult_1.MULT_BYPASS = "DISABLED";
    defparam dsp_mult_1.RESETMODE = "ASYNC";
    GSR GSR_INST (.GSR(VCC_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VHI i91 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

