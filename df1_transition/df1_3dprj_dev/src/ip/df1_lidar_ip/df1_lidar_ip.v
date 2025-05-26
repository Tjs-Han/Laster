/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module df1_lidar_ip
//
module df1_lidar_ip (asfifo_256x64_Data, asfifo_256x64_Q, asfifo_256x96_Data, 
            asfifo_256x96_Q, asfifo_decode_Data, asfifo_decode_Q, code_ram128x32_Data, 
            code_ram128x32_Q, code_ram128x32_RdAddress, code_ram128x32_WrAddress, 
            dataram_1024x8_Data, dataram_1024x8_Q, dataram_1024x8_RdAddress, 
            dataram_1024x8_WrAddress, dataram_2048x8_Data, dataram_2048x8_Q, 
            dataram_2048x8_RdAddress, dataram_2048x8_WrAddress, dcfifo_rmiirx_36x2_Data, 
            dcfifo_rmiirx_36x2_Q, dcfifo_rmiitx_2048x2_Data, dcfifo_rmiitx_2048x2_Q, 
            dcfifo_rmiitx_4096x2_Data, dcfifo_rmiitx_4096x2_Q, divider_24bit_denominator, 
            divider_24bit_numerator, divider_24bit_quotient, divider_24bit_remainder, 
            divider_32x24_denominator, divider_32x24_numerator, divider_32x24_quotient, 
            divider_32x24_remainder, divider_34x16_denominator, divider_34x16_numerator, 
            divider_34x16_quotient, divider_34x16_remainder, fifo_mac_frame_2048x10_Data, 
            fifo_mac_frame_2048x10_Q, iddrx2f_datain, iddrx2f_dcntl, iddrx2f_q, 
            mpt2042_rom_Address, mpt2042_rom_Q, multiplier_10x32_DataA, 
            multiplier_10x32_DataB, multiplier_10x32_Result, multiplier_16x8_DataA, 
            multiplier_16x8_DataB, multiplier_16x8_Result, multiplier_DataA, 
            multiplier_DataB, multiplier_Result, multiplier_in32bit_DataA, 
            multiplier_in32bit_DataB, multiplier_in32bit_Result, sfifo128x88_Data, 
            sfifo128x88_Q, sfifo_128x96_Data, sfifo_128x96_Q, sfifo_64x48_Data, 
            sfifo_64x48_Q, sub_ip_DataA, sub_ip_DataB, sub_ip_Result, 
            synfifo_data_2048x8_Data, synfifo_data_2048x8_Q, asfifo_256x64_Empty, 
            asfifo_256x64_Full, asfifo_256x64_RPReset, asfifo_256x64_RdClock, 
            asfifo_256x64_RdEn, asfifo_256x64_Reset, asfifo_256x64_WrClock, 
            asfifo_256x64_WrEn, asfifo_256x96_Empty, asfifo_256x96_Full, 
            asfifo_256x96_RPReset, asfifo_256x96_RdClock, asfifo_256x96_RdEn, 
            asfifo_256x96_Reset, asfifo_256x96_WrClock, asfifo_256x96_WrEn, 
            asfifo_decode_Empty, asfifo_decode_Full, asfifo_decode_RPReset, 
            asfifo_decode_RdClock, asfifo_decode_RdEn, asfifo_decode_Reset, 
            asfifo_decode_WrClock, asfifo_decode_WrEn, code_ram128x32_RdClock, 
            code_ram128x32_RdClockEn, code_ram128x32_Reset, code_ram128x32_WE, 
            code_ram128x32_WrClock, code_ram128x32_WrClockEn, dataram_1024x8_RdClock, 
            dataram_1024x8_RdClockEn, dataram_1024x8_Reset, dataram_1024x8_WE, 
            dataram_1024x8_WrClock, dataram_1024x8_WrClockEn, dataram_2048x8_RdClock, 
            dataram_2048x8_RdClockEn, dataram_2048x8_Reset, dataram_2048x8_WE, 
            dataram_2048x8_WrClock, dataram_2048x8_WrClockEn, dcfifo_rmiirx_36x2_Empty, 
            dcfifo_rmiirx_36x2_Full, dcfifo_rmiirx_36x2_RPReset, dcfifo_rmiirx_36x2_RdClock, 
            dcfifo_rmiirx_36x2_RdEn, dcfifo_rmiirx_36x2_Reset, dcfifo_rmiirx_36x2_WrClock, 
            dcfifo_rmiirx_36x2_WrEn, dcfifo_rmiitx_2048x2_Empty, dcfifo_rmiitx_2048x2_Full, 
            dcfifo_rmiitx_2048x2_RPReset, dcfifo_rmiitx_2048x2_RdClock, 
            dcfifo_rmiitx_2048x2_RdEn, dcfifo_rmiitx_2048x2_Reset, dcfifo_rmiitx_2048x2_WrClock, 
            dcfifo_rmiitx_2048x2_WrEn, dcfifo_rmiitx_4096x2_Empty, dcfifo_rmiitx_4096x2_Full, 
            dcfifo_rmiitx_4096x2_RPReset, dcfifo_rmiitx_4096x2_RdClock, 
            dcfifo_rmiitx_4096x2_RdEn, dcfifo_rmiitx_4096x2_Reset, dcfifo_rmiitx_4096x2_WrClock, 
            dcfifo_rmiitx_4096x2_WrEn, divider_24bit_clk, divider_24bit_rstn, 
            divider_32x24_clk, divider_32x24_rstn, divider_34x16_clk, 
            divider_34x16_dvalid_in, divider_34x16_dvalid_out, divider_34x16_rstn, 
            eth_pll_CLKI, eth_pll_CLKOP, fifo_mac_frame_2048x10_Clock, 
            fifo_mac_frame_2048x10_Empty, fifo_mac_frame_2048x10_Full, fifo_mac_frame_2048x10_RdEn, 
            fifo_mac_frame_2048x10_Reset, fifo_mac_frame_2048x10_WrEn, iddrx2f_alignwd, 
            iddrx2f_clkin, iddrx2f_ready, iddrx2f_sclk, iddrx2f_sync_clk, 
            iddrx2f_sync_reset, iddrx2f_update, mpt2042_rom_OutClock, 
            mpt2042_rom_OutClockEn, mpt2042_rom_Reset, multiplier_10x32_Aclr, 
            multiplier_10x32_ClkEn, multiplier_10x32_Clock, multiplier_16x8_Aclr, 
            multiplier_16x8_ClkEn, multiplier_16x8_Clock, multiplier_Aclr, 
            multiplier_ClkEn, multiplier_Clock, multiplier_in32bit_Aclr, 
            multiplier_in32bit_ClkEn, multiplier_in32bit_Clock, pll_CLKI, 
            pll_CLKOP, pll_CLKOS, pll_CLKOS2, pll_LOCK, sfifo128x88_Clock, 
            sfifo128x88_Empty, sfifo128x88_Full, sfifo128x88_RdEn, sfifo128x88_Reset, 
            sfifo128x88_WrEn, sfifo_128x96_Clock, sfifo_128x96_Empty, 
            sfifo_128x96_Full, sfifo_128x96_RdEn, sfifo_128x96_Reset, 
            sfifo_128x96_WrEn, sfifo_64x48_Clock, sfifo_64x48_Empty, sfifo_64x48_Full, 
            sfifo_64x48_RdEn, sfifo_64x48_Reset, sfifo_64x48_WrEn, synfifo_data_2048x8_Clock, 
            synfifo_data_2048x8_Empty, synfifo_data_2048x8_Full, synfifo_data_2048x8_RdEn, 
            synfifo_data_2048x8_Reset, synfifo_data_2048x8_WrEn) /* synthesis sbp_module=true */ ;
    input [63:0]asfifo_256x64_Data;
    output [63:0]asfifo_256x64_Q;
    input [95:0]asfifo_256x96_Data;
    output [95:0]asfifo_256x96_Q;
    input [9:0]asfifo_decode_Data;
    output [9:0]asfifo_decode_Q;
    input [31:0]code_ram128x32_Data;
    output [7:0]code_ram128x32_Q;
    input [8:0]code_ram128x32_RdAddress;
    input [6:0]code_ram128x32_WrAddress;
    input [7:0]dataram_1024x8_Data;
    output [7:0]dataram_1024x8_Q;
    input [9:0]dataram_1024x8_RdAddress;
    input [9:0]dataram_1024x8_WrAddress;
    input [7:0]dataram_2048x8_Data;
    output [7:0]dataram_2048x8_Q;
    input [10:0]dataram_2048x8_RdAddress;
    input [10:0]dataram_2048x8_WrAddress;
    input [1:0]dcfifo_rmiirx_36x2_Data;
    output [1:0]dcfifo_rmiirx_36x2_Q;
    input [1:0]dcfifo_rmiitx_2048x2_Data;
    output [1:0]dcfifo_rmiitx_2048x2_Q;
    input [1:0]dcfifo_rmiitx_4096x2_Data;
    output [1:0]dcfifo_rmiitx_4096x2_Q;
    input [15:0]divider_24bit_denominator;
    input [23:0]divider_24bit_numerator;
    output [23:0]divider_24bit_quotient;
    output [15:0]divider_24bit_remainder;
    input [23:0]divider_32x24_denominator;
    input [31:0]divider_32x24_numerator;
    output [31:0]divider_32x24_quotient;
    output [23:0]divider_32x24_remainder;
    input [15:0]divider_34x16_denominator;
    input [33:0]divider_34x16_numerator;
    output [33:0]divider_34x16_quotient;
    output [15:0]divider_34x16_remainder;
    input [9:0]fifo_mac_frame_2048x10_Data;
    output [9:0]fifo_mac_frame_2048x10_Q;
    input [0:0]iddrx2f_datain;
    output [7:0]iddrx2f_dcntl;
    output [3:0]iddrx2f_q;
    input [6:0]mpt2042_rom_Address;
    output [7:0]mpt2042_rom_Q;
    input [9:0]multiplier_10x32_DataA;
    input [23:0]multiplier_10x32_DataB;
    output [33:0]multiplier_10x32_Result;
    input [15:0]multiplier_16x8_DataA;
    input [7:0]multiplier_16x8_DataB;
    output [23:0]multiplier_16x8_Result;
    input [15:0]multiplier_DataA;
    input [15:0]multiplier_DataB;
    output [31:0]multiplier_Result;
    input [9:0]multiplier_in32bit_DataA;
    input [31:0]multiplier_in32bit_DataB;
    output [41:0]multiplier_in32bit_Result;
    input [87:0]sfifo128x88_Data;
    output [87:0]sfifo128x88_Q;
    input [95:0]sfifo_128x96_Data;
    output [95:0]sfifo_128x96_Q;
    input [47:0]sfifo_64x48_Data;
    output [47:0]sfifo_64x48_Q;
    input [31:0]sub_ip_DataA;
    input [31:0]sub_ip_DataB;
    output [31:0]sub_ip_Result;
    input [7:0]synfifo_data_2048x8_Data;
    output [7:0]synfifo_data_2048x8_Q;
    output asfifo_256x64_Empty;
    output asfifo_256x64_Full;
    input asfifo_256x64_RPReset;
    input asfifo_256x64_RdClock;
    input asfifo_256x64_RdEn;
    input asfifo_256x64_Reset;
    input asfifo_256x64_WrClock;
    input asfifo_256x64_WrEn;
    output asfifo_256x96_Empty;
    output asfifo_256x96_Full;
    input asfifo_256x96_RPReset;
    input asfifo_256x96_RdClock;
    input asfifo_256x96_RdEn;
    input asfifo_256x96_Reset;
    input asfifo_256x96_WrClock;
    input asfifo_256x96_WrEn;
    output asfifo_decode_Empty;
    output asfifo_decode_Full;
    input asfifo_decode_RPReset;
    input asfifo_decode_RdClock;
    input asfifo_decode_RdEn;
    input asfifo_decode_Reset;
    input asfifo_decode_WrClock;
    input asfifo_decode_WrEn;
    input code_ram128x32_RdClock;
    input code_ram128x32_RdClockEn;
    input code_ram128x32_Reset;
    input code_ram128x32_WE;
    input code_ram128x32_WrClock;
    input code_ram128x32_WrClockEn;
    input dataram_1024x8_RdClock;
    input dataram_1024x8_RdClockEn;
    input dataram_1024x8_Reset;
    input dataram_1024x8_WE;
    input dataram_1024x8_WrClock;
    input dataram_1024x8_WrClockEn;
    input dataram_2048x8_RdClock;
    input dataram_2048x8_RdClockEn;
    input dataram_2048x8_Reset;
    input dataram_2048x8_WE;
    input dataram_2048x8_WrClock;
    input dataram_2048x8_WrClockEn;
    output dcfifo_rmiirx_36x2_Empty;
    output dcfifo_rmiirx_36x2_Full;
    input dcfifo_rmiirx_36x2_RPReset;
    input dcfifo_rmiirx_36x2_RdClock;
    input dcfifo_rmiirx_36x2_RdEn;
    input dcfifo_rmiirx_36x2_Reset;
    input dcfifo_rmiirx_36x2_WrClock;
    input dcfifo_rmiirx_36x2_WrEn;
    output dcfifo_rmiitx_2048x2_Empty;
    output dcfifo_rmiitx_2048x2_Full;
    input dcfifo_rmiitx_2048x2_RPReset;
    input dcfifo_rmiitx_2048x2_RdClock;
    input dcfifo_rmiitx_2048x2_RdEn;
    input dcfifo_rmiitx_2048x2_Reset;
    input dcfifo_rmiitx_2048x2_WrClock;
    input dcfifo_rmiitx_2048x2_WrEn;
    output dcfifo_rmiitx_4096x2_Empty;
    output dcfifo_rmiitx_4096x2_Full;
    input dcfifo_rmiitx_4096x2_RPReset;
    input dcfifo_rmiitx_4096x2_RdClock;
    input dcfifo_rmiitx_4096x2_RdEn;
    input dcfifo_rmiitx_4096x2_Reset;
    input dcfifo_rmiitx_4096x2_WrClock;
    input dcfifo_rmiitx_4096x2_WrEn;
    input divider_24bit_clk;
    input divider_24bit_rstn;
    input divider_32x24_clk;
    input divider_32x24_rstn;
    input divider_34x16_clk;
    input divider_34x16_dvalid_in;
    output divider_34x16_dvalid_out;
    input divider_34x16_rstn;
    input eth_pll_CLKI;
    output eth_pll_CLKOP;
    input fifo_mac_frame_2048x10_Clock;
    output fifo_mac_frame_2048x10_Empty;
    output fifo_mac_frame_2048x10_Full;
    input fifo_mac_frame_2048x10_RdEn;
    input fifo_mac_frame_2048x10_Reset;
    input fifo_mac_frame_2048x10_WrEn;
    input iddrx2f_alignwd;
    input iddrx2f_clkin;
    output iddrx2f_ready;
    output iddrx2f_sclk;
    input iddrx2f_sync_clk;
    input iddrx2f_sync_reset;
    input iddrx2f_update;
    input mpt2042_rom_OutClock;
    input mpt2042_rom_OutClockEn;
    input mpt2042_rom_Reset;
    input multiplier_10x32_Aclr;
    input multiplier_10x32_ClkEn;
    input multiplier_10x32_Clock;
    input multiplier_16x8_Aclr;
    input multiplier_16x8_ClkEn;
    input multiplier_16x8_Clock;
    input multiplier_Aclr;
    input multiplier_ClkEn;
    input multiplier_Clock;
    input multiplier_in32bit_Aclr;
    input multiplier_in32bit_ClkEn;
    input multiplier_in32bit_Clock;
    input pll_CLKI;
    output pll_CLKOP;
    output pll_CLKOS;
    output pll_CLKOS2;
    output pll_LOCK;
    input sfifo128x88_Clock;
    output sfifo128x88_Empty;
    output sfifo128x88_Full;
    input sfifo128x88_RdEn;
    input sfifo128x88_Reset;
    input sfifo128x88_WrEn;
    input sfifo_128x96_Clock;
    output sfifo_128x96_Empty;
    output sfifo_128x96_Full;
    input sfifo_128x96_RdEn;
    input sfifo_128x96_Reset;
    input sfifo_128x96_WrEn;
    input sfifo_64x48_Clock;
    output sfifo_64x48_Empty;
    output sfifo_64x48_Full;
    input sfifo_64x48_RdEn;
    input sfifo_64x48_Reset;
    input sfifo_64x48_WrEn;
    input synfifo_data_2048x8_Clock;
    output synfifo_data_2048x8_Empty;
    output synfifo_data_2048x8_Full;
    input synfifo_data_2048x8_RdEn;
    input synfifo_data_2048x8_Reset;
    input synfifo_data_2048x8_WrEn;
    
    
    asfifo_256x64 asfifo_256x64_inst (.Data({asfifo_256x64_Data}), .Q({asfifo_256x64_Q}), 
            .Empty(asfifo_256x64_Empty), .Full(asfifo_256x64_Full), .RPReset(asfifo_256x64_RPReset), 
            .RdClock(asfifo_256x64_RdClock), .RdEn(asfifo_256x64_RdEn), 
            .Reset(asfifo_256x64_Reset), .WrClock(asfifo_256x64_WrClock), 
            .WrEn(asfifo_256x64_WrEn));
    asfifo_256x96 asfifo_256x96_inst (.Data({asfifo_256x96_Data}), .Q({asfifo_256x96_Q}), 
            .Empty(asfifo_256x96_Empty), .Full(asfifo_256x96_Full), .RPReset(asfifo_256x96_RPReset), 
            .RdClock(asfifo_256x96_RdClock), .RdEn(asfifo_256x96_RdEn), 
            .Reset(asfifo_256x96_Reset), .WrClock(asfifo_256x96_WrClock), 
            .WrEn(asfifo_256x96_WrEn));
    asfifo_decode asfifo_decode_inst (.Data({asfifo_decode_Data}), .Q({asfifo_decode_Q}), 
            .Empty(asfifo_decode_Empty), .Full(asfifo_decode_Full), .RPReset(asfifo_decode_RPReset), 
            .RdClock(asfifo_decode_RdClock), .RdEn(asfifo_decode_RdEn), 
            .Reset(asfifo_decode_Reset), .WrClock(asfifo_decode_WrClock), 
            .WrEn(asfifo_decode_WrEn));
    code_ram128x32 code_ram128x32_inst (.Data({code_ram128x32_Data}), .Q({code_ram128x32_Q}), 
            .RdAddress({code_ram128x32_RdAddress}), .WrAddress({code_ram128x32_WrAddress}), 
            .RdClock(code_ram128x32_RdClock), .RdClockEn(code_ram128x32_RdClockEn), 
            .Reset(code_ram128x32_Reset), .WE(code_ram128x32_WE), .WrClock(code_ram128x32_WrClock), 
            .WrClockEn(code_ram128x32_WrClockEn));
    dataram_1024x8 dataram_1024x8_inst (.Data({dataram_1024x8_Data}), .Q({dataram_1024x8_Q}), 
            .RdAddress({dataram_1024x8_RdAddress}), .WrAddress({dataram_1024x8_WrAddress}), 
            .RdClock(dataram_1024x8_RdClock), .RdClockEn(dataram_1024x8_RdClockEn), 
            .Reset(dataram_1024x8_Reset), .WE(dataram_1024x8_WE), .WrClock(dataram_1024x8_WrClock), 
            .WrClockEn(dataram_1024x8_WrClockEn));
    dataram_2048x8 dataram_2048x8_inst (.Data({dataram_2048x8_Data}), .Q({dataram_2048x8_Q}), 
            .RdAddress({dataram_2048x8_RdAddress}), .WrAddress({dataram_2048x8_WrAddress}), 
            .RdClock(dataram_2048x8_RdClock), .RdClockEn(dataram_2048x8_RdClockEn), 
            .Reset(dataram_2048x8_Reset), .WE(dataram_2048x8_WE), .WrClock(dataram_2048x8_WrClock), 
            .WrClockEn(dataram_2048x8_WrClockEn));
    dcfifo_rmiirx_36x2 dcfifo_rmiirx_36x2_inst (.Data({dcfifo_rmiirx_36x2_Data}), 
            .Q({dcfifo_rmiirx_36x2_Q}), .Empty(dcfifo_rmiirx_36x2_Empty), 
            .Full(dcfifo_rmiirx_36x2_Full), .RPReset(dcfifo_rmiirx_36x2_RPReset), 
            .RdClock(dcfifo_rmiirx_36x2_RdClock), .RdEn(dcfifo_rmiirx_36x2_RdEn), 
            .Reset(dcfifo_rmiirx_36x2_Reset), .WrClock(dcfifo_rmiirx_36x2_WrClock), 
            .WrEn(dcfifo_rmiirx_36x2_WrEn));
    dcfifo_rmiitx_2048x2 dcfifo_rmiitx_2048x2_inst (.Data({dcfifo_rmiitx_2048x2_Data}), 
            .Q({dcfifo_rmiitx_2048x2_Q}), .Empty(dcfifo_rmiitx_2048x2_Empty), 
            .Full(dcfifo_rmiitx_2048x2_Full), .RPReset(dcfifo_rmiitx_2048x2_RPReset), 
            .RdClock(dcfifo_rmiitx_2048x2_RdClock), .RdEn(dcfifo_rmiitx_2048x2_RdEn), 
            .Reset(dcfifo_rmiitx_2048x2_Reset), .WrClock(dcfifo_rmiitx_2048x2_WrClock), 
            .WrEn(dcfifo_rmiitx_2048x2_WrEn));
    dcfifo_rmiitx_4096x2 dcfifo_rmiitx_4096x2_inst (.Data({dcfifo_rmiitx_4096x2_Data}), 
            .Q({dcfifo_rmiitx_4096x2_Q}), .Empty(dcfifo_rmiitx_4096x2_Empty), 
            .Full(dcfifo_rmiitx_4096x2_Full), .RPReset(dcfifo_rmiitx_4096x2_RPReset), 
            .RdClock(dcfifo_rmiitx_4096x2_RdClock), .RdEn(dcfifo_rmiitx_4096x2_RdEn), 
            .Reset(dcfifo_rmiitx_4096x2_Reset), .WrClock(dcfifo_rmiitx_4096x2_WrClock), 
            .WrEn(dcfifo_rmiitx_4096x2_WrEn));
    divider_24bit divider_24bit_inst (.denominator({divider_24bit_denominator}), 
            .numerator({divider_24bit_numerator}), .quotient({divider_24bit_quotient}), 
            .remainder({divider_24bit_remainder}), .clk(divider_24bit_clk), 
            .rstn(divider_24bit_rstn));
    divider_32x24 divider_32x24_inst (.denominator({divider_32x24_denominator}), 
            .numerator({divider_32x24_numerator}), .quotient({divider_32x24_quotient}), 
            .remainder({divider_32x24_remainder}), .clk(divider_32x24_clk), 
            .rstn(divider_32x24_rstn));
    divider_34x16 divider_34x16_inst (.denominator({divider_34x16_denominator}), 
            .numerator({divider_34x16_numerator}), .quotient({divider_34x16_quotient}), 
            .remainder({divider_34x16_remainder}), .clk(divider_34x16_clk), 
            .dvalid_in(divider_34x16_dvalid_in), .dvalid_out(divider_34x16_dvalid_out), 
            .rstn(divider_34x16_rstn));
    eth_pll eth_pll_inst (.CLKI(eth_pll_CLKI), .CLKOP(eth_pll_CLKOP));
    fifo_mac_frame_2048x10 fifo_mac_frame_2048x10_inst (.Data({fifo_mac_frame_2048x10_Data}), 
            .Q({fifo_mac_frame_2048x10_Q}), .Clock(fifo_mac_frame_2048x10_Clock), 
            .Empty(fifo_mac_frame_2048x10_Empty), .Full(fifo_mac_frame_2048x10_Full), 
            .RdEn(fifo_mac_frame_2048x10_RdEn), .Reset(fifo_mac_frame_2048x10_Reset), 
            .WrEn(fifo_mac_frame_2048x10_WrEn));
    iddrx2f iddrx2f_inst (.datain({iddrx2f_datain}), .dcntl({iddrx2f_dcntl}), 
            .q({iddrx2f_q}), .alignwd(iddrx2f_alignwd), .clkin(iddrx2f_clkin), 
            .ready(iddrx2f_ready), .sclk(iddrx2f_sclk), .sync_clk(iddrx2f_sync_clk), 
            .sync_reset(iddrx2f_sync_reset), .update(iddrx2f_update));
    mpt2042_rom mpt2042_rom_inst (.Address({mpt2042_rom_Address}), .Q({mpt2042_rom_Q}), 
            .OutClock(mpt2042_rom_OutClock), .OutClockEn(mpt2042_rom_OutClockEn), 
            .Reset(mpt2042_rom_Reset));
    multiplier multiplier_inst (.DataA({multiplier_DataA}), .DataB({multiplier_DataB}), 
            .Result({multiplier_Result}), .Aclr(multiplier_Aclr), .ClkEn(multiplier_ClkEn), 
            .Clock(multiplier_Clock));
    multiplier_10x32 multiplier_10x32_inst (.DataA({multiplier_10x32_DataA}), 
            .DataB({multiplier_10x32_DataB}), .Result({multiplier_10x32_Result}), 
            .Aclr(multiplier_10x32_Aclr), .ClkEn(multiplier_10x32_ClkEn), 
            .Clock(multiplier_10x32_Clock));
    multiplier_16x8 multiplier_16x8_inst (.DataA({multiplier_16x8_DataA}), 
            .DataB({multiplier_16x8_DataB}), .Result({multiplier_16x8_Result}), 
            .Aclr(multiplier_16x8_Aclr), .ClkEn(multiplier_16x8_ClkEn), 
            .Clock(multiplier_16x8_Clock));
    multiplier_in32bit multiplier_in32bit_inst (.DataA({multiplier_in32bit_DataA}), 
            .DataB({multiplier_in32bit_DataB}), .Result({multiplier_in32bit_Result}), 
            .Aclr(multiplier_in32bit_Aclr), .ClkEn(multiplier_in32bit_ClkEn), 
            .Clock(multiplier_in32bit_Clock));
    pll pll_inst (.CLKI(pll_CLKI), .CLKOP(pll_CLKOP), .CLKOS(pll_CLKOS), 
        .CLKOS2(pll_CLKOS2), .LOCK(pll_LOCK));
    sfifo128x88 sfifo128x88_inst (.Data({sfifo128x88_Data}), .Q({sfifo128x88_Q}), 
            .Clock(sfifo128x88_Clock), .Empty(sfifo128x88_Empty), .Full(sfifo128x88_Full), 
            .RdEn(sfifo128x88_RdEn), .Reset(sfifo128x88_Reset), .WrEn(sfifo128x88_WrEn));
    sfifo_128x96 sfifo_128x96_inst (.Data({sfifo_128x96_Data}), .Q({sfifo_128x96_Q}), 
            .Clock(sfifo_128x96_Clock), .Empty(sfifo_128x96_Empty), .Full(sfifo_128x96_Full), 
            .RdEn(sfifo_128x96_RdEn), .Reset(sfifo_128x96_Reset), .WrEn(sfifo_128x96_WrEn));
    sfifo_64x48 sfifo_64x48_inst (.Data({sfifo_64x48_Data}), .Q({sfifo_64x48_Q}), 
            .Clock(sfifo_64x48_Clock), .Empty(sfifo_64x48_Empty), .Full(sfifo_64x48_Full), 
            .RdEn(sfifo_64x48_RdEn), .Reset(sfifo_64x48_Reset), .WrEn(sfifo_64x48_WrEn));
    sub_ip sub_ip_inst (.DataA({sub_ip_DataA}), .DataB({sub_ip_DataB}), 
           .Result({sub_ip_Result}));
    synfifo_data_2048x8 synfifo_data_2048x8_inst (.Data({synfifo_data_2048x8_Data}), 
            .Q({synfifo_data_2048x8_Q}), .Clock(synfifo_data_2048x8_Clock), 
            .Empty(synfifo_data_2048x8_Empty), .Full(synfifo_data_2048x8_Full), 
            .RdEn(synfifo_data_2048x8_RdEn), .Reset(synfifo_data_2048x8_Reset), 
            .WrEn(synfifo_data_2048x8_WrEn));
    
endmodule

