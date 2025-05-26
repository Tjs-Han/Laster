// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Tue May 18 13:50:59 2021
//
// Verilog Description of module packet_data_fifo
//

module packet_data_fifo (Data, Clock, WrEn, RdEn, Reset, Q, WCNT, 
            Empty, Full) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(8[8:24])
    input [7:0]Data;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(10[22:26])
    input Clock;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(11[16:21])
    input WrEn;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(12[16:20])
    input RdEn;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(13[16:20])
    input Reset;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(14[16:21])
    output [7:0]Q;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(15[23:24])
    output [11:0]WCNT;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(16[24:28])
    output Empty;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(17[17:22])
    output Full;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(18[17:21])
    
    wire Clock /* synthesis is_clock=1, SET_AS_NETWORK=Clock */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(11[16:21])
    
    wire invout_1, invout_0, rden_i_inv, fcnt_en, empty_d, full_d, 
        ifcount_0, ifcount_1, bdcnt_bctr_ci, ifcount_2, ifcount_3, 
        co0, ifcount_4, ifcount_5, co1, ifcount_6, ifcount_7, co2, 
        ifcount_8, ifcount_9, co3, ifcount_10, ifcount_11, cnt_con, 
        co4, cmp_ci, rden_i, co0_1, co1_1, co2_1, co3_1, co4_1, 
        cmp_le_1, cmp_le_1_c, cmp_ci_1, co0_2, co1_2, co2_2, co3_2, 
        co4_2, wren_i, wren_i_inv, cmp_ge_d1, cmp_ge_d1_c, iwcount_0, 
        iwcount_1, w_ctr_ci, wcount_0, wcount_1, iwcount_2, iwcount_3, 
        co0_3, wcount_2, wcount_3, iwcount_4, iwcount_5, co1_3, 
        wcount_4, wcount_5, iwcount_6, iwcount_7, co2_3, wcount_6, 
        wcount_7, iwcount_8, iwcount_9, co3_3, wcount_8, wcount_9, 
        iwcount_10, iwcount_11, co4_3, wcount_10, wcount_11, ircount_0, 
        ircount_1, r_ctr_ci, rcount_0, rcount_1, ircount_2, ircount_3, 
        co0_4, rcount_2, rcount_3, ircount_4, ircount_5, co1_4, 
        rcount_4, rcount_5, ircount_6, ircount_7, co2_4, rcount_6, 
        rcount_7, ircount_8, ircount_9, co3_4, rcount_8, rcount_9, 
        ircount_10, ircount_11, scuba_vhi, scuba_vlo, co4_4, rcount_10, 
        rcount_11;
    
    FD1P3DX FF_36 (.D(ifcount_1), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[1])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(213[13] 214[22])
    defparam FF_36.GSR = "ENABLED";
    FD1P3DX FF_35 (.D(ifcount_2), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[2])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(217[13] 218[22])
    defparam FF_35.GSR = "ENABLED";
    FD1P3DX FF_34 (.D(ifcount_3), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[3])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(221[13] 222[22])
    defparam FF_34.GSR = "ENABLED";
    FD1P3DX FF_33 (.D(ifcount_4), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[4])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(225[13] 226[22])
    defparam FF_33.GSR = "ENABLED";
    FD1P3DX FF_32 (.D(ifcount_5), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[5])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(229[13] 230[22])
    defparam FF_32.GSR = "ENABLED";
    FD1P3DX FF_31 (.D(ifcount_6), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[6])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(233[13] 234[22])
    defparam FF_31.GSR = "ENABLED";
    FD1P3DX FF_30 (.D(ifcount_7), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[7])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(237[13] 238[22])
    defparam FF_30.GSR = "ENABLED";
    FD1P3DX FF_29 (.D(ifcount_8), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[8])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(241[13] 242[22])
    defparam FF_29.GSR = "ENABLED";
    FD1P3DX FF_28 (.D(ifcount_9), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[9])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(245[13] 246[22])
    defparam FF_28.GSR = "ENABLED";
    FD1P3DX FF_27 (.D(ifcount_10), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[10])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(249[13] 250[23])
    defparam FF_27.GSR = "ENABLED";
    FD1P3DX FF_26 (.D(ifcount_11), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[11])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(253[13] 254[23])
    defparam FF_26.GSR = "ENABLED";
    FD1S3BX FF_25 (.D(empty_d), .CK(Clock), .PD(Reset), .Q(Empty)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(257[13:69])
    defparam FF_25.GSR = "ENABLED";
    FD1S3DX FF_24 (.D(full_d), .CK(Clock), .CD(Reset), .Q(Full)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(260[13:67])
    defparam FF_24.GSR = "ENABLED";
    FD1P3DX FF_23 (.D(iwcount_0), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_0)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(263[13:85])
    defparam FF_23.GSR = "ENABLED";
    FD1P3DX FF_22 (.D(iwcount_1), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_1)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(266[13:85])
    defparam FF_22.GSR = "ENABLED";
    FD1P3DX FF_21 (.D(iwcount_2), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_2)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(269[13:85])
    defparam FF_21.GSR = "ENABLED";
    FD1P3DX FF_20 (.D(iwcount_3), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_3)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(272[13:85])
    defparam FF_20.GSR = "ENABLED";
    FD1P3DX FF_19 (.D(iwcount_4), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_4)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(275[13:85])
    defparam FF_19.GSR = "ENABLED";
    FD1P3DX FF_18 (.D(iwcount_5), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_5)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(278[13:85])
    defparam FF_18.GSR = "ENABLED";
    FD1P3DX FF_17 (.D(iwcount_6), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_6)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(281[13:85])
    defparam FF_17.GSR = "ENABLED";
    FD1P3DX FF_16 (.D(iwcount_7), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_7)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(284[13:85])
    defparam FF_16.GSR = "ENABLED";
    FD1P3DX FF_15 (.D(iwcount_8), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_8)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(287[13:85])
    defparam FF_15.GSR = "ENABLED";
    FD1P3DX FF_14 (.D(iwcount_9), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_9)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(290[13:85])
    defparam FF_14.GSR = "ENABLED";
    FD1P3DX FF_13 (.D(iwcount_10), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_10)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(293[13] 294[23])
    defparam FF_13.GSR = "ENABLED";
    FD1P3DX FF_12 (.D(iwcount_11), .SP(wren_i), .CK(Clock), .CD(Reset), 
            .Q(wcount_11)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(297[13] 298[23])
    defparam FF_12.GSR = "ENABLED";
    FD1P3DX FF_11 (.D(ircount_0), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_0)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(301[13:85])
    defparam FF_11.GSR = "ENABLED";
    FD1P3DX FF_10 (.D(ircount_1), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_1)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(304[13:85])
    defparam FF_10.GSR = "ENABLED";
    FD1P3DX FF_9 (.D(ircount_2), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_2)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(307[13:84])
    defparam FF_9.GSR = "ENABLED";
    FD1P3DX FF_8 (.D(ircount_3), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_3)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(310[13:84])
    defparam FF_8.GSR = "ENABLED";
    FD1P3DX FF_7 (.D(ircount_4), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_4)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(313[13:84])
    defparam FF_7.GSR = "ENABLED";
    FD1P3DX FF_6 (.D(ircount_5), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_5)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(316[13:84])
    defparam FF_6.GSR = "ENABLED";
    FD1P3DX FF_5 (.D(ircount_6), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_6)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(319[13:84])
    defparam FF_5.GSR = "ENABLED";
    FD1P3DX FF_4 (.D(ircount_7), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_7)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(322[13:84])
    defparam FF_4.GSR = "ENABLED";
    FD1P3DX FF_3 (.D(ircount_8), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_8)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(325[13:84])
    defparam FF_3.GSR = "ENABLED";
    FD1P3DX FF_2 (.D(ircount_9), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_9)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(328[13:84])
    defparam FF_2.GSR = "ENABLED";
    FD1P3DX FF_1 (.D(ircount_10), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_10)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(331[13:86])
    defparam FF_1.GSR = "ENABLED";
    FD1P3DX FF_0 (.D(ircount_11), .SP(rden_i), .CK(Clock), .CD(Reset), 
            .Q(rcount_11)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(334[13:86])
    defparam FF_0.GSR = "ENABLED";
    CCU2C bdcnt_bctr_cia (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(cnt_con), .B1(cnt_con), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(bdcnt_bctr_ci)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(341[11] 343[52])
    defparam bdcnt_bctr_cia.INIT0 = 16'b0110011010101010;
    defparam bdcnt_bctr_cia.INIT1 = 16'b0110011010101010;
    defparam bdcnt_bctr_cia.INJECT1_0 = "NO";
    defparam bdcnt_bctr_cia.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_0 (.A0(WCNT[0]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[1]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(bdcnt_bctr_ci), .COUT(co0), .S0(ifcount_0), .S1(ifcount_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(349[11] 351[73])
    defparam bdcnt_bctr_0.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_0.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_0.INJECT1_0 = "NO";
    defparam bdcnt_bctr_0.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_1 (.A0(WCNT[2]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[3]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0), .COUT(co1), .S0(ifcount_2), .S1(ifcount_3)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(357[11] 359[63])
    defparam bdcnt_bctr_1.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_1.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_1.INJECT1_0 = "NO";
    defparam bdcnt_bctr_1.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_2 (.A0(WCNT[4]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[5]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1), .COUT(co2), .S0(ifcount_4), .S1(ifcount_5)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(365[11] 367[63])
    defparam bdcnt_bctr_2.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_2.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_2.INJECT1_0 = "NO";
    defparam bdcnt_bctr_2.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_3 (.A0(WCNT[6]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[7]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2), .COUT(co3), .S0(ifcount_6), .S1(ifcount_7)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(373[11] 375[63])
    defparam bdcnt_bctr_3.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_3.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_3.INJECT1_0 = "NO";
    defparam bdcnt_bctr_3.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_4 (.A0(WCNT[8]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[9]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3), .COUT(co4), .S0(ifcount_8), .S1(ifcount_9)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(381[11] 383[63])
    defparam bdcnt_bctr_4.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_4.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_4.INJECT1_0 = "NO";
    defparam bdcnt_bctr_4.INJECT1_1 = "NO";
    CCU2C bdcnt_bctr_5 (.A0(WCNT[10]), .B0(cnt_con), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[11]), .B1(cnt_con), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4), .S0(ifcount_10), .S1(ifcount_11)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(389[11] 391[65])
    defparam bdcnt_bctr_5.INIT0 = 16'b1001100110101010;
    defparam bdcnt_bctr_5.INIT1 = 16'b1001100110101010;
    defparam bdcnt_bctr_5.INJECT1_0 = "NO";
    defparam bdcnt_bctr_5.INJECT1_1 = "NO";
    CCU2C e_cmp_ci_a (.A0(scuba_vhi), .B0(scuba_vhi), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(cmp_ci)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(397[11] 399[45])
    defparam e_cmp_ci_a.INIT0 = 16'b0110011010101010;
    defparam e_cmp_ci_a.INIT1 = 16'b0110011010101010;
    defparam e_cmp_ci_a.INJECT1_0 = "NO";
    defparam e_cmp_ci_a.INJECT1_1 = "NO";
    CCU2C e_cmp_0 (.A0(rden_i), .B0(WCNT[0]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[1]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(cmp_ci), .COUT(co0_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(405[11] 407[50])
    defparam e_cmp_0.INIT0 = 16'b1001100110101010;
    defparam e_cmp_0.INIT1 = 16'b1001100110101010;
    defparam e_cmp_0.INJECT1_0 = "NO";
    defparam e_cmp_0.INJECT1_1 = "NO";
    CCU2C e_cmp_1 (.A0(scuba_vlo), .B0(WCNT[2]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[3]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_1), .COUT(co1_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(413[11] 415[49])
    defparam e_cmp_1.INIT0 = 16'b1001100110101010;
    defparam e_cmp_1.INIT1 = 16'b1001100110101010;
    defparam e_cmp_1.INJECT1_0 = "NO";
    defparam e_cmp_1.INJECT1_1 = "NO";
    CCU2C e_cmp_2 (.A0(scuba_vlo), .B0(WCNT[4]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[5]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_1), .COUT(co2_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(421[11] 423[49])
    defparam e_cmp_2.INIT0 = 16'b1001100110101010;
    defparam e_cmp_2.INIT1 = 16'b1001100110101010;
    defparam e_cmp_2.INJECT1_0 = "NO";
    defparam e_cmp_2.INJECT1_1 = "NO";
    CCU2C e_cmp_3 (.A0(scuba_vlo), .B0(WCNT[6]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[7]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2_1), .COUT(co3_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(429[11] 431[49])
    defparam e_cmp_3.INIT0 = 16'b1001100110101010;
    defparam e_cmp_3.INIT1 = 16'b1001100110101010;
    defparam e_cmp_3.INJECT1_0 = "NO";
    defparam e_cmp_3.INJECT1_1 = "NO";
    CCU2C e_cmp_4 (.A0(scuba_vlo), .B0(WCNT[8]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[9]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3_1), .COUT(co4_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(437[11] 439[49])
    defparam e_cmp_4.INIT0 = 16'b1001100110101010;
    defparam e_cmp_4.INIT1 = 16'b1001100110101010;
    defparam e_cmp_4.INJECT1_0 = "NO";
    defparam e_cmp_4.INJECT1_1 = "NO";
    CCU2C e_cmp_5 (.A0(scuba_vlo), .B0(WCNT[10]), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(WCNT[11]), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4_1), .COUT(cmp_le_1_c)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(445[11] 447[54])
    defparam e_cmp_5.INIT0 = 16'b1001100110101010;
    defparam e_cmp_5.INIT1 = 16'b1001100110101010;
    defparam e_cmp_5.INJECT1_0 = "NO";
    defparam e_cmp_5.INJECT1_1 = "NO";
    CCU2C a0 (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(cmp_le_1_c), .S0(cmp_le_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(453[11] 455[57])
    defparam a0.INIT0 = 16'b0110011010101010;
    defparam a0.INIT1 = 16'b0110011010101010;
    defparam a0.INJECT1_0 = "NO";
    defparam a0.INJECT1_1 = "NO";
    CCU2C g_cmp_ci_a (.A0(scuba_vhi), .B0(scuba_vhi), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(cmp_ci_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(461[11] 463[47])
    defparam g_cmp_ci_a.INIT0 = 16'b0110011010101010;
    defparam g_cmp_ci_a.INIT1 = 16'b0110011010101010;
    defparam g_cmp_ci_a.INJECT1_0 = "NO";
    defparam g_cmp_ci_a.INJECT1_1 = "NO";
    CCU2C g_cmp_0 (.A0(WCNT[0]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[1]), .B1(wren_i), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(cmp_ci_1), .COUT(co0_2)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(469[11] 471[52])
    defparam g_cmp_0.INIT0 = 16'b1001100110101010;
    defparam g_cmp_0.INIT1 = 16'b1001100110101010;
    defparam g_cmp_0.INJECT1_0 = "NO";
    defparam g_cmp_0.INJECT1_1 = "NO";
    CCU2C g_cmp_1 (.A0(WCNT[2]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[3]), .B1(wren_i), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_2), .COUT(co1_2)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(477[11] 479[49])
    defparam g_cmp_1.INIT0 = 16'b1001100110101010;
    defparam g_cmp_1.INIT1 = 16'b1001100110101010;
    defparam g_cmp_1.INJECT1_0 = "NO";
    defparam g_cmp_1.INJECT1_1 = "NO";
    CCU2C g_cmp_2 (.A0(WCNT[4]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[5]), .B1(wren_i), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_2), .COUT(co2_2)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(485[11] 487[49])
    defparam g_cmp_2.INIT0 = 16'b1001100110101010;
    defparam g_cmp_2.INIT1 = 16'b1001100110101010;
    defparam g_cmp_2.INJECT1_0 = "NO";
    defparam g_cmp_2.INJECT1_1 = "NO";
    CCU2C g_cmp_3 (.A0(WCNT[6]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[7]), .B1(wren_i), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2_2), .COUT(co3_2)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(493[11] 495[49])
    defparam g_cmp_3.INIT0 = 16'b1001100110101010;
    defparam g_cmp_3.INIT1 = 16'b1001100110101010;
    defparam g_cmp_3.INJECT1_0 = "NO";
    defparam g_cmp_3.INJECT1_1 = "NO";
    CCU2C g_cmp_4 (.A0(WCNT[8]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[9]), .B1(wren_i), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3_2), .COUT(co4_2)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(501[11] 503[49])
    defparam g_cmp_4.INIT0 = 16'b1001100110101010;
    defparam g_cmp_4.INIT1 = 16'b1001100110101010;
    defparam g_cmp_4.INJECT1_0 = "NO";
    defparam g_cmp_4.INJECT1_1 = "NO";
    CCU2C g_cmp_5 (.A0(WCNT[10]), .B0(wren_i), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(WCNT[11]), .B1(wren_i_inv), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4_2), .COUT(cmp_ge_d1_c)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(509[11] 511[55])
    defparam g_cmp_5.INIT0 = 16'b1001100110101010;
    defparam g_cmp_5.INIT1 = 16'b1001100110101010;
    defparam g_cmp_5.INJECT1_0 = "NO";
    defparam g_cmp_5.INJECT1_1 = "NO";
    CCU2C a1 (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(cmp_ge_d1_c), .S0(cmp_ge_d1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(517[11] 519[59])
    defparam a1.INIT0 = 16'b0110011010101010;
    defparam a1.INIT1 = 16'b0110011010101010;
    defparam a1.INJECT1_0 = "NO";
    defparam a1.INJECT1_1 = "NO";
    CCU2C w_ctr_cia (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), .D1(scuba_vhi), 
          .COUT(w_ctr_ci)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(525[11] 527[47])
    defparam w_ctr_cia.INIT0 = 16'b0110011010101010;
    defparam w_ctr_cia.INIT1 = 16'b0110011010101010;
    defparam w_ctr_cia.INJECT1_0 = "NO";
    defparam w_ctr_cia.INJECT1_1 = "NO";
    CCU2C w_ctr_0 (.A0(wcount_0), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_1), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(w_ctr_ci), .COUT(co0_3), .S0(iwcount_0), .S1(iwcount_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(533[11] 535[70])
    defparam w_ctr_0.INIT0 = 16'b0110011010101010;
    defparam w_ctr_0.INIT1 = 16'b0110011010101010;
    defparam w_ctr_0.INJECT1_0 = "NO";
    defparam w_ctr_0.INJECT1_1 = "NO";
    CCU2C w_ctr_1 (.A0(wcount_2), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_3), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_3), .COUT(co1_3), .S0(iwcount_2), .S1(iwcount_3)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(541[11] 543[67])
    defparam w_ctr_1.INIT0 = 16'b0110011010101010;
    defparam w_ctr_1.INIT1 = 16'b0110011010101010;
    defparam w_ctr_1.INJECT1_0 = "NO";
    defparam w_ctr_1.INJECT1_1 = "NO";
    CCU2C w_ctr_2 (.A0(wcount_4), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_5), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_3), .COUT(co2_3), .S0(iwcount_4), .S1(iwcount_5)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(549[11] 551[67])
    defparam w_ctr_2.INIT0 = 16'b0110011010101010;
    defparam w_ctr_2.INIT1 = 16'b0110011010101010;
    defparam w_ctr_2.INJECT1_0 = "NO";
    defparam w_ctr_2.INJECT1_1 = "NO";
    CCU2C w_ctr_3 (.A0(wcount_6), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_7), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2_3), .COUT(co3_3), .S0(iwcount_6), .S1(iwcount_7)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(557[11] 559[67])
    defparam w_ctr_3.INIT0 = 16'b0110011010101010;
    defparam w_ctr_3.INIT1 = 16'b0110011010101010;
    defparam w_ctr_3.INJECT1_0 = "NO";
    defparam w_ctr_3.INJECT1_1 = "NO";
    CCU2C w_ctr_4 (.A0(wcount_8), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_9), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3_3), .COUT(co4_3), .S0(iwcount_8), .S1(iwcount_9)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(565[11] 567[67])
    defparam w_ctr_4.INIT0 = 16'b0110011010101010;
    defparam w_ctr_4.INIT1 = 16'b0110011010101010;
    defparam w_ctr_4.INJECT1_0 = "NO";
    defparam w_ctr_4.INJECT1_1 = "NO";
    CCU2C w_ctr_5 (.A0(wcount_10), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_11), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4_3), .S0(iwcount_10), .S1(iwcount_11)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(573[11] 575[69])
    defparam w_ctr_5.INIT0 = 16'b0110011010101010;
    defparam w_ctr_5.INIT1 = 16'b0110011010101010;
    defparam w_ctr_5.INJECT1_0 = "NO";
    defparam w_ctr_5.INJECT1_1 = "NO";
    CCU2C r_ctr_cia (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), .D1(scuba_vhi), 
          .COUT(r_ctr_ci)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(581[11] 583[47])
    defparam r_ctr_cia.INIT0 = 16'b0110011010101010;
    defparam r_ctr_cia.INIT1 = 16'b0110011010101010;
    defparam r_ctr_cia.INJECT1_0 = "NO";
    defparam r_ctr_cia.INJECT1_1 = "NO";
    CCU2C r_ctr_0 (.A0(rcount_0), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_1), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(r_ctr_ci), .COUT(co0_4), .S0(ircount_0), .S1(ircount_1)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(589[11] 591[70])
    defparam r_ctr_0.INIT0 = 16'b0110011010101010;
    defparam r_ctr_0.INIT1 = 16'b0110011010101010;
    defparam r_ctr_0.INJECT1_0 = "NO";
    defparam r_ctr_0.INJECT1_1 = "NO";
    CCU2C r_ctr_1 (.A0(rcount_2), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_3), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_4), .COUT(co1_4), .S0(ircount_2), .S1(ircount_3)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(597[11] 599[67])
    defparam r_ctr_1.INIT0 = 16'b0110011010101010;
    defparam r_ctr_1.INIT1 = 16'b0110011010101010;
    defparam r_ctr_1.INJECT1_0 = "NO";
    defparam r_ctr_1.INJECT1_1 = "NO";
    CCU2C r_ctr_2 (.A0(rcount_4), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_5), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_4), .COUT(co2_4), .S0(ircount_4), .S1(ircount_5)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(605[11] 607[67])
    defparam r_ctr_2.INIT0 = 16'b0110011010101010;
    defparam r_ctr_2.INIT1 = 16'b0110011010101010;
    defparam r_ctr_2.INJECT1_0 = "NO";
    defparam r_ctr_2.INJECT1_1 = "NO";
    CCU2C r_ctr_3 (.A0(rcount_6), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_7), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2_4), .COUT(co3_4), .S0(ircount_6), .S1(ircount_7)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(613[11] 615[67])
    defparam r_ctr_3.INIT0 = 16'b0110011010101010;
    defparam r_ctr_3.INIT1 = 16'b0110011010101010;
    defparam r_ctr_3.INJECT1_0 = "NO";
    defparam r_ctr_3.INJECT1_1 = "NO";
    CCU2C r_ctr_4 (.A0(rcount_8), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_9), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co3_4), .COUT(co4_4), .S0(ircount_8), .S1(ircount_9)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(621[11] 623[67])
    defparam r_ctr_4.INIT0 = 16'b0110011010101010;
    defparam r_ctr_4.INIT1 = 16'b0110011010101010;
    defparam r_ctr_4.INJECT1_0 = "NO";
    defparam r_ctr_4.INJECT1_1 = "NO";
    VHI scuba_vhi_inst (.Z(scuba_vhi));
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    CCU2C r_ctr_5 (.A0(rcount_10), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_11), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co4_4), .S0(ircount_10), .S1(ircount_11)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(633[11] 635[69])
    defparam r_ctr_5.INIT0 = 16'b0110011010101010;
    defparam r_ctr_5.INIT1 = 16'b0110011010101010;
    defparam r_ctr_5.INJECT1_0 = "NO";
    defparam r_ctr_5.INJECT1_1 = "NO";
    GSR GSR_INST (.GSR(scuba_vhi));
    AND2 AND2_t3 (.A(WrEn), .B(invout_1), .Z(wren_i)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(144[10:54])
    INV INV_3 (.A(Full), .Z(invout_1));
    AND2 AND2_t2 (.A(RdEn), .B(invout_0), .Z(rden_i)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(148[10:54])
    INV INV_2 (.A(Empty), .Z(invout_0));
    AND2 AND2_t1 (.A(wren_i), .B(rden_i_inv), .Z(cnt_con)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(152[10:59])
    XOR2 XOR2_t0 (.A(wren_i), .B(rden_i), .Z(fcnt_en)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(154[10:55])
    INV INV_1 (.A(rden_i), .Z(rden_i_inv));
    INV INV_0 (.A(wren_i), .Z(wren_i_inv));
    ROM16X1A LUT4_1 (.AD0(Empty), .AD1(wren_i), .AD2(cmp_le_1), .AD3(scuba_vlo), 
            .DO0(empty_d)) /* synthesis syn_instantiated=1 */ ;
    defparam LUT4_1.initval = 16'b0011001000110010;
    ROM16X1A LUT4_0 (.AD0(Full), .AD1(rden_i), .AD2(cmp_ge_d1), .AD3(scuba_vlo), 
            .DO0(full_d)) /* synthesis syn_instantiated=1 */ ;
    defparam LUT4_0.initval = 16'b0011001000110010;
    DP16KD pdp_ram_0_0_0 (.DIA0(Data[0]), .DIA1(Data[1]), .DIA2(Data[2]), 
           .DIA3(Data[3]), .DIA4(Data[4]), .DIA5(Data[5]), .DIA6(Data[6]), 
           .DIA7(Data[7]), .DIA8(scuba_vlo), .DIA9(scuba_vlo), .DIA10(scuba_vlo), 
           .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
           .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vlo), 
           .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(wcount_0), .ADA4(wcount_1), 
           .ADA5(wcount_2), .ADA6(wcount_3), .ADA7(wcount_4), .ADA8(wcount_5), 
           .ADA9(wcount_6), .ADA10(wcount_7), .ADA11(wcount_8), .ADA12(wcount_9), 
           .ADA13(wcount_10), .CEA(wren_i), .OCEA(wren_i), .CLKA(Clock), 
           .WEA(scuba_vhi), .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), 
           .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), .DIB2(scuba_vlo), 
           .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), 
           .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), 
           .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), 
           .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), 
           .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(rcount_0), .ADB4(rcount_1), 
           .ADB5(rcount_2), .ADB6(rcount_3), .ADB7(rcount_4), .ADB8(rcount_5), 
           .ADB9(rcount_6), .ADB10(rcount_7), .ADB11(rcount_8), .ADB12(rcount_9), 
           .ADB13(rcount_10), .CEB(rden_i), .OCEB(rden_i), .CLKB(Clock), 
           .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), 
           .RSTB(Reset), .DOB0(Q[0]), .DOB1(Q[1]), .DOB2(Q[2]), .DOB3(Q[3]), 
           .DOB4(Q[4]), .DOB5(Q[5]), .DOB6(Q[6]), .DOB7(Q[7])) /* synthesis MEM_LPC_FILE="packet_data_fifo.lpc", MEM_INIT_FILE="", syn_instantiated=1 */ ;
    defparam pdp_ram_0_0_0.DATA_WIDTH_A = 9;
    defparam pdp_ram_0_0_0.DATA_WIDTH_B = 9;
    defparam pdp_ram_0_0_0.REGMODE_A = "NOREG";
    defparam pdp_ram_0_0_0.REGMODE_B = "NOREG";
    defparam pdp_ram_0_0_0.RESETMODE = "SYNC";
    defparam pdp_ram_0_0_0.ASYNC_RESET_RELEASE = "SYNC";
    defparam pdp_ram_0_0_0.WRITEMODE_A = "NORMAL";
    defparam pdp_ram_0_0_0.WRITEMODE_B = "NORMAL";
    defparam pdp_ram_0_0_0.CSDECODE_A = "0b000";
    defparam pdp_ram_0_0_0.CSDECODE_B = "0b000";
    defparam pdp_ram_0_0_0.GSR = "ENABLED";
    defparam pdp_ram_0_0_0.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_20 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_21 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_22 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_23 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_24 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_25 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_26 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_27 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_28 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_29 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_30 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_31 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_32 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_33 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_34 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_35 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_36 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_37 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_38 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_39 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INIT_DATA = "STATIC";
    FD1P3DX FF_37 (.D(ifcount_0), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
            .Q(WCNT[0])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c200_fpga/c200_fpga/packet_data_fifo/packet_data_fifo.v(209[13] 210[22])
    defparam FF_37.GSR = "ENABLED";
    PUR PUR_INST (.PUR(scuba_vhi));
    defparam PUR_INST.RST_PULSE = 1;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

