/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module c25x_fpga_ip
//
module c25x_fpga_ip (cache_opto_ram_Data, cache_opto_ram_Q, cache_opto_ram_RdAddress, 
            cache_opto_ram_WrAddress, distance_ram_Data, distance_ram_Q, 
            distance_ram_RdAddress, distance_ram_WrAddress, eth_data_ram_Data, 
            eth_data_ram_Q, eth_data_ram_RdAddress, eth_data_ram_WrAddress, 
            eth_send_ram_Data, eth_send_ram_Q, eth_send_ram_RdAddress, 
            eth_send_ram_WrAddress, multiplier3_DataA, multiplier3_DataB, 
            multiplier3_Result, multiplier_DataA, multiplier_DataB, multiplier_Result, 
            opto_ram_Data, opto_ram_Q, opto_ram_RdAddress, opto_ram_WrAddress, 
            packet_data_ram_Data, packet_data_ram_Q, packet_data_ram_RdAddress, 
            packet_data_ram_WrAddress, tcp_recv_fifo_Data, tcp_recv_fifo_Q, 
            tcp_recv_fifo_WCNT, c25x_pll_CLKI, c25x_pll_CLKOP, c25x_pll_CLKOS, 
            c25x_pll_CLKOS2, cache_opto_ram_RdClock, cache_opto_ram_RdClockEn, 
            cache_opto_ram_Reset, cache_opto_ram_WE, cache_opto_ram_WrClock, 
            cache_opto_ram_WrClockEn, distance_ram_RdClock, distance_ram_RdClockEn, 
            distance_ram_Reset, distance_ram_WE, distance_ram_WrClock, 
            distance_ram_WrClockEn, eth_data_ram_RdClock, eth_data_ram_RdClockEn, 
            eth_data_ram_Reset, eth_data_ram_WE, eth_data_ram_WrClock, 
            eth_data_ram_WrClockEn, eth_send_ram_RdClock, eth_send_ram_RdClockEn, 
            eth_send_ram_Reset, eth_send_ram_WE, eth_send_ram_WrClock, 
            eth_send_ram_WrClockEn, multiplier3_Aclr, multiplier3_ClkEn, 
            multiplier3_Clock, multiplier_Aclr, multiplier_ClkEn, multiplier_Clock, 
            opto_ram_RdClock, opto_ram_RdClockEn, opto_ram_Reset, opto_ram_WE, 
            opto_ram_WrClock, opto_ram_WrClockEn, packet_data_ram_RdClock, 
            packet_data_ram_RdClockEn, packet_data_ram_Reset, packet_data_ram_WE, 
            packet_data_ram_WrClock, packet_data_ram_WrClockEn, tcp_recv_fifo_Clock, 
            tcp_recv_fifo_Empty, tcp_recv_fifo_Full, tcp_recv_fifo_RdEn, 
            tcp_recv_fifo_Reset, tcp_recv_fifo_WrEn) /* synthesis sbp_module=true */ ;
    input [15:0]cache_opto_ram_Data;
    output [15:0]cache_opto_ram_Q;
    input [7:0]cache_opto_ram_RdAddress;
    input [7:0]cache_opto_ram_WrAddress;
    input [63:0]distance_ram_Data;
    output [63:0]distance_ram_Q;
    input [7:0]distance_ram_RdAddress;
    input [7:0]distance_ram_WrAddress;
    input [7:0]eth_data_ram_Data;
    output [7:0]eth_data_ram_Q;
    input [9:0]eth_data_ram_RdAddress;
    input [9:0]eth_data_ram_WrAddress;
    input [7:0]eth_send_ram_Data;
    output [7:0]eth_send_ram_Q;
    input [10:0]eth_send_ram_RdAddress;
    input [10:0]eth_send_ram_WrAddress;
    input [7:0]multiplier3_DataA;
    input [7:0]multiplier3_DataB;
    output [15:0]multiplier3_Result;
    input [15:0]multiplier_DataA;
    input [15:0]multiplier_DataB;
    output [31:0]multiplier_Result;
    input [7:0]opto_ram_Data;
    output [7:0]opto_ram_Q;
    input [7:0]opto_ram_RdAddress;
    input [7:0]opto_ram_WrAddress;
    input [7:0]packet_data_ram_Data;
    output [7:0]packet_data_ram_Q;
    input [9:0]packet_data_ram_RdAddress;
    input [9:0]packet_data_ram_WrAddress;
    input [7:0]tcp_recv_fifo_Data;
    output [7:0]tcp_recv_fifo_Q;
    output [11:0]tcp_recv_fifo_WCNT;
    input c25x_pll_CLKI;
    output c25x_pll_CLKOP;
    output c25x_pll_CLKOS;
    output c25x_pll_CLKOS2;
    input cache_opto_ram_RdClock;
    input cache_opto_ram_RdClockEn;
    input cache_opto_ram_Reset;
    input cache_opto_ram_WE;
    input cache_opto_ram_WrClock;
    input cache_opto_ram_WrClockEn;
    input distance_ram_RdClock;
    input distance_ram_RdClockEn;
    input distance_ram_Reset;
    input distance_ram_WE;
    input distance_ram_WrClock;
    input distance_ram_WrClockEn;
    input eth_data_ram_RdClock;
    input eth_data_ram_RdClockEn;
    input eth_data_ram_Reset;
    input eth_data_ram_WE;
    input eth_data_ram_WrClock;
    input eth_data_ram_WrClockEn;
    input eth_send_ram_RdClock;
    input eth_send_ram_RdClockEn;
    input eth_send_ram_Reset;
    input eth_send_ram_WE;
    input eth_send_ram_WrClock;
    input eth_send_ram_WrClockEn;
    input multiplier3_Aclr;
    input multiplier3_ClkEn;
    input multiplier3_Clock;
    input multiplier_Aclr;
    input multiplier_ClkEn;
    input multiplier_Clock;
    input opto_ram_RdClock;
    input opto_ram_RdClockEn;
    input opto_ram_Reset;
    input opto_ram_WE;
    input opto_ram_WrClock;
    input opto_ram_WrClockEn;
    input packet_data_ram_RdClock;
    input packet_data_ram_RdClockEn;
    input packet_data_ram_Reset;
    input packet_data_ram_WE;
    input packet_data_ram_WrClock;
    input packet_data_ram_WrClockEn;
    input tcp_recv_fifo_Clock;
    output tcp_recv_fifo_Empty;
    output tcp_recv_fifo_Full;
    input tcp_recv_fifo_RdEn;
    input tcp_recv_fifo_Reset;
    input tcp_recv_fifo_WrEn;
    
    
    c25x_pll c25x_pll_inst (.CLKI(c25x_pll_CLKI), .CLKOP(c25x_pll_CLKOP), 
            .CLKOS(c25x_pll_CLKOS), .CLKOS2(c25x_pll_CLKOS2));
    cache_opto_ram cache_opto_ram_inst (.Data({cache_opto_ram_Data}), .Q({cache_opto_ram_Q}), 
            .RdAddress({cache_opto_ram_RdAddress}), .WrAddress({cache_opto_ram_WrAddress}), 
            .RdClock(cache_opto_ram_RdClock), .RdClockEn(cache_opto_ram_RdClockEn), 
            .Reset(cache_opto_ram_Reset), .WE(cache_opto_ram_WE), .WrClock(cache_opto_ram_WrClock), 
            .WrClockEn(cache_opto_ram_WrClockEn));
    distance_ram distance_ram_inst (.Data({distance_ram_Data}), .Q({distance_ram_Q}), 
            .RdAddress({distance_ram_RdAddress}), .WrAddress({distance_ram_WrAddress}), 
            .RdClock(distance_ram_RdClock), .RdClockEn(distance_ram_RdClockEn), 
            .Reset(distance_ram_Reset), .WE(distance_ram_WE), .WrClock(distance_ram_WrClock), 
            .WrClockEn(distance_ram_WrClockEn));
    eth_data_ram eth_data_ram_inst (.Data({eth_data_ram_Data}), .Q({eth_data_ram_Q}), 
            .RdAddress({eth_data_ram_RdAddress}), .WrAddress({eth_data_ram_WrAddress}), 
            .RdClock(eth_data_ram_RdClock), .RdClockEn(eth_data_ram_RdClockEn), 
            .Reset(eth_data_ram_Reset), .WE(eth_data_ram_WE), .WrClock(eth_data_ram_WrClock), 
            .WrClockEn(eth_data_ram_WrClockEn));
    eth_send_ram eth_send_ram_inst (.Data({eth_send_ram_Data}), .Q({eth_send_ram_Q}), 
            .RdAddress({eth_send_ram_RdAddress}), .WrAddress({eth_send_ram_WrAddress}), 
            .RdClock(eth_send_ram_RdClock), .RdClockEn(eth_send_ram_RdClockEn), 
            .Reset(eth_send_ram_Reset), .WE(eth_send_ram_WE), .WrClock(eth_send_ram_WrClock), 
            .WrClockEn(eth_send_ram_WrClockEn));
    multiplier multiplier_inst (.DataA({multiplier_DataA}), .DataB({multiplier_DataB}), 
            .Result({multiplier_Result}), .Aclr(multiplier_Aclr), .ClkEn(multiplier_ClkEn), 
            .Clock(multiplier_Clock));
    multiplier3 multiplier3_inst (.DataA({multiplier3_DataA}), .DataB({multiplier3_DataB}), 
            .Result({multiplier3_Result}), .Aclr(multiplier3_Aclr), .ClkEn(multiplier3_ClkEn), 
            .Clock(multiplier3_Clock));
    opto_ram opto_ram_inst (.Data({opto_ram_Data}), .Q({opto_ram_Q}), .RdAddress({opto_ram_RdAddress}), 
            .WrAddress({opto_ram_WrAddress}), .RdClock(opto_ram_RdClock), 
            .RdClockEn(opto_ram_RdClockEn), .Reset(opto_ram_Reset), .WE(opto_ram_WE), 
            .WrClock(opto_ram_WrClock), .WrClockEn(opto_ram_WrClockEn));
    packet_data_ram packet_data_ram_inst (.Data({packet_data_ram_Data}), .Q({packet_data_ram_Q}), 
            .RdAddress({packet_data_ram_RdAddress}), .WrAddress({packet_data_ram_WrAddress}), 
            .RdClock(packet_data_ram_RdClock), .RdClockEn(packet_data_ram_RdClockEn), 
            .Reset(packet_data_ram_Reset), .WE(packet_data_ram_WE), .WrClock(packet_data_ram_WrClock), 
            .WrClockEn(packet_data_ram_WrClockEn));
    tcp_recv_fifo tcp_recv_fifo_inst (.Data({tcp_recv_fifo_Data}), .Q({tcp_recv_fifo_Q}), 
            .WCNT({tcp_recv_fifo_WCNT}), .Clock(tcp_recv_fifo_Clock), .Empty(tcp_recv_fifo_Empty), 
            .Full(tcp_recv_fifo_Full), .RdEn(tcp_recv_fifo_RdEn), .Reset(tcp_recv_fifo_Reset), 
            .WrEn(tcp_recv_fifo_WrEn));
    
endmodule

