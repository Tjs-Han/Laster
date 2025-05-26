// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.12.0.240.2
// Netlist written on Mon May 17 13:14:31 2021
//
// Verilog Description of module parameter_test
//

module parameter_test (i_clk_50m, i_rst_n, i_read_complete_sig, o_sram_csen_eth, 
            o_sram_wren_eth, o_sram_rden_eth, o_sram_addr_eth, o_sram_data_eth, 
            i_sram_data_eth, o_config_mode, o_pwm_value_0, o_stop_window, 
            o_rst_n) /* synthesis syn_module_defined=1 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(1[8:22])
    input i_clk_50m;   // d:/programs/fpga/c200_fpga/parameter_test.v(3[10:19])
    input i_rst_n;   // d:/programs/fpga/c200_fpga/parameter_test.v(4[10:17])
    input i_read_complete_sig;   // d:/programs/fpga/c200_fpga/parameter_test.v(6[10:29])
    output o_sram_csen_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(8[11:26])
    output o_sram_wren_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(9[11:26])
    output o_sram_rden_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(10[11:26])
    output [17:0]o_sram_addr_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    output [15:0]o_sram_data_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    input [15:0]i_sram_data_eth;   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    output [7:0]o_config_mode;   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    output [15:0]o_pwm_value_0;   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    output [15:0]o_stop_window;   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    output o_rst_n;   // d:/programs/fpga/c200_fpga/parameter_test.v(19[11:18])
    
    wire i_clk_50m_c /* synthesis is_clock=1, SET_AS_NETWORK=i_clk_50m_c */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(3[10:19])
    
    wire GND_net, VCC_net, i_rst_n_c, i_read_complete_sig_c, o_sram_csen_eth_c, 
        o_sram_rden_eth_c, n1823, n1808, n29, o_sram_addr_eth_c_1, 
        o_sram_addr_eth_c_0, n1822, n28, i_sram_data_eth_c_15, i_sram_data_eth_c_14, 
        i_sram_data_eth_c_13, i_sram_data_eth_c_12, i_sram_data_eth_c_11, 
        i_sram_data_eth_c_10, i_sram_data_eth_c_9, i_sram_data_eth_c_8, 
        i_sram_data_eth_c_7, i_sram_data_eth_c_6, i_sram_data_eth_c_5, 
        i_sram_data_eth_c_4, i_sram_data_eth_c_3, i_sram_data_eth_c_2, 
        i_sram_data_eth_c_1, i_sram_data_eth_c_0, o_config_mode_c_7, o_config_mode_c_6, 
        o_config_mode_c_5, o_config_mode_c_4, o_config_mode_c_3, o_config_mode_c_2, 
        o_config_mode_c_1, o_config_mode_c_0, o_pwm_value_0_c_15, o_pwm_value_0_c_14, 
        o_pwm_value_0_c_13, o_pwm_value_0_c_12, o_pwm_value_0_c_11, o_pwm_value_0_c_10, 
        o_pwm_value_0_c_9, o_pwm_value_0_c_8, o_pwm_value_0_c_7, o_pwm_value_0_c_6, 
        o_pwm_value_0_c_5, o_pwm_value_0_c_4, o_pwm_value_0_c_3, o_pwm_value_0_c_2, 
        o_pwm_value_0_c_1, o_pwm_value_0_c_0, o_stop_window_c_15, o_stop_window_c_14, 
        o_stop_window_c_13, o_stop_window_c_12, o_stop_window_c_11, o_stop_window_c_10, 
        o_stop_window_c_9, o_stop_window_c_8, o_stop_window_c_7, o_stop_window_c_6, 
        o_stop_window_c_5, o_stop_window_c_4, o_stop_window_c_3, o_stop_window_c_2, 
        o_stop_window_c_1, o_stop_window_c_0, o_rst_n_c, n1772, n1736;
    wire [9:0]r_para_state;   // d:/programs/fpga/c200_fpga/parameter_test.v(22[13:25])
    
    wire o_config_mode_7__N_73, n1476, n1821;
    wire [9:0]r_para_state_9__N_60;
    
    wire n1794, n1233, n1636, n1231, n1820, n1803, n1237, n1757, 
        i_clk_50m_c_enable_2, i_clk_50m_c_enable_38, n1804, n1771, i_clk_50m_c_enable_33, 
        n1818, n1817, n1755, n1525, n1230, n1816, n1815, n1812, 
        i_clk_50m_c_enable_45, i_clk_50m_c_enable_40, i_clk_50m_c_enable_36, 
        n1795, n4, n1826, n1809, n1824, n1796, n1615;
    
    VHI i2 (.Z(VCC_net));
    LUT4 i1_3_lut_4_lut (.A(r_para_state[6]), .B(r_para_state[5]), .C(r_para_state[1]), 
         .D(n28), .Z(n29)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i1_3_lut_4_lut.init = 16'h0100;
    OB o_stop_window_pad_10 (.I(o_stop_window_c_10), .O(o_stop_window[10]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_11 (.I(o_stop_window_c_11), .O(o_stop_window[11]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_12 (.I(o_stop_window_c_12), .O(o_stop_window[12]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_13 (.I(o_stop_window_c_13), .O(o_stop_window[13]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_14 (.I(o_stop_window_c_14), .O(o_stop_window[14]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_15 (.I(o_stop_window_c_15), .O(o_stop_window[15]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_pwm_value_0_pad_0 (.I(o_pwm_value_0_c_0), .O(o_pwm_value_0[0]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    FD1P3AX r_sram_csen_eth_48 (.D(n1809), .SP(i_clk_50m_c_enable_2), .CK(i_clk_50m_c), 
            .Q(o_sram_csen_eth_c)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_sram_csen_eth_48.GSR = "ENABLED";
    FD1P3AY r_sram_rden_eth_51 (.D(n1476), .SP(i_clk_50m_c_enable_2), .CK(i_clk_50m_c), 
            .Q(o_sram_rden_eth_c)) /* synthesis lse_init_val=1 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_sram_rden_eth_51.GSR = "ENABLED";
    OB o_config_mode_pad_3 (.I(o_config_mode_c_3), .O(o_config_mode[3]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    OB o_pwm_value_0_pad_1 (.I(o_pwm_value_0_c_1), .O(o_pwm_value_0[1]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_config_mode_pad_4 (.I(o_config_mode_c_4), .O(o_config_mode[4]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    OB o_pwm_value_0_pad_2 (.I(o_pwm_value_0_c_2), .O(o_pwm_value_0[2]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    FD1P3IX r_stop_window_i0_i4 (.D(i_sram_data_eth_c_3), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_3)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i4.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i5 (.D(i_sram_data_eth_c_4), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_4)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i5.GSR = "ENABLED";
    OB o_pwm_value_0_pad_3 (.I(o_pwm_value_0_c_3), .O(o_pwm_value_0[3]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_4 (.I(o_pwm_value_0_c_4), .O(o_pwm_value_0[4]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_5 (.I(o_pwm_value_0_c_5), .O(o_pwm_value_0[5]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_6 (.I(o_pwm_value_0_c_6), .O(o_pwm_value_0[6]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    FD1P3IX r_pwm_value_0_i0_i12 (.D(i_sram_data_eth_c_11), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_11)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i12.GSR = "ENABLED";
    OB o_sram_csen_eth_pad (.I(o_sram_csen_eth_c), .O(o_sram_csen_eth));   // d:/programs/fpga/c200_fpga/parameter_test.v(8[11:26])
    OB o_config_mode_pad_5 (.I(o_config_mode_c_5), .O(o_config_mode[5]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    OB o_config_mode_pad_6 (.I(o_config_mode_c_6), .O(o_config_mode[6]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    OB o_config_mode_pad_7 (.I(o_config_mode_c_7), .O(o_config_mode[7]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    FD1P3IX r_pwm_value_0_i0_i6 (.D(i_sram_data_eth_c_5), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_5)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i6.GSR = "ENABLED";
    OB o_sram_data_eth_pad_0 (.I(GND_net), .O(o_sram_data_eth[0]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_1 (.I(GND_net), .O(o_sram_data_eth[1]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    FD1P3IX r_pwm_value_0_i0_i7 (.D(i_sram_data_eth_c_6), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_6)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i7.GSR = "ENABLED";
    OB o_sram_data_eth_pad_2 (.I(GND_net), .O(o_sram_data_eth[2]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_3 (.I(GND_net), .O(o_sram_data_eth[3]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    FD1P3IX r_stop_window_i0_i6 (.D(i_sram_data_eth_c_5), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_5)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i6.GSR = "ENABLED";
    OB o_sram_data_eth_pad_4 (.I(GND_net), .O(o_sram_data_eth[4]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_5 (.I(GND_net), .O(o_sram_data_eth[5]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    FD1P3IX r_pwm_value_0_i0_i8 (.D(i_sram_data_eth_c_7), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_7)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i8.GSR = "ENABLED";
    OB o_pwm_value_0_pad_7 (.I(o_pwm_value_0_c_7), .O(o_pwm_value_0[7]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_8 (.I(o_pwm_value_0_c_8), .O(o_pwm_value_0[8]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_9 (.I(o_pwm_value_0_c_9), .O(o_pwm_value_0[9]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_10 (.I(o_pwm_value_0_c_10), .O(o_pwm_value_0[10]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_11 (.I(o_pwm_value_0_c_11), .O(o_pwm_value_0[11]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    FD1P3IX r_config_mode_i0_i1 (.D(i_sram_data_eth_c_0), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_0)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i1.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i7 (.D(i_sram_data_eth_c_6), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_6)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i7.GSR = "ENABLED";
    FD1P3IX r_sram_addr_eth_i1 (.D(o_config_mode_7__N_73), .SP(i_clk_50m_c_enable_38), 
            .CD(n1233), .CK(i_clk_50m_c), .Q(o_sram_addr_eth_c_0)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_sram_addr_eth_i1.GSR = "ENABLED";
    OB o_sram_data_eth_pad_6 (.I(GND_net), .O(o_sram_data_eth[6]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_pwm_value_0_pad_12 (.I(o_pwm_value_0_c_12), .O(o_pwm_value_0[12]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_13 (.I(o_pwm_value_0_c_13), .O(o_pwm_value_0[13]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_pwm_value_0_pad_14 (.I(o_pwm_value_0_c_14), .O(o_pwm_value_0[14]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    OB o_sram_data_eth_pad_7 (.I(GND_net), .O(o_sram_data_eth[7]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_pwm_value_0_pad_15 (.I(o_pwm_value_0_c_15), .O(o_pwm_value_0[15]));   // d:/programs/fpga/c200_fpga/parameter_test.v(16[16:29])
    FD1P3IX r_stop_window_i0_i1 (.D(i_sram_data_eth_c_0), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_0)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i1.GSR = "ENABLED";
    GSR GSR_INST (.GSR(i_rst_n_c));
    OB o_config_mode_pad_0 (.I(o_config_mode_c_0), .O(o_config_mode[0]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    OB o_config_mode_pad_1 (.I(o_config_mode_c_1), .O(o_config_mode[1]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    PFUMX i1010 (.BLUT(n1804), .ALUT(n1803), .C0(n1815), .Z(r_para_state_9__N_60[1]));
    FD1P3IX r_stop_window_i0_i8 (.D(i_sram_data_eth_c_7), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_7)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i8.GSR = "ENABLED";
    IB i_sram_data_eth_pad_3 (.I(i_sram_data_eth[3]), .O(i_sram_data_eth_c_3));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    OB o_sram_data_eth_pad_8 (.I(GND_net), .O(o_sram_data_eth[8]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_9 (.I(GND_net), .O(o_sram_data_eth[9]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_10 (.I(GND_net), .O(o_sram_data_eth[10]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    FD1S3AX r_para_state_i6 (.D(r_para_state_9__N_60[6]), .CK(i_clk_50m_c), 
            .Q(r_para_state[6])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i6.GSR = "ENABLED";
    IB i_sram_data_eth_pad_4 (.I(i_sram_data_eth[4]), .O(i_sram_data_eth_c_4));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    OB o_sram_data_eth_pad_11 (.I(GND_net), .O(o_sram_data_eth[11]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_12 (.I(GND_net), .O(o_sram_data_eth[12]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_13 (.I(GND_net), .O(o_sram_data_eth[13]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    OB o_sram_data_eth_pad_14 (.I(GND_net), .O(o_sram_data_eth[14]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    FD1P3IX r_stop_window_i0_i9 (.D(i_sram_data_eth_c_8), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_8)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i9.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i10 (.D(i_sram_data_eth_c_9), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_9)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i10.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i11 (.D(i_sram_data_eth_c_10), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_10)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i11.GSR = "ENABLED";
    LUT4 i1006_2_lut_3_lut_4_lut_4_lut (.A(r_para_state[6]), .B(r_para_state[5]), 
         .C(n1817), .D(n1816), .Z(i_clk_50m_c_enable_40)) /* synthesis lut_function=(!(A ((C)+!B)+!A (B (C)+!B (D)))) */ ;
    defparam i1006_2_lut_3_lut_4_lut_4_lut.init = 16'h0c1d;
    FD1P3IX r_pwm_value_0_i0_i1 (.D(i_sram_data_eth_c_0), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_0)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i1.GSR = "ENABLED";
    LUT4 i557_2_lut_rep_42 (.A(r_para_state[3]), .B(r_para_state[4]), .Z(n1823)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i557_2_lut_rep_42.init = 16'heeee;
    LUT4 i1_2_lut_rep_35_3_lut_4_lut (.A(r_para_state[3]), .B(r_para_state[4]), 
         .C(r_para_state[2]), .D(r_para_state[1]), .Z(n1816)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1_2_lut_rep_35_3_lut_4_lut.init = 16'hfffe;
    LUT4 i483_2_lut_4_lut_3_lut_4_lut (.A(n1822), .B(r_para_state[4]), .C(r_para_state[3]), 
         .D(n1821), .Z(n1231)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(82[5:17])
    defparam i483_2_lut_4_lut_3_lut_4_lut.init = 16'h0001;
    LUT4 i1_3_lut_4_lut_adj_1 (.A(n1820), .B(n1818), .C(n1817), .D(n29), 
         .Z(i_clk_50m_c_enable_38)) /* synthesis lut_function=(A ((D)+!C)+!A (B+((D)+!C))) */ ;
    defparam i1_3_lut_4_lut_adj_1.init = 16'hff4f;
    LUT4 i1_3_lut_rep_36_4_lut (.A(r_para_state[3]), .B(r_para_state[4]), 
         .C(r_para_state[1]), .D(n1824), .Z(n1817)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i1_3_lut_rep_36_4_lut.init = 16'hfffe;
    FD1P3IX r_stop_window_i0_i12 (.D(i_sram_data_eth_c_11), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_11)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i12.GSR = "ENABLED";
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    FD1P3IX r_pwm_value_0_i0_i16 (.D(i_sram_data_eth_c_15), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_15)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i16.GSR = "ENABLED";
    FD1S3AX r_para_state_i5 (.D(r_para_state_9__N_60[5]), .CK(i_clk_50m_c), 
            .Q(r_para_state[5])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i5.GSR = "ENABLED";
    FD1S3AX r_para_state_i4 (.D(r_para_state_9__N_60[4]), .CK(i_clk_50m_c), 
            .Q(r_para_state[4])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i4.GSR = "ENABLED";
    FD1S3IX r_para_state_i3 (.D(n4), .CK(i_clk_50m_c), .CD(r_para_state[3]), 
            .Q(r_para_state[3])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i3.GSR = "ENABLED";
    FD1S3AX r_para_state_i2 (.D(r_para_state_9__N_60[2]), .CK(i_clk_50m_c), 
            .Q(r_para_state[2])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i2.GSR = "ENABLED";
    FD1S3AX r_para_state_i1 (.D(r_para_state_9__N_60[1]), .CK(i_clk_50m_c), 
            .Q(r_para_state[1])) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_para_state_i1.GSR = "ENABLED";
    LUT4 i1_4_lut (.A(n1525), .B(n1755), .C(r_para_state[1]), .D(r_para_state[2]), 
         .Z(n4)) /* synthesis lut_function=(!(A (B+(C (D)))+!A (B+(C+!(D))))) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(57[4] 108[12])
    defparam i1_4_lut.init = 16'h0322;
    LUT4 i502_4_lut_3_lut_4_lut (.A(n1822), .B(r_para_state[3]), .C(r_para_state[4]), 
         .D(n1821), .Z(n1237)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;
    defparam i502_4_lut_3_lut_4_lut.init = 16'h0001;
    LUT4 i1_2_lut_rep_43 (.A(r_para_state[2]), .B(r_para_state[6]), .Z(n1824)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_rep_43.init = 16'heeee;
    IB i_sram_data_eth_pad_5 (.I(i_sram_data_eth[5]), .O(i_sram_data_eth_c_5));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    LUT4 n1531_bdd_4_lut (.A(r_para_state[3]), .B(r_para_state[4]), .C(r_para_state[5]), 
         .D(r_para_state[6]), .Z(n1795)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam n1531_bdd_4_lut.init = 16'h0100;
    LUT4 i821_2_lut_rep_34_3_lut_4_lut (.A(r_para_state[2]), .B(r_para_state[6]), 
         .C(r_para_state[4]), .D(r_para_state[5]), .Z(n1815)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i821_2_lut_rep_34_3_lut_4_lut.init = 16'hfffe;
    LUT4 i1000_4_lut (.A(r_para_state[1]), .B(r_para_state[5]), .C(n1818), 
         .D(n1615), .Z(n1476)) /* synthesis lut_function=(!(A+!(B+!(C+(D))))) */ ;
    defparam i1000_4_lut.init = 16'h4445;
    LUT4 i1_4_lut_adj_2 (.A(r_para_state[4]), .B(r_para_state[3]), .C(r_para_state[2]), 
         .D(r_para_state[6]), .Z(n1615)) /* synthesis lut_function=(!(A+(B+(C (D)+!C !(D))))) */ ;
    defparam i1_4_lut_adj_2.init = 16'h0110;
    LUT4 i44_3_lut_4_lut_3_lut (.A(r_para_state[3]), .B(r_para_state[4]), 
         .C(r_para_state[2]), .Z(n28)) /* synthesis lut_function=(!(A (B+(C))+!A (B (C)+!B !(C)))) */ ;
    defparam i44_3_lut_4_lut_3_lut.init = 16'h1616;
    OB o_sram_data_eth_pad_15 (.I(GND_net), .O(o_sram_data_eth[15]));   // d:/programs/fpga/c200_fpga/parameter_test.v(12[16:31])
    LUT4 i1_3_lut_rep_37_4_lut (.A(r_para_state[3]), .B(r_para_state[4]), 
         .C(r_para_state[6]), .D(r_para_state[2]), .Z(n1818)) /* synthesis lut_function=(!(A (B+(C+(D)))+!A ((C+(D))+!B))) */ ;
    defparam i1_3_lut_rep_37_4_lut.init = 16'h0006;
    LUT4 n1574_bdd_4_lut (.A(n1816), .B(n1826), .C(r_para_state[3]), .D(r_para_state[5]), 
         .Z(n1804)) /* synthesis lut_function=(!(A ((C)+!B)+!A (B (C (D))+!B (D)))) */ ;
    defparam n1574_bdd_4_lut.init = 16'h0c5d;
    FD1P3IX r_stop_window_i0_i13 (.D(i_sram_data_eth_c_12), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_12)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i13.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i14 (.D(i_sram_data_eth_c_13), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_13)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i14.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i15 (.D(i_sram_data_eth_c_14), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_14)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i15.GSR = "ENABLED";
    LUT4 i1_2_lut_rep_45 (.A(r_para_state[1]), .B(i_read_complete_sig_c), 
         .Z(n1826)) /* synthesis lut_function=(!((B)+!A)) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(57[4] 108[12])
    defparam i1_2_lut_rep_45.init = 16'h2222;
    LUT4 r_para_state_3__bdd_4_lut_1012 (.A(r_para_state[3]), .B(r_para_state[1]), 
         .C(r_para_state[6]), .D(i_read_complete_sig_c), .Z(i_clk_50m_c_enable_33)) /* synthesis lut_function=(!(A+(B (C+!(D))))) */ ;
    defparam r_para_state_3__bdd_4_lut_1012.init = 16'h1511;
    OB o_sram_addr_eth_pad_0 (.I(o_sram_addr_eth_c_0), .O(o_sram_addr_eth[0]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_1 (.I(o_sram_addr_eth_c_1), .O(o_sram_addr_eth[1]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    FD1P3IX r_stop_window_i0_i16 (.D(i_sram_data_eth_c_15), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_15)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i16.GSR = "ENABLED";
    LUT4 i1_2_lut_3_lut (.A(r_para_state[1]), .B(i_read_complete_sig_c), 
         .C(r_para_state[3]), .Z(n1525)) /* synthesis lut_function=(!((B+!(C))+!A)) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(57[4] 108[12])
    defparam i1_2_lut_3_lut.init = 16'h2020;
    LUT4 i995_2_lut_3_lut (.A(r_para_state[5]), .B(r_para_state[4]), .C(r_para_state[6]), 
         .Z(n1755)) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i995_2_lut_3_lut.init = 16'hfefe;
    LUT4 i807_2_lut_rep_39 (.A(r_para_state[1]), .B(r_para_state[5]), .Z(n1820)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i807_2_lut_rep_39.init = 16'heeee;
    LUT4 n1808_bdd_2_lut_3_lut (.A(r_para_state[1]), .B(r_para_state[5]), 
         .C(n1808), .Z(n1809)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam n1808_bdd_2_lut_3_lut.init = 16'h1010;
    LUT4 i1_4_lut_adj_3 (.A(n1771), .B(n1755), .C(r_para_state[1]), .D(i_read_complete_sig_c), 
         .Z(r_para_state_9__N_60[2])) /* synthesis lut_function=(!(A+(B+!(C (D))))) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(57[4] 108[12])
    defparam i1_4_lut_adj_3.init = 16'h1000;
    LUT4 i1_2_lut_rep_40 (.A(r_para_state[1]), .B(r_para_state[2]), .Z(n1821)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_rep_40.init = 16'heeee;
    IB i_sram_data_eth_pad_0 (.I(i_sram_data_eth[0]), .O(i_sram_data_eth_c_0));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_1 (.I(i_sram_data_eth[1]), .O(i_sram_data_eth_c_1));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    FD1P3IX r_pwm_value_0_i0_i9 (.D(i_sram_data_eth_c_8), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_8)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i9.GSR = "ENABLED";
    FD1P3IX r_config_mode_i0_i2 (.D(i_sram_data_eth_c_1), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_1)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i2.GSR = "ENABLED";
    IB i_sram_data_eth_pad_2 (.I(i_sram_data_eth[2]), .O(i_sram_data_eth_c_2));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    FD1P3IX r_config_mode_i0_i3 (.D(i_sram_data_eth_c_2), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_2)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i3.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i2 (.D(i_sram_data_eth_c_1), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_1)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i2.GSR = "ENABLED";
    LUT4 i1003_2_lut_rep_33_3_lut_4_lut (.A(r_para_state[1]), .B(r_para_state[2]), 
         .C(r_para_state[3]), .D(n1822), .Z(i_clk_50m_c_enable_45)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;
    defparam i1003_2_lut_rep_33_3_lut_4_lut.init = 16'h0001;
    OB o_config_mode_pad_2 (.I(o_config_mode_c_2), .O(o_config_mode[2]));   // d:/programs/fpga/c200_fpga/parameter_test.v(15[15:28])
    LUT4 i1_3_lut_4_lut_adj_4 (.A(n1772), .B(n1824), .C(r_para_state[3]), 
         .D(r_para_state[1]), .Z(r_para_state_9__N_60[4])) /* synthesis lut_function=(!(A+(B+((D)+!C)))) */ ;
    defparam i1_3_lut_4_lut_adj_4.init = 16'h0010;
    OB o_sram_addr_eth_pad_2 (.I(GND_net), .O(o_sram_addr_eth[2]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_3 (.I(GND_net), .O(o_sram_addr_eth[3]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_4 (.I(GND_net), .O(o_sram_addr_eth[4]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    LUT4 r_para_state_5__bdd_3_lut (.A(r_para_state[2]), .B(r_para_state[1]), 
         .C(r_para_state[3]), .Z(n1794)) /* synthesis lut_function=(!(A (B+(C))+!A (B))) */ ;
    defparam r_para_state_5__bdd_3_lut.init = 16'h1313;
    FD1P3IX r_config_mode_i0_i4 (.D(i_sram_data_eth_c_3), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_3)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i4.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_5 (.A(r_para_state[6]), .B(n1636), .C(n1794), .D(n1772), 
         .Z(i_clk_50m_c_enable_2)) /* synthesis lut_function=(!(A+(B ((D)+!C)))) */ ;
    defparam i1_4_lut_adj_5.init = 16'h1151;
    OB o_sram_addr_eth_pad_5 (.I(GND_net), .O(o_sram_addr_eth[5]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    LUT4 i997_4_lut (.A(o_rst_n_c), .B(n1796), .C(n1772), .D(r_para_state[2]), 
         .Z(n1757)) /* synthesis lut_function=(A (B+(C+(D)))+!A !((C+(D))+!B)) */ ;
    defparam i997_4_lut.init = 16'haaac;
    FD1P3IX r_config_mode_i0_i5 (.D(i_sram_data_eth_c_4), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_4)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i5.GSR = "ENABLED";
    FD1P3IX r_config_mode_i0_i6 (.D(i_sram_data_eth_c_5), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_5)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i6.GSR = "ENABLED";
    OB o_sram_addr_eth_pad_6 (.I(GND_net), .O(o_sram_addr_eth[6]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_7 (.I(GND_net), .O(o_sram_addr_eth[7]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_8 (.I(GND_net), .O(o_sram_addr_eth[8]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_9 (.I(GND_net), .O(o_sram_addr_eth[9]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_10 (.I(GND_net), .O(o_sram_addr_eth[10]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_11 (.I(GND_net), .O(o_sram_addr_eth[11]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    IB i_sram_data_eth_pad_6 (.I(i_sram_data_eth[6]), .O(i_sram_data_eth_c_6));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_7 (.I(i_sram_data_eth[7]), .O(i_sram_data_eth_c_7));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    OB o_sram_addr_eth_pad_12 (.I(GND_net), .O(o_sram_addr_eth[12]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    IB i_sram_data_eth_pad_8 (.I(i_sram_data_eth[8]), .O(i_sram_data_eth_c_8));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_9 (.I(i_sram_data_eth[9]), .O(i_sram_data_eth_c_9));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    FD1P3IX r_pwm_value_0_i0_i14 (.D(i_sram_data_eth_c_13), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_13)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i14.GSR = "ENABLED";
    FD1P3AX r_rst_n_54 (.D(n1757), .SP(i_clk_50m_c_enable_33), .CK(i_clk_50m_c), 
            .Q(o_rst_n_c)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_rst_n_54.GSR = "ENABLED";
    IB i_sram_data_eth_pad_10 (.I(i_sram_data_eth[10]), .O(i_sram_data_eth_c_10));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_11 (.I(i_sram_data_eth[11]), .O(i_sram_data_eth_c_11));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_12 (.I(i_sram_data_eth[12]), .O(i_sram_data_eth_c_12));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    FD1P3IX r_pwm_value_0_i0_i13 (.D(i_sram_data_eth_c_12), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_12)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i13.GSR = "ENABLED";
    IB i_sram_data_eth_pad_13 (.I(i_sram_data_eth[13]), .O(i_sram_data_eth_c_13));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    VLO i1 (.Z(GND_net));
    FD1P3IX r_config_mode_i0_i7 (.D(i_sram_data_eth_c_6), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_6)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i7.GSR = "ENABLED";
    LUT4 r_para_state_9__I_0_58_i20_1_lut_3_lut_4_lut (.A(n1822), .B(r_para_state[4]), 
         .C(n1821), .D(r_para_state[3]), .Z(o_config_mode_7__N_73)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(82[5:17])
    defparam r_para_state_9__I_0_58_i20_1_lut_3_lut_4_lut.init = 16'h0100;
    LUT4 i485_3_lut_4_lut (.A(n1820), .B(n1818), .C(n29), .D(n1817), 
         .Z(n1233)) /* synthesis lut_function=(A (C+!(D))+!A !(B+!(C+!(D)))) */ ;
    defparam i485_3_lut_4_lut.init = 16'hb0bb;
    OB o_sram_addr_eth_pad_13 (.I(GND_net), .O(o_sram_addr_eth[13]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    FD1P3IX r_config_mode_i0_i8 (.D(i_sram_data_eth_c_7), .SP(i_clk_50m_c_enable_36), 
            .CD(n1231), .CK(i_clk_50m_c), .Q(o_config_mode_c_7)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_config_mode_i0_i8.GSR = "ENABLED";
    FD1P3IX r_pwm_value_0_i0_i10 (.D(i_sram_data_eth_c_9), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_9)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i10.GSR = "ENABLED";
    OB o_sram_addr_eth_pad_14 (.I(GND_net), .O(o_sram_addr_eth[14]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_addr_eth_pad_15 (.I(GND_net), .O(o_sram_addr_eth[15]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    LUT4 i1009_2_lut_rep_32_3_lut_4_lut (.A(r_para_state[1]), .B(r_para_state[2]), 
         .C(r_para_state[4]), .D(n1822), .Z(i_clk_50m_c_enable_36)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;
    defparam i1009_2_lut_rep_32_3_lut_4_lut.init = 16'h0001;
    FD1P3IX r_sram_addr_eth_i2 (.D(n1812), .SP(i_clk_50m_c_enable_38), .CD(n1233), 
            .CK(i_clk_50m_c), .Q(o_sram_addr_eth_c_1)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_sram_addr_eth_i2.GSR = "ENABLED";
    IB i_sram_data_eth_pad_14 (.I(i_sram_data_eth[14]), .O(i_sram_data_eth_c_14));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_sram_data_eth_pad_15 (.I(i_sram_data_eth[15]), .O(i_sram_data_eth_c_15));   // d:/programs/fpga/c200_fpga/parameter_test.v(13[15:30])
    IB i_read_complete_sig_pad (.I(i_read_complete_sig), .O(i_read_complete_sig_c));   // d:/programs/fpga/c200_fpga/parameter_test.v(6[10:29])
    OB o_sram_addr_eth_pad_16 (.I(GND_net), .O(o_sram_addr_eth[16]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    LUT4 i801_rep_9_2_lut (.A(r_para_state[5]), .B(r_para_state[4]), .Z(n1772)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i801_rep_9_2_lut.init = 16'heeee;
    IB i_rst_n_pad (.I(i_rst_n), .O(i_rst_n_c));   // d:/programs/fpga/c200_fpga/parameter_test.v(4[10:17])
    IB i_clk_50m_pad (.I(i_clk_50m), .O(i_clk_50m_c));   // d:/programs/fpga/c200_fpga/parameter_test.v(3[10:19])
    OB o_rst_n_pad (.I(o_rst_n_c), .O(o_rst_n));   // d:/programs/fpga/c200_fpga/parameter_test.v(19[11:18])
    OB o_stop_window_pad_0 (.I(o_stop_window_c_0), .O(o_stop_window[0]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_1 (.I(o_stop_window_c_1), .O(o_stop_window[1]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    LUT4 i811_rep_8_2_lut (.A(r_para_state[2]), .B(r_para_state[3]), .Z(n1771)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i811_rep_8_2_lut.init = 16'heeee;
    LUT4 n1795_bdd_2_lut_3_lut (.A(r_para_state[1]), .B(r_para_state[2]), 
         .C(n1795), .Z(n1796)) /* synthesis lut_function=(!(A+(B+!(C)))) */ ;
    defparam n1795_bdd_2_lut_3_lut.init = 16'h1010;
    OB o_sram_addr_eth_pad_17 (.I(GND_net), .O(o_sram_addr_eth[17]));   // d:/programs/fpga/c200_fpga/parameter_test.v(11[16:31])
    OB o_sram_rden_eth_pad (.I(o_sram_rden_eth_c), .O(o_sram_rden_eth));   // d:/programs/fpga/c200_fpga/parameter_test.v(10[11:26])
    OB o_sram_wren_eth_pad (.I(VCC_net), .O(o_sram_wren_eth));   // d:/programs/fpga/c200_fpga/parameter_test.v(9[11:26])
    FD1P3IX r_pwm_value_0_i0_i11 (.D(i_sram_data_eth_c_10), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_10)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i11.GSR = "ENABLED";
    FD1P3IX r_stop_window_i0_i3 (.D(i_sram_data_eth_c_2), .SP(i_clk_50m_c_enable_40), 
            .CD(n1230), .CK(i_clk_50m_c), .Q(o_stop_window_c_2)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_stop_window_i0_i3.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_6 (.A(n1824), .B(n1823), .C(r_para_state[1]), .D(r_para_state[5]), 
         .Z(r_para_state_9__N_60[6])) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i1_4_lut_adj_6.init = 16'h0100;
    FD1P3IX r_pwm_value_0_i0_i2 (.D(i_sram_data_eth_c_1), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_1)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i2.GSR = "ENABLED";
    OB o_stop_window_pad_2 (.I(o_stop_window_c_2), .O(o_stop_window[2]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_3 (.I(o_stop_window_c_3), .O(o_stop_window[3]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_4 (.I(o_stop_window_c_4), .O(o_stop_window[4]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    FD1P3IX r_pwm_value_0_i0_i3 (.D(i_sram_data_eth_c_2), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_2)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i3.GSR = "ENABLED";
    OB o_stop_window_pad_5 (.I(o_stop_window_c_5), .O(o_stop_window[5]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    LUT4 i1_4_lut_adj_7 (.A(n1736), .B(n1820), .C(r_para_state[2]), .D(r_para_state[4]), 
         .Z(r_para_state_9__N_60[5])) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i1_4_lut_adj_7.init = 16'h0100;
    OB o_stop_window_pad_6 (.I(o_stop_window_c_6), .O(o_stop_window[6]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_7 (.I(o_stop_window_c_7), .O(o_stop_window[7]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_8 (.I(o_stop_window_c_8), .O(o_stop_window[8]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    OB o_stop_window_pad_9 (.I(o_stop_window_c_9), .O(o_stop_window[9]));   // d:/programs/fpga/c200_fpga/parameter_test.v(17[16:29])
    FD1P3IX r_pwm_value_0_i0_i4 (.D(i_sram_data_eth_c_3), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_3)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i4.GSR = "ENABLED";
    FD1P3IX r_pwm_value_0_i0_i5 (.D(i_sram_data_eth_c_4), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_4)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i5.GSR = "ENABLED";
    LUT4 i976_2_lut (.A(r_para_state[6]), .B(r_para_state[3]), .Z(n1736)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i976_2_lut.init = 16'heeee;
    FD1P3IX r_pwm_value_0_i0_i15 (.D(i_sram_data_eth_c_14), .SP(i_clk_50m_c_enable_45), 
            .CD(n1237), .CK(i_clk_50m_c), .Q(o_pwm_value_0_c_14)) /* synthesis lse_init_val=0 */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(56[8] 109[7])
    defparam r_pwm_value_0_i0_i15.GSR = "ENABLED";
    LUT4 n1574_bdd_2_lut_3_lut_4_lut (.A(r_para_state[1]), .B(r_para_state[2]), 
         .C(r_para_state[5]), .D(n1823), .Z(n1803)) /* synthesis lut_function=(!(A+(B+(C+(D))))) */ ;
    defparam n1574_bdd_2_lut_3_lut_4_lut.init = 16'h0001;
    LUT4 n1558_bdd_4_lut (.A(r_para_state[4]), .B(r_para_state[6]), .C(r_para_state[2]), 
         .D(r_para_state[3]), .Z(n1808)) /* synthesis lut_function=(!(A (B+(C+(D)))+!A (B+(C (D)+!C !(D))))) */ ;
    defparam n1558_bdd_4_lut.init = 16'h0112;
    LUT4 i1_4_lut_adj_8 (.A(r_para_state[4]), .B(n1771), .C(r_para_state[1]), 
         .D(r_para_state[5]), .Z(n1636)) /* synthesis lut_function=(A (B+(C+(D)))+!A (B+(C))) */ ;
    defparam i1_4_lut_adj_8.init = 16'hfefc;
    LUT4 i1_3_lut_rep_31_4_lut (.A(n1822), .B(r_para_state[4]), .C(n1821), 
         .D(r_para_state[3]), .Z(n1812)) /* synthesis lut_function=(A+(B+(C+!(D)))) */ ;   // d:/programs/fpga/c200_fpga/parameter_test.v(82[5:17])
    defparam i1_3_lut_rep_31_4_lut.init = 16'hfeff;
    LUT4 i482_2_lut_3_lut_4_lut_3_lut (.A(r_para_state[6]), .B(r_para_state[5]), 
         .C(n1816), .Z(n1230)) /* synthesis lut_function=(!(A+(B+(C)))) */ ;
    defparam i482_2_lut_3_lut_4_lut_3_lut.init = 16'h0101;
    LUT4 i980_2_lut_rep_41 (.A(r_para_state[6]), .B(r_para_state[5]), .Z(n1822)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i980_2_lut_rep_41.init = 16'heeee;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

