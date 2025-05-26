// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Thu Sep 02 13:42:46 2021
//
// Verilog Description of module multiplier
//

module multiplier (Clock, ClkEn, Aclr, DataA, DataB, Result) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(8[8:18])
    input Clock;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(9[16:21])
    input ClkEn;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(10[16:21])
    input Aclr;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(11[16:20])
    input [15:0]DataA;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(12[23:28])
    input [15:0]DataB;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(13[23:28])
    output [31:0]Result;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(14[24:30])
    
    wire Clock /* synthesis is_clock=1, SET_AS_NETWORK=Clock */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(9[16:21])
    
    wire multiplier_or2_0, multiplier_or1_0, multiplier_or2_1, multiplier_or1_1, 
        multiplier_or2_2, multiplier_or1_2, multiplier_or2_3, multiplier_or1_3, 
        multiplier_or2_4, multiplier_or1_4, multiplier_or2_5, multiplier_or1_5, 
        multiplier_or2_6, multiplier_or1_6, multiplier_or2_7, multiplier_or1_7, 
        multiplier_or2_8, multiplier_or1_8, multiplier_or2_9, multiplier_or1_9, 
        multiplier_or2_10, multiplier_or1_10, multiplier_or2_11, multiplier_or1_11, 
        multiplier_or2_12, multiplier_or1_12, multiplier_or2_13, multiplier_or1_13, 
        multiplier_or2_14, multiplier_or1_14, multiplier_or2_15, multiplier_or1_15, 
        multiplier_or2_16, multiplier_or1_16, multiplier_or2_17, multiplier_or1_17, 
        multiplier_or2_18, multiplier_or1_18, multiplier_or2_19, multiplier_or1_19, 
        multiplier_or2_20, multiplier_or1_20, multiplier_or2_21, multiplier_or1_21, 
        multiplier_or2_22, multiplier_or1_22, multiplier_or2_23, multiplier_or1_23, 
        multiplier_or2_24, multiplier_or1_24, multiplier_or2_25, multiplier_or1_25, 
        multiplier_or2_26, multiplier_or1_26, multiplier_or2_27, multiplier_or1_27, 
        multiplier_or2_28, multiplier_or1_28, multiplier_or2_29, multiplier_or1_29, 
        multiplier_or2_30, multiplier_or1_30, multiplier_or2_31, multiplier_or1_31, 
        scuba_vhi, scuba_vlo;
    
    FD1P3DX FF_62 (.D(multiplier_or2_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[1])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(123[13] 124[23])
    defparam FF_62.GSR = "ENABLED";
    FD1P3DX FF_61 (.D(multiplier_or2_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[2])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(127[13] 128[23])
    defparam FF_61.GSR = "ENABLED";
    FD1P3DX FF_60 (.D(multiplier_or2_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[3])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(131[13] 132[23])
    defparam FF_60.GSR = "ENABLED";
    FD1P3DX FF_59 (.D(multiplier_or2_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[4])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(135[13] 136[23])
    defparam FF_59.GSR = "ENABLED";
    FD1P3DX FF_58 (.D(multiplier_or2_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[5])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(139[13] 140[23])
    defparam FF_58.GSR = "ENABLED";
    FD1P3DX FF_57 (.D(multiplier_or2_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[6])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(143[13] 144[23])
    defparam FF_57.GSR = "ENABLED";
    FD1P3DX FF_56 (.D(multiplier_or2_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[7])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(147[13] 148[23])
    defparam FF_56.GSR = "ENABLED";
    FD1P3DX FF_55 (.D(multiplier_or2_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[8])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(151[13] 152[23])
    defparam FF_55.GSR = "ENABLED";
    FD1P3DX FF_54 (.D(multiplier_or2_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[9])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(155[13] 156[23])
    defparam FF_54.GSR = "ENABLED";
    FD1P3DX FF_53 (.D(multiplier_or2_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[10])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(159[13] 160[24])
    defparam FF_53.GSR = "ENABLED";
    FD1P3DX FF_52 (.D(multiplier_or2_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[11])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(163[13] 164[24])
    defparam FF_52.GSR = "ENABLED";
    FD1P3DX FF_51 (.D(multiplier_or2_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[12])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(167[13] 168[24])
    defparam FF_51.GSR = "ENABLED";
    FD1P3DX FF_50 (.D(multiplier_or2_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[13])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(171[13] 172[24])
    defparam FF_50.GSR = "ENABLED";
    FD1P3DX FF_49 (.D(multiplier_or2_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[14])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(175[13] 176[24])
    defparam FF_49.GSR = "ENABLED";
    FD1P3DX FF_48 (.D(multiplier_or2_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[15])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(179[13] 180[24])
    defparam FF_48.GSR = "ENABLED";
    FD1P3DX FF_47 (.D(multiplier_or2_16), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[16])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(183[13] 184[24])
    defparam FF_47.GSR = "ENABLED";
    FD1P3DX FF_46 (.D(multiplier_or2_17), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[17])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(187[13] 188[24])
    defparam FF_46.GSR = "ENABLED";
    FD1P3DX FF_45 (.D(multiplier_or2_18), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[18])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(191[13] 192[24])
    defparam FF_45.GSR = "ENABLED";
    FD1P3DX FF_44 (.D(multiplier_or2_19), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[19])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(195[13] 196[24])
    defparam FF_44.GSR = "ENABLED";
    FD1P3DX FF_43 (.D(multiplier_or2_20), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[20])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(199[13] 200[24])
    defparam FF_43.GSR = "ENABLED";
    FD1P3DX FF_42 (.D(multiplier_or2_21), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[21])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(203[13] 204[24])
    defparam FF_42.GSR = "ENABLED";
    FD1P3DX FF_41 (.D(multiplier_or2_22), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[22])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(207[13] 208[24])
    defparam FF_41.GSR = "ENABLED";
    FD1P3DX FF_40 (.D(multiplier_or2_23), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[23])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(211[13] 212[24])
    defparam FF_40.GSR = "ENABLED";
    FD1P3DX FF_39 (.D(multiplier_or2_24), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[24])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(215[13] 216[24])
    defparam FF_39.GSR = "ENABLED";
    FD1P3DX FF_38 (.D(multiplier_or2_25), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[25])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(219[13] 220[24])
    defparam FF_38.GSR = "ENABLED";
    FD1P3DX FF_37 (.D(multiplier_or2_26), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[26])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(223[13] 224[24])
    defparam FF_37.GSR = "ENABLED";
    FD1P3DX FF_36 (.D(multiplier_or2_27), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[27])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(227[13] 228[24])
    defparam FF_36.GSR = "ENABLED";
    FD1P3DX FF_35 (.D(multiplier_or2_28), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[28])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(231[13] 232[24])
    defparam FF_35.GSR = "ENABLED";
    FD1P3DX FF_34 (.D(multiplier_or2_29), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[29])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(235[13] 236[24])
    defparam FF_34.GSR = "ENABLED";
    FD1P3DX FF_33 (.D(multiplier_or2_30), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[30])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(239[13] 240[24])
    defparam FF_33.GSR = "ENABLED";
    FD1P3DX FF_32 (.D(multiplier_or2_31), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[31])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(243[13] 244[24])
    defparam FF_32.GSR = "ENABLED";
    FD1P3DX FF_31 (.D(multiplier_or1_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_0)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(247[13] 248[30])
    defparam FF_31.GSR = "ENABLED";
    FD1P3DX FF_30 (.D(multiplier_or1_1), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_1)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(251[13] 252[30])
    defparam FF_30.GSR = "ENABLED";
    FD1P3DX FF_29 (.D(multiplier_or1_2), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_2)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(255[13] 256[30])
    defparam FF_29.GSR = "ENABLED";
    FD1P3DX FF_28 (.D(multiplier_or1_3), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_3)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(259[13] 260[30])
    defparam FF_28.GSR = "ENABLED";
    FD1P3DX FF_27 (.D(multiplier_or1_4), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_4)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(263[13] 264[30])
    defparam FF_27.GSR = "ENABLED";
    FD1P3DX FF_26 (.D(multiplier_or1_5), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_5)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(267[13] 268[30])
    defparam FF_26.GSR = "ENABLED";
    FD1P3DX FF_25 (.D(multiplier_or1_6), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_6)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(271[13] 272[30])
    defparam FF_25.GSR = "ENABLED";
    FD1P3DX FF_24 (.D(multiplier_or1_7), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_7)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(275[13] 276[30])
    defparam FF_24.GSR = "ENABLED";
    FD1P3DX FF_23 (.D(multiplier_or1_8), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_8)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(279[13] 280[30])
    defparam FF_23.GSR = "ENABLED";
    FD1P3DX FF_22 (.D(multiplier_or1_9), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_9)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(283[13] 284[30])
    defparam FF_22.GSR = "ENABLED";
    FD1P3DX FF_21 (.D(multiplier_or1_10), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_10)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(287[13] 288[31])
    defparam FF_21.GSR = "ENABLED";
    FD1P3DX FF_20 (.D(multiplier_or1_11), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_11)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(291[13] 292[31])
    defparam FF_20.GSR = "ENABLED";
    FD1P3DX FF_19 (.D(multiplier_or1_12), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_12)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(295[13] 296[31])
    defparam FF_19.GSR = "ENABLED";
    FD1P3DX FF_18 (.D(multiplier_or1_13), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_13)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(299[13] 300[31])
    defparam FF_18.GSR = "ENABLED";
    FD1P3DX FF_17 (.D(multiplier_or1_14), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_14)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(303[13] 304[31])
    defparam FF_17.GSR = "ENABLED";
    FD1P3DX FF_16 (.D(multiplier_or1_15), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_15)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(307[13] 308[31])
    defparam FF_16.GSR = "ENABLED";
    FD1P3DX FF_15 (.D(multiplier_or1_16), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_16)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(311[13] 312[31])
    defparam FF_15.GSR = "ENABLED";
    FD1P3DX FF_14 (.D(multiplier_or1_17), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_17)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(315[13] 316[31])
    defparam FF_14.GSR = "ENABLED";
    FD1P3DX FF_13 (.D(multiplier_or1_18), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_18)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(319[13] 320[31])
    defparam FF_13.GSR = "ENABLED";
    FD1P3DX FF_12 (.D(multiplier_or1_19), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_19)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(323[13] 324[31])
    defparam FF_12.GSR = "ENABLED";
    FD1P3DX FF_11 (.D(multiplier_or1_20), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_20)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(327[13] 328[31])
    defparam FF_11.GSR = "ENABLED";
    FD1P3DX FF_10 (.D(multiplier_or1_21), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_21)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(331[13] 332[31])
    defparam FF_10.GSR = "ENABLED";
    FD1P3DX FF_9 (.D(multiplier_or1_22), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_22)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(335[13] 336[31])
    defparam FF_9.GSR = "ENABLED";
    FD1P3DX FF_8 (.D(multiplier_or1_23), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_23)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(339[13] 340[31])
    defparam FF_8.GSR = "ENABLED";
    FD1P3DX FF_7 (.D(multiplier_or1_24), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_24)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(343[13] 344[31])
    defparam FF_7.GSR = "ENABLED";
    FD1P3DX FF_6 (.D(multiplier_or1_25), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_25)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(347[13] 348[31])
    defparam FF_6.GSR = "ENABLED";
    FD1P3DX FF_5 (.D(multiplier_or1_26), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_26)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(351[13] 352[31])
    defparam FF_5.GSR = "ENABLED";
    FD1P3DX FF_4 (.D(multiplier_or1_27), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_27)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(355[13] 356[31])
    defparam FF_4.GSR = "ENABLED";
    FD1P3DX FF_3 (.D(multiplier_or1_28), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_28)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(359[13] 360[31])
    defparam FF_3.GSR = "ENABLED";
    FD1P3DX FF_2 (.D(multiplier_or1_29), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_29)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(363[13] 364[31])
    defparam FF_2.GSR = "ENABLED";
    FD1P3DX FF_1 (.D(multiplier_or1_30), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_30)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(367[13] 368[31])
    defparam FF_1.GSR = "ENABLED";
    FD1P3DX FF_0 (.D(multiplier_or1_31), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(multiplier_or2_31)) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(371[13] 372[31])
    defparam FF_0.GSR = "ENABLED";
    VHI scuba_vhi_inst (.Z(scuba_vhi));
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    MULT18X18D dsp_mult_0 (.A17(DataA[15]), .A16(DataA[14]), .A15(DataA[13]), 
            .A14(DataA[12]), .A13(DataA[11]), .A12(DataA[10]), .A11(DataA[9]), 
            .A10(DataA[8]), .A9(DataA[7]), .A8(DataA[6]), .A7(DataA[5]), 
            .A6(DataA[4]), .A5(DataA[3]), .A4(DataA[2]), .A3(DataA[1]), 
            .A2(DataA[0]), .A1(scuba_vlo), .A0(scuba_vlo), .B17(DataB[15]), 
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
            .CE3(scuba_vhi), .CE2(scuba_vhi), .CE1(scuba_vhi), .CE0(ClkEn), 
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
            .SRIB1(scuba_vlo), .SRIB0(scuba_vlo), .P35(multiplier_or1_31), 
            .P34(multiplier_or1_30), .P33(multiplier_or1_29), .P32(multiplier_or1_28), 
            .P31(multiplier_or1_27), .P30(multiplier_or1_26), .P29(multiplier_or1_25), 
            .P28(multiplier_or1_24), .P27(multiplier_or1_23), .P26(multiplier_or1_22), 
            .P25(multiplier_or1_21), .P24(multiplier_or1_20), .P23(multiplier_or1_19), 
            .P22(multiplier_or1_18), .P21(multiplier_or1_17), .P20(multiplier_or1_16), 
            .P19(multiplier_or1_15), .P18(multiplier_or1_14), .P17(multiplier_or1_13), 
            .P16(multiplier_or1_12), .P15(multiplier_or1_11), .P14(multiplier_or1_10), 
            .P13(multiplier_or1_9), .P12(multiplier_or1_8), .P11(multiplier_or1_7), 
            .P10(multiplier_or1_6), .P9(multiplier_or1_5), .P8(multiplier_or1_4), 
            .P7(multiplier_or1_3), .P6(multiplier_or1_2), .P5(multiplier_or1_1), 
            .P4(multiplier_or1_0)) /* synthesis syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(404[16] 460[57])
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
    FD1P3DX FF_63 (.D(multiplier_or2_0), .SP(ClkEn), .CK(Clock), .CD(Aclr), 
            .Q(Result[0])) /* synthesis GSR="ENABLED", syn_instantiated=1 */ ;   // d:/programs/fpga/c25x/c25x_fpga_ip/multiplier/multiplier.v(119[13] 120[23])
    defparam FF_63.GSR = "ENABLED";
    PUR PUR_INST (.PUR(scuba_vhi));
    defparam PUR_INST.RST_PULSE = 1;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

