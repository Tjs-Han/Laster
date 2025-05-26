// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: rmii_rx
// Date Created     : 2024/10/08
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	: rmii_rx
// This file is accroding to DP83822 manual
// The format of the read/write communication protocol for the MDIO interface is as follows:
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module rmii_rx(
    input                       i_clk,
    input                       i_rst_n,

	input					    i_ethphy_refclk, //D3 50Mhz        1:0 3:2 5:4 7:6
	input					    i_ethphy_crsdv,
	input					    i_ethphy_rxer,
	input					    i_ethphy_rxdv,
	input  [1:0]				i_ethphy_rxd,		//RMII rxd

    output						o_rmii_rxvld,
    output [1:0]                o_rmii_rxdata
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
	parameter D = 2;
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg  [1:0]       		r_rmii_rxd;
    reg                     r_ethphy_rxdv;

	reg                     r_rmii_rxvld;
	wire                    w_fifo_dc_ren;
	wire [1:0]				w_fifo_dc_rdat;  
	wire                    w_fifo_dc_empty;
	wire                    w_fifo_dc_full;    
	reg                     r0_fifo_dc_ren;
	reg                     r1_fifo_dc_ren;
	reg  [1:0]				r_rmii_rxdata;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //------------------------------------------------
	/*	
        i_ethphy_refclk domain sequence logic
        receive rmii data from eth phy clk domain
    */
    //-----------------------------------------------
    always@(posedge i_ethphy_refclk)begin
	    if(!i_rst_n) begin
		  r_rmii_rxd <=#D 2'b0;                     
	    end else begin
	      r_rmii_rxd <=#D i_ethphy_rxd;                    
	    end
	end

	always@(posedge i_ethphy_refclk)begin
	    if(!i_rst_n) begin
		  r_ethphy_rxdv <=#D 1'b0;                     
	    end else begin
	      r_ethphy_rxdv <=#D i_ethphy_rxdv;
	    end
	end

    dcfifo_rmiirx_36x2  u_dcfifo_rmiirx_36x2
	(
	    .Data       	( r_rmii_rxd			), 
	    .WrClock    	( i_ethphy_refclk       ), 
	    .RdClock    	( i_clk					),
	    .WrEn       	( r_ethphy_rxdv			),
	    .RdEn       	( w_fifo_dc_ren			),      
	    .Reset      	( ~i_rst_n				),
	    .RPReset    	( ~i_rst_n				),
	    .Q          	( w_fifo_dc_rdat		),
	    .Empty			( w_fifo_dc_empty		),
	    .Full       	( w_fifo_dc_full		)
	);
    assign w_fifo_dc_ren = ~w_fifo_dc_empty;
    //------------------------------------------------
	/*	
        i_clk domain sequence logic
        Cross-clock domain processing fifo is use
    */
    //------------------------------------------------
    always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r0_fifo_dc_ren	<=#D 1'b0;
        	r1_fifo_dc_ren	<=#D 1'b0;
			r_rmii_rxvld	<=#D 1'b0;
	    end else begin
	    	r0_fifo_dc_ren	<=#D w_fifo_dc_ren;
        	r1_fifo_dc_ren	<=#D r0_fifo_dc_ren;
			r_rmii_rxvld	<=#D r1_fifo_dc_ren;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		  r_rmii_rxdata <=#D 2'b0;                     
	    end else begin
	      r_rmii_rxdata <=#D w_fifo_dc_rdat;                    
	    end
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_rmii_rxvld		= r_rmii_rxvld;
    assign o_rmii_rxdata	= r_rmii_rxdata;
endmodule