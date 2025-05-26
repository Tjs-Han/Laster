// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mac_rx
// Date Created 	: 2024/10/14
// Version 			: V1.1
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:       
    a: Identify the start and end of the mac frame;
    b: check mac frame by crc32;
    c: Output a valid mac frame; 
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
// -------------------------------------------------------------------------------------------------
// File description	:mac_rx
//            receive mac packet
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module mac_rx(
	input					i_clk,
	input					i_rst_n,

	//interface with rmii_top module
	input           		i_rmii_rxvld,
	input  [1:0]    		i_rmii_rxdata,

	output          		o_mac_packet_rx_sop,
	output          		o_mac_packet_rx_eop,
	output          		o_mac_packet_rx_vld,
	output [7:0]    		o_mac_packet_rx_dat
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	parameter D = 2;
    parameter PREAMBLE_SFD  = 64'hd555_5555_5555_5555;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg						r_mac_packet_rx_sop;
	reg                     r_mac_packet_rx_eop;
	reg                     r_mac_packet_rx_vld;
	reg  [7:0]              r_mac_packet_rx_dat;

    reg                     r0_rmii_rx_vld;
	reg                     r1_rmii_rx_vld;
	reg                     r2_rmii_rx_vld;
	reg                     r3_rmii_rx_vld;

	reg  [1:0]       		r0_rmii_rx_dat;
	reg  [1:0]       		r1_rmii_rx_dat;
	reg  [1:0]       		r2_rmii_rx_dat;

	reg  [63:0]      		r_mac_preamble;
    reg                     r_mac_head_vld;
    wire                    w_mac_head_vld;
    reg                     r_mac_frame_flag;
	reg  [12:0]      		r_mac_frame_length;
	reg  [5:0]       		r_rmii_rx_vld_idle_cnt;
	reg  [1:0]       		r_rmii_rxdcnt;
    reg                     r_mac_frame_sop;
    reg                     r_mac_frame_eop;
    reg                     r_mac_frame_vld;
    reg  [7:0]              r_mac_frame_data;

    reg                     r_fifo_wren;
	reg  [9:0]       		r_fifo_wrdata;

	wire                    w_fifo_rden;
	wire                    w_fifo_empty;
	wire                    w_fifo_full;
	wire [9:0]       		w_fifo_rdata;
    //--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
    //------------------------------------------------
	/*	
        Preamble and Start Frame Delimiter is 
        consist of 7Byte + 1Byte(7 0x55+ 1 0xd5)
    */
    //------------------------------------------------
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r0_rmii_rx_vld <=#D 1'd0;
			r1_rmii_rx_vld <=#D 1'd0;
			r2_rmii_rx_vld <=#D 1'd0;
			r3_rmii_rx_vld <=#D 1'd0;
	    end else begin
			r0_rmii_rx_vld <=#D i_rmii_rxvld;
			r1_rmii_rx_vld <=#D r0_rmii_rx_vld;
			r2_rmii_rx_vld <=#D r1_rmii_rx_vld;
			r3_rmii_rx_vld <=#D r2_rmii_rx_vld;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r0_rmii_rx_dat <=#D 2'b00;
			r1_rmii_rx_dat <=#D 2'b00;
			r2_rmii_rx_dat <=#D 2'b00;
	    end else begin
			r0_rmii_rx_dat <=#D i_rmii_rxdata;
			r1_rmii_rx_dat <=#D r0_rmii_rx_dat;
			r2_rmii_rx_dat <=#D r1_rmii_rx_dat;
	    end
	end

	//The mode is: Send/receive the lower 2 bits and then send/receive the higher 2 bits.
	//D1,D0  D3,D2   D5,D4   D7,D6
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			 r_mac_preamble <=#D 64'd0;
	    end else if(r0_rmii_rx_vld)begin
			 r_mac_preamble <=#D {r0_rmii_rx_dat[1:0], r_mac_preamble[63:2]};
	    end
	end
    // assign w_mac_head_vld = (r_mac_preamble == PREAMBLE_SFD)? 1:0;

    //7Byte + 1Byte(7 0x55+ 1 0xd5)
	always@(posedge i_clk)begin
	    if(!i_rst_n)
			r_mac_head_vld <=#D 1'b0;
        else if(r_mac_preamble == PREAMBLE_SFD)
            r_mac_head_vld <=#D 1'b1;
        else
            r_mac_head_vld <=#D 1'b0;
	end
    
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_frame_flag <=#D 1'd0;
	    end else if(~r_mac_frame_flag && r_mac_head_vld)begin
			r_mac_frame_flag <=#D 1'd1; 
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld && (r_mac_frame_length == 13'd6072))begin // 1518*8bit/2bit      Frame length exception handling
			r_mac_frame_flag <=#D 1'd0;                       
	    end else if( r_mac_frame_flag && &r_rmii_rx_vld_idle_cnt)begin
			r_mac_frame_flag <=#D 1'd0;           
	    end
	end

    //inter frame gap >= 12
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_rmii_rx_vld_idle_cnt <=#D 6'd0;
	    end else if(~r_mac_frame_flag && r_mac_head_vld)begin
			r_rmii_rx_vld_idle_cnt <=#D 6'd0;

	    end else if( r_mac_frame_flag && r2_rmii_rx_vld)begin     //Frame length exception handling
			r_rmii_rx_vld_idle_cnt <=#D 6'd0;  
	
	    end else if( r_mac_frame_flag)begin
			r_rmii_rx_vld_idle_cnt <=#D r_rmii_rx_vld_idle_cnt + 6'd1;             
	    end
	end

	// 6 + 6 +2 + 1500 + 4 = 1518 Bytes
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		    r_mac_frame_length <=#D 13'd0;
	    end else if(~r_mac_frame_flag && r_mac_head_vld)begin
			r_mac_frame_length <=#D 13'd1;           
	
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld && (r_mac_frame_length == 13'd6072))begin // 1518*8bit/2bit      
			r_mac_frame_length <=#D 13'd0;  

	    end else if( r_mac_frame_flag && &r_rmii_rx_vld_idle_cnt)begin
			r_mac_frame_length <=#D 13'd0;

	    end else if( r_mac_frame_flag && r2_rmii_rx_vld)begin
			r_mac_frame_length <=#D r_mac_frame_length + 13'd1;                 
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_rmii_rxdcnt <=#D 2'd0;
	    end else if(~r_mac_frame_flag && r_mac_head_vld)begin
			r_rmii_rxdcnt <=#D 2'd0;      
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld && (r_mac_frame_length == 13'd6072))begin 
			r_rmii_rxdcnt <=#D 2'd0;              
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld && &r_rmii_rxdcnt)begin
			r_rmii_rxdcnt <=#D 2'd0;        
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld)begin
			r_rmii_rxdcnt <=#D r_rmii_rxdcnt + 2'd1;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_frame_sop <=#D 1'd0;
	    end else if(~r_mac_frame_flag && r_mac_head_vld)begin
			r_mac_frame_sop <=#D 1'd1;      
	    end else if(r_mac_frame_vld)begin
			r_mac_frame_sop <=#D 1'd0;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_frame_eop <=#D 1'd0;
	    end else if( r_mac_frame_flag && r2_rmii_rx_vld && (r_mac_frame_length == 13'd6072))begin 
			r_mac_frame_eop <=#D 1'd1;      
	    end else if( r_mac_frame_flag && &r_rmii_rx_vld_idle_cnt)begin
			r_mac_frame_eop <=#D 1'd1;
	    end else begin
			r_mac_frame_eop <=#D 1'd0;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_frame_vld <=#D 1'd0;
	    end else begin
			r_mac_frame_vld <=#D r_mac_frame_flag && r2_rmii_rx_vld && &r_rmii_rxdcnt;                
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			  r_mac_frame_data <=#D 8'd0;
	    end else if(r_mac_frame_flag && r2_rmii_rx_vld)begin
	      case(r_rmii_rxdcnt)
			   2'b00: r_mac_frame_data[1:0] <=#D r2_rmii_rx_dat[1:0];  
			   2'b01: r_mac_frame_data[3:2] <=#D r2_rmii_rx_dat[1:0]; 
			   2'b10: r_mac_frame_data[5:4] <=#D r2_rmii_rx_dat[1:0]; 
			   2'b11: r_mac_frame_data[7:6] <=#D r2_rmii_rx_dat[1:0];                                    
	      endcase
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_fifo_wren <=#D 1'b0;
	    end else begin
			r_fifo_wren <=#D r_mac_frame_vld || r_mac_frame_eop;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_fifo_wrdata <=#D 10'd0;
	    end else if(r_mac_frame_vld || r_mac_frame_eop)begin
			r_fifo_wrdata <=#D {r_mac_frame_sop, r_mac_frame_eop, r_mac_frame_data}; 
	    end 
	end

	//fIfo_mac_rx_frame 2048x10
	// LUT : 80  EBR : 1  Reg : 38
	// out register  
	// delay 2 clk
	fifo_mac_frame_2048x10 u_fifo_mac_frame_2048x10
	(
	  .Clock        ( i_clk                 ),
	  .Reset        ( ~i_rst_n              ),  
         
	  .WrEn         ( r_fifo_wren           ), 
	  .Data         ( r_fifo_wrdata         ), 
	  .RdEn         ( w_fifo_rden           ),       
	  .Q            ( w_fifo_rdata          ),     
	  .Empty        ( w_fifo_empty          ),   
	  .Full         ( w_fifo_full           )    
	);
    assign w_fifo_rden = ~w_fifo_empty;

    always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   r_mac_packet_rx_sop <=#D 1'b0;
	    end else begin
		   r_mac_packet_rx_sop <=#D w_fifo_rden && w_fifo_rdata[9];      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_eop <=#D 1'b0;
	    end else begin
			r_mac_packet_rx_eop <=#D w_fifo_rden && w_fifo_rdata[8];      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_vld <=#D 1'b0;
	    end else begin
			r_mac_packet_rx_vld <=#D w_fifo_rden;      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_dat <=#D 8'b0;
	    end else begin
			r_mac_packet_rx_dat <=#D w_fifo_rdata[7:0];      
	    end
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_mac_packet_rx_sop	= r_mac_packet_rx_sop;
    assign o_mac_packet_rx_eop	= r_mac_packet_rx_eop;
	assign o_mac_packet_rx_vld	= r_mac_packet_rx_vld;
	assign o_mac_packet_rx_dat	= r_mac_packet_rx_dat;
endmodule