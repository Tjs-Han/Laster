//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: rssi_cal
// Date Created 	: 2023/12/19 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:rssi_cal
//				rssi calculation Ctrl module
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module rssi_cal
#(
	parameter DDR_AW 		    	= 32,
	parameter DDR_DW 		    	= 64,
	parameter DDR_RSSI_BASE_ADDR	= 32'h8000
)
(
	input						i_clk,
	input						i_rst_n,

	input						i_rssi_switch,
	input						i_dist_flag,
	input  [31:0]				i_pulse_data,
	input  [15:0]				i_code_angle1,
	input  [15:0]				i_code_angle2,
	input  [31:0]				i_dist_data,

	output						o_rssi_ddr_en,
	output						o_ddr_rden,
	output						o_fifo_rden,
	input  [DDR_DW-1:0]			i_fifo_rddata,
	output [DDR_AW-1:0]     	o_rdddr_addr_base,
	input						i_fifo_empty,

	output [17:0]				o_coe_sram_addr,
	input  [15:0]				i_coe_sram_data,

	output [15:0]				o_rssi_data,
	output [15:0]				o_rssi_tail,
	output [15:0]				o_rssical_angle1,
	output [15:0]				o_rssical_angle2,
	output						o_rssical_newsig
);
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg  [19:0]			r_rssi_state 		= 20'd0;
	reg					r_ddr_rden			= 1'b0;
	reg					r_fifo_rden			= 1'b0;
	reg  [DDR_AW-1:0]   r_rdddr_addr_base	= {DDR_AW{1'b0}};
	reg					r_rssical_newsig	= 1'b0;
	reg					r_dist_new_sig_1 	= 1'b0;
	reg					r_dist_new_sig_2 	= 1'b0;
	reg					r_rssi_ddr_en 		= 1'b0;
	
	reg					r_incr_polar  		= 1'b0;
	reg  [15:0]			r_mult1_dataA 		= 16'd0;
    reg  [15:0]			r_mult1_dataB 		= 16'd0;
	reg					r_mult1_en	  		= 1'b0;
    wire [31:0]			w_mult1_result;
	
	reg  [15:0]			r_mult2_dataA 		= 16'd0;
    reg  [15:0]			r_mult2_dataB 		= 16'd0;
	reg					r_mult2_en	  		= 1'b0;
    wire [31:0]			w_mult2_result;
	
	reg					r_divide_en	  		= 1'b0;
	reg  [15:0]			r_dividend	  		= 16'd0;
	reg  [15:0]			r_divisor	  		= 16'd0;
	wire [15:0]			w_divide_result;
	wire				w_divide_done;
	
	reg  [31:0]			r_dist_data 		= 32'd0;
	reg  [15:0]			r_rssi_data 		= 16'd0;
	reg  [15:0]			r_dist_index 		= 16'd0;
	reg  [15:0]			r_dist_value 		= 16'd0;
	reg  [31:0]			r_dist_remain 		= 32'd0;
	reg  [15:0]			r_rssi_para	 		= 16'd0;
	reg  [15:0]			r_rssi_para1 		= 16'd0;
	reg  [15:0]			r_rssi_para2 		= 16'd0;
	reg  [15:0]			r_pulse_para  		= 16'd0;
	reg  [15:0]			r_pulse_para1 		= 16'd0;
	reg  [15:0]			r_pulse_para2 		= 16'd0;
	
	reg  [15:0]			r_rssi_tail 		= 16'd0;

	reg  [15:0]			r_delay_cnt			= 16'd0;
	reg  [2:0]			r_beat_cnt			= 3'd0;
	reg  [15:0]			r_rssical_angle1 	= 16'd0;
	reg  [15:0]			r_rssical_angle2 	= 16'd0;
	
	localparam	IDLE				= 20'b0000_0000_0000_0000_0000,
				DIST_INDEX			= 20'b0000_0000_0000_0000_0001,
				RSSI_PRE			= 20'b0000_0000_0000_0000_0010,
				READ_FIFO_FIR		= 20'b0000_0000_0000_0000_0100,
				READ_FIFO_DATA_FIR	= 20'b0000_0000_0000_0000_1000,
				RSSI_READ1			= 20'b0000_0000_0000_0001_0000,
				RSSI_READ2			= 20'b0000_0000_0000_0010_0000,
				WAIT_FIFO			= 20'b0000_0000_0000_0100_0000,
				READ_FIFO_SEC		= 20'b0000_0000_0000_1000_0000,
				READ_FIFO_DATA_SEC	= 20'b0000_0000_0001_0000_0000,
				RSSI_READ3			= 20'b0000_0000_0010_0000_0000,
				RSSI_READ4			= 20'b0000_0000_0100_0000_0000,
				WAIT_FIFO_EMPTY		= 20'b0000_0000_1000_0000_0000,
				RSSI_CAL			= 20'b0000_0001_0000_0000_0000,
				RSSI_DELAY			= 20'b0000_0010_0000_0000_0000,
				RSSI_DIVID			= 20'b0000_0100_0000_0000_0000,
				RSSI_WAIT			= 20'b0000_1000_0000_0000_0000,
				RSSI_END			= 20'b0001_0000_0000_0000_0000;
	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_ddr_rden			<= 1'b0;
			r_fifo_rden			<= 1'b0;
			r_rdddr_addr_base	<= {DDR_AW{1'b0}};

			r_dist_data			<= 32'd0;
			r_rssi_data			<= 16'd0;
			r_dist_index 		<= 16'd0;
			r_dist_value 		<= 16'd0;
			r_dist_remain		<= 32'd0;
			r_rssi_para			<= 16'd0;
			r_rssi_para1		<= 16'd0;
			r_rssi_para2		<= 16'd0;
			r_pulse_para		<= 16'd0;
			r_pulse_para1		<= 16'd0;
			r_pulse_para2		<= 16'd0;
			r_delay_cnt			<= 16'd0;
			r_rssical_newsig	<= 1'b0;
			r_rssi_ddr_en		<= 1'b0;
			r_rssi_state		<= IDLE;
		end
		else begin
			case(r_rssi_state)
				IDLE		:begin
					r_rssical_newsig	<= 1'b0;
					if(i_dist_flag)begin
						r_rssi_ddr_en		<= 1'b1;
						r_rssical_angle1	<= i_code_angle1;
						r_rssical_angle2	<= i_code_angle2;
						if(i_dist_data == 16'd0 || i_rssi_switch == 1'b0)begin
							r_rssi_data			<= 16'd0;
							r_rssi_state		<= RSSI_END;
						end else begin
							r_ddr_rden			<= 1'b0;
							r_fifo_rden			<= 1'b0;
							r_rdddr_addr_base	<= {DDR_AW{1'b0}};

							r_rssi_data			<= 16'd0;
							r_dist_index 		<= 16'd0;
							r_dist_value 		<= 16'd0;
							r_dist_remain		<= 32'd0;
							r_rssi_para			<= 16'd0;
							r_rssi_para1		<= 16'd0;
							r_rssi_para2		<= 16'd0;
							r_pulse_para		<= 16'd0;
							r_pulse_para1		<= 16'd0;
							r_pulse_para2		<= 16'd0;
							r_delay_cnt			<= 16'd0;
							r_dist_data			<= i_dist_data;
							r_rssi_state		<= DIST_INDEX;
						end
					end else
						r_rssi_state	<= IDLE;
				end
				DIST_INDEX: begin
					r_dist_index	<= r_dist_data[31:6];
					r_dist_value	<= {r_dist_data[31:6], 6'd0};
					r_rssi_state	<= RSSI_PRE;
					end
				RSSI_PRE: begin
					r_ddr_rden			<= 1'b1;
					r_rdddr_addr_base 	<= DDR_RSSI_BASE_ADDR + r_dist_index;
					r_dist_remain		<= r_dist_data - r_dist_value;
					r_rssi_state		<= READ_FIFO_FIR;
				end
				READ_FIFO_FIR: begin
					r_ddr_rden			<= 1'b0;
					if(~i_fifo_empty) begin
						r_fifo_rden		<= 1'b1;
						r_rssi_state	<= READ_FIFO_DATA_FIR;
					end else begin
						r_fifo_rden		<= 1'b0;
						r_rssi_state	<= READ_FIFO_FIR;
					end
				end
				READ_FIFO_DATA_FIR: begin
					r_fifo_rden		<= 1'b0;
					r_rssi_state	<= RSSI_READ1;
				end
				RSSI_READ1: begin
					r_rssi_para1	<= i_fifo_rddata;
					r_rssi_state	<= RSSI_READ2;
				end
				RSSI_READ2	:begin					
					r_rssi_para2	<= i_fifo_rddata;
					r_rssi_state	<= WAIT_FIFO;
				end
				WAIT_FIFO: begin
					if(i_fifo_empty) begin
						r_ddr_rden			<= 1'b1;
						r_fifo_rden			<= 1'b0;
						r_rdddr_addr_base 	<= DDR_RSSI_BASE_ADDR + r_dist_index + 16'd1024;
						r_rssi_state		<= READ_FIFO_SEC;
					end else begin
						r_ddr_rden			<= 1'b0;
						r_fifo_rden			<= 1'b1;
						r_rssi_state		<= WAIT_FIFO;
					end
				end
				READ_FIFO_SEC: begin
					r_ddr_rden			<= 1'b0;
					if(~i_fifo_empty) begin
						r_fifo_rden			<= 1'b1;
						r_rssi_state		<= READ_FIFO_DATA_SEC;
					end else begin
						r_fifo_rden			<= 1'b0;
						r_rssi_state		<= READ_FIFO_SEC;
					end
				end
				READ_FIFO_DATA_SEC: begin
					r_fifo_rden		<= 1'b0;
					r_rssi_state	<= RSSI_READ3;
				end
				RSSI_READ3: begin
					r_pulse_para1		<= i_fifo_rddata;
					r_rssi_state		<= RSSI_READ4;
				end
				RSSI_READ4: begin
					r_pulse_para2		<= i_fifo_rddata;
					r_rssi_state		<= WAIT_FIFO_EMPTY;
				end
				WAIT_FIFO_EMPTY: begin
					if(i_fifo_empty) begin
						r_fifo_rden			<= 1'b0;
						r_rssi_state		<= RSSI_CAL;
					end else begin
						r_rssi_state		<= WAIT_FIFO_EMPTY;
						r_fifo_rden			<= 1'b1;
					end
				end
				RSSI_CAL: begin
					r_mult1_en			<= 1'b1;
					r_mult1_dataA		<= r_dist_remain;
					r_mult2_en			<= 1'b1;
					r_mult2_dataA		<= r_dist_remain;
					if(r_rssi_para2 >= r_rssi_para1)
						r_mult1_dataB		<= r_rssi_para2 - r_rssi_para1;
					else 
						r_mult1_dataB		<= r_rssi_para1 - r_rssi_para2;
					if(r_pulse_para2 >= r_pulse_para1)
						r_mult2_dataB		<= r_pulse_para2 - r_pulse_para1;
					else 
						r_mult2_dataB		<= r_pulse_para1 - r_pulse_para2;
					r_rssi_state			<= RSSI_DELAY;
					end
				RSSI_DELAY: begin
					if(r_delay_cnt == 16'd9)begin
						r_mult1_en			<= 1'b0;
						r_mult2_en			<= 1'b0;
						r_delay_cnt			<= 16'd0;
						if(r_rssi_para2 >= r_rssi_para1)
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para1;
						else
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para2;
						if(r_pulse_para2 >= r_pulse_para1)
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para1;
						else
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para2;
						r_rssi_state			<= RSSI_DIVID;
						end
					else
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end	
				RSSI_DIVID: begin
					if(i_pulse_data > r_pulse_para)begin
						r_divide_en			<= 1'b1;
						r_dividend			<= i_pulse_data - r_pulse_para;
						r_divisor			<= r_rssi_para;
						r_rssi_state		<= RSSI_WAIT;
						end
					else begin
						r_divide_en			<= 1'b0;
						r_rssi_data			<= 16'd1;
						r_rssi_state		<= RSSI_END;
						end
					end
				RSSI_WAIT: begin
					r_divide_en			<= 1'b0;
					if(w_divide_done)begin
						r_rssi_state		<= RSSI_END;
						if(i_rssi_switch == 1'b0)begin
							r_rssi_data	<= i_pulse_data >> 2'd3;
						end else begin
							if(w_divide_result >= 16'd255)
								r_rssi_data	<= 16'd4095;
							else if(w_divide_result == 16'd0)
								r_rssi_data	<= 16'd1;
							else
								r_rssi_data	<= {w_divide_result[11:0],4'd0};
							end
						end
					end
				RSSI_END: begin	
					if(r_beat_cnt > 3'd3) begin
						r_rssi_state		<= IDLE;
						r_rssi_ddr_en		<= 1'b0;
						r_rssical_newsig	<= 1'b1;
					end else begin
						r_rssi_state		<= RSSI_END;
						r_rssi_ddr_en		<= 1'b1;
						r_rssical_newsig	<= 1'b0;
					end
				end
				default:
					r_rssi_state		<= IDLE;
			endcase
		end
	end

	//r_beat_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_beat_cnt	<= 3'd0; 
		else if(r_rssi_state == RSSI_END)
			r_beat_cnt	<= r_beat_cnt + 1'b1;
		else
			r_beat_cnt	<= 3'd0;
	end	
	//r_rssi_tail
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)begin
			r_rssi_tail		<= 16'd0;
		end else if(i_dist_flag)begin
			r_rssi_tail		<= 16'd0;
		end else if(r_rssi_state == RSSI_WAIT && w_divide_done)begin
			if(w_divide_result >= 16'd255)
				r_rssi_tail		<= 16'd4095;
			else if(w_divide_result == 16'd0)
				r_rssi_tail		<= 16'd1;
			else
				r_rssi_tail		<= {w_divide_result[11:0],4'd0};
		end
	end

	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)begin
			r_dist_new_sig_1	<= 1'b0;
			r_dist_new_sig_2	<= 1'b0;
		end else begin
			r_dist_new_sig_1	<= r_rssical_newsig;
			r_dist_new_sig_2	<= r_dist_new_sig_1;
		end
	end		
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	multiplier_in32bit u1_multiplier_in32bit
	(
		.Clock				(i_clk					), 
		.ClkEn				(r_mult1_en				), 
		
		.Aclr				(1'b0					), 
		.DataA				(r_mult1_dataA			), // input [31:0]
		.DataB				(r_mult1_dataB			), // input [31:0]
		.Result				(w_mult1_result			)  // output [63:0]
	);

	multiplier_in32bit u2_multiplier_in32bit
	(
		.Clock				(i_clk					), 
		.ClkEn				(r_mult2_en				), 
		
		.Aclr				(1'b0					), 
		.DataA				(r_mult2_dataA			), // input [31:0]
		.DataB				(r_mult2_dataB			), // input [31:0]
		.Result				(w_mult2_result			)  // output [63:0]
	);
	
	div_rill U3
	(
		.clk  				( i_clk					),
		.rst  				( i_rst_n				),
		.enable 			( r_divide_en			),
		.a    				( r_dividend			),
		.b    				( r_divisor				),
		.done 				( w_divide_done			),
		.yshang				( w_divide_result		),
		.yyushu				( 						)
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------												
	assign	o_rssi_ddr_en 		= r_rssi_ddr_en;
	assign	o_rssi_data			= r_rssi_data;
	assign	o_rssi_tail			= r_rssi_tail;
	assign	o_rssical_angle1	= r_rssical_angle1;
	assign	o_rssical_angle2	= r_rssical_angle2;
	assign	o_rssical_newsig	= r_rssical_newsig;
	assign	o_ddr_rden			= r_ddr_rden;
	assign	o_fifo_rden			= r_fifo_rden;
	assign	o_rdddr_addr_base 	= r_rdddr_addr_base;

endmodule 