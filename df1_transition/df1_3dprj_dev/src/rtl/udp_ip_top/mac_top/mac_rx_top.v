// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: mac_rx_top
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
// File description	:mac_rx_top
//            receive mac packet
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module mac_rx_top(
	input					i_clk,
	input					i_rst_n,

	//interface with rmii_top module
	input           		i_rmii_rx_vld,
	input  [1:0]    		i_rmii_rx_dat,

	output          		o_mac_packet_rx_sop,
	output          		o_mac_packet_rx_eop,
	output          		o_mac_packet_rx_vld,
	output [7:0]    		o_mac_packet_rx_dat
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	parameter D = 2;

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

	reg  [63:0]      		f0_mac_preamble;

	reg                     f1_mac_head_vld_0;
	reg                     f1_mac_head_vld_1;
	reg                     f1_mac_head_vld_2;
	reg                     f1_mac_head_vld_3;

	reg                     f2_mac_head_vld;

	reg                     f2_mac_frame_flag;
	reg  [12:0]      		f2_mac_frame_length;
	reg  [5:0]       		f2_rmii_rx_vld_idle_cnt;
	reg  [1:0]       		f2_mac_frame_byte_cnt;

	reg                     use_mac_frame_sop;
	reg                     use_mac_frame_eop;
	reg                     use_mac_frame_vld;
	reg  [7:0]       		use_mac_frame_dat; 

	reg                     fifo_wr;
	reg  [9:0]       		fifo_wdat;

	wire                    fifo_rd;
	wire                    fifo_empty;
	wire                    fifo_full;
	wire [9:0]       		fifo_rdat;
	reg                     mac_frame_ren_flag;
	reg  [7:0]       		fifo_packet_cnt;
	reg                     start_vld;
	reg                     data_vld;
	reg  [7:0]       		data;

	wire [31:0]      		next_xor_crc;
	reg  [31:0]      		next_xor_crc_reg;
	reg  [31:0]      		f0_next_xor_crc_reg;
	reg  [31:0]      		f1_next_xor_crc_reg;
	reg  [31:0]      		f2_next_xor_crc_reg;
	reg  [31:0]      		f3_next_xor_crc_reg;

	reg  [31:0]      		mac_crc_data;

	reg                     mac_frame_crc_result_vld;
	reg                     mac_frame_crc_result;
	wire                    fifo_1_rd;
	wire                    fifo_1_rdat;
	wire                    fifo_1_empty;
	wire                    fifo_1_full;

	reg                     f0_fifo_1_rd;
	reg                     f1_fifo_1_rd;
	reg                     mac_frame_crc_ren_flag;
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r0_rmii_rx_vld <=#D 1'd0;
			r1_rmii_rx_vld <=#D 1'd0;
			r2_rmii_rx_vld <=#D 1'd0;
			r3_rmii_rx_vld <=#D 1'd0;
	    end else begin
			r0_rmii_rx_vld <=#D i_rmii_rx_vld;
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
			r0_rmii_rx_dat <=#D i_rmii_rx_dat;
			r1_rmii_rx_dat <=#D r0_rmii_rx_dat;
			r2_rmii_rx_dat <=#D r1_rmii_rx_dat;
	    end
	end

	//The mode is: Send/receive the lower 2 bits and then send/receive the higher 2 bits.
	//D1,D0  D3,D2   D5,D4   D7,D6
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			 f0_mac_preamble <=#D 64'd0;
	    end else if(r0_rmii_rx_vld)begin
			 f0_mac_preamble <=#D {r0_rmii_rx_dat[1:0],f0_mac_preamble[63:2]};
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			 f1_mac_head_vld_0 <=#D 1'd0;
	    end else if(r0_rmii_rx_vld && (f0_mac_preamble[15:0] == 16'haa_ab))begin
			 f1_mac_head_vld_0 <=#D 1'd1;
	    end else begin
			 f1_mac_head_vld_0 <=#D 1'd0;        
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f1_mac_head_vld_1 <=#D 1'd0;
	    end else if(r0_rmii_rx_vld && (f0_mac_preamble[31:16] == 16'haa_aa))begin
			f1_mac_head_vld_1 <=#D 1'd1;
	    end else begin
			f1_mac_head_vld_1 <=#D 1'd0;        
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f1_mac_head_vld_2 <=#D 1'd0;
	    end else if(r0_rmii_rx_vld && (f0_mac_preamble[47:32] == 16'haa_aa))begin
			f1_mac_head_vld_2 <=#D 1'd1;
	    end else begin
			f1_mac_head_vld_2 <=#D 1'd0;        
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f1_mac_head_vld_3 <=#D 1'd0;
	    end else if(r0_rmii_rx_vld && (f0_mac_preamble[63:48] == 16'haa_aa))begin
			f1_mac_head_vld_3 <=#D 1'd1;
	    end else begin
			f1_mac_head_vld_3 <=#D 1'd0;        
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f2_mac_head_vld <=#D 1'd0;
	    end else begin
			f2_mac_head_vld <=#D f1_mac_head_vld_0 && f1_mac_head_vld_1 && f1_mac_head_vld_2 && f1_mac_head_vld_3;        
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f2_mac_frame_flag <=#D 1'd0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
			f2_mac_frame_flag <=#D 1'd1; 
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && (f2_mac_frame_length == 13'd6072))begin // 1518*8bit/2bit      Frame length exception handling
			f2_mac_frame_flag <=#D 1'd0;                       
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && &f2_rmii_rx_vld_idle_cnt)begin
			f2_mac_frame_flag <=#D 1'd0;           
	    end
	end

	// 6 + 6 +2 + 1500 + 4 = 1518 Bytes
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		    f2_mac_frame_length <=#D 13'd0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
			f2_mac_frame_length <=#D 13'd1;           
	
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && (f2_mac_frame_length == 13'd6072))begin // 1518*8bit/2bit      
			f2_mac_frame_length <=#D 13'd0;  

	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && &f2_rmii_rx_vld_idle_cnt)begin
			f2_mac_frame_length <=#D 13'd0;      

	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld)begin
			f2_mac_frame_length <=#D f2_mac_frame_length + 13'd1;                 
	    end
	end

	//inter frame gap >= 12
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f2_rmii_rx_vld_idle_cnt <=#D 6'd0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
			f2_rmii_rx_vld_idle_cnt <=#D 6'd0;

	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld)begin     //Frame length exception handling
			f2_rmii_rx_vld_idle_cnt <=#D 6'd0;  
	
	    end else if( f2_mac_frame_flag)begin
			f2_rmii_rx_vld_idle_cnt <=#D f2_rmii_rx_vld_idle_cnt + 6'd1;             
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			f2_mac_frame_byte_cnt <=#D 2'd0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
			f2_mac_frame_byte_cnt <=#D 2'd0;      
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && (f2_mac_frame_length == 13'd6072))begin 
			f2_mac_frame_byte_cnt <=#D 2'd0;              
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && &f2_mac_frame_byte_cnt)begin
			f2_mac_frame_byte_cnt <=#D 2'd0;        
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld)begin
			f2_mac_frame_byte_cnt <=#D f2_mac_frame_byte_cnt + 2'd1;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			use_mac_frame_sop <=#D 1'd0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
			use_mac_frame_sop <=#D 1'd1;      
	    end else if(use_mac_frame_vld)begin
			use_mac_frame_sop <=#D 1'd0;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			use_mac_frame_eop <=#D 1'd0;
	    end else if( f2_mac_frame_flag && r2_rmii_rx_vld && (f2_mac_frame_length == 13'd6072))begin 
			use_mac_frame_eop <=#D 1'd1;      
	    end else if( f2_mac_frame_flag && &f2_rmii_rx_vld_idle_cnt)begin
			use_mac_frame_eop <=#D 1'd1;  
	    end else begin
			use_mac_frame_eop <=#D 1'd0;                         
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			use_mac_frame_vld <=#D 1'd0;
	    end else begin
			use_mac_frame_vld <=#D f2_mac_frame_flag && r2_rmii_rx_vld && &f2_mac_frame_byte_cnt;                
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			  use_mac_frame_dat <=#D 8'd0;
	    end else if(f2_mac_frame_flag && r2_rmii_rx_vld)begin
	      case(f2_mac_frame_byte_cnt)
			   2'b00: use_mac_frame_dat[1:0] <=#D r2_rmii_rx_dat[1:0];  
			   2'b01: use_mac_frame_dat[3:2] <=#D r2_rmii_rx_dat[1:0]; 
			   2'b10: use_mac_frame_dat[5:4] <=#D r2_rmii_rx_dat[1:0]; 
			   2'b11: use_mac_frame_dat[7:6] <=#D r2_rmii_rx_dat[1:0];                                    
	      endcase
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			fifo_wr <=#D 1'b0;
	    end else begin
			fifo_wr <=#D use_mac_frame_vld || use_mac_frame_eop || f0_use_mac_frame_eop || f1_use_mac_frame_eop;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			fifo_wdat <=#D 10'd0;
	    end else if(use_mac_frame_vld || use_mac_frame_eop)begin
			fifo_wdat <=#D {use_mac_frame_sop,use_mac_frame_eop,use_mac_frame_dat}; 
	    end else if(f0_use_mac_frame_eop || f1_use_mac_frame_eop)begin
			fifo_wdat <=#D 10'd0;                         
	    end
	end

	//fIfo_mac_rx_frame 2048x10
	// LUT : 80  EBR : 1  Reg : 38
	// out register  
	// delay 2 clk
	fIfo_mac_frame_2048x10 u_fIfo_mac_frame_2048x10
	(
	  .Clock  (i_clk),
	  .Reset  (~i_rst_n),  

	  .WrEn   (fifo_wr), 
	  .Data   (fifo_wdat), 
	  .RdEn   (fifo_rd),       
	  .Q      (fifo_rdat),     
	  .Empty  (fifo_empty),   
	  .Full   (fifo_full)    
	);

	assign fifo_rd = ~fifo_empty && mac_frame_ren_flag;

	reg            f0_fifo_rd;
	reg            f1_fifo_rd;
	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
	     f0_fifo_rd <=#D 1'b0;
	    end else begin
		 f0_fifo_rd <=#D fifo_rd;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
	     f1_fifo_rd <=#D 1'b0;
	    end else begin
		 f1_fifo_rd <=#D f0_fifo_rd;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 fifo_packet_cnt <=#D 8'd0;
	    end else if(fifo_wr && fifo_wdat[8] && f1_fifo_rd && fifo_rdat[9])begin
		 fifo_packet_cnt <=#D fifo_packet_cnt;     
	    end else if(fifo_wr && fifo_wdat[8])begin
		 fifo_packet_cnt <=#D fifo_packet_cnt + 8'd1;    
	    end else if(f1_fifo_rd && fifo_rdat[9])begin
		 fifo_packet_cnt <=#D fifo_packet_cnt - 8'd1;                   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
	     start_vld <=#D 1'b0;
	    end else if(~f2_mac_frame_flag && f2_mac_head_vld)begin
		 start_vld <=#D 1'b1; 
	    end else begin
		 start_vld <=#D 1'b0;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 data_vld <=#D 1'b0;
	    end else begin
		 data_vld <=#D use_mac_frame_vld;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
	     data <=#D 8'b0;
	    end else begin
		 data <=#D use_mac_frame_dat;
	    end
	end

	crc32_d8_top u_crc32_d8_top
	(
	  .i_clk    (i_clk),
	  .i_rst_n  (i_rst_n),  

	  .start_vld  (start_vld), 

	  .data_vld   (data_vld), 
	  .data       (data),       

	  //delay 2 clk 
	  .next_xor_crc  (next_xor_crc)   
	);

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f0_data_vld <=#D 1'b0;
	    end else begin
		 f0_data_vld <=#D data_vld;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f1_data_vld <=#D 1'b0;
	    end else begin
		 f1_data_vld <=#D f0_data_vld;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 next_xor_crc_reg <=#D 32'b0;
	    end else if(f1_data_vld)begin
		 next_xor_crc_reg <=#D next_xor_crc;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f0_next_xor_crc_reg <=#D 32'b0;
	    end else if(f1_data_vld)begin
		 f0_next_xor_crc_reg <=#D next_xor_crc_reg;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f1_next_xor_crc_reg <=#D 32'b0;
	    end else if(f1_data_vld)begin
		 f1_next_xor_crc_reg <=#D f0_next_xor_crc_reg;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f2_next_xor_crc_reg <=#D 32'b0;
	    end else if(f1_data_vld)begin
		 f2_next_xor_crc_reg <=#D f1_next_xor_crc_reg;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		 f3_next_xor_crc_reg <=#D 32'b0;
	    end else if(f1_data_vld)begin
	     f3_next_xor_crc_reg <=#D f1_next_xor_crc_reg;
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			mac_crc_data <=#D 32'b0;
	    end else if(f1_data_vld)begin
			mac_crc_data <=#D {mac_crc_data[23:0],f1_data[7:0]};
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			mac_frame_crc_result_vld<=#D 1'b0;
	    end else begin
			mac_frame_crc_result_vld <=#D use_mac_frame_eop || f0_use_mac_frame_eop || f1_use_mac_frame_eop;    
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		  mac_frame_crc_result<=#D 1'b0;
	    end else if(use_mac_frame_eop && (f3_next_xor_crc_reg == mac_crc_data))begin
		  mac_frame_crc_result <=#D 1'b1;
	    end else begin
		  mac_frame_crc_result <=#D 1'b0;      
	    end
	end

	//12x1
	fIfo_mac_rx_frame_crc_result u_fIfo_mac_rx_frame_crc_result
	(
	  .Clock  (i_clk),
	  .Reset  (~i_rst_n),  

	  .WrEn   (mac_frame_crc_result_vld), 
	  .Data   (mac_frame_crc_result), 
	  .RdEn   (fifo_1_rd),       
	  .Q      (fifo_1_rdat),     
	  .Empty  (fifo_1_empty),   
	  .Full   (fifo_1_full)    
	);

	assign fifo_1_rd = ~fifo_1_empty && mac_frame_crc_ren_flag;

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   f0_fifo_1_rd <=#D 1'b0;
	    end else begin
		   f0_fifo_1_rd <=#D fifo_1_rd;   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   f1_fifo_1_rd <=#D 1'b0;
	    end else begin
		   f1_fifo_1_rd <=#D f0_fifo_1_rd;   
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   mac_frame_crc_ren_flag <=#D 1'b0;
	    end else if(|fifo_packet_cnt && ~fifo_1_empty && ~mac_frame_ren_flag)begin
		   mac_frame_crc_ren_flag <=#D 1'b1;
	    end else if(f1_fifo_1_rd)begin
		   mac_frame_crc_ren_flag <=#D 1'b0;      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   mac_frame_ren_flag <=#D 1'b0;
	    end else if(|fifo_packet_cnt && ~fifo_1_empty && ~mac_frame_ren_flag)begin
		   mac_frame_ren_flag <=#D 1'b1;
	    end else if(f1_fifo_rd && fifo_rdat[8] && mac_frame_ren_flag)begin
		   mac_frame_ren_flag <=#D 1'b0;      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
		   r_mac_packet_rx_sop <=#D 1'b0;
	    end else begin
		   r_mac_packet_rx_sop <=#D f1_fifo_rd && fifo_rdat[9];      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_eop <=#D 1'b0;
	    end else begin
			r_mac_packet_rx_eop <=#D f1_fifo_rd && fifo_rdat[8];      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_vld <=#D 1'b0;
	    end else begin
			r_mac_packet_rx_vld <=#D f1_fifo_rd;      
	    end
	end

	always@(posedge i_clk)begin
	    if(!i_rst_n) begin
			r_mac_packet_rx_dat <=#D 8'b0;
	    end else begin
			r_mac_packet_rx_dat <=#D fifo_rdat[7:0];      
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