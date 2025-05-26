// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mac_top
// Date Created 	: 2024/10/14
// Version 			: V1.1
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:   
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
// -------------------------------------------------------------------------------------------------
// File description	:mac_top
//            receive mac packet
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module mac_top(
    input                       i_clk,
    input                       i_rst_n,

    //interface with rmii_top module
    input                       i_rmii_rxvld,
    input  [1:0]                i_rmii_rxdata,

    output                      o_mac_packet_rx_sop,
    output                      o_mac_packet_rx_eop,
    output                      o_mac_packet_rx_vld,
    output [7:0]                o_mac_packet_rx_dat,

    input                       i_arp_tx_sop,
    input                       i_arp_tx_eop,
    input                       i_arp_tx_vld,
    input  [7:0]                i_arp_tx_dat,

    input                       i_mac_packet_tx_sop,
    input                       i_mac_packet_tx_eop,
    input                       i_mac_packet_tx_vld,
    input  [7:0]                i_mac_packet_tx_dat,

    output                      o_rmii_txen,
    output [1:0]                o_rmii_txd
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
    parameter D = 2;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
     wire                       mac_tx_sop;
     wire                       mac_tx_eop;
     wire                       mac_tx_vld;
     wire [7:0]                 mac_tx_dat;
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	mac_rx u_mac_rx (
		.i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        //input 
        .i_rmii_rxvld           ( i_rmii_rxvld              ),
        .i_rmii_rxdata          ( i_rmii_rxdata             ),

        //output    
        .o_mac_packet_rx_sop    ( o_mac_packet_rx_sop       ),
        .o_mac_packet_rx_eop    ( o_mac_packet_rx_eop       ),
        .o_mac_packet_rx_vld    ( o_mac_packet_rx_vld       ),
        .o_mac_packet_rx_dat    ( o_mac_packet_rx_dat       )
    );

	mac_tx u_mac_tx (
        .i_clk                  ( i_clk                     ),
        .i_rst_n                ( i_rst_n                   ),

        //input 
		.i_mac_packet_tx_sop    ( i_mac_packet_tx_sop       ),
        .i_mac_packet_tx_eop    ( i_mac_packet_tx_eop       ),
        .i_mac_packet_tx_vld    ( i_mac_packet_tx_vld       ),
        .i_mac_packet_tx_dat    ( i_mac_packet_tx_dat       ),

        //output    
        .o_rmii_txen           	( o_rmii_txen				),
        .o_rmii_txd          	( o_rmii_txd				)
    );
endmodule
