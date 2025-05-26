// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Sun Apr 27 13:26:44 2025
//
// Verilog Description of module ram_w32_depth64
//

module ram_w32_depth64 (WrAddress, RdAddress, Data, WE, RdClock, RdClockEn, 
            Reset, WrClock, WrClockEn, Q) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(8[8:23])
    input [5:0]WrAddress;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    input [5:0]RdAddress;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    input [31:0]Data;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    input WE;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(13[16:18])
    input RdClock;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(14[16:23])
    input RdClockEn;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(15[16:25])
    input Reset;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(16[16:21])
    input WrClock;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(17[16:23])
    input WrClockEn;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(18[16:25])
    output [31:0]Q;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    
    wire RdClock_c /* synthesis is_clock=1 */ ;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(14[16:23])
    wire WrClock_c /* synthesis is_clock=1 */ ;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(17[16:23])
    
    wire WrAddress_c_5, WrAddress_c_4, WrAddress_c_3, WrAddress_c_2, 
        WrAddress_c_1, WrAddress_c_0, RdAddress_c_5, RdAddress_c_4, 
        RdAddress_c_3, RdAddress_c_2, RdAddress_c_1, RdAddress_c_0, 
        Data_c_31, Data_c_30, Data_c_29, Data_c_28, Data_c_27, Data_c_26, 
        Data_c_25, Data_c_24, Data_c_23, Data_c_22, Data_c_21, Data_c_20, 
        Data_c_19, Data_c_18, Data_c_17, Data_c_16, Data_c_15, Data_c_14, 
        Data_c_13, Data_c_12, Data_c_11, Data_c_10, Data_c_9, Data_c_8, 
        Data_c_7, Data_c_6, Data_c_5, Data_c_4, Data_c_3, Data_c_2, 
        Data_c_1, Data_c_0, WE_c, RdClockEn_c, Reset_c, WrClockEn_c, 
        Q_c_31, Q_c_30, Q_c_29, Q_c_28, Q_c_27, Q_c_26, Q_c_25, 
        Q_c_24, Q_c_23, Q_c_22, Q_c_21, Q_c_20, Q_c_19, Q_c_18, 
        Q_c_17, Q_c_16, Q_c_15, Q_c_14, Q_c_13, Q_c_12, Q_c_11, 
        Q_c_10, Q_c_9, Q_c_8, Q_c_7, Q_c_6, Q_c_5, Q_c_4, Q_c_3, 
        Q_c_2, Q_c_1, Q_c_0, scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    PDPW16KD ram_w32_depth64_0_0_0 (.DI0(Data_c_0), .DI1(Data_c_1), .DI2(Data_c_2), 
            .DI3(Data_c_3), .DI4(Data_c_4), .DI5(Data_c_5), .DI6(Data_c_6), 
            .DI7(Data_c_7), .DI8(Data_c_8), .DI9(Data_c_9), .DI10(Data_c_10), 
            .DI11(Data_c_11), .DI12(Data_c_12), .DI13(Data_c_13), .DI14(Data_c_14), 
            .DI15(Data_c_15), .DI16(Data_c_16), .DI17(Data_c_17), .DI18(Data_c_18), 
            .DI19(Data_c_19), .DI20(Data_c_20), .DI21(Data_c_21), .DI22(Data_c_22), 
            .DI23(Data_c_23), .DI24(Data_c_24), .DI25(Data_c_25), .DI26(Data_c_26), 
            .DI27(Data_c_27), .DI28(Data_c_28), .DI29(Data_c_29), .DI30(Data_c_30), 
            .DI31(Data_c_31), .DI32(scuba_vlo), .DI33(scuba_vlo), .DI34(scuba_vlo), 
            .DI35(scuba_vlo), .ADW0(WrAddress_c_0), .ADW1(WrAddress_c_1), 
            .ADW2(WrAddress_c_2), .ADW3(WrAddress_c_3), .ADW4(WrAddress_c_4), 
            .ADW5(WrAddress_c_5), .ADW6(scuba_vlo), .ADW7(scuba_vlo), 
            .ADW8(scuba_vlo), .BE0(VCC_net), .BE1(VCC_net), .BE2(VCC_net), 
            .BE3(VCC_net), .CEW(WrClockEn_c), .CLKW(WrClock_c), .CSW0(WE_c), 
            .CSW1(scuba_vlo), .CSW2(scuba_vlo), .ADR0(scuba_vlo), .ADR1(scuba_vlo), 
            .ADR2(scuba_vlo), .ADR3(scuba_vlo), .ADR4(scuba_vlo), .ADR5(RdAddress_c_0), 
            .ADR6(RdAddress_c_1), .ADR7(RdAddress_c_2), .ADR8(RdAddress_c_3), 
            .ADR9(RdAddress_c_4), .ADR10(RdAddress_c_5), .ADR11(scuba_vlo), 
            .ADR12(scuba_vlo), .ADR13(scuba_vlo), .CER(RdClockEn_c), .OCER(RdClockEn_c), 
            .CLKR(RdClock_c), .CSR0(scuba_vlo), .CSR1(scuba_vlo), .CSR2(scuba_vlo), 
            .RST(Reset_c), .DO0(Q_c_18), .DO1(Q_c_19), .DO2(Q_c_20), 
            .DO3(Q_c_21), .DO4(Q_c_22), .DO5(Q_c_23), .DO6(Q_c_24), 
            .DO7(Q_c_25), .DO8(Q_c_26), .DO9(Q_c_27), .DO10(Q_c_28), 
            .DO11(Q_c_29), .DO12(Q_c_30), .DO13(Q_c_31), .DO18(Q_c_0), 
            .DO19(Q_c_1), .DO20(Q_c_2), .DO21(Q_c_3), .DO22(Q_c_4), 
            .DO23(Q_c_5), .DO24(Q_c_6), .DO25(Q_c_7), .DO26(Q_c_8), 
            .DO27(Q_c_9), .DO28(Q_c_10), .DO29(Q_c_11), .DO30(Q_c_12), 
            .DO31(Q_c_13), .DO32(Q_c_14), .DO33(Q_c_15), .DO34(Q_c_16), 
            .DO35(Q_c_17)) /* synthesis MEM_LPC_FILE="ram_w32_depth64.lpc", MEM_INIT_FILE="INIT_ALL_0s", syn_instantiated=1 */ ;
    defparam ram_w32_depth64_0_0_0.DATA_WIDTH_W = 36;
    defparam ram_w32_depth64_0_0_0.DATA_WIDTH_R = 36;
    defparam ram_w32_depth64_0_0_0.GSR = "ENABLED";
    defparam ram_w32_depth64_0_0_0.REGMODE = "NOREG";
    defparam ram_w32_depth64_0_0_0.RESETMODE = "ASYNC";
    defparam ram_w32_depth64_0_0_0.ASYNC_RESET_RELEASE = "SYNC";
    defparam ram_w32_depth64_0_0_0.CSDECODE_W = "0b001";
    defparam ram_w32_depth64_0_0_0.CSDECODE_R = "0b000";
    defparam ram_w32_depth64_0_0_0.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_20 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_21 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_22 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_23 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_24 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_25 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_26 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_27 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_28 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_29 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_2F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_30 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_31 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_32 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_33 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_34 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_35 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_36 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_37 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_38 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_39 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INITVAL_3F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_w32_depth64_0_0_0.INIT_DATA = "STATIC";
    OB Q_pad_29 (.I(Q_c_29), .O(Q[29]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_30 (.I(Q_c_30), .O(Q[30]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_31 (.I(Q_c_31), .O(Q[31]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_28 (.I(Q_c_28), .O(Q[28]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_27 (.I(Q_c_27), .O(Q[27]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_26 (.I(Q_c_26), .O(Q[26]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_25 (.I(Q_c_25), .O(Q[25]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_24 (.I(Q_c_24), .O(Q[24]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_23 (.I(Q_c_23), .O(Q[23]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_22 (.I(Q_c_22), .O(Q[22]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_21 (.I(Q_c_21), .O(Q[21]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_20 (.I(Q_c_20), .O(Q[20]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_19 (.I(Q_c_19), .O(Q[19]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_18 (.I(Q_c_18), .O(Q[18]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_17 (.I(Q_c_17), .O(Q[17]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_16 (.I(Q_c_16), .O(Q[16]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_15 (.I(Q_c_15), .O(Q[15]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_14 (.I(Q_c_14), .O(Q[14]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_13 (.I(Q_c_13), .O(Q[13]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_12 (.I(Q_c_12), .O(Q[12]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_11 (.I(Q_c_11), .O(Q[11]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_10 (.I(Q_c_10), .O(Q[10]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_9 (.I(Q_c_9), .O(Q[9]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_8 (.I(Q_c_8), .O(Q[8]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_7 (.I(Q_c_7), .O(Q[7]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_6 (.I(Q_c_6), .O(Q[6]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_5 (.I(Q_c_5), .O(Q[5]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_4 (.I(Q_c_4), .O(Q[4]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_3 (.I(Q_c_3), .O(Q[3]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_2 (.I(Q_c_2), .O(Q[2]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_1 (.I(Q_c_1), .O(Q[1]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    OB Q_pad_0 (.I(Q_c_0), .O(Q[0]));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(19[24:25])
    IB WrAddress_pad_5 (.I(WrAddress[5]), .O(WrAddress_c_5));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB WrAddress_pad_4 (.I(WrAddress[4]), .O(WrAddress_c_4));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB WrAddress_pad_3 (.I(WrAddress[3]), .O(WrAddress_c_3));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB WrAddress_pad_2 (.I(WrAddress[2]), .O(WrAddress_c_2));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB WrAddress_pad_1 (.I(WrAddress[1]), .O(WrAddress_c_1));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB WrAddress_pad_0 (.I(WrAddress[0]), .O(WrAddress_c_0));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(10[22:31])
    IB RdAddress_pad_5 (.I(RdAddress[5]), .O(RdAddress_c_5));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB RdAddress_pad_4 (.I(RdAddress[4]), .O(RdAddress_c_4));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB RdAddress_pad_3 (.I(RdAddress[3]), .O(RdAddress_c_3));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB RdAddress_pad_2 (.I(RdAddress[2]), .O(RdAddress_c_2));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB RdAddress_pad_1 (.I(RdAddress[1]), .O(RdAddress_c_1));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB RdAddress_pad_0 (.I(RdAddress[0]), .O(RdAddress_c_0));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(11[22:31])
    IB Data_pad_31 (.I(Data[31]), .O(Data_c_31));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_30 (.I(Data[30]), .O(Data_c_30));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_29 (.I(Data[29]), .O(Data_c_29));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_28 (.I(Data[28]), .O(Data_c_28));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_27 (.I(Data[27]), .O(Data_c_27));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_26 (.I(Data[26]), .O(Data_c_26));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_25 (.I(Data[25]), .O(Data_c_25));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_24 (.I(Data[24]), .O(Data_c_24));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_23 (.I(Data[23]), .O(Data_c_23));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_22 (.I(Data[22]), .O(Data_c_22));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_21 (.I(Data[21]), .O(Data_c_21));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_20 (.I(Data[20]), .O(Data_c_20));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_19 (.I(Data[19]), .O(Data_c_19));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_18 (.I(Data[18]), .O(Data_c_18));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_17 (.I(Data[17]), .O(Data_c_17));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_16 (.I(Data[16]), .O(Data_c_16));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_15 (.I(Data[15]), .O(Data_c_15));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_14 (.I(Data[14]), .O(Data_c_14));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_13 (.I(Data[13]), .O(Data_c_13));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_12 (.I(Data[12]), .O(Data_c_12));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_11 (.I(Data[11]), .O(Data_c_11));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_10 (.I(Data[10]), .O(Data_c_10));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_9 (.I(Data[9]), .O(Data_c_9));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_8 (.I(Data[8]), .O(Data_c_8));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_7 (.I(Data[7]), .O(Data_c_7));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_6 (.I(Data[6]), .O(Data_c_6));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_5 (.I(Data[5]), .O(Data_c_5));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_4 (.I(Data[4]), .O(Data_c_4));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_3 (.I(Data[3]), .O(Data_c_3));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_2 (.I(Data[2]), .O(Data_c_2));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_1 (.I(Data[1]), .O(Data_c_1));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB Data_pad_0 (.I(Data[0]), .O(Data_c_0));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(12[23:27])
    IB WE_pad (.I(WE), .O(WE_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(13[16:18])
    IB RdClock_pad (.I(RdClock), .O(RdClock_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(14[16:23])
    IB RdClockEn_pad (.I(RdClockEn), .O(RdClockEn_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(15[16:25])
    IB Reset_pad (.I(Reset), .O(Reset_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(16[16:21])
    IB WrClock_pad (.I(WrClock), .O(WrClock_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(17[16:23])
    IB WrClockEn_pad (.I(WrClockEn), .O(WrClockEn_c));   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(18[16:25])
    GSR GSR_INST (.GSR(VCC_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VHI i6 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

