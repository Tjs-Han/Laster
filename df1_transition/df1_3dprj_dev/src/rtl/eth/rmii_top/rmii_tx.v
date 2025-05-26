// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: rmii_tx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	: rmii_tx
// This file is accroding to DP83822 manual
// The format of the read/write communication protocol for the MDIO interface is as follows:
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module rmii_tx(
    input                       i_clk,
    input                       i_rst_n,

	input					    i_phy_refclk_90,
	output reg				    o_ethphy_txen,
    output reg [1:0]            o_ethphy_txd,

	//interface with udp_ip_top
	input           		    i_rmii_txen,
	input  [1:0]    		    i_rmii_txd
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
	parameter D = 2;
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg  [1:0]       		    r_rmii_txd;
	reg                         r_rmii_txvld;
	wire                        w_dcfifo_rden;
    reg                         r0_dcfifo_rden;
	reg                         r1_dcfifo_rden;
	wire [1:0]       		    w_dcfifo_rdata;  
	wire                        w_dcfifo_empty;
	wire                        w_dcfifo_full;    
	reg						    r_ethphy_txen;
	reg  [1:0]                  r_ethphy_txd;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------------------
	// rmii send logic domain
    //--------------------------------------------------------------------------------------------------
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		  r_rmii_txd <=#D 2'b0;                     
	    end else begin
	      r_rmii_txd <=#D i_rmii_txd;                    
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		  r_rmii_txvld <=#D 1'b0;                     
	    end else begin
	      r_rmii_txvld <=#D i_rmii_txen;                    
	    end
	end

	dcfifo_rmiitx_4096x2  u_dcfifo_rmiitx_4096x2
	(
	    .Data       	( r_rmii_txd			), 
	    .WrClock    	( i_clk					), 
	    .RdClock    	( i_phy_refclk_90		),
	    .WrEn       	( r_rmii_txvld			),
	    .RdEn       	( w_dcfifo_rden         ),      
	    .Reset      	( ~i_rst_n				),
	    .RPReset    	( ~i_rst_n				),
	    .Q          	( w_dcfifo_rdata		),
	    .Empty     		( w_dcfifo_empty        ),
	    .Full       	( w_dcfifo_full         )
	);

	assign w_dcfifo_rden = ~w_dcfifo_empty;

	always@(posedge i_phy_refclk_90)begin
	    if(!i_rst_n) begin
		  r0_dcfifo_rden <=#D 1'b0;                     
	    end else begin
	      r0_dcfifo_rden <=#D w_dcfifo_rden;                    
	    end
	end

	always@(posedge i_phy_refclk_90)begin
	    if(!i_rst_n) begin
		  r1_dcfifo_rden <=#D 1'b0;                     
	    end else begin
	      r1_dcfifo_rden <=#D r0_dcfifo_rden;                    
	    end
	end

	always@(posedge i_phy_refclk_90)begin
	    if(!i_rst_n) begin
		  o_ethphy_txen <=#D 1'b0;                     
	    end else begin
	      o_ethphy_txen <=#D r1_dcfifo_rden;                    
	    end
	end

	// always@(posedge i_phy_refclk_90)begin
	//     if(!i_rst_n) begin
	// 	  r_ethphy_txd <=#D 1'b0;                     
	//     end else begin
	//       r_ethphy_txd <=#D w_dcfifo_rdata;                    
	//     end
	// end
    always@(posedge i_phy_refclk_90)begin
	    if(!i_rst_n) begin
		  o_ethphy_txd <=#D 1'b0;                     
	    end else begin
	      o_ethphy_txd <=#D w_dcfifo_rdata;
	    end
	end

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    // assign o_ethphy_txen    = r_ethphy_txen;
    // assign o_ethphy_txd		= r_ethphy_txd;
endmodule