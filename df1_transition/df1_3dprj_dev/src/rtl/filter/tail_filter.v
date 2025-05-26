// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jian Yu Zhao
// Filename 		: tail_filter
// Date Created 	: 2023/07/10
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	: tail_filter
// -------------------------------------------------------------------------------------------------
// Revision History : V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module tail_filter 
#(
	parameter DIST_HOLD_VAULE 		= 10,
	parameter PWIDTH_HOLD_VAULE 	= 20
)
(
	input				i_clk_50m,
	input				i_rst_n,
		
	input  [15:0]		i_code_angle,
	input  [15:0]		i_dist_data,
	input  [15:0]		i_rssi_data,
	input				i_dist_new_sig,
		
	input  [15:0]		i_rise_data,
	input  [15:0]		i_fall_data,	
		
	input				i_tail_switch,
	input  [15:0]		i_tail_para1,
	input  [15:0]		i_tail_para2,
	input  [15:0]		i_tail_para3,
		
	output [15:0]		o_code_angle,
	output [15:0]		o_dist_data,
	output [15:0]		o_rssi_data,
	output				o_dist_new_sig		
);
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg [15:0]			r_code_angle 	= 16'd0;
	reg [15:0]			r_dist_data 	= 16'd0;
	reg [15:0]			r_rssi_data 	= 16'd0;
	reg					r_dist_new_sig 	= 1'b0;

	reg [15:0]			r_filter_state 	= 16'd0;

	reg [15:0]			r_dist_data1 	= 16'd0;
	reg [15:0]			r_dist_data2 	= 16'd0;
	reg [15:0]			r_dist_data3 	= 16'd0;
	reg [15:0]			r_dist_data4 	= 16'd0;
	reg [15:0]			r_dist_data5 	= 16'd0;	

	reg [15:0]			r_rssi_data1 	= 16'd0;
	reg [15:0]			r_rssi_data2 	= 16'd0;
	reg [15:0]			r_rssi_data3 	= 16'd0;
	reg [15:0]			r_rssi_data4 	= 16'd0;
	reg [15:0]			r_rssi_data5 	= 16'd0;

	reg [15:0]			r_rise_data1 	= 16'd0;
	reg [15:0]			r_rise_data2 	= 16'd0;
	reg [15:0]			r_rise_data3 	= 16'd0;
	reg [15:0]			r_rise_data4 	= 16'd0;
	reg [15:0]			r_rise_data5 	= 16'd0;	

	reg [15:0]			r_fall_data1 	= 16'd0;
	reg [15:0]			r_fall_data2 	= 16'd0;
	reg [15:0]			r_fall_data3 	= 16'd0;
	reg [15:0]			r_fall_data4 	= 16'd0;
	reg [15:0]			r_fall_data5 	= 16'd0;	

	reg [15:0]			r_dist_diff1 	= 16'd0;
	reg [15:0]			r_dist_diff2 	= 16'd0;
	reg [15:0]			r_dist_diff3 	= 16'd0;
	reg [15:0]			r_dist_diff4 	= 16'd0;	
	reg [15:0]			r_dist_diff5 	= 16'd0;
	reg [15:0]			r_dist_diff6 	= 16'd0;
	reg [15:0]			r_dist_diff7 	= 16'd0;
	reg [15:0]			r_dist_diff8 	= 16'd0;
	reg [15:0]			r_dist_diff9 	= 16'd0;	
	reg [15:0]			r_dist_diff10 	= 16'd0;
	reg [15:0]			r_dist_diff11 	= 16'd0;
	reg [15:0]			r_dist_diff12 	= 16'd0;	

	reg [15:0]			r_pluse_diff1 	= 16'd0;
	reg [15:0]			r_pluse_diff2 	= 16'd0;
	reg [15:0]			r_pluse_diff3 	= 16'd0;
	reg [15:0]			r_pluse_diff4 	= 16'd0;
	reg [15:0]			r_pluse_diff5 	= 16'd0;
	reg [15:0]			r_pluse_diff6 	= 16'd0;
	reg [15:0]			r_pluse_diff7 	= 16'd0;
	
	reg	 				r_diff1_polar 	= 1'b0;
	reg	 				r_diff2_polar 	= 1'b0;
//	reg	 				r_diff3_polar = 1'b0;

	reg [15:0]			r_tail_diff		= 16'd0;
	reg [23:0]			r_tail_mult		= 24'd0;
	reg [15:0]			r_tail_dist		= 16'd0;

	reg [7:0]			r_delay_cnt 	= 8'd0;

	reg [23:0]			r_tail_mult2	= 24'd0;
	reg 				r_mult_en2 		= 1'b0;	
	wire [31:0]			w_tail_mult2;	

	reg					r_mult_en 		= 1'b0;
	wire [31:0]			w_tail_mult;

	reg	[23:0]			r_tail_mult3 	= 24'd0;	
	reg					r_mult_en3 		= 1'b0;	
	wire [31:0]			w_tail_mult3;	

	reg [23:0]			r_tail_mult1	= 24'd0;	
	reg					r_mult_en1 		= 1'b0;	
	wire [31:0]			w_tail_mult1;

	reg [15:0] 			r_tail_parameter;

	reg [15:0]			r_tail_para1;
	reg [15:0]			r_tail_para2;
	reg [15:0]			r_tail_para3;
	
	parameter			FILTER_IDLE		= 16'd1,
						FILTER_WAIT		= 16'd2,
						FILTER_ASSIGN	= 16'd3,
						FILTER_SHIFT	= 16'd4,
						FILTER_SUB		= 16'd5,
						FILTER_COMP1	= 16'd6,
						FILTER_COMP2	= 16'd7,
						FILTER_COMP3	= 16'd8,
						FILTER_MULT2	= 16'd9,
						FILTER_DELAY2	= 16'd10,
						FILTER_COMP4	= 16'd11,
						FILTER_COMP5	= 16'd12,
						FILTER_MULT3	= 16'd13,
						FILTER_DELAY3	= 16'd14,						
						FILTER_COMP6	= 16'd15,
						FILTER_COMP7	= 16'd16,	
						FILTER_MULT		= 16'd17,
						FILTER_DELAY	= 16'd18,					
						FILTER_COMP8	= 16'd19,					
						FILTER_CAL1		= 16'd20,
						FILTER_CAL2		= 16'd21,
						FILTER_END		= 16'd22,
						FILTER_OVER		= 16'd23;
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			r_dist_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			r_dist_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_ASSIGN)begin
			r_dist_data1 <= r_dist_data2;
			r_dist_data2 <= r_dist_data3;
			r_dist_data3 <= r_dist_data4;
			r_dist_data4 <= r_dist_data5;
			r_dist_data5 <= i_dist_data;
		end
	end
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			r_rssi_data5 <= 16'd0;			
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			r_rssi_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_ASSIGN)begin
			r_rssi_data1 <= r_rssi_data2;
			r_rssi_data2 <= r_rssi_data3;
			r_rssi_data3 <= r_rssi_data4;
			r_rssi_data4 <= r_rssi_data5;
			r_rssi_data5 <= i_rssi_data;
		end		
	end
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_rise_data1 <= 16'd0;
			r_rise_data2 <= 16'd0;
			r_rise_data3 <= 16'd0;
			r_rise_data4 <= 16'd0;
			r_rise_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_rise_data1 <= 16'd0;
			r_rise_data2 <= 16'd0;
			r_rise_data3 <= 16'd0;
			r_rise_data4 <= 16'd0;
			r_rise_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_ASSIGN)begin
			r_rise_data1 <= r_rise_data2;
			r_rise_data2 <= r_rise_data3;
			r_rise_data3 <= r_rise_data4;
			r_rise_data4 <= r_rise_data5;
			r_rise_data5 <= i_rise_data;
		end			
	end	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_fall_data1 <= 16'd0;
			r_fall_data2 <= 16'd0;
			r_fall_data3 <= 16'd0;
			r_fall_data4 <= 16'd0;
			r_fall_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_fall_data1 <= 16'd0;
			r_fall_data2 <= 16'd0;
			r_fall_data3 <= 16'd0;
			r_fall_data4 <= 16'd0;
			r_fall_data5 <= 16'd0;
		end else if(r_filter_state	== FILTER_ASSIGN)begin
			r_fall_data1 <= r_fall_data2;
			r_fall_data2 <= r_fall_data3;
			r_fall_data3 <= r_fall_data4;
			r_fall_data4 <= r_fall_data5;
			r_fall_data5 <= i_fall_data;
		end
	end
					
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			r_dist_diff4 <= 16'd0;	
			r_dist_diff5 <= 16'd0;
			r_dist_diff6 <= 16'd0;
			r_dist_diff7 <= 16'd0;
			r_dist_diff8 <= 16'd0;
			r_dist_diff9 <= 16'd0;	
			r_dist_diff10 <= 16'd0;
			r_dist_diff11 <= 16'd0;	
			r_dist_diff12 <= 16'd0;				
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			r_dist_diff4 <= 16'd0;
			r_dist_diff5 <= 16'd0;
			r_dist_diff6 <= 16'd0;
			r_dist_diff7 <= 16'd0;
			r_dist_diff8 <= 16'd0;
			r_dist_diff9 <= 16'd0;
			r_dist_diff10 <= 16'd0;
			r_dist_diff11 <= 16'd0;	
			r_dist_diff12 <= 16'd0;	
		end else if(r_filter_state	== FILTER_SUB)begin
			if(r_dist_data3 >= r_dist_data1)
				r_dist_diff1	<= r_dist_data3 - r_dist_data1;
			else
				r_dist_diff1	<= 16'd0;
			if(r_dist_data4 >= r_dist_data2)
				r_dist_diff2	<= r_dist_data4 - r_dist_data2;
			else
				r_dist_diff2	<= 16'd0;
			if(r_dist_data3 >= r_dist_data5)
				r_dist_diff3	<= r_dist_data3 - r_dist_data5;
			else
				r_dist_diff3	<= 16'd0;	
			if(r_dist_data2 >= r_dist_data4)
				r_dist_diff4	<= r_dist_data2 - r_dist_data4;
			else
				r_dist_diff4	<= 16'd0;		
			if(r_dist_data3 >= r_dist_data4)
				r_dist_diff5	<= r_dist_data3 - r_dist_data4;
			else
				r_dist_diff5	<= r_dist_data4 - r_dist_data3;
			if(r_dist_data4 >= r_dist_data5)
				r_dist_diff6	<= r_dist_data4 - r_dist_data5;
			else
				r_dist_diff6	<= r_dist_data5 - r_dist_data4;
			if(r_dist_data3 >= r_dist_data5)											
				r_dist_diff9	<= r_dist_data3 - r_dist_data5;
			else
				r_dist_diff9	<= r_dist_data5 - r_dist_data3;
			if(r_dist_data2 >= r_dist_data4)										
				r_dist_diff10	<= r_dist_data2 - r_dist_data4;
			else
				r_dist_diff10	<= r_dist_data4 - r_dist_data2;
			if(r_dist_data2 >= r_dist_data3)											
				r_dist_diff11	<= r_dist_data2 - r_dist_data3;
			else
				r_dist_diff11	<= r_dist_data3 - r_dist_data2;
			if(r_dist_data1 >= r_dist_data2)											
				r_dist_diff12	<= r_dist_data1 - r_dist_data2;
			else
				r_dist_diff12	<= r_dist_data2 - r_dist_data1;				
			if(r_dist_data3 >= r_dist_data1)
				r_dist_diff8	<= r_dist_data3 - r_dist_data1;
			else
				r_dist_diff8	<= r_dist_data1 - r_dist_data3;
			end	
	end
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_pluse_diff1 <= 16'd0;
			r_pluse_diff2 <= 16'd0;
			r_pluse_diff3 <= 16'd0;
			r_pluse_diff4 <= 16'd0;
			r_pluse_diff5 <= 16'd0;
			r_pluse_diff6 <= 16'd0;		
			r_pluse_diff7 <= 16'd0;				
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_pluse_diff1 <= 16'd0;
			r_pluse_diff2 <= 16'd0;
			r_pluse_diff3 <= 16'd0;
			r_pluse_diff4 <= 16'd0;
			r_pluse_diff5 <= 16'd0;
			r_pluse_diff6 <= 16'd0;		
			r_pluse_diff7 <= 16'd0;	
			end
		else if(r_filter_state	== FILTER_SUB)begin
			if((r_fall_data1-r_rise_data1) >= (r_fall_data2-r_rise_data2))
				r_pluse_diff1 <= (r_fall_data1-r_rise_data1) - (r_fall_data2-r_rise_data2) ;
			else
				r_pluse_diff1 <= (r_fall_data2-r_rise_data2) - (r_fall_data1-r_rise_data1) ;
			if((r_fall_data1-r_rise_data1) >= (r_fall_data3-r_rise_data3))
				r_pluse_diff2 <= (r_fall_data1-r_rise_data1) - (r_fall_data3-r_rise_data3) ;
			else
				r_pluse_diff2 <= (r_fall_data3-r_rise_data3) - (r_fall_data1-r_rise_data1) ;
			if((r_fall_data2-r_rise_data2) >= (r_fall_data3-r_rise_data3))
				r_pluse_diff3 <= (r_fall_data2-r_rise_data2) - (r_fall_data3-r_rise_data3) ;
			else
				r_pluse_diff3 <= (r_fall_data3-r_rise_data3) - (r_fall_data2-r_rise_data2) ;
			if((r_fall_data2-r_rise_data2) >= (r_fall_data4-r_rise_data4))
				r_pluse_diff4 <= (r_fall_data2-r_rise_data2) - (r_fall_data4-r_rise_data4) ;
			else
				r_pluse_diff4 <= (r_fall_data4-r_rise_data4) - (r_fall_data2-r_rise_data2) ;								
			if((r_fall_data3-r_rise_data3) >= (r_fall_data4-r_rise_data4))
				r_pluse_diff5 <= (r_fall_data3-r_rise_data3) - (r_fall_data4-r_rise_data4) ;
			else
				r_pluse_diff5 <= (r_fall_data4-r_rise_data4) - (r_fall_data3-r_rise_data3) ;
			if((r_fall_data4-r_rise_data4) >= (r_fall_data5-r_rise_data5))
				r_pluse_diff6 <= (r_fall_data5-r_rise_data5) - (r_fall_data5-r_rise_data5) ;
			else
				r_pluse_diff6 <= (r_fall_data5-r_rise_data5) - (r_fall_data4-r_rise_data4) ;
			if((r_fall_data3-r_rise_data3) >= (r_fall_data5-r_rise_data5))
				r_pluse_diff7 <= (r_fall_data3-r_rise_data3) - (r_fall_data5-r_rise_data5) ;
			else
				r_pluse_diff7 <= (r_fall_data5-r_rise_data5) - (r_fall_data3-r_rise_data3) ;			
		end

	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_diff1_polar <= 1'b0;
			r_diff2_polar <= 1'b0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_diff1_polar <= 1'b0;
			r_diff2_polar <= 1'b0;
		end else if(r_filter_state	== FILTER_SUB)begin
			if(r_dist_data3 >= r_dist_data1)
				r_diff1_polar <= 1'b1;
			else
				r_diff1_polar <= 1'b0;
			if(r_dist_data3 >= r_dist_data5)
				r_diff2_polar <= 1'b1;
			else
				r_diff2_polar <= 1'b0;
		end
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 1'b0)begin
			r_tail_diff	<= 16'd0;
			r_tail_dist	<= 16'd0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_tail_diff	<= 16'd0;
			r_tail_dist	<= 16'd0;
		end else if(r_filter_state	== FILTER_COMP1)begin
			if(r_dist_diff1 >= 16'd10)begin
				r_tail_diff	<= r_dist_diff1;
				r_tail_dist	<= r_dist_data1;
			end else if(r_dist_diff2 >= 16'd10)begin
				r_tail_diff	<= r_dist_diff2;
				r_tail_dist	<= r_dist_data2;
			end else if(r_dist_diff3 >= 16'd10 )begin
				r_tail_diff	<= r_dist_diff3;
				r_tail_dist	<= r_dist_data5;
			end else if(r_dist_diff4 >= 16'd10 )begin
				r_tail_diff	<= r_dist_diff4;
				r_tail_dist	<= r_dist_data4;
			end else begin
				r_tail_diff	<= 16'd0;
				r_tail_dist	<= 16'd0;
			end
		end
	end

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_mult_en1 <= 1'b0;
		else if(r_filter_state	== FILTER_MULT2)
			r_mult_en1 <= 1'b1;
		else if(r_filter_state	== FILTER_COMP4)
			r_mult_en1 <= 1'b0;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult_en2 <= 1'b0;
		else if(r_filter_state	== FILTER_MULT3)
			r_mult_en2 <= 1'b1;
		else if(r_filter_state	== FILTER_COMP6)
			r_mult_en2 <= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_mult_en3 <= 1'b0;
		else if(r_filter_state	== FILTER_MULT)
			r_mult_en3 <= 1'b1;
		else if(r_filter_state	== FILTER_COMP8)
			r_mult_en3 <= 1'b0;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_tail_mult	<= 24'd0;
		else if(r_filter_state	== FILTER_DELAY && r_delay_cnt >= 8'd5)
			r_tail_mult	<= w_tail_mult[23:0];
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_tail_mult1	<= 24'd0;
		else if(r_filter_state	== FILTER_DELAY2 && r_delay_cnt >= 8'd5)
			r_tail_mult1	<= w_tail_mult1[23:0];


	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_tail_mult2	<= 24'd0;
		else if(r_filter_state	== FILTER_DELAY2 && r_delay_cnt >= 8'd5)
			r_tail_mult2	<= w_tail_mult2[23:0];			

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_tail_mult3	<= 24'd0;
		else if(r_filter_state	== FILTER_DELAY3 && r_delay_cnt >= 8'd5)
			r_tail_mult3	<= w_tail_mult3[24:0];	

	//r_delay_cnt 
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_delay_cnt	<= 8'd0;
		else if(r_filter_state	== FILTER_DELAY ||r_filter_state	== FILTER_DELAY2 ||r_filter_state	== FILTER_DELAY3)
			r_delay_cnt	<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt	<= 8'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_data	<= 16'd0; 
		else if(r_filter_state	== FILTER_IDLE)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL1)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL2)
			r_dist_data	<= r_dist_data3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL1)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL2)
			r_rssi_data	<= r_rssi_data3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_code_angle <= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_code_angle <= 16'd0;
		else if(r_filter_state == FILTER_END)begin
			if(i_code_angle >= 16'd2)
				r_code_angle <= i_code_angle - 2'd2;
			else
				r_code_angle <= i_code_angle;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_tail_para1	<= {8'd15,8'd50};
		else
			r_tail_para1	<= i_tail_para1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_tail_para2	<= 16'd6556;
		else
			r_tail_para2	<= i_tail_para2;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_tail_para3	<= 16'd1000;
		else
			r_tail_para3	<= i_tail_para3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_new_sig <= 1'b0;
		else if(r_filter_state == FILTER_OVER)
			r_dist_new_sig <= 1'b1;
		else
			r_dist_new_sig <= 1'b0;
			
	reg [15:0] r_mult1	;	
	reg [15:0] r_mult2	;	
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_mult1 <= 16'd0;			
			r_mult2 <= 16'd0;
		end else if(r_filter_state	== FILTER_IDLE)begin
			r_mult1 <= 16'd0;
			r_mult2 <= 16'd0;
		end else if(r_filter_state == FILTER_COMP3)begin
			if(r_dist_diff11 <= 8'd10)
				r_mult1 <= 16'd0;
			else
				r_mult1 <= (r_dist_diff11 <<2'd1) + r_dist_diff11;
			if(r_dist_diff5 <= 8'd10)
				r_mult2 <= 16'd0;
			else
				r_mult2 <= (r_dist_diff5 <<2'd1) + r_dist_diff5;
		end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_filter_state	<= FILTER_IDLE;
			r_tail_parameter <= 16'd50;
			end
		else begin
			case(r_filter_state)
				FILTER_IDLE: begin
					r_filter_state	<= FILTER_WAIT;
				end
				FILTER_WAIT: begin
					if(i_dist_new_sig)
						r_filter_state	<= FILTER_ASSIGN;
					else
						r_filter_state	<= FILTER_WAIT;
				end
				FILTER_ASSIGN: begin
					r_tail_parameter <= r_tail_para1[7:0];
					r_filter_state	<= FILTER_SHIFT;
				end
				FILTER_SHIFT: begin
					if(i_tail_switch)
						r_filter_state	<= FILTER_SUB;
					else
						r_filter_state	<= FILTER_CAL2;
				end
				FILTER_SUB:
					r_filter_state	<= FILTER_COMP1; 
				FILTER_COMP1: begin
					if(r_dist_data3 == 16'd0 || r_dist_data3 >= 16'd12000)
						r_filter_state	<= FILTER_CAL2;
					else if(( r_dist_diff5 <= DIST_HOLD_VAULE && r_dist_diff6  <= DIST_HOLD_VAULE && r_dist_diff9  <= DIST_HOLD_VAULE ) ||
							( r_dist_diff5 <= DIST_HOLD_VAULE && r_dist_diff10 <= DIST_HOLD_VAULE && r_dist_diff11 <= DIST_HOLD_VAULE ) ||
							( r_dist_diff11 <= DIST_HOLD_VAULE && r_dist_diff12 <= DIST_HOLD_VAULE && r_dist_diff8 <= DIST_HOLD_VAULE ))
					begin
						r_filter_state	<= FILTER_COMP5;
						r_tail_parameter <= r_tail_para1[15:8];
					end else
						r_filter_state	<= FILTER_COMP2;
				end
				FILTER_COMP2: begin
					if(( r_pluse_diff1 <= PWIDTH_HOLD_VAULE && r_pluse_diff2 <= PWIDTH_HOLD_VAULE && r_pluse_diff3 <= PWIDTH_HOLD_VAULE ) || 
					   ( r_pluse_diff3 <= PWIDTH_HOLD_VAULE && r_pluse_diff4 <= PWIDTH_HOLD_VAULE && r_pluse_diff5 <= PWIDTH_HOLD_VAULE ) || 
					   ( r_pluse_diff5 <= PWIDTH_HOLD_VAULE && r_pluse_diff6 <= PWIDTH_HOLD_VAULE && r_pluse_diff7 <= PWIDTH_HOLD_VAULE ))
					begin
						r_filter_state	<= FILTER_COMP5;
						r_tail_parameter <= r_tail_para1[15:8];
					end else
						r_filter_state	<= FILTER_COMP3;
				end					
				FILTER_COMP3:
					r_filter_state	<= FILTER_MULT2;
				FILTER_MULT2:
					r_filter_state	<= FILTER_DELAY2;					
				FILTER_DELAY2: begin	
					if(r_delay_cnt >= 8'd5)
						r_filter_state	<= FILTER_COMP4;
					else
						r_filter_state	<= FILTER_DELAY2;
				end
				FILTER_COMP4: begin	
					if(r_tail_mult2 <= r_tail_para2 && r_tail_mult1 <= r_tail_para2)begin
						r_filter_state	<= FILTER_COMP5;
						r_tail_parameter <= r_tail_para1[15:8];
					end else begin
						r_filter_state	<= FILTER_COMP5;
						r_tail_parameter <= r_tail_para1[7:0];
					end
				end					
				FILTER_COMP5: begin	
					if(r_diff1_polar == r_diff2_polar && r_dist_data1 >16'd0 && r_dist_data2 >16'd0 && r_dist_data3 >16'd0 && r_dist_data4 >16'd0 )
						r_filter_state	<= FILTER_MULT3;
					else
						r_filter_state	<= FILTER_COMP7;
				end
				FILTER_MULT3:
					r_filter_state	<= FILTER_DELAY3;
				FILTER_DELAY3: begin	
					if(r_delay_cnt >= 8'd5)
						r_filter_state	<= FILTER_COMP6;
					else
						r_filter_state	<= FILTER_DELAY3;
				end	
				FILTER_COMP6: begin
					if(r_tail_mult3 >= r_tail_para3)
						r_filter_state	<= FILTER_CAL2;
					else
						r_filter_state	<= FILTER_COMP7;
				end	
				FILTER_COMP7: begin
					if(r_dist_diff1 >= DIST_HOLD_VAULE || r_dist_diff2 >= DIST_HOLD_VAULE || r_dist_diff3 >= DIST_HOLD_VAULE || r_dist_diff4 >= DIST_HOLD_VAULE)
						r_filter_state	<= FILTER_MULT;
					else
						r_filter_state	<= FILTER_CAL2;
				end
				FILTER_MULT:
					r_filter_state	<= FILTER_DELAY;
				FILTER_DELAY: begin	
					if(r_delay_cnt >= 8'd5)
						r_filter_state	<= FILTER_COMP8;
					else
						r_filter_state	<= FILTER_DELAY;
				end
				FILTER_COMP8: begin
					if(r_tail_mult >= r_tail_dist)
						r_filter_state	<= FILTER_CAL1;
					else
						r_filter_state	<= FILTER_CAL2;
				end					
				FILTER_CAL1,FILTER_CAL2:
					r_filter_state	<= FILTER_END;
				FILTER_END:
					r_filter_state	<= FILTER_OVER;
				FILTER_OVER:
					r_filter_state	<= FILTER_WAIT;
				default:r_filter_state	<= FILTER_IDLE;
				endcase
			end
	
	multiplier u1
	(
		.Clock				( i_clk_50m			),
		.ClkEn				( r_mult_en3		),

		.Aclr				( 1'b0				),
		.DataA				( r_tail_diff		),
		.DataB				( r_tail_parameter	),
		.Result				( w_tail_mult		)
	);	

	multiplier u2
	(
		.Clock				( i_clk_50m			), 
		.ClkEn				( r_mult_en1		), 
		 
		.Aclr				( 1'b0				), 
		.DataA				( r_mult1			), 
		.DataB				( r_pluse_diff3		), 
		.Result				( w_tail_mult1		)
	);
	
	multiplier u3
	(
		.Clock				( i_clk_50m			),
		.ClkEn				( r_mult_en1		),
 
		.Aclr				( 1'b0				),
		.DataA				( r_mult2			),
		.DataB				( r_pluse_diff5		),
		.Result				( w_tail_mult2		)
	);
	
	multiplier u4
	(
		.Clock				( i_clk_50m			),
		.ClkEn				( r_mult_en2		),
		 
		.Aclr				( 1'b0				),
		.DataA				( r_dist_diff8		),
		.DataB				( r_dist_diff9		),
		.Result				( w_tail_mult3		)
	);	
	

			
	assign	o_code_angle 	= r_code_angle;
	assign	o_dist_data 	= r_dist_data;
	assign	o_rssi_data 	= r_rssi_data;
	assign	o_dist_new_sig 	= r_dist_new_sig;
				

endmodule 