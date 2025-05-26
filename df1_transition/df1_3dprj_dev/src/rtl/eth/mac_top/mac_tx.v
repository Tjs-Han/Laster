// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mac_tx
// Date Created 	: 2024/10/14
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:mac_tx
//            receive mac packet
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module mac_tx(
	input					i_clk,
	input					i_rst_n,

  	input          		  	i_mac_packet_tx_sop,
	input          		  	i_mac_packet_tx_eop,
	input          		  	i_mac_packet_tx_vld,
	input  [7:0]    		i_mac_packet_tx_dat,

	//interface with rmii_top module
	output           		o_rmii_txen,
	output [1:0]    		o_rmii_txd
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	parameter D = 2;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    wire                    w_rmii_txen;
    reg 					r0_rmii_txen;
	reg 					r1_rmii_txen;
	reg             		r_rmii_txen;
	reg [1:0]    			r_rmii_txd;

	reg 					r_fifo_wren;
	reg  [9:0]				r_fifo_wdata;
	wire 					w_fifo_rden;
	wire [9:0]				w_fifo_rdata;
	wire					w_fifo_empty;
	wire					w_fifo_full;

	reg  [1:0]				r_rmii_txdcnt;
    reg  [1:0]				r0_rmii_txdcnt;
    reg  [1:0]				r1_rmii_txdcnt;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			  r_fifo_wren <=#D 1'b0;
	    end else begin
			  r_fifo_wren <=#D i_mac_packet_tx_vld;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) 
			r_fifo_wdata <=#D 10'd0;
	     else if(i_mac_packet_tx_vld)
			r_fifo_wdata <=#D {i_mac_packet_tx_sop, i_mac_packet_tx_eop, i_mac_packet_tx_dat};
	end

	fifo_mac_frame_2048x10 u_fifo_mac_frame_2048x10
	(
	  	.Clock        ( i_clk                 ),
	  	.Reset        ( ~i_rst_n              ),
	
	  	.WrEn         ( r_fifo_wren           ),
	  	.Data         ( r_fifo_wdata         	),
	  	.RdEn         ( w_fifo_rden           ),
	  	.Q            ( w_fifo_rdata          ),
	  	.Empty        ( w_fifo_empty          ),
	  	.Full         ( w_fifo_full           )
	);

	assign w_fifo_rden = ~w_fifo_empty && (r_rmii_txdcnt == 2'd0);
    assign w_rmii_txen = ~w_fifo_empty;

	//r0_rmii_txen, r1_rmii_txen
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   r0_rmii_txen <=#D 1'b0;
		   r1_rmii_txen <=#D 1'b0;
	    end else begin
		   r0_rmii_txen <=#D w_rmii_txen;
		   r1_rmii_txen	<=#D r0_rmii_txen;
	    end
	end

	//r_rmii_txdcnt
	always@(posedge i_clk)begin
	    if(!i_rst_n)
			r_rmii_txdcnt	<=#D 2'd0;
		else if(&r_rmii_txdcnt)
			r_rmii_txdcnt	<=#D 2'd0;
	    else if(w_rmii_txen || (|r_rmii_txdcnt))
			r_rmii_txdcnt	<=#D r_rmii_txdcnt + 1'b1;
		else
			r_rmii_txdcnt	<=#D 2'd0;
	end

    //r0_rmii_txdcnt, r1_rmii_txdcnt
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r0_rmii_txdcnt	<=#D 2'd0;
            r1_rmii_txdcnt	<=#D 2'd0;
        end else begin
			r0_rmii_txdcnt	<=#D r_rmii_txdcnt;
            r1_rmii_txdcnt	<=#D r0_rmii_txdcnt;
        end
	end
	
	//r_rmii_txen
	always@(posedge i_clk)begin
	    if(!i_rst_n)
			r_rmii_txen <=#D 1'b0;
	    else if(r0_rmii_txen)
			r_rmii_txen <=#D 1'b1;
		else if(w_fifo_empty && (r0_rmii_txdcnt == 2'd0))
			r_rmii_txen <=#D 1'b0;
	end

	//r_rmii_txd
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_rmii_txd <=#D 2'b00;
	    end else begin
	      case(r0_rmii_txdcnt)
			   2'b00: r_rmii_txd <=#D w_fifo_rdata[1:0];  
			   2'b01: r_rmii_txd <=#D w_fifo_rdata[3:2]; 
			   2'b10: r_rmii_txd <=#D w_fifo_rdata[5:4]; 
			   2'b11: r_rmii_txd <=#D w_fifo_rdata[7:6];                                    
	      endcase
	    end
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_rmii_txen	= r_rmii_txen;
    assign o_rmii_txd	= r_rmii_txd;
endmodule

