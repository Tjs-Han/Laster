// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Fri Apr 25 14:08:57 2025
//
// Verilog Description of module statistics_cycle
//

module statistics_cycle (i_clk_50m, i_rst_n, i_opto_switch, i_zero_sign, 
            i_motor_state, i_ram_raddr, i_ram_ren, o_ram_rdata) /* synthesis syn_module_defined=1 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(26[8:24])
    input i_clk_50m;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(27[13:22])
    input i_rst_n;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(28[10:17])
    input i_opto_switch;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(31[13:26])
    input i_zero_sign;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(32[21:32])
    input i_motor_state;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(33[21:34])
    input [5:0]i_ram_raddr;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    input i_ram_ren;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(36[21:30])
    output [31:0]o_ram_rdata;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    
    wire VCC_net /* synthesis CE_NET_FOR_BUS20=20, DSPPORT_20=CE3 */ ;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(18[16:25])
    wire i_clk_50m_c /* synthesis DSPPORT_20=CLK3, CLOCK_NET_FOR_BUS20=20, is_clock=1, SET_AS_NETWORK=i_clk_50m_c */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(27[13:22])
    wire i_rst_n_N_2 /* synthesis DSPPORT_20=RST3, RESET_NET_FOR_BUS20=20 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    
    wire GND_net, i_rst_n_c, i_opto_switch_c, i_zero_sign_c, i_ram_raddr_c_5, 
        i_ram_raddr_c_4, i_ram_raddr_c_3, i_ram_raddr_c_2, i_ram_raddr_c_1, 
        i_ram_raddr_c_0, i_ram_ren_c, o_ram_rdata_c_31, o_ram_rdata_c_30, 
        o_ram_rdata_c_29, o_ram_rdata_c_28, o_ram_rdata_c_27, o_ram_rdata_c_26, 
        o_ram_rdata_c_25, o_ram_rdata_c_24, o_ram_rdata_c_23, o_ram_rdata_c_22, 
        o_ram_rdata_c_21, o_ram_rdata_c_20, o_ram_rdata_c_19, o_ram_rdata_c_18, 
        o_ram_rdata_c_17, o_ram_rdata_c_16, o_ram_rdata_c_15, o_ram_rdata_c_14, 
        o_ram_rdata_c_13, o_ram_rdata_c_12, o_ram_rdata_c_11, o_ram_rdata_c_10, 
        o_ram_rdata_c_9, o_ram_rdata_c_8, o_ram_rdata_c_7, o_ram_rdata_c_6, 
        o_ram_rdata_c_5, o_ram_rdata_c_4, o_ram_rdata_c_3, o_ram_rdata_c_2, 
        o_ram_rdata_c_1, o_ram_rdata_c_0;
    wire [31:0]r_opto_opto_cnt;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(39[13:28])
    wire [7:0]r_opto_num;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(40[13:23])
    
    wire r_opto_switch1, r_opto_switch2, r_zero_sign, r_zero_sign1;
    wire [5:0]r_ram_waddr;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(49[13:24])
    
    wire r_we;
    wire [31:0]r_ram_wdata;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(51[13:24])
    
    wire n441, n153, n152, n151, n150, n149, n148, n147, n146, 
        n145, n144, n143, n142, n141, n140, n139, n138, n137, 
        n136, n135, n134, n154, n155, i_clk_50m_c_enable_1, n655, 
        n199, n200, n201, n202, n203, n626, n629, n17, n633, 
        n640, r_we_N_130, n6, n628, n632, n639, n631, n638;
    wire [31:0]r_ram_wdata_31__N_49;
    
    wire n156, n157, n158, n159, n160, n161, n162, n163, n164, 
        n165, n637, n636, n654, n635, n641, n653, n627, n630, 
        n634;
    
    VHI i2 (.Z(VCC_net));
    LUT4 i87_2_lut_3_lut_4_lut (.A(r_zero_sign1), .B(r_zero_sign), .C(r_opto_switch1), 
         .D(r_opto_switch2), .Z(n441)) /* synthesis lut_function=(!(A ((D)+!C)+!A !(B+!((D)+!C)))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(75[27:52])
    defparam i87_2_lut_3_lut_4_lut.init = 16'h44f4;
    FD1S3AX r_zero_sign_54 (.D(i_zero_sign_c), .CK(i_clk_50m_c), .Q(r_zero_sign));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(70[18] 73[12])
    defparam r_zero_sign_54.GSR = "ENABLED";
    FD1S3AX r_zero_sign1_55 (.D(r_zero_sign), .CK(i_clk_50m_c), .Q(r_zero_sign1));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(70[18] 73[12])
    defparam r_zero_sign1_55.GSR = "ENABLED";
    FD1S3IX r_ram_waddr__i0 (.D(n17), .CK(i_clk_50m_c), .CD(n655), .Q(r_ram_waddr[0]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i0.GSR = "ENABLED";
    OB o_ram_rdata_pad_30 (.I(o_ram_rdata_c_30), .O(o_ram_rdata[30]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    FD1S3IX r_ram_wdata_i0 (.D(r_opto_opto_cnt[0]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[0]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i0.GSR = "ENABLED";
    FD1S3AX r_we_59 (.D(r_we_N_130), .CK(i_clk_50m_c), .Q(r_we));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_we_59.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i0 (.D(n165), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[0])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i0.GSR = "ENABLED";
    FD1S3AY r_opto_switch2_53 (.D(r_opto_switch1), .CK(i_clk_50m_c), .Q(r_opto_switch2));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(58[12] 61[6])
    defparam r_opto_switch2_53.GSR = "ENABLED";
    FD1S3AY r_opto_switch1_52 (.D(i_opto_switch_c), .CK(i_clk_50m_c), .Q(r_opto_switch1));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(58[12] 61[6])
    defparam r_opto_switch1_52.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i31 (.D(n134), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[31])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i31.GSR = "ENABLED";
    OB o_ram_rdata_pad_31 (.I(o_ram_rdata_c_31), .O(o_ram_rdata[31]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    FD1S3IX r_opto_opto_cnt_85__i30 (.D(n135), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[30])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i30.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i29 (.D(n136), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[29])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i29.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i28 (.D(n137), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[28])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i28.GSR = "ENABLED";
    LUT4 i100_2_lut (.A(r_ram_waddr[1]), .B(r_ram_waddr[0]), .Z(n203)) /* synthesis lut_function=(!(A (B)+!A !(B))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i100_2_lut.init = 16'h6666;
    LUT4 i2_2_lut_rep_3 (.A(r_ram_waddr[2]), .B(r_ram_waddr[1]), .Z(n654)) /* synthesis lut_function=(A (B)) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i2_2_lut_rep_3.init = 16'h8888;
    LUT4 i114_3_lut_4_lut (.A(r_ram_waddr[2]), .B(r_ram_waddr[1]), .C(r_ram_waddr[0]), 
         .D(r_ram_waddr[3]), .Z(n201)) /* synthesis lut_function=(!(A (B (C (D)+!C !(D))+!B !(D))+!A !(D))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i114_3_lut_4_lut.init = 16'h7f80;
    LUT4 i_rst_n_I_0_63_1_lut (.A(i_rst_n_c), .Z(i_rst_n_N_2)) /* synthesis lut_function=(!(A)) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(131[19:27])
    defparam i_rst_n_I_0_63_1_lut.init = 16'h5555;
    LUT4 w_zero_rise_I_0_2_lut_rep_4 (.A(r_zero_sign1), .B(r_zero_sign), 
         .Z(n655)) /* synthesis lut_function=(!(A+!(B))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(75[27:52])
    defparam w_zero_rise_I_0_2_lut_rep_4.init = 16'h4444;
    FD1S3IX r_opto_opto_cnt_85__i27 (.D(n138), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[27])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i27.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i26 (.D(n139), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[26])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i26.GSR = "ENABLED";
    GSR GSR_INST (.GSR(i_rst_n_c));
    FD1S3IX r_opto_opto_cnt_85__i25 (.D(n140), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[25])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i25.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i24 (.D(n141), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[24])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i24.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i23 (.D(n142), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[23])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i23.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i22 (.D(n143), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[22])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i22.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i21 (.D(n144), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[21])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i21.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i20 (.D(n145), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[20])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i20.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i19 (.D(n146), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[19])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i19.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i18 (.D(n147), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[18])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i18.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i17 (.D(n148), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[17])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i17.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i16 (.D(n149), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[16])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i16.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i15 (.D(n150), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[15])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i15.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i14 (.D(n151), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[14])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i14.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i13 (.D(n152), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[13])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i13.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i12 (.D(n153), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[12])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i12.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i11 (.D(n154), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[11])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i11.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i10 (.D(n155), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[10])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i10.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i9 (.D(n156), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[9])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i9.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i8 (.D(n157), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[8])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i8.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i7 (.D(n158), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[7])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i7.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i6 (.D(n159), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[6])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i6.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i5 (.D(n160), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[5])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i5.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i4 (.D(n161), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[4])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i4.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i3 (.D(n162), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[3])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i3.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i2 (.D(n163), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[2])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i2.GSR = "ENABLED";
    FD1S3IX r_opto_opto_cnt_85__i1 (.D(n164), .CK(i_clk_50m_c), .CD(n441), 
            .Q(r_opto_opto_cnt[1])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85__i1.GSR = "ENABLED";
    FD1P3IX r_opto_num__i2 (.D(VCC_net), .SP(i_clk_50m_c_enable_1), .CD(n655), 
            .CK(i_clk_50m_c), .Q(r_opto_num[1]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(97[18] 103[12])
    defparam r_opto_num__i2.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i31 (.D(r_opto_opto_cnt[31]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[31]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i31.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i30 (.D(r_opto_opto_cnt[30]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[30]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i30.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i29 (.D(r_opto_opto_cnt[29]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[29]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i29.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i28 (.D(r_opto_opto_cnt[28]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[28]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i28.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i27 (.D(r_opto_opto_cnt[27]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[27]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i27.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i26 (.D(r_opto_opto_cnt[26]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[26]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i26.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i25 (.D(r_opto_opto_cnt[25]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[25]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i25.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i24 (.D(r_opto_opto_cnt[24]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[24]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i24.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i23 (.D(r_opto_opto_cnt[23]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[23]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i23.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i22 (.D(r_opto_opto_cnt[22]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[22]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i22.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i21 (.D(r_opto_opto_cnt[21]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[21]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i21.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i20 (.D(r_opto_opto_cnt[20]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[20]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i20.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i19 (.D(r_opto_opto_cnt[19]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[19]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i19.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i18 (.D(r_opto_opto_cnt[18]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[18]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i18.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i17 (.D(r_opto_opto_cnt[17]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[17]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i17.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i16 (.D(r_opto_opto_cnt[16]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[16]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i16.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i15 (.D(r_opto_opto_cnt[15]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[15]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i15.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i14 (.D(r_opto_opto_cnt[14]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[14]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i14.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i13 (.D(r_opto_opto_cnt[13]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[13]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i13.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i12 (.D(r_opto_opto_cnt[12]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[12]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i12.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i11 (.D(r_opto_opto_cnt[11]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[11]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i11.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i10 (.D(r_opto_opto_cnt[10]), .CK(i_clk_50m_c), 
            .CD(n655), .Q(r_ram_wdata[10]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i10.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i9 (.D(r_opto_opto_cnt[9]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[9]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i9.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i8 (.D(r_opto_opto_cnt[8]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[8]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i8.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i7 (.D(r_opto_opto_cnt[7]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[7]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i7.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i6 (.D(r_opto_opto_cnt[6]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[6]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i6.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i5 (.D(r_opto_opto_cnt[5]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[5]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i5.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i4 (.D(r_opto_opto_cnt[4]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[4]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i4.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i3 (.D(r_opto_opto_cnt[3]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[3]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i3.GSR = "ENABLED";
    FD1S3IX r_ram_wdata_i2 (.D(r_opto_opto_cnt[2]), .CK(i_clk_50m_c), .CD(n655), 
            .Q(r_ram_wdata[2]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i2.GSR = "ENABLED";
    FD1S3AX r_ram_wdata_i1 (.D(r_ram_wdata_31__N_49[1]), .CK(i_clk_50m_c), 
            .Q(r_ram_wdata[1]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_wdata_i1.GSR = "ENABLED";
    FD1P3IX r_ram_waddr__i5 (.D(n199), .SP(r_we_N_130), .CD(n655), .CK(i_clk_50m_c), 
            .Q(r_ram_waddr[5]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i5.GSR = "ENABLED";
    CCU2C r_opto_opto_cnt_85_add_4_7 (.A0(r_opto_opto_cnt[5]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[6]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n628), .COUT(n629), .S0(n160), 
          .S1(n159));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_7.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_7.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_7.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_7.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_5 (.A0(r_opto_opto_cnt[3]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[4]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n627), .COUT(n628), .S0(n162), 
          .S1(n161));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_5.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_5.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_5.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_5.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_15 (.A0(r_opto_opto_cnt[13]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[14]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n632), .COUT(n633), .S0(n152), 
          .S1(n151));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_15.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_15.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_15.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_15.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_29 (.A0(r_opto_opto_cnt[27]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[28]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n639), .COUT(n640), .S0(n138), 
          .S1(n137));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_29.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_29.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_29.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_29.INJECT1_1 = "NO";
    LUT4 i148_2_lut (.A(r_ram_waddr[0]), .B(r_we_N_130), .Z(n17)) /* synthesis lut_function=(!(A (B)+!A !(B))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam i148_2_lut.init = 16'h6666;
    CCU2C r_opto_opto_cnt_85_add_4_13 (.A0(r_opto_opto_cnt[11]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[12]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n631), .COUT(n632), .S0(n154), 
          .S1(n153));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_13.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_13.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_13.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_13.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_11 (.A0(r_opto_opto_cnt[9]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[10]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n630), .COUT(n631), .S0(n156), 
          .S1(n155));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_11.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_11.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_11.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_11.INJECT1_1 = "NO";
    LUT4 i1_4_lut_4_lut (.A(r_zero_sign1), .B(r_zero_sign), .C(i_zero_sign_c), 
         .D(i_clk_50m_c_enable_1), .Z(r_we_N_130)) /* synthesis lut_function=(A (B (D)+!B (C+(D)))+!A (B+(C+(D)))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(75[27:52])
    defparam i1_4_lut_4_lut.init = 16'hff74;
    LUT4 i102_2_lut_rep_2 (.A(r_ram_waddr[1]), .B(r_ram_waddr[0]), .Z(n653)) /* synthesis lut_function=(A (B)) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i102_2_lut_rep_2.init = 16'h8888;
    LUT4 w_opto_rise_I_0_64_2_lut_rep_1 (.A(r_opto_switch2), .B(r_opto_switch1), 
         .Z(i_clk_50m_c_enable_1)) /* synthesis lut_function=(!(A+!(B))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(63[23:55])
    defparam w_opto_rise_I_0_64_2_lut_rep_1.init = 16'h4444;
    LUT4 i107_2_lut_3_lut (.A(r_ram_waddr[1]), .B(r_ram_waddr[0]), .C(r_ram_waddr[2]), 
         .Z(n202)) /* synthesis lut_function=(!(A (B (C)+!B !(C))+!A !(C))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i107_2_lut_3_lut.init = 16'h7878;
    LUT4 i128_4_lut (.A(r_ram_waddr[5]), .B(n654), .C(r_ram_waddr[0]), 
         .D(n6), .Z(n199)) /* synthesis lut_function=(!(A (B (C (D)))+!A !(B (C (D))))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i128_4_lut.init = 16'h6aaa;
    CCU2C r_opto_opto_cnt_85_add_4_27 (.A0(r_opto_opto_cnt[25]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[26]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n638), .COUT(n639), .S0(n140), 
          .S1(n139));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_27.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_27.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_27.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_27.INJECT1_1 = "NO";
    LUT4 r_opto_opto_cnt_31__I_0_i2_3_lut_4_lut (.A(r_zero_sign1), .B(r_zero_sign), 
         .C(r_opto_num[1]), .D(r_opto_opto_cnt[1]), .Z(r_ram_wdata_31__N_49[1])) /* synthesis lut_function=(A (D)+!A (B (C)+!B (D))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(75[27:52])
    defparam r_opto_opto_cnt_31__I_0_i2_3_lut_4_lut.init = 16'hfb40;
    CCU2C r_opto_opto_cnt_85_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(r_opto_opto_cnt[0]), .B1(GND_net), .C1(GND_net), 
          .D1(VCC_net), .COUT(n626), .S1(n165));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_1.INIT0 = 16'h0000;
    defparam r_opto_opto_cnt_85_add_4_1.INIT1 = 16'h555f;
    defparam r_opto_opto_cnt_85_add_4_1.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_1.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_25 (.A0(r_opto_opto_cnt[23]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[24]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n637), .COUT(n638), .S0(n142), 
          .S1(n141));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_25.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_25.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_25.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_25.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_23 (.A0(r_opto_opto_cnt[21]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[22]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n636), .COUT(n637), .S0(n144), 
          .S1(n143));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_23.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_23.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_23.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_23.INJECT1_1 = "NO";
    FD1P3IX r_ram_waddr__i4 (.D(n200), .SP(r_we_N_130), .CD(n655), .CK(i_clk_50m_c), 
            .Q(r_ram_waddr[4]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i4.GSR = "ENABLED";
    FD1P3IX r_ram_waddr__i3 (.D(n201), .SP(r_we_N_130), .CD(n655), .CK(i_clk_50m_c), 
            .Q(r_ram_waddr[3]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i3.GSR = "ENABLED";
    FD1P3IX r_ram_waddr__i2 (.D(n202), .SP(r_we_N_130), .CD(n655), .CK(i_clk_50m_c), 
            .Q(r_ram_waddr[2]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i2.GSR = "ENABLED";
    FD1P3IX r_ram_waddr__i1 (.D(n203), .SP(r_we_N_130), .CD(n655), .CK(i_clk_50m_c), 
            .Q(r_ram_waddr[1]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(111[18] 121[12])
    defparam r_ram_waddr__i1.GSR = "ENABLED";
    LUT4 i1_2_lut (.A(r_ram_waddr[4]), .B(r_ram_waddr[3]), .Z(n6)) /* synthesis lut_function=(A (B)) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i1_2_lut.init = 16'h8888;
    CCU2C r_opto_opto_cnt_85_add_4_3 (.A0(r_opto_opto_cnt[1]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[2]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n626), .COUT(n627), .S0(n164), 
          .S1(n163));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_3.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_3.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_3.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_3.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_9 (.A0(r_opto_opto_cnt[7]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[8]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n629), .COUT(n630), .S0(n158), 
          .S1(n157));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_9.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_9.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_9.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_9.INJECT1_1 = "NO";
    OB o_ram_rdata_pad_29 (.I(o_ram_rdata_c_29), .O(o_ram_rdata[29]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_28 (.I(o_ram_rdata_c_28), .O(o_ram_rdata[28]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_27 (.I(o_ram_rdata_c_27), .O(o_ram_rdata[27]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_26 (.I(o_ram_rdata_c_26), .O(o_ram_rdata[26]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_25 (.I(o_ram_rdata_c_25), .O(o_ram_rdata[25]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_24 (.I(o_ram_rdata_c_24), .O(o_ram_rdata[24]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_23 (.I(o_ram_rdata_c_23), .O(o_ram_rdata[23]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_22 (.I(o_ram_rdata_c_22), .O(o_ram_rdata[22]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_21 (.I(o_ram_rdata_c_21), .O(o_ram_rdata[21]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_20 (.I(o_ram_rdata_c_20), .O(o_ram_rdata[20]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_19 (.I(o_ram_rdata_c_19), .O(o_ram_rdata[19]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_18 (.I(o_ram_rdata_c_18), .O(o_ram_rdata[18]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_17 (.I(o_ram_rdata_c_17), .O(o_ram_rdata[17]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_16 (.I(o_ram_rdata_c_16), .O(o_ram_rdata[16]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_15 (.I(o_ram_rdata_c_15), .O(o_ram_rdata[15]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_14 (.I(o_ram_rdata_c_14), .O(o_ram_rdata[14]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_13 (.I(o_ram_rdata_c_13), .O(o_ram_rdata[13]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_12 (.I(o_ram_rdata_c_12), .O(o_ram_rdata[12]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_11 (.I(o_ram_rdata_c_11), .O(o_ram_rdata[11]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_10 (.I(o_ram_rdata_c_10), .O(o_ram_rdata[10]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_9 (.I(o_ram_rdata_c_9), .O(o_ram_rdata[9]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_8 (.I(o_ram_rdata_c_8), .O(o_ram_rdata[8]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_7 (.I(o_ram_rdata_c_7), .O(o_ram_rdata[7]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_6 (.I(o_ram_rdata_c_6), .O(o_ram_rdata[6]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_5 (.I(o_ram_rdata_c_5), .O(o_ram_rdata[5]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_4 (.I(o_ram_rdata_c_4), .O(o_ram_rdata[4]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_3 (.I(o_ram_rdata_c_3), .O(o_ram_rdata[3]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_2 (.I(o_ram_rdata_c_2), .O(o_ram_rdata[2]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_1 (.I(o_ram_rdata_c_1), .O(o_ram_rdata[1]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    OB o_ram_rdata_pad_0 (.I(o_ram_rdata_c_0), .O(o_ram_rdata[0]));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    IB i_clk_50m_pad (.I(i_clk_50m), .O(i_clk_50m_c));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(27[13:22])
    IB i_rst_n_pad (.I(i_rst_n), .O(i_rst_n_c));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(28[10:17])
    IB i_opto_switch_pad (.I(i_opto_switch), .O(i_opto_switch_c));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(31[13:26])
    IB i_zero_sign_pad (.I(i_zero_sign), .O(i_zero_sign_c));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(32[21:32])
    IB i_ram_raddr_pad_5 (.I(i_ram_raddr[5]), .O(i_ram_raddr_c_5));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_raddr_pad_4 (.I(i_ram_raddr[4]), .O(i_ram_raddr_c_4));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_raddr_pad_3 (.I(i_ram_raddr[3]), .O(i_ram_raddr_c_3));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_raddr_pad_2 (.I(i_ram_raddr[2]), .O(i_ram_raddr_c_2));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_raddr_pad_1 (.I(i_ram_raddr[1]), .O(i_ram_raddr_c_1));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_raddr_pad_0 (.I(i_ram_raddr[0]), .O(i_ram_raddr_c_0));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(35[21:32])
    IB i_ram_ren_pad (.I(i_ram_ren), .O(i_ram_ren_c));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(36[21:30])
    CCU2C r_opto_opto_cnt_85_add_4_21 (.A0(r_opto_opto_cnt[19]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[20]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n635), .COUT(n636), .S0(n146), 
          .S1(n145));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_21.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_21.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_21.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_21.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_19 (.A0(r_opto_opto_cnt[17]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[18]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n634), .COUT(n635), .S0(n148), 
          .S1(n147));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_19.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_19.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_19.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_19.INJECT1_1 = "NO";
    LUT4 i121_4_lut (.A(r_ram_waddr[4]), .B(r_ram_waddr[3]), .C(n653), 
         .D(r_ram_waddr[2]), .Z(n200)) /* synthesis lut_function=(!(A (B (C (D)))+!A !(B (C (D))))) */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(118[93:110])
    defparam i121_4_lut.init = 16'h6aaa;
    VLO i1 (.Z(GND_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    ram_w32_depth64 ram (.r_ram_waddr({r_ram_waddr}), .i_ram_raddr_c_5(i_ram_raddr_c_5), 
            .i_ram_raddr_c_4(i_ram_raddr_c_4), .i_ram_raddr_c_3(i_ram_raddr_c_3), 
            .i_ram_raddr_c_2(i_ram_raddr_c_2), .i_ram_raddr_c_1(i_ram_raddr_c_1), 
            .i_ram_raddr_c_0(i_ram_raddr_c_0), .r_ram_wdata({r_ram_wdata}), 
            .r_we(r_we), .i_clk_50m_c(i_clk_50m_c), .i_ram_ren_c(i_ram_ren_c), 
            .i_rst_n_N_2(i_rst_n_N_2), .VCC_net(VCC_net), .o_ram_rdata_c_31(o_ram_rdata_c_31), 
            .o_ram_rdata_c_30(o_ram_rdata_c_30), .o_ram_rdata_c_29(o_ram_rdata_c_29), 
            .o_ram_rdata_c_28(o_ram_rdata_c_28), .o_ram_rdata_c_27(o_ram_rdata_c_27), 
            .o_ram_rdata_c_26(o_ram_rdata_c_26), .o_ram_rdata_c_25(o_ram_rdata_c_25), 
            .o_ram_rdata_c_24(o_ram_rdata_c_24), .o_ram_rdata_c_23(o_ram_rdata_c_23), 
            .o_ram_rdata_c_22(o_ram_rdata_c_22), .o_ram_rdata_c_21(o_ram_rdata_c_21), 
            .o_ram_rdata_c_20(o_ram_rdata_c_20), .o_ram_rdata_c_19(o_ram_rdata_c_19), 
            .o_ram_rdata_c_18(o_ram_rdata_c_18), .o_ram_rdata_c_17(o_ram_rdata_c_17), 
            .o_ram_rdata_c_16(o_ram_rdata_c_16), .o_ram_rdata_c_15(o_ram_rdata_c_15), 
            .o_ram_rdata_c_14(o_ram_rdata_c_14), .o_ram_rdata_c_13(o_ram_rdata_c_13), 
            .o_ram_rdata_c_12(o_ram_rdata_c_12), .o_ram_rdata_c_11(o_ram_rdata_c_11), 
            .o_ram_rdata_c_10(o_ram_rdata_c_10), .o_ram_rdata_c_9(o_ram_rdata_c_9), 
            .o_ram_rdata_c_8(o_ram_rdata_c_8), .o_ram_rdata_c_7(o_ram_rdata_c_7), 
            .o_ram_rdata_c_6(o_ram_rdata_c_6), .o_ram_rdata_c_5(o_ram_rdata_c_5), 
            .o_ram_rdata_c_4(o_ram_rdata_c_4), .o_ram_rdata_c_3(o_ram_rdata_c_3), 
            .o_ram_rdata_c_2(o_ram_rdata_c_2), .o_ram_rdata_c_1(o_ram_rdata_c_1), 
            .o_ram_rdata_c_0(o_ram_rdata_c_0), .GND_net(GND_net)) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(124[17] 135[2])
    CCU2C r_opto_opto_cnt_85_add_4_33 (.A0(r_opto_opto_cnt[31]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(GND_net), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n641), .S0(n134));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_33.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_33.INIT1 = 16'h0000;
    defparam r_opto_opto_cnt_85_add_4_33.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_33.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_31 (.A0(r_opto_opto_cnt[29]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[30]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n640), .COUT(n641), .S0(n136), 
          .S1(n135));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_31.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_31.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_31.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_31.INJECT1_1 = "NO";
    CCU2C r_opto_opto_cnt_85_add_4_17 (.A0(r_opto_opto_cnt[15]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(r_opto_opto_cnt[16]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n633), .COUT(n634), .S0(n150), 
          .S1(n149));   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(88[39:59])
    defparam r_opto_opto_cnt_85_add_4_17.INIT0 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_17.INIT1 = 16'haaa0;
    defparam r_opto_opto_cnt_85_add_4_17.INJECT1_0 = "NO";
    defparam r_opto_opto_cnt_85_add_4_17.INJECT1_1 = "NO";
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

//
// Verilog Description of module ram_w32_depth64
//

module ram_w32_depth64 (r_ram_waddr, i_ram_raddr_c_5, i_ram_raddr_c_4, 
            i_ram_raddr_c_3, i_ram_raddr_c_2, i_ram_raddr_c_1, i_ram_raddr_c_0, 
            r_ram_wdata, r_we, i_clk_50m_c, i_ram_ren_c, i_rst_n_N_2, 
            VCC_net, o_ram_rdata_c_31, o_ram_rdata_c_30, o_ram_rdata_c_29, 
            o_ram_rdata_c_28, o_ram_rdata_c_27, o_ram_rdata_c_26, o_ram_rdata_c_25, 
            o_ram_rdata_c_24, o_ram_rdata_c_23, o_ram_rdata_c_22, o_ram_rdata_c_21, 
            o_ram_rdata_c_20, o_ram_rdata_c_19, o_ram_rdata_c_18, o_ram_rdata_c_17, 
            o_ram_rdata_c_16, o_ram_rdata_c_15, o_ram_rdata_c_14, o_ram_rdata_c_13, 
            o_ram_rdata_c_12, o_ram_rdata_c_11, o_ram_rdata_c_10, o_ram_rdata_c_9, 
            o_ram_rdata_c_8, o_ram_rdata_c_7, o_ram_rdata_c_6, o_ram_rdata_c_5, 
            o_ram_rdata_c_4, o_ram_rdata_c_3, o_ram_rdata_c_2, o_ram_rdata_c_1, 
            o_ram_rdata_c_0, GND_net) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;
    input [5:0]r_ram_waddr;
    input i_ram_raddr_c_5;
    input i_ram_raddr_c_4;
    input i_ram_raddr_c_3;
    input i_ram_raddr_c_2;
    input i_ram_raddr_c_1;
    input i_ram_raddr_c_0;
    input [31:0]r_ram_wdata;
    input r_we;
    input i_clk_50m_c;
    input i_ram_ren_c;
    input i_rst_n_N_2;
    input VCC_net;
    output o_ram_rdata_c_31;
    output o_ram_rdata_c_30;
    output o_ram_rdata_c_29;
    output o_ram_rdata_c_28;
    output o_ram_rdata_c_27;
    output o_ram_rdata_c_26;
    output o_ram_rdata_c_25;
    output o_ram_rdata_c_24;
    output o_ram_rdata_c_23;
    output o_ram_rdata_c_22;
    output o_ram_rdata_c_21;
    output o_ram_rdata_c_20;
    output o_ram_rdata_c_19;
    output o_ram_rdata_c_18;
    output o_ram_rdata_c_17;
    output o_ram_rdata_c_16;
    output o_ram_rdata_c_15;
    output o_ram_rdata_c_14;
    output o_ram_rdata_c_13;
    output o_ram_rdata_c_12;
    output o_ram_rdata_c_11;
    output o_ram_rdata_c_10;
    output o_ram_rdata_c_9;
    output o_ram_rdata_c_8;
    output o_ram_rdata_c_7;
    output o_ram_rdata_c_6;
    output o_ram_rdata_c_5;
    output o_ram_rdata_c_4;
    output o_ram_rdata_c_3;
    output o_ram_rdata_c_2;
    output o_ram_rdata_c_1;
    output o_ram_rdata_c_0;
    input GND_net;
    
    wire i_clk_50m_c /* synthesis DSPPORT_20=CLK3, CLOCK_NET_FOR_BUS20=20, is_clock=1, SET_AS_NETWORK=i_clk_50m_c */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(27[13:22])
    wire i_rst_n_N_2 /* synthesis DSPPORT_20=RST3, RESET_NET_FOR_BUS20=20 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(37[21:32])
    wire VCC_net /* synthesis CE_NET_FOR_BUS20=20, DSPPORT_20=CE3 */ ;   // d:/project/c20f_haikang/sim/sim_statistics_cycle/impl1/ram_w32_depth64/ram_w32_depth64.v(18[16:25])
    
    PDPW16KD ram_w32_depth64_0_0_0 (.DI0(r_ram_wdata[0]), .DI1(r_ram_wdata[1]), 
            .DI2(r_ram_wdata[2]), .DI3(r_ram_wdata[3]), .DI4(r_ram_wdata[4]), 
            .DI5(r_ram_wdata[5]), .DI6(r_ram_wdata[6]), .DI7(r_ram_wdata[7]), 
            .DI8(r_ram_wdata[8]), .DI9(r_ram_wdata[9]), .DI10(r_ram_wdata[10]), 
            .DI11(r_ram_wdata[11]), .DI12(r_ram_wdata[12]), .DI13(r_ram_wdata[13]), 
            .DI14(r_ram_wdata[14]), .DI15(r_ram_wdata[15]), .DI16(r_ram_wdata[16]), 
            .DI17(r_ram_wdata[17]), .DI18(r_ram_wdata[18]), .DI19(r_ram_wdata[19]), 
            .DI20(r_ram_wdata[20]), .DI21(r_ram_wdata[21]), .DI22(r_ram_wdata[22]), 
            .DI23(r_ram_wdata[23]), .DI24(r_ram_wdata[24]), .DI25(r_ram_wdata[25]), 
            .DI26(r_ram_wdata[26]), .DI27(r_ram_wdata[27]), .DI28(r_ram_wdata[28]), 
            .DI29(r_ram_wdata[29]), .DI30(r_ram_wdata[30]), .DI31(r_ram_wdata[31]), 
            .DI32(GND_net), .DI33(GND_net), .DI34(GND_net), .DI35(GND_net), 
            .ADW0(r_ram_waddr[0]), .ADW1(r_ram_waddr[1]), .ADW2(r_ram_waddr[2]), 
            .ADW3(r_ram_waddr[3]), .ADW4(r_ram_waddr[4]), .ADW5(r_ram_waddr[5]), 
            .ADW6(GND_net), .ADW7(GND_net), .ADW8(GND_net), .BE0(VCC_net), 
            .BE1(VCC_net), .BE2(VCC_net), .BE3(VCC_net), .CEW(VCC_net), 
            .CLKW(i_clk_50m_c), .CSW0(r_we), .CSW1(GND_net), .CSW2(GND_net), 
            .ADR0(GND_net), .ADR1(GND_net), .ADR2(GND_net), .ADR3(GND_net), 
            .ADR4(GND_net), .ADR5(i_ram_raddr_c_0), .ADR6(i_ram_raddr_c_1), 
            .ADR7(i_ram_raddr_c_2), .ADR8(i_ram_raddr_c_3), .ADR9(i_ram_raddr_c_4), 
            .ADR10(i_ram_raddr_c_5), .ADR11(GND_net), .ADR12(GND_net), 
            .ADR13(GND_net), .CER(i_ram_ren_c), .OCER(i_ram_ren_c), .CLKR(i_clk_50m_c), 
            .CSR0(GND_net), .CSR1(GND_net), .CSR2(GND_net), .RST(i_rst_n_N_2), 
            .DO0(o_ram_rdata_c_18), .DO1(o_ram_rdata_c_19), .DO2(o_ram_rdata_c_20), 
            .DO3(o_ram_rdata_c_21), .DO4(o_ram_rdata_c_22), .DO5(o_ram_rdata_c_23), 
            .DO6(o_ram_rdata_c_24), .DO7(o_ram_rdata_c_25), .DO8(o_ram_rdata_c_26), 
            .DO9(o_ram_rdata_c_27), .DO10(o_ram_rdata_c_28), .DO11(o_ram_rdata_c_29), 
            .DO12(o_ram_rdata_c_30), .DO13(o_ram_rdata_c_31), .DO18(o_ram_rdata_c_0), 
            .DO19(o_ram_rdata_c_1), .DO20(o_ram_rdata_c_2), .DO21(o_ram_rdata_c_3), 
            .DO22(o_ram_rdata_c_4), .DO23(o_ram_rdata_c_5), .DO24(o_ram_rdata_c_6), 
            .DO25(o_ram_rdata_c_7), .DO26(o_ram_rdata_c_8), .DO27(o_ram_rdata_c_9), 
            .DO28(o_ram_rdata_c_10), .DO29(o_ram_rdata_c_11), .DO30(o_ram_rdata_c_12), 
            .DO31(o_ram_rdata_c_13), .DO32(o_ram_rdata_c_14), .DO33(o_ram_rdata_c_15), 
            .DO34(o_ram_rdata_c_16), .DO35(o_ram_rdata_c_17)) /* synthesis MEM_LPC_FILE="ram_w32_depth64.lpc", MEM_INIT_FILE="INIT_ALL_0s", syn_instantiated=1, LSE_LINE_FILE_ID=3, LSE_LCOL=17, LSE_RCOL=2, LSE_LLINE=124, LSE_RLINE=135 */ ;   // d:/project/c20f_haikang/c200_fpga/rtl_tjs/statistics_cycle.v(124[17] 135[2])
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
    
endmodule
