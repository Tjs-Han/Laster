/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.12.0.240.2 */
/* Module Version: 4.9 */
/* E:\tools\Iscc\diamond\3.12\ispfpga\bin\nt64\scuba.exe -w -n multiplier3 -lang verilog -synth lse -bus_exp 7 -bb -arch sa5p00 -type dspmult -simple_portname -widtha 8 -widthb 8 -widthp 16 -PL_stages 3 -input_reg -output_reg -clk0 -ce0 -rst0 -fdc D:/programs/fpga/C200_FPGA_MS1004/C200_FPGA_MS1004_20210712/C200_FPGA/multiplier3/multiplier3.fdc  */
/* Mon Jul 12 11:39:22 2021 */


`timescale 1 ns / 1 ps
module multiplier3 (Clock, ClkEn, Aclr, DataA, DataB, Result)/* synthesis NGD_DRC_MASK=1 */;
    input wire Clock;
    input wire ClkEn;
    input wire Aclr;
    input wire [7:0] DataA;
    input wire [7:0] DataB;
    output wire [15:0] Result;

    wire multiplier3_or2_0;
    wire multiplier3_or1_0;
    wire multiplier3_or2_1;
    wire multiplier3_or1_1;
    wire multiplier3_or2_2;
    wire multiplier3_or1_2;
    wire multiplier3_or2_3;
    wire multiplier3_or1_3;
    wire multiplier3_or2_4;
    wire multiplier3_or1_4;
    wire multiplier3_or2_5;
    wire multiplier3_or1_5;
    wire multiplier3_or2_6;
    wire multiplier3_or1_6;
    wire multiplier3_or2_7;
    wire multiplier3_or1_7;
    wire multiplier3_or2_8;
    wire multiplier3_or1_8;
    wire multiplier3_or2_9;
    wire multiplier3_or1_9;
    wire multiplier3_or2_10;
    wire multiplier3_or1_10;
    wire multiplier3_or2_11;
    wire multiplier3_or1_11;
    wire multiplier3_or2_12;
    wire multiplier3_or1_12;
    wire multiplier3_or2_13;
    wire multiplier3_or1_13;
    wire multiplier3_or2_14;
    wire multiplier3_or1_14;
    wire multiplier3_or2_15;
    wire multiplier3_or1_15;
    wire multiplier3_mult_direct_out_1_17;
    wire multiplier3_mult_direct_out_1_16;
    wire multiplier3_mult_direct_out_1_15;
    wire multiplier3_mult_direct_out_1_14;
    wire multiplier3_mult_direct_out_1_13;
    wire multiplier3_mult_direct_out_1_12;
    wire multiplier3_mult_direct_out_1_11;
    wire multiplier3_mult_direct_out_1_10;
    wire multiplier3_mult_direct_out_1_9;
    wire multiplier3_mult_direct_out_1_8;
    wire multiplier3_mult_direct_out_1_7;
    wire multiplier3_mult_direct_out_1_6;
    wire multiplier3_mult_direct_out_1_5;
    wire multiplier3_mult_direct_out_1_4;
    wire multiplier3_mult_direct_out_1_3;
    wire multiplier3_mult_direct_out_1_2;
    wire multiplier3_mult_direct_out_1_1;
    wire multiplier3_mult_direct_out_1_0;
    wire scuba_vhi;
    wire scuba_vlo;

    FD1P3DX FF_31 (.D(multiplier3_or2_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[0]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_30 (.D(multiplier3_or2_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[1]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_29 (.D(multiplier3_or2_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[2]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_28 (.D(multiplier3_or2_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[3]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_27 (.D(multiplier3_or2_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[4]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_26 (.D(multiplier3_or2_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[5]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_25 (.D(multiplier3_or2_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[6]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_24 (.D(multiplier3_or2_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[7]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_23 (.D(multiplier3_or2_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[8]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_22 (.D(multiplier3_or2_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[9]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_21 (.D(multiplier3_or2_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[10]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_20 (.D(multiplier3_or2_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[11]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_19 (.D(multiplier3_or2_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[12]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_18 (.D(multiplier3_or2_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[13]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_17 (.D(multiplier3_or2_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[14]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_16 (.D(multiplier3_or2_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(Result[15]))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_15 (.D(multiplier3_or1_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_0))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_14 (.D(multiplier3_or1_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_1))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_13 (.D(multiplier3_or1_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_2))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_12 (.D(multiplier3_or1_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_3))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_11 (.D(multiplier3_or1_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_4))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_10 (.D(multiplier3_or1_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_5))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_9 (.D(multiplier3_or1_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_6))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_8 (.D(multiplier3_or1_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_7))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_7 (.D(multiplier3_or1_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_8))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_6 (.D(multiplier3_or1_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_9))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_5 (.D(multiplier3_or1_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_10))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_4 (.D(multiplier3_or1_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_11))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_3 (.D(multiplier3_or1_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_12))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_2 (.D(multiplier3_or1_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_13))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_1 (.D(multiplier3_or1_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_14))
             /* synthesis GSR="ENABLED" */;

    FD1P3DX FF_0 (.D(multiplier3_or1_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
        .Q(multiplier3_or2_15))
             /* synthesis GSR="ENABLED" */;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam dsp_mult_0.CLK3_DIV = "ENABLED" ;
    defparam dsp_mult_0.CLK2_DIV = "ENABLED" ;
    defparam dsp_mult_0.CLK1_DIV = "ENABLED" ;
    defparam dsp_mult_0.CLK0_DIV = "ENABLED" ;
    defparam dsp_mult_0.HIGHSPEED_CLK = "NONE" ;
    defparam dsp_mult_0.REG_INPUTC_RST = "RST0" ;
    defparam dsp_mult_0.REG_INPUTC_CE = "CE0" ;
    defparam dsp_mult_0.REG_INPUTC_CLK = "NONE" ;
    defparam dsp_mult_0.SOURCEB_MODE = "B_SHIFT" ;
    defparam dsp_mult_0.MULT_BYPASS = "DISABLED" ;
    defparam dsp_mult_0.CAS_MATCH_REG = "FALSE" ;
    defparam dsp_mult_0.RESETMODE = "ASYNC" ;
    defparam dsp_mult_0.GSR = "ENABLED" ;
    defparam dsp_mult_0.REG_OUTPUT_RST = "RST0" ;
    defparam dsp_mult_0.REG_OUTPUT_CE = "CE0" ;
    defparam dsp_mult_0.REG_OUTPUT_CLK = "CLK0" ;
    defparam dsp_mult_0.REG_PIPELINE_RST = "RST0" ;
    defparam dsp_mult_0.REG_PIPELINE_CE = "CE0" ;
    defparam dsp_mult_0.REG_PIPELINE_CLK = "CLK0" ;
    defparam dsp_mult_0.REG_INPUTB_RST = "RST0" ;
    defparam dsp_mult_0.REG_INPUTB_CE = "CE0" ;
    defparam dsp_mult_0.REG_INPUTB_CLK = "CLK0" ;
    defparam dsp_mult_0.REG_INPUTA_RST = "RST0" ;
    defparam dsp_mult_0.REG_INPUTA_CE = "CE0" ;
    defparam dsp_mult_0.REG_INPUTA_CLK = "CLK0" ;
    MULT9X9D dsp_mult_0 (.A8(DataA[7]), .A7(DataA[6]), .A6(DataA[5]), .A5(DataA[4]), 
        .A4(DataA[3]), .A3(DataA[2]), .A2(DataA[1]), .A1(DataA[0]), .A0(scuba_vlo), 
        .B8(DataB[7]), .B7(DataB[6]), .B6(DataB[5]), .B5(DataB[4]), .B4(DataB[3]), 
        .B3(DataB[2]), .B2(DataB[1]), .B1(DataB[0]), .B0(scuba_vlo), .C8(scuba_vlo), 
        .C7(scuba_vlo), .C6(scuba_vlo), .C5(scuba_vlo), .C4(scuba_vlo), 
        .C3(scuba_vlo), .C2(scuba_vlo), .C1(scuba_vlo), .C0(scuba_vlo), 
        .SIGNEDA(scuba_vlo), .SIGNEDB(scuba_vlo), .SOURCEA(scuba_vlo), .SOURCEB(scuba_vlo), 
        .CE0(ClkEn), .CE1(scuba_vhi), .CE2(scuba_vhi), .CE3(scuba_vhi), 
        .CLK0(Clock), .CLK1(scuba_vlo), .CLK2(scuba_vlo), .CLK3(scuba_vlo), 
        .RST0(Aclr), .RST1(scuba_vlo), .RST2(scuba_vlo), .RST3(scuba_vlo), 
        .SRIA8(scuba_vlo), .SRIA7(scuba_vlo), .SRIA6(scuba_vlo), .SRIA5(scuba_vlo), 
        .SRIA4(scuba_vlo), .SRIA3(scuba_vlo), .SRIA2(scuba_vlo), .SRIA1(scuba_vlo), 
        .SRIA0(scuba_vlo), .SRIB8(scuba_vlo), .SRIB7(scuba_vlo), .SRIB6(scuba_vlo), 
        .SRIB5(scuba_vlo), .SRIB4(scuba_vlo), .SRIB3(scuba_vlo), .SRIB2(scuba_vlo), 
        .SRIB1(scuba_vlo), .SRIB0(scuba_vlo), .SROA8(), .SROA7(), .SROA6(), 
        .SROA5(), .SROA4(), .SROA3(), .SROA2(), .SROA1(), .SROA0(), .SROB8(), 
        .SROB7(), .SROB6(), .SROB5(), .SROB4(), .SROB3(), .SROB2(), .SROB1(), 
        .SROB0(), .ROA8(), .ROA7(), .ROA6(), .ROA5(), .ROA4(), .ROA3(), 
        .ROA2(), .ROA1(), .ROA0(), .ROB8(), .ROB7(), .ROB6(), .ROB5(), .ROB4(), 
        .ROB3(), .ROB2(), .ROB1(), .ROB0(), .ROC8(), .ROC7(), .ROC6(), .ROC5(), 
        .ROC4(), .ROC3(), .ROC2(), .ROC1(), .ROC0(), .P17(multiplier3_mult_direct_out_1_17), 
        .P16(multiplier3_mult_direct_out_1_16), .P15(multiplier3_mult_direct_out_1_15), 
        .P14(multiplier3_mult_direct_out_1_14), .P13(multiplier3_mult_direct_out_1_13), 
        .P12(multiplier3_mult_direct_out_1_12), .P11(multiplier3_mult_direct_out_1_11), 
        .P10(multiplier3_mult_direct_out_1_10), .P9(multiplier3_mult_direct_out_1_9), 
        .P8(multiplier3_mult_direct_out_1_8), .P7(multiplier3_mult_direct_out_1_7), 
        .P6(multiplier3_mult_direct_out_1_6), .P5(multiplier3_mult_direct_out_1_5), 
        .P4(multiplier3_mult_direct_out_1_4), .P3(multiplier3_mult_direct_out_1_3), 
        .P2(multiplier3_mult_direct_out_1_2), .P1(multiplier3_mult_direct_out_1_1), 
        .P0(multiplier3_mult_direct_out_1_0), .SIGNEDP());

    assign multiplier3_or1_15 = multiplier3_mult_direct_out_1_17;
    assign multiplier3_or1_14 = multiplier3_mult_direct_out_1_16;
    assign multiplier3_or1_13 = multiplier3_mult_direct_out_1_15;
    assign multiplier3_or1_12 = multiplier3_mult_direct_out_1_14;
    assign multiplier3_or1_11 = multiplier3_mult_direct_out_1_13;
    assign multiplier3_or1_10 = multiplier3_mult_direct_out_1_12;
    assign multiplier3_or1_9 = multiplier3_mult_direct_out_1_11;
    assign multiplier3_or1_8 = multiplier3_mult_direct_out_1_10;
    assign multiplier3_or1_7 = multiplier3_mult_direct_out_1_9;
    assign multiplier3_or1_6 = multiplier3_mult_direct_out_1_8;
    assign multiplier3_or1_5 = multiplier3_mult_direct_out_1_7;
    assign multiplier3_or1_4 = multiplier3_mult_direct_out_1_6;
    assign multiplier3_or1_3 = multiplier3_mult_direct_out_1_5;
    assign multiplier3_or1_2 = multiplier3_mult_direct_out_1_4;
    assign multiplier3_or1_1 = multiplier3_mult_direct_out_1_3;
    assign multiplier3_or1_0 = multiplier3_mult_direct_out_1_2;


    // exemplar begin
    // exemplar attribute FF_31 GSR ENABLED
    // exemplar attribute FF_30 GSR ENABLED
    // exemplar attribute FF_29 GSR ENABLED
    // exemplar attribute FF_28 GSR ENABLED
    // exemplar attribute FF_27 GSR ENABLED
    // exemplar attribute FF_26 GSR ENABLED
    // exemplar attribute FF_25 GSR ENABLED
    // exemplar attribute FF_24 GSR ENABLED
    // exemplar attribute FF_23 GSR ENABLED
    // exemplar attribute FF_22 GSR ENABLED
    // exemplar attribute FF_21 GSR ENABLED
    // exemplar attribute FF_20 GSR ENABLED
    // exemplar attribute FF_19 GSR ENABLED
    // exemplar attribute FF_18 GSR ENABLED
    // exemplar attribute FF_17 GSR ENABLED
    // exemplar attribute FF_16 GSR ENABLED
    // exemplar attribute FF_15 GSR ENABLED
    // exemplar attribute FF_14 GSR ENABLED
    // exemplar attribute FF_13 GSR ENABLED
    // exemplar attribute FF_12 GSR ENABLED
    // exemplar attribute FF_11 GSR ENABLED
    // exemplar attribute FF_10 GSR ENABLED
    // exemplar attribute FF_9 GSR ENABLED
    // exemplar attribute FF_8 GSR ENABLED
    // exemplar attribute FF_7 GSR ENABLED
    // exemplar attribute FF_6 GSR ENABLED
    // exemplar attribute FF_5 GSR ENABLED
    // exemplar attribute FF_4 GSR ENABLED
    // exemplar attribute FF_3 GSR ENABLED
    // exemplar attribute FF_2 GSR ENABLED
    // exemplar attribute FF_1 GSR ENABLED
    // exemplar attribute FF_0 GSR ENABLED
    // exemplar end

endmodule
