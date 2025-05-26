//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: dist_cal
// Date Created 	: 2024/12/5 
// Version 			: V1.1
//--------------------------------------------------------------------------------------------------
// File description	:dist_cal
//				distance calculation Ctrl module
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module dist_cal
#(
	parameter DDR_AW 		    = 27,
	parameter DDR_DW 		    = 64,
	parameter DDR_COE_BASE_ADDR	= 32'h20000
)
(
	input					i_clk,
	input					i_rst_n,

	//index fifo
	output					o_indfifo_rden,
	input  [87:0]			i_indfifo_rdata,
	input					i_indfifo_empty,
	input					i_indfifo_full,

	input  [31:0]			i_distance_min,
	input  [31:0]			i_distance_max,
	input  [15:0]			i_dist_compen,

	input					i_rssi_ddr_en,
	output					o_ddr_rden,
	output					o_fifo_rden,
	output [DDR_AW-1:0]     o_rdddr_addr_base,
	input  [DDR_DW-1:0]		i_fifo_rddata,
	input					i_fifo_empty,
	
	output					o_dist_flag,
	output [15:0]			o_discal_angle1,
	output [15:0]			o_discal_angle2,
	output [31:0]			o_dist_data
);
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg  [7:0]				r_dist_state 		= 8'd0;
	reg						r_ddr_rden			= 1'b0;
	reg						r_fifo_rden			= 1'b0;
	reg  [DDR_AW-1:0]   	r_rdddr_addr_base	= {DDR_AW{1'b0}};
	reg  [3:0]				r_addr_remain		= 4'd0;
	reg  [7:0]				r_caldelay_cnt		= 8'd0;
	reg						r_cal_reset			= 1'b0;

	reg  [31:0]				r_dist_coe_ll 		= 32'd0;
	reg  [31:0]				r_dist_coe_lh 		= 32'd0;
	reg  [31:0]				r_dist_coe_hl 		= 32'd0;
	reg  [31:0]				r_dist_coe_hh 		= 32'd0;
	reg  [31:0]				r_dist_data_l 		= 32'd0;
	reg  [31:0]				r_dist_data_h 		= 32'd0;
	
	reg						r_sign_coe_ll 		= 1'b0;
	reg						r_sign_coe_lh 		= 1'b0;
	reg						r_sign_coe_hl 		= 1'b0;
	reg						r_sign_coe_hh 		= 1'b0;
	reg						r_sign_data_l 		= 1'b0;
	reg						r_sign_data_h 		= 1'b0;
	reg						r_sign_data	  		= 1'b0;
	
	reg						r_incr_polar 		= 1'b0;
	reg  [9:0]				r_mult1_dataA		= 10'd0;
    reg  [31:0]				r_mult1_dataB		= 32'd0;
	reg						r_mult1_en	 		= 1'b0;
    wire [41:0]				w_mult1_result;
	
	reg  [9:0]				r_mult2_dataA 		= 10'd0;
    reg  [31:0]				r_mult2_dataB 		= 32'd0;
	reg						r_mult2_en	  		= 1'b0;
    wire [41:0]				w_mult2_result;

	//index fifo
	reg						r_indfifo_rden		= 1'b0;
	reg 					r_dist_flag			= 1'b0;
	reg  [31:0]				r_dist_data			= 32'd0;
	reg 					r_distcal_flag		= 1'b0;
	reg  [31:0]				r_distcal_data		= 32'd0;
	reg  [15:0]				r_discal_angle1 	= 16'd0;
	reg  [15:0]				r_discal_angle2 	= 16'd0;
	reg  [3:0]				r_index_flag		= 4'h0;
	reg  [15:0]				r_rise_index		= 16'd0;
	reg  [9:0]				r_rise_remain		= 10'd0;
	reg  [15:0]				r_pulse_index		= 16'd0;
	reg  [9:0]				r_pulse_remain		= 10'd0;

	reg  [7:0]				r_delay_cnt			= 8'd0;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam	DELAY_NUM				= 12'd60;
	localparam	ST_IDLE					= 8'b0000_0000,//0
				ST_INDEX_WAIT			= 8'b0000_0001,//1
				ST_READY				= 8'b0000_0011,//3
				ST_PRE_READ				= 8'b0000_0010,//2
				ST_CALADDR_REMAIN1		= 8'b0000_0110,//6
				ST_RDFIFO_FIREN			= 8'b0000_0111,//7
				ST_RDFIFO_FIRDATA		= 8'b0000_0101,//5
				ST_READ_DIST1			= 8'b0000_0100,//4
				ST_RDDR_REMAIN_ADDR1	= 8'b0000_1100,//12
				ST_RFIFO_REMAIN1		= 8'b0000_1101,//13
				ST_RFIFO_REDATA1		= 8'b0000_1111,//15
				ST_READ_DIST2			= 8'b0000_1110,//14
				ST_WAIT_RDEMPTY			= 8'b0000_1010,//10
				ST_ADDR_REMAIN_SEC		= 8'b0000_1011,//11
				ST_RDFIFO_SECREN		= 8'b0000_1001,//9
				ST_RDFIFO_SECDATA		= 8'b0000_1000,//8
				ST_READ_DIST3			= 8'b0001_1000,//24
				ST_RDDR_REMAIN_ADDR2	= 8'b0001_1001,//25
				ST_RFIFO_REMAIN2		= 8'b0001_1011,//27
				ST_RFIFO_REDATA2		= 8'b0001_1010,//26
				ST_READ_DIST4			= 8'b0001_1110,//30
				ST_WAIT_FIFO_EMPTY		= 8'b0001_1111,//31
				ST_DIST_CAL1			= 8'b0001_1101,//29
				ST_CAL_DELAY			= 8'b0001_1100,//28
				ST_DIST_CAL2			= 8'b0001_0100,//20
				ST_CAL_DELAY2			= 8'b0001_0101,//21
				ST_CAL_END				= 8'b0001_0111,//23
				ST_CAL_OVER				= 8'b0001_0110,//22
				ST_DONE					= 8'b0001_0010;//18

	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_ddr_rden			<= 1'b0;
			r_fifo_rden			<= 1'b0;
			r_addr_remain		<= 4'd0;
			r_rdddr_addr_base	<= {DDR_AW{1'b0}};
			r_indfifo_rden		<= 1'b0;
			r_dist_coe_ll 		<= 32'd0;
			r_dist_coe_lh 		<= 32'd0;
			r_dist_coe_hl 		<= 32'd0;
			r_dist_coe_hh 		<= 32'd0;
			r_dist_data_l 		<= 32'd0;
			r_dist_data_h 		<= 32'd0;
			r_distcal_data		<= 32'd0;
			r_distcal_flag		<= 1'b0;
			r_sign_coe_ll 		<= 1'b0;
			r_sign_coe_lh 		<= 1'b0;
			r_sign_coe_hl 		<= 1'b0;
			r_sign_coe_hh 		<= 1'b0;
			r_sign_data_l 		<= 1'b0;
			r_sign_data_h 		<= 1'b0;
			r_sign_data			<= 1'b0;
			r_incr_polar		<= 1'b0;
			r_index_flag		<= 4'd0;
			r_delay_cnt			<= 8'd0;
			r_dist_state		<= ST_IDLE;
		end else begin
			case(r_dist_state)
				ST_IDLE: begin //0
					r_ddr_rden			<= 1'b0;
					r_fifo_rden			<= 1'b0;
					r_addr_remain		<= 4'd0;
					r_rdddr_addr_base	<= {DDR_AW{1'b0}};

					r_dist_coe_ll 		<= 32'd0;
					r_dist_coe_lh 		<= 32'd0;
					r_dist_coe_hl 		<= 32'd0;
					r_dist_coe_hh 		<= 32'd0;
					r_dist_data_l 		<= 32'd0;
					r_dist_data_h 		<= 32'd0;
					r_distcal_flag			<= 1'b0;
					r_sign_coe_ll 		<= 1'b0;
					r_sign_coe_lh 		<= 1'b0;
					r_sign_coe_hl 		<= 1'b0;
					r_sign_coe_hh 		<= 1'b0;
					r_sign_data_l 		<= 1'b0;
					r_sign_data_h 		<= 1'b0;
					r_sign_data			<= 1'b0;
					r_incr_polar		<= 1'b0;
					r_delay_cnt			<= 8'd0;
					if(~i_indfifo_empty) begin
						r_indfifo_rden	<= 1'b1;
						r_dist_state	<= ST_INDEX_WAIT;
					end else begin
						r_indfifo_rden	<= 1'b0;
						r_dist_state	<= ST_IDLE;
					end
				end
				ST_INDEX_WAIT: begin //1
					r_indfifo_rden	<= 1'b0;
					r_dist_state	<= ST_READY;
				end
				ST_READY: begin //3
					if(~i_rssi_ddr_en)begin
						if(i_indfifo_rdata[87])begin
							r_index_flag	<= i_indfifo_rdata[87:84];
							r_rise_index	<= i_indfifo_rdata[83:68];
							r_rise_remain	<= i_indfifo_rdata[67:58];
							r_pulse_index	<= i_indfifo_rdata[57:42];
							r_pulse_remain	<= i_indfifo_rdata[41:32];
							r_discal_angle1	<= i_indfifo_rdata[31:16];
							r_discal_angle2	<= i_indfifo_rdata[15:0];
							r_distcal_data	<= 32'd0;
							r_dist_state	<= ST_PRE_READ;
                        end
					end else
						r_dist_state		<= ST_READY;
				end
				ST_PRE_READ: begin //2
					if(r_index_flag[0])begin
						r_distcal_data			<= 32'd0;
						r_dist_state		<= ST_CAL_OVER;
					end else begin
						r_ddr_rden			<= 1'b1;
						r_rdddr_addr_base	<= DDR_COE_BASE_ADDR + (r_pulse_index << 4'd11) + (r_rise_index << 1'b1);
						r_dist_state		<= ST_CALADDR_REMAIN1;
					end
				end
				ST_CALADDR_REMAIN1: begin//6
					r_ddr_rden		<= 1'b0;
					r_addr_remain	<= r_rdddr_addr_base - {r_rdddr_addr_base[26:2], 2'b00};
					r_dist_state	<= ST_RDFIFO_FIREN;
				end
				ST_RDFIFO_FIREN: begin//7
					if(~i_fifo_empty) begin
						r_fifo_rden		<= 1'b1;
						r_dist_state	<= ST_RDFIFO_FIRDATA;
					end else begin
						r_fifo_rden		<= 1'b0;
						r_dist_state	<= ST_RDFIFO_FIREN;
					end
				end
				ST_RDFIFO_FIRDATA: begin //5
					r_fifo_rden		<= 1'b0;
					r_dist_state	<= ST_READ_DIST1;
				end
				ST_READ_DIST1: begin //4
					if(i_fifo_rddata[63:60] == 4'hF)begin
						r_dist_coe_ll	<= {4'h0, i_fifo_rddata[59:32]};
						r_sign_coe_ll	<= 1'b1;
					end else begin
						r_dist_coe_ll	<= i_fifo_rddata[63:32];
						r_sign_coe_ll	<= 1'b0;
					end
					
					if(r_addr_remain == 4'd0) begin
						r_dist_state	<= ST_WAIT_RDEMPTY;
						if(i_fifo_rddata[31:28] == 4'hF)begin
							r_dist_coe_lh	<= {4'h0, i_fifo_rddata[27:0]};
							r_sign_coe_lh	<= 1'b1;
						end else begin
							r_dist_coe_lh	<= i_fifo_rddata[31:0];
							r_sign_coe_lh	<= 1'b0;
						end
					end else 
						r_dist_state	<= ST_RDDR_REMAIN_ADDR1;
				end
				ST_RDDR_REMAIN_ADDR1: begin//12
					r_ddr_rden			<= 1'b1;
					r_rdddr_addr_base	<= {r_rdddr_addr_base[26:2], 2'b00} + 4'd4;
					r_dist_state		<= ST_RFIFO_REMAIN1;
				end
				ST_RFIFO_REMAIN1: begin//13
					r_ddr_rden		<= 1'b0;
					if(~i_fifo_empty) begin
						r_fifo_rden		<= 1'b1;
						r_dist_state	<= ST_RFIFO_REDATA1;
					end else begin
						r_fifo_rden		<= 1'b0;
						r_dist_state	<= ST_RFIFO_REMAIN1;
					end
				end
				ST_RFIFO_REDATA1: begin//15
					r_fifo_rden		<= 1'b0;
					r_dist_state	<= ST_READ_DIST2;
				end
				ST_READ_DIST2: begin //14
					if(i_fifo_rddata[63:60] == 4'hF)begin
						r_dist_coe_lh	<= {4'h0, i_fifo_rddata[59:32]};
						r_sign_coe_lh	<= 1'b1;
					end else begin
						r_dist_coe_lh	<= i_fifo_rddata[63:32];
						r_sign_coe_lh	<= 1'b0;
					end
					r_dist_state	<= ST_WAIT_RDEMPTY;
				end
				ST_WAIT_RDEMPTY: begin //10
					if(i_fifo_empty) begin
						r_ddr_rden			<= 1'b1;
						r_fifo_rden			<= 1'b0;
						r_rdddr_addr_base	<= DDR_COE_BASE_ADDR + ((r_pulse_index + 1'b1)<< 4'd11) + (r_rise_index << 1'b1);
						r_dist_state		<= ST_ADDR_REMAIN_SEC;
					end else begin
						r_ddr_rden		<= 1'b0;
						r_fifo_rden		<= 1'b1;
						r_dist_state	<= ST_WAIT_RDEMPTY;
					end
				end
				ST_ADDR_REMAIN_SEC: begin//11
					r_ddr_rden		<= 1'b0;
					r_addr_remain	<= r_rdddr_addr_base - {r_rdddr_addr_base[26:2], 2'b00};
					r_dist_state	<= ST_RDFIFO_SECREN;
				end
				ST_RDFIFO_SECREN: begin//9
					if(~i_fifo_empty) begin
						r_fifo_rden		<= 1'b1;
						r_dist_state	<= ST_RDFIFO_SECDATA;
					end else begin
						r_fifo_rden		<= 1'b0;
						r_dist_state	<= ST_RDFIFO_SECREN;
					end
				end
				ST_RDFIFO_SECDATA: begin //8
					r_fifo_rden		<= 1'b0;
					r_dist_state	<= ST_READ_DIST3;
				end
				ST_READ_DIST3: begin //24
					if(i_fifo_rddata[63:60] == 4'hF)begin
						r_dist_coe_hl	<= {4'h0, i_fifo_rddata[59:32]};
						r_sign_coe_hl	<= 1'b1;
					end else begin
						r_dist_coe_hl	<= i_fifo_rddata[63:32];
						r_sign_coe_hl	<= 1'b0;
					end
					if(r_addr_remain == 4'd0) begin
						r_dist_state	<= ST_WAIT_FIFO_EMPTY;
						if(i_fifo_rddata[31:28] == 4'hF)begin
							r_dist_coe_hh	<= {4'h0, i_fifo_rddata[27:0]};
							r_sign_coe_hh	<= 1'b1;
						end else begin
							r_dist_coe_hh	<= i_fifo_rddata[31:0];
							r_sign_coe_hh	<= 1'b0;
						end
					end else 
						r_dist_state	<= ST_RDDR_REMAIN_ADDR2;
				end
				ST_RDDR_REMAIN_ADDR2: begin//25
					r_ddr_rden		<= 1'b1;
					r_rdddr_addr_base	<= {r_rdddr_addr_base[26:2], 2'b00} + 4'd4;
					r_dist_state		<= ST_RFIFO_REMAIN2;
				end
				ST_RFIFO_REMAIN2: begin//27
					r_ddr_rden		<= 1'b0;
					if(~i_fifo_empty) begin
						r_fifo_rden		<= 1'b1;
						r_dist_state	<= ST_RFIFO_REDATA2;
					end else begin
						r_fifo_rden		<= 1'b0;
						r_dist_state	<= ST_RFIFO_REMAIN2;
					end
				end
				ST_RFIFO_REDATA2: begin//26
					r_fifo_rden		<= 1'b0;
					r_dist_state	<= ST_READ_DIST4;
				end
				ST_READ_DIST4: begin //30
					if(i_fifo_rddata[63:60] == 4'hF)begin
						r_dist_coe_hh	<= {4'h0, i_fifo_rddata[59:32]};
						r_sign_coe_hh	<= 1'b1;
					end else begin
						r_dist_coe_hh	<= i_fifo_rddata[63:32];
						r_sign_coe_hh	<= 1'b0;
					end
					r_dist_state		<= ST_WAIT_FIFO_EMPTY;
				end
				ST_WAIT_FIFO_EMPTY: begin //31
					if(i_fifo_empty) begin
						r_fifo_rden		<= 1'b0;
						r_dist_state	<= ST_DIST_CAL1;
					end else begin
						r_dist_state	<= ST_WAIT_FIFO_EMPTY;
						r_fifo_rden		<= 1'b1;
					end
				end
				ST_DIST_CAL1: begin //29
					if(r_dist_coe_ll == 0 || r_dist_coe_lh == 0 || r_dist_coe_hl == 0 || r_dist_coe_hh == 0)begin
						r_distcal_data			<= 32'd0;
						r_dist_state		<= ST_CAL_OVER;
					end else begin
						r_mult1_en			<= 1'b1;
						r_mult2_en			<= 1'b1;
						r_mult1_dataA		<= r_rise_remain;
						r_mult2_dataA		<= r_rise_remain;
						if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b0)begin
							if(r_dist_coe_lh < r_dist_coe_ll)
								r_mult1_dataB		<= 32'd0;
							else
								r_mult1_dataB		<= r_dist_coe_lh - r_dist_coe_ll;
						end else if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_lh + r_dist_coe_ll;
						else if(r_sign_coe_lh == 1'b1 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_ll - r_dist_coe_lh;
						else
							r_mult1_dataB		<= 32'd0;
						
						if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b0)begin
							if(r_dist_coe_hh < r_dist_coe_hl)
								r_mult2_dataB		<= 32'd0;
							else
								r_mult2_dataB		<= r_dist_coe_hh - r_dist_coe_hl;
						end else if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hh + r_dist_coe_hl;
						else if(r_sign_coe_hh == 1'b1 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hl - r_dist_coe_hh;
						else
							r_mult2_dataB	<= 32'd0;

						r_dist_state		<= ST_CAL_DELAY;
					end
				end
				ST_CAL_DELAY: begin //28
					if(r_delay_cnt >= 8'd9)begin
						r_dist_state	<= ST_DIST_CAL2;
						r_delay_cnt		<= 8'd0;
						if(r_sign_coe_ll == 1'b1)begin
							if(r_dist_data_l >= r_dist_coe_ll)begin
								r_dist_data_l	<= r_dist_data_l - r_dist_coe_ll;
								r_sign_data_l	<= 1'b0;
							end else begin
								r_dist_data_l	<= r_dist_coe_ll - r_dist_data_l;
								r_sign_data_l	<= 1'b1;
							end
						end else begin
							r_dist_data_l	<= r_dist_data_l + r_dist_coe_ll;
							r_sign_data_l	<= 1'b0;
						end
						if(r_sign_coe_hl == 1'b1)begin
							if(r_dist_data_h >= r_dist_coe_hl)begin
								r_dist_data_h	<= r_dist_data_h - r_dist_coe_hl;
								r_sign_data_h	<= 1'b0;
							end else begin
								r_dist_data_h	<= r_dist_coe_hl - r_dist_data_h;
								r_sign_data_h	<= 1'b1;
							end
						end else begin
							r_dist_data_h	<= r_dist_data_h + r_dist_coe_hl;
							r_sign_data_h	<= 1'b0;
						end
					end else if(r_delay_cnt == 8'd5)begin
						r_dist_data_l	<= w_mult1_result[39:8];
						r_dist_data_h	<= w_mult2_result[39:8];
						r_mult1_en		<= 1'b0;
						r_mult2_en		<= 1'b0;
						r_delay_cnt		<= r_delay_cnt + 1'b1;
					end else 
						r_delay_cnt		<= r_delay_cnt + 1'b1;
				end
				ST_DIST_CAL2: begin //20
					r_dist_state		<= ST_CAL_DELAY2;
					r_mult1_en			<= 1'b1;
					r_mult1_dataA		<= r_pulse_remain;
					if(r_sign_data_h == 1'b0 && r_sign_data_l == 1'b0)begin
						if(r_dist_data_h >= r_dist_data_l)begin
							r_incr_polar		<= 1'b0;
							r_mult1_dataB		<= r_dist_data_h - r_dist_data_l;
						end else begin
							r_incr_polar		<= 1'b1;
							r_mult1_dataB		<= r_dist_data_l - r_dist_data_h;
						end
					end else if(r_sign_data_h == 1'b1 && r_sign_data_l == 1'b0)begin
						r_incr_polar		<= 1'b1;
						r_mult1_dataB		<= r_dist_data_l + r_dist_data_h;
					end else if(r_sign_data_h == 1'b0 && r_sign_data_l == 1'b1)begin
						r_incr_polar		<= 1'b0;
						r_mult1_dataB		<= r_dist_data_h + r_dist_data_l;
					end else begin
						if(r_dist_data_h >= r_dist_data_l)begin
							r_incr_polar		<= 1'b1;
							r_mult1_dataB		<= r_dist_data_h - r_dist_data_l;
						end else begin
							r_incr_polar		<= 1'b0;
							r_mult1_dataB		<= r_dist_data_l - r_dist_data_h;
						end
					end
				end
				ST_CAL_DELAY2: begin //21
					if(r_delay_cnt >= 8'd9)begin
						r_dist_state	<= ST_CAL_END;
						r_delay_cnt		<= 8'd0;
						if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b0)
							r_distcal_data	<= r_dist_data_l + r_distcal_data;
						else if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b1)begin
							if(r_distcal_data >= r_dist_data_l)
								r_distcal_data	<= r_distcal_data - r_dist_data_l;
							else
								r_distcal_data	<= 32'd0;
						end else if(r_incr_polar == 1'b1 && r_sign_data_l == 1'b0)begin
							if(r_distcal_data >= r_dist_data_l)
								r_distcal_data	<= 32'd0;
							else
								r_distcal_data	<= r_dist_data_l - r_distcal_data;
						end else 
							r_distcal_data	<= 32'd0;
					end else if(r_delay_cnt == 8'd5)begin
						r_mult1_en			<= 1'b0;
						if(r_index_flag[1])
							r_distcal_data			<= w_mult1_result[40:9];
						else
							r_distcal_data			<= w_mult1_result[38:7];
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
				end	
				ST_CAL_END: begin //23
					r_dist_state	<= ST_CAL_OVER;
					if(r_distcal_data == 32'd0)
						r_distcal_data	<= 32'd0;
					else if(i_dist_compen[15] == 1'b1)
						r_distcal_data	<= r_distcal_data + i_dist_compen[14:0];
					else if(i_dist_compen[15] == 1'b0)begin
						if(r_distcal_data >= i_dist_compen[14:0])
							r_distcal_data	<= r_distcal_data - i_dist_compen[14:0];
						else
							r_distcal_data	<= 32'd0;
					end
				end
				ST_CAL_OVER: begin //22
					r_dist_state	<= ST_DONE;
					r_distcal_flag		<= 1'b1;
					if(r_distcal_data <= i_distance_min || r_distcal_data >= i_distance_max)
						r_distcal_data		<= 32'd0;
				end
				ST_DONE: begin //18
					r_distcal_flag		<= 1'b0;
					if(i_rssi_ddr_en)
						r_dist_state	<= ST_IDLE;
					else
						r_dist_state	<= ST_DONE;
				end
				default:
					r_dist_state	<= ST_IDLE;
			endcase
		end
	end

	//r_cal_reset
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
            r_cal_reset  <= 1'b0;
        else if(r_caldelay_cnt >= DELAY_NUM)
            r_cal_reset  <= 1'b1;
        else
            r_cal_reset  <= 1'b0;
    end

	// //r_dist_flag
	// always@(posedge i_clk or negedge i_rst_n)begin
	// 	if(i_rst_n == 1'b0)
    //         r_dist_flag  <= 1'b0;
    //     else
    //         r_dist_flag  <= r_distcal_flag;
    // end

	// //r_dist_data
	// always@(posedge i_clk or negedge i_rst_n)begin
	// 	if(i_rst_n == 1'b0)
    //         r_dist_data  <= 32'd0;
    //     else
    //         r_dist_data  <= r_distcal_data;
    // end
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	multiplier_in32bit u1_multiplier_in32bit
	(
		.Clock				(i_clk					), 
		.ClkEn				(r_mult1_en				), 
		
		.Aclr				(1'b0					), 
		.DataA				(r_mult1_dataA			), // input [9:0]
		.DataB				(r_mult1_dataB			), // input [31:0]
		.Result				(w_mult1_result			)  // output [41:0]
	);

	multiplier_in32bit u2_multiplier_in32bit
	(
		.Clock				(i_clk					), 
		.ClkEn				(r_mult2_en				), 
		
		.Aclr				(1'b0					), 
		.DataA				(r_mult2_dataA			), // input [9:0]
		.DataB				(r_mult2_dataB			), // input [31:0]
		.Result				(w_mult2_result			)  // output [41:0]
	);

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign  o_indfifo_rden		= r_indfifo_rden;
	assign	o_dist_flag			= r_distcal_flag;
	assign	o_dist_data			= r_distcal_data;
	assign	o_discal_angle1		= r_discal_angle1;
	assign	o_discal_angle2		= r_discal_angle2;
	assign	o_ddr_rden			= r_ddr_rden;
	assign	o_fifo_rden			= r_fifo_rden;
	assign	o_rdddr_addr_base 	= r_rdddr_addr_base;

endmodule 