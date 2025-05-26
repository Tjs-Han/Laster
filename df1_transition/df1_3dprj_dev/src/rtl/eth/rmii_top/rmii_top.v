// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: rmii_top
// Date Created 	: 2024/10/18
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:rmii_top
//            receive 2 bit rmii data to fifo
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module rmii_top(
    input                       i_clk,
    input                       i_rst_n,

	//rmii rx domain
	input					    i_ethphy_refclk, //D3 50Mhz        1:0 3:2 5:4 7:6
	input					    i_ethphy_crsdv,
	input					    i_ethphy_rxer,
	input					    i_ethphy_rxdv,
	input  [1:0]				i_ethphy_rxd,		//RMII rxd
	output						o_rmii_rxvld,
    output [1:0]                o_rmii_rxdata,

	//rmii tx domain
	input					    i_phy_refclk_90,
	input           		    i_rmii_txen,
	input  [1:0]    		    i_rmii_txd,
	output						o_ethphy_txen,
    output [1:0]				o_ethphy_txd
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
	rmii_rx u_rmii_rx (     
	    .i_clk   		        ( i_clk						),
	    .i_rst_n  			    ( i_rst_n                   ),

        .i_ethphy_refclk        ( i_ethphy_refclk           ),
        .i_ethphy_crsdv         ( i_ethphy_crsdv            ),
	    .i_ethphy_rxdv          ( i_ethphy_rxdv             ),
		.i_ethphy_rxd           ( i_ethphy_rxd              ),
	    .i_ethphy_rxer          ( i_ethphy_rxer             ),
    
        .o_rmii_rxvld           ( o_rmii_rxvld              ),
        .o_rmii_rxdata          ( o_rmii_rxdata             )
	);
    
    rmii_tx u_rmii_tx (     
	    .i_clk   		        ( i_clk						),
	    .i_rst_n  			    ( i_rst_n                   ),

        .i_phy_refclk_90       	( i_phy_refclk_90			),
		.i_rmii_txen            ( i_rmii_txen               ),
	    .i_rmii_txd             ( i_rmii_txd                ),
        .o_ethphy_txen          ( o_ethphy_txen             ),
	    .o_ethphy_txd           ( o_ethphy_txd              )    
	);
endmodule