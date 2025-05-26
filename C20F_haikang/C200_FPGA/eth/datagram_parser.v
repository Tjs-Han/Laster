`timescale 1ns / 1ps

`include "datagram_cmd_defines.v"

`define HEAD_SIZE			16'd9

`define READ_DOWN			8'h00
`define WRITE_DOWN			8'h01
`define METHOD_DOWN			8'h02
`define READ_UP				8'h10
`define WRITE_UP			8'h11
`define METHOD_UP			8'h12

module datagram_parser
(
	input				clk,
	input				rst_n,

	input		[31:0]	i_set_para0,
	input		[31:0]	i_set_para1,
	input		[31:0]	i_set_para2,
	input		[31:0]	i_set_para3,
	input		[31:0]	i_set_para4,
	input		[31:0]	i_set_para5,
	input		[31:0]	i_set_para6,
	input		[31:0]	i_set_para7,
	input		[31:0]	i_set_para8,

	output reg	[31:0]	o_get_para0 = 32'h0,
	output reg	[31:0]	o_get_para1 = 32'h0,
	output reg	[31:0]	o_get_para2 = 32'h0,
	output reg	[31:0]	o_get_para3 = 32'h0,
	output reg	[31:0]	o_get_para4 = 32'h0,
	output reg	[31:0]	o_get_para5 = 32'h0,
	output reg	[31:0]	o_get_para6 = 32'h0,

	input		[ 7:0]	i_set_cmd_code,
	output reg	[ 7:0]	o_get_cmd_code = `ERROR,
	input				i_cmd_make,
	output reg			o_cmd_end = 1'b0,
	
	output reg			o_sram_cs_n = 1'b0,
	output reg	[17:0]	o_sram_addr = 18'd0,
	input		[15:0]	i_sram_data,

	input				i_cmd_parse,
	output reg			o_cmd_ack = 1'b0,

	output reg			o_wr_req = 1'b0,
	output reg	[10:0]	o_wr_addr = 11'd0,
	output reg	[ 7:0]	o_data_out = 8'h0,
	output reg	[15:0]	o_send_num = 16'd0,

	output reg			o_rd_req = 1'b0,
	input		[ 7:0]	i_data_in,
	input		[15:0]	i_recv_num,
	
	input				i_packet_wren,
	input				i_packet_pingpang,
	input		[7:0]	i_packet_wrdata,
	input		[9:0]	i_packet_wraddr,
	
	input				i_calib_wren,
	input				i_calib_pingpang,
	input		[7:0]	i_calib_wrdata,
	input		[9:0]	i_calib_wraddr,
		
	input		[9:0]	i_eth_rdaddr,
	output 		[7:0]	o_eth_data,
	
	input               i_iap_flag,
	
	input		[15:0] i_first_rise,

	output reg			o_busy = 1'b0,
	
	output				o_code_right
);

	localparam IDLE   				= 10'b00_0000_0000;
	localparam READY				= 10'b00_0000_0010;
	localparam RDEN					= 10'b00_0000_0100;
	localparam SHIFT				= 10'b00_0000_1000;
	localparam MAKE_DATA			= 10'b00_0001_0000;
	localparam PARSE_DATA			= 10'b00_0010_0000;
	localparam DELAY				= 10'b00_0100_0000;	
	localparam OUT_DATA				= 10'b00_1000_0000;
	localparam IN_DATA				= 10'b01_0000_0000;
	localparam DONE					= 10'b10_0000_0000;

	reg			[9:0]	r_state = IDLE;
	reg			[9:0]  r_next_state;
	
	reg			[15:0]	r_byte_size = 16'd0;
	reg			[15:0]	r_byte_cnt = 16'd0;
	reg			[ 7:0]	r_check_sum = 8'h0;
	reg					r_rw = 1'b0;
	reg 				r_cmd_valid = 1'b1;
	reg 		[ 7:0]	r_opt_code = 8'h0;
	reg					r_write_num = 1'b0;
	
	reg			[9:0]	r_packet_rdaddr = 10'd0;
	wire		[7:0]	w_packet_rddata;
	wire		[7:0]	w_packet_rddata1;
	wire		[7:0]	w_packet_rddata2;
	
	reg			[9:0]	r_calib_rdaddr = 10'd0;
	wire		[7:0]	w_calib_rddata;
	wire		[7:0]	w_calib_rddata1;
	wire		[7:0]	w_calib_rddata2;
	
//	reg		    [7:0]	r_check_sum_recv;

	//Set the number of bytes received or sent during initialization
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_size <= 16'd0;
		else if (i_cmd_make == 1'b1) begin
			case(i_set_cmd_code)
				`RESET_DEV, `LOGIN, `LOGOUT, `SET_PASSWORD, `CHECK_PASSWORD, `SAVE_F_PARA, `SAVE_U_PARA, `LOAD_F_CFG, 
				`LOAD_U_CFG, `MEAS_SWITCH, `GET_DEV_ID, `GET_DEV_STA, `SET_TIME_SWITCH, `GET_TIME_SWITCH, `SET_RSSI_SWITCH, 
				`GET_RSSI_SWITCH, `SET_TRAIL_SWITCH, `GET_TRAIL_SWITCH, `LOOP_DATA_SWITCH, `RESET_TDC, `GET_TEMP, 
				`SET_CALI_SWITCH, `GET_CALI_SWITCH, `SET_LASING_SWITCH, `GET_LASING_SWITCH, `SET_FILTER_SWITCH, 
				`GET_FILTER_SWITCH, `SET_COMP_SWITCH, `GET_COMP_SWITCH, `SET_0_SWITCH, `GET_0_SWITCH, `SET_COE, `SAVE_COE,
				`SET_CODE, `SET_RSSI_COE,`SET_TDC_SWITCH,`GET_TDC_SWITCH,`GET_WORK_MODE,`GET_IAP_PRO,`SET_OPTO_PERIOD: begin
					r_byte_size <= `HEAD_SIZE + 16'd1;
				end
				`SET_CHARGE_TIME, `GET_CHARGE_TIME, `SET_TDC_WIN, `GET_TDC_WIN, `GET_HV_VALUE, `SET_HV_REF, `GET_HV_REF, 
				`SET_MOTOR_PWM, `GET_MOTOR_PWM, `SET_ANGLE_OFFSET, `GET_ANGLE_OFFSET, `SET_ZERO_OFFSET, `GET_ZERO_OFFSET,`SAVE_CODE,`SET_FIXED_VALUE,`GET_FIXED_VALUE,`SET_DIRT_SWITCH: begin
					r_byte_size <= `HEAD_SIZE + 16'd2;
				end
				`SET_RESOLUTION, `GET_RESOLUTION, `GET_FW_VER, `SET_DEV_NAME, `GET_DEV_NAME, `SET_IP, `GET_IP, `SET_GATEWAY, `GET_GATEWAY,
				`SET_SUBNET, `GET_SUBNET, `SET_SN, `GET_SN, `SET_DIST_LMT, `GET_DIST_LMT ,`SET_TEMP_DIST,`GET_TEMP_DIST , `GET_DIRT_SWITCH: begin
					r_byte_size <= `HEAD_SIZE + 16'd4;
				end
				`SET_UP_PARA:begin
					r_byte_size <= `HEAD_SIZE + 16'd2;
				end 
				`GET_UP_PARA:begin
					r_byte_size <= `HEAD_SIZE + 16'd8;
				end
				`SET_MAC, `GET_MAC, `GET_ADC, `SET_TEMP_COE, `GET_TEMP_COE,`GET_OPTO_PERIOD: begin
					r_byte_size <= `HEAD_SIZE + 16'd6;
				end
				`SET_ANGLE, `GET_ANGLE: begin
					r_byte_size <= `HEAD_SIZE + 16'd9;
				end
				`SET_TIMESTAMP, `GET_TIMESTAMP: begin
					r_byte_size <= `HEAD_SIZE + 16'd10;
				end
				`SET_COE_PARA: begin
					r_byte_size <= `HEAD_SIZE + 16'd17;
				end
				`GET_COE_PARA: begin
					r_byte_size <= `HEAD_SIZE + 16'd12;
				end

				`GET_DEBUG_INFO: begin
					r_byte_size <= `HEAD_SIZE + 16'd5;
				end
				
				
				`LOOP_DATA,`ONCE_DATA: begin
					r_byte_size <= `HEAD_SIZE + 16'd24 + (i_set_para6[13:0] << 2'd2);
				end
				`CALI_DATA: begin
					r_byte_size <= i_set_para0[13:0] << 2'd3;
				end
				`GET_COE: begin
					r_byte_size <= 16'd1024;
				end
				`ERROR: begin
					r_byte_size <= `HEAD_SIZE;
				end
				default: r_byte_size <= 16'd0;
			endcase
		end
		else if (i_cmd_parse == 1'b1)
			r_byte_size <= i_recv_num;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_cnt <= 16'd0;
		else if (r_state == OUT_DATA || r_state == IN_DATA)
			r_byte_cnt <= r_byte_cnt + 16'd1;
		else if (r_state == IDLE || r_state == DONE)
			r_byte_cnt <= 16'd0;
	end
		
	//r_packet_rdaddr
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_packet_rdaddr <= 10'd0;
		else if(r_state == IDLE)
			r_packet_rdaddr <= 10'd0;
		else if(r_state == OUT_DATA && (i_set_cmd_code == `ONCE_DATA || i_set_cmd_code == `LOOP_DATA))begin
			if(r_byte_cnt >= 16'd22 && r_byte_cnt + 3'd6 <= r_byte_size)
				r_packet_rdaddr <= r_packet_rdaddr + 1'b1;
			end
	end
	
	//r_calib_rdaddr
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_calib_rdaddr <= 10'd0;
		else if(r_state == IDLE)
			r_calib_rdaddr <= 10'd0;
		else if(r_state == OUT_DATA && i_set_cmd_code == `CALI_DATA)
			r_calib_rdaddr <= r_calib_rdaddr + 1'b1;
	end
	
	//o_sram_cs_n
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			o_sram_cs_n <= 1'b0;
		else if (r_state == IDLE)
			o_sram_cs_n <= 1'b0;
		else if (r_state == READY && i_cmd_make == 1'b1)begin
			if(i_set_cmd_code == `GET_COE)
				o_sram_cs_n <= 1'b1;
			else
				o_sram_cs_n <= 1'b0;
			end
			
	//o_sram_addr
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			o_sram_addr <= 18'd0;
		else if (r_state == IDLE)
			o_sram_addr <= 18'd0;
		else if (r_state == READY && i_cmd_make == 1'b1)begin
			if (i_set_cmd_code == `GET_COE)
				o_sram_addr <= 18'h10000 + (i_set_para0[7:0] << 4'd9);
			else
				o_sram_addr <= 18'd0;
			end
		else if (r_state == MAKE_DATA && r_byte_cnt >= 16'd1)begin
			if (r_write_num == 1'b1 && o_sram_cs_n == 1'b1)
				o_sram_addr <= o_sram_addr + 1'b1;
			end
			
	//r_write_num
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			r_write_num <= 1'b0;
		else if (r_state == IDLE)
			r_write_num <= 1'b0;
		else if (r_state == MAKE_DATA && r_byte_cnt >= 16'd1 && o_sram_cs_n == 1'b1)
			r_write_num <= ~r_write_num;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) 
			o_wr_req <= 1'b0;
		else if (r_state == MAKE_DATA)
			o_wr_req <= 1'b1;
		else
			o_wr_req <= 1'b0;
	end
	
	//o_wr_addr
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) 
			o_wr_addr <= 11'd0;
		else if (r_state == OUT_DATA)
			o_wr_addr <= o_wr_addr + 1'b1;
		else if (r_state == IDLE)
			o_wr_addr <= 11'd0;
	end
	
	//o_send_num
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_send_num <= 16'd0;
		else if (r_state == DONE && r_rw)
			o_send_num <= r_byte_size;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_rd_req <= 1'b0;
		else if (r_state == RDEN)
			o_rd_req <= 1'b1;
		else if (r_state == SHIFT)
			o_rd_req <= 1'b0;
		else if (r_state == PARSE_DATA && r_byte_cnt < r_byte_size - 16'd1)
			o_rd_req <= 1'b1;
		else
			o_rd_req <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_rw <= 1'b0;
		else if (i_cmd_make == 1'b1)
			r_rw <= 1'b1;
		else if (i_cmd_parse == 1'b1)
			r_rw <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			o_cmd_end <= 1'b0;
			o_cmd_ack <= 1'b0;
		end
		else if (r_state == DONE) begin
			if (r_rw == 1'b0) begin
				o_cmd_end <= 1'b0;
				o_cmd_ack <= 1'b1;
			end
			else begin
				o_cmd_end <= 1'b1;
				o_cmd_ack <= 1'b0;
			end
		end
		else begin
			o_cmd_end <= 1'b0;
			o_cmd_ack <= 1'b0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_check_sum <= 8'h0;
		else if (r_state == IDLE)
			r_check_sum <= 8'h0;
		else if (r_state == OUT_DATA)
			r_check_sum <= r_check_sum + o_data_out;
		else if (r_state == PARSE_DATA && r_byte_cnt < r_byte_size - 16'd1)
			r_check_sum <= r_check_sum + i_data_in;
	end

	//When make data, output data to external FIFO
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_out <= 8'h0;
		else begin
			if (r_state == MAKE_DATA) begin
				if (r_byte_cnt <= 16'd3)
					o_data_out <= 8'h02;
				else if (r_byte_cnt == 16'd4)
					o_data_out <= r_byte_size[15:8];
				else if (r_byte_cnt == 16'd5)
					o_data_out <= r_byte_size[7:0];
				else if (r_byte_cnt == 16'd7)
					o_data_out <= i_set_cmd_code;
				else if (r_byte_cnt == (r_byte_size - 16'd1))
					o_data_out <= r_check_sum;

				case(i_set_cmd_code)
					`RESET_DEV, `LOGIN, `LOGOUT, `SAVE_F_PARA, `SAVE_U_PARA, `LOAD_F_CFG, `LOAD_U_CFG, 
					`MEAS_SWITCH, `GET_DEV_ID, `GET_DEV_STA, `RESET_TDC, `GET_TEMP, `SAVE_COE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`SAVE_CODE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
					end
					`SET_PASSWORD, `SET_CALI_SWITCH, `SET_LASING_SWITCH,`SET_OPTO_PERIOD, `SET_FILTER_SWITCH, `SET_COMP_SWITCH, 
					`SET_0_SWITCH, `SET_COE, `SET_RSSI_COE, `SET_CODE,`SET_TDC_SWITCH: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`CHECK_PASSWORD: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`SET_IP, `SET_GATEWAY, `SET_SUBNET,`SET_TEMP_DIST: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para3[7:0];
					end
					`GET_IP, `GET_GATEWAY, `GET_SUBNET,`GET_TEMP_DIST: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para3[7:0];
					end
					`SET_MAC: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para5[7:0];
					end
					`GET_MAC: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para5[7:0];
					end
					`GET_FW_VER: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[31:24];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[23:16];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para0[7:0];
					end
					`SET_DEV_NAME, `SET_SN: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[31:24];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[23:16];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para0[7:0];
					end
					`GET_DEV_NAME, `GET_SN: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[31:24];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[23:16];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para0[7:0];
					end
					`SET_CHARGE_TIME, `SET_HV_REF, `SET_MOTOR_PWM,`SET_FIXED_VALUE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
					end
					`SET_TEMP_COE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[7:0];
					end
					`GET_CHARGE_TIME, `GET_HV_VALUE, `GET_HV_REF, `GET_MOTOR_PWM,`GET_FIXED_VALUE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
					end
					`GET_TEMP_COE,`GET_OPTO_PERIOD: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[7:0];
					end
					`SET_TIME_SWITCH, `SET_RSSI_SWITCH, `SET_TRAIL_SWITCH: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`GET_TIME_SWITCH, `GET_RSSI_SWITCH, `GET_TRAIL_SWITCH, 
					`GET_CALI_SWITCH, `GET_LASING_SWITCH, `GET_FILTER_SWITCH, `GET_COMP_SWITCH, 
					`GET_0_SWITCH,`GET_TDC_SWITCH: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`SET_ANGLE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[31:24];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[23:16];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[31:24];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para2[23:16];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para2[7:0];
					end
					`GET_ANGLE: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[31:24];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[23:16];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[31:24];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para2[23:16];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para2[7:0];
					end
					`SET_TIMESTAMP: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para5[7:0];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para6[23:16];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para6[15:8];
						else if (r_byte_cnt == 16'd17)
							o_data_out <= i_set_para6[7:0];
					end
					`GET_TIMESTAMP: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para5[7:0];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para6[23:16];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para6[15:8];
						else if (r_byte_cnt == 16'd17)
							o_data_out <= i_set_para6[7:0];
					end
					`LOOP_DATA_SWITCH: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
					end
					`GET_ADC: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[7:0];
					end
					`SET_RESOLUTION, `SET_DIST_LMT: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
					end
					`SET_DIRT_SWITCH:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
					end
					`GET_DIRT_SWITCH:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_first_rise[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_first_rise[7:0];
					end					
					`GET_RESOLUTION,`GET_DIST_LMT: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
					end
					`SET_UP_PARA:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						end
					`GET_UP_PARA:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para3[15:8];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para3[7:0];
					end
					`SET_TDC_WIN, `SET_ANGLE_OFFSET, `SET_ZERO_OFFSET: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
					end
					`GET_TDC_WIN, `GET_ANGLE_OFFSET, `GET_ZERO_OFFSET: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[7:0];
					end
					`ONCE_DATA,`LOOP_DATA: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para3[15:8];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para4[31:24];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para4[23:16];	
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para4[15:8];
						else if (r_byte_cnt == 16'd17)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd18)
							o_data_out <= i_set_para5[15:8];
						else if (r_byte_cnt == 16'd19)
							o_data_out <= i_set_para5[7:0];
						else if (r_byte_cnt == 16'd20)
							o_data_out <= i_set_para6[15:8];
						else if (r_byte_cnt == 16'd21)
							o_data_out <= i_set_para6[7:0];
						else if (r_byte_cnt >= 16'd22 && r_byte_cnt + 4'd12 <= r_byte_size)
							o_data_out <= w_packet_rddata;
						else if (r_byte_cnt + 4'd11 == r_byte_size)
							o_data_out <= i_set_para0[31:24];
						else if (r_byte_cnt + 4'd10 == r_byte_size)
							o_data_out <= i_set_para0[23:16];
						else if (r_byte_cnt + 4'd9 == r_byte_size)
							o_data_out <= i_set_para7[31:24];
						else if (r_byte_cnt + 4'd8 == r_byte_size)
							o_data_out <= i_set_para7[23:16];
						else if (r_byte_cnt + 4'd7 == r_byte_size)
							o_data_out <= i_set_para7[15:8];
						else if (r_byte_cnt + 4'd6 == r_byte_size)
							o_data_out <= i_set_para7[7:0];	
						else if (r_byte_cnt + 4'd5 == r_byte_size)
							o_data_out <= i_set_para8[31:24];
						else if (r_byte_cnt + 4'd4 == r_byte_size)
							o_data_out <= i_set_para8[23:16];
						else if (r_byte_cnt + 4'd3 == r_byte_size)
							o_data_out <= i_set_para8[15:8];
						else if (r_byte_cnt + 4'd2 == r_byte_size)
							o_data_out <= i_set_para8[7:0];
					end
					`CALI_DATA: begin
						o_data_out <= w_calib_rddata;
						end
					`GET_COE: begin
						case(r_write_num)
							1'b0:o_data_out <= i_sram_data[15:8];
							1'b1:o_data_out <= i_sram_data[7:0];
							endcase
						end
					`SET_COE_PARA:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `WRITE_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[31:24];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[23:16];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para3[31:24];
						else if (r_byte_cnt == 16'd17)
							o_data_out <= i_set_para3[23:16];
						else if (r_byte_cnt == 16'd18)
							o_data_out <= i_set_para3[15:8];
						else if (r_byte_cnt == 16'd19)
							o_data_out <= i_set_para3[7:0];
						else if (r_byte_cnt == 16'd20)
							o_data_out <= i_set_para4[31:24];
						else if (r_byte_cnt == 16'd21)
							o_data_out <= i_set_para4[23:16];
						else if (r_byte_cnt == 16'd22)
							o_data_out <= i_set_para4[15:8];
						else if (r_byte_cnt == 16'd23)
							o_data_out <= i_set_para4[7:0];
						else if (r_byte_cnt == 16'd24)
							o_data_out <= i_set_para5[7:0];
						end
					`GET_COE_PARA:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para1[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para1[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para2[31:24];
						else if (r_byte_cnt == 16'd13)
							o_data_out <= i_set_para2[23:16];
						else if (r_byte_cnt == 16'd14)
							o_data_out <= i_set_para2[15:8];
						else if (r_byte_cnt == 16'd15)
							o_data_out <= i_set_para2[7:0];
						else if (r_byte_cnt == 16'd16)
							o_data_out <= i_set_para3[31:24];
						else if (r_byte_cnt == 16'd17)
							o_data_out <= i_set_para3[23:16];
						else if (r_byte_cnt == 16'd18)
							o_data_out <= i_set_para3[15:8];
						else if (r_byte_cnt == 16'd19)
							o_data_out <= i_set_para3[7:0];
						end

					`GET_DEBUG_INFO:begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_set_para0[31:24];
						else if (r_byte_cnt == 16'd9)
							o_data_out <= i_set_para0[23:16];
						else if (r_byte_cnt == 16'd10)
							o_data_out <= i_set_para0[15:8];
						else if (r_byte_cnt == 16'd11)
							o_data_out <= i_set_para0[7:0];
						else if (r_byte_cnt == 16'd12)
							o_data_out <= i_set_para1[7:0];
							
					end

					`GET_WORK_MODE:
					    if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= 8'd1;
					`GET_IAP_PRO:
					    if (r_byte_cnt == 16'd6)
							o_data_out <= `READ_UP;
						else if (r_byte_cnt == 16'd8)
							o_data_out <= i_iap_flag;
					`ERROR: begin
						if (r_byte_cnt == 16'd6)
							o_data_out <= `METHOD_UP;
					end
				endcase
			end
		end
	end

	//Judge whether the data of each segment is valid, and clear r_cmd_valid when it is invalid
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cmd_valid <= 1'b1;
		else if (r_state == IDLE)
			r_cmd_valid <= 1'b1;
		else if (r_state == IN_DATA) begin
			if (r_byte_cnt < 16'd3) begin
				if (i_data_in != 8'h02)
					r_cmd_valid <= 1'b0;
			end
			else if (r_byte_cnt == 16'd3) begin
				if (r_byte_size[15:8] != i_data_in)
					r_cmd_valid <= 1'b0;
			end
			else if (r_byte_cnt == 16'd4) begin
				if (r_byte_size[7:0] != i_data_in)
					r_cmd_valid <= 1'b0;
			end
			else if (r_byte_cnt == 16'd5)
				r_opt_code <= i_data_in;
			else if (r_byte_cnt == 16'd7) begin
				case(o_get_cmd_code)
					`RESET_DEV, `LOGOUT, `SAVE_F_PARA, `SAVE_U_PARA, `LOAD_F_CFG, `LOAD_U_CFG, 
					`GET_DEV_ID, `GET_DEV_STA, `GET_FW_VER, `RESET_TDC, `GET_TEMP, `GET_ADC, `SAVE_COE: begin
						if (r_opt_code != `METHOD_DOWN || r_byte_size != 16'd9)
							r_cmd_valid <= 1'b0;
					end
					`LOGIN, `CHECK_PASSWORD: begin
						if (r_opt_code != `METHOD_DOWN || r_byte_size != 16'd14)
							r_cmd_valid <= 1'b0;
					end
					`SET_PASSWORD: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd14)
							r_cmd_valid <= 1'b0;
					end
					`MEAS_SWITCH, `LOOP_DATA_SWITCH, `SAVE_CODE: begin
						if (r_opt_code != `METHOD_DOWN || r_byte_size != 16'd10)
							r_cmd_valid <= 1'b0;
					end
					`SET_DEV_NAME, `SET_IP, `SET_GATEWAY, `SET_SUBNET, `SET_SN, 
					`SET_DIST_LMT, `SET_RESOLUTION,`SET_TEMP_DIST: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd13)
							r_cmd_valid <= 1'b0;
					end
					`SET_COE_PARA:begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd25)
							r_cmd_valid <= 1'b0;
					end
					`GET_DEV_NAME, `GET_IP, `GET_GATEWAY, `GET_SUBNET, `GET_MAC, `GET_SN, `GET_RESOLUTION, 
					`GET_ANGLE, `GET_TIME_SWITCH, `GET_TIMESTAMP, `GET_RSSI_SWITCH, `GET_TRAIL_SWITCH, 
					`GET_CALI_SWITCH, `GET_LASING_SWITCH, `GET_FILTER_SWITCH, `GET_COMP_SWITCH, `GET_0_SWITCH, 
					`GET_UP_PARA, `GET_CHARGE_TIME, `GET_TDC_WIN, `GET_HV_VALUE, `GET_HV_REF, `GET_MOTOR_PWM, 
					`GET_TEMP_COE,`GET_OPTO_PERIOD, `GET_DIST_LMT, `GET_ANGLE_OFFSET, `GET_COE_PARA, `GET_ZERO_OFFSET,
					`GET_TEMP_DIST,`GET_TDC_SWITCH,`GET_FIXED_VALUE,`GET_IAP_PRO,`GET_WORK_MODE,`GET_DIRT_SWITCH,`GET_DEBUG_INFO: begin
						if (r_opt_code != `READ_DOWN || r_byte_size != 16'd9)
							r_cmd_valid <= 1'b0;
					end
					`SET_MAC, `SET_TEMP_COE: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd15)
							r_cmd_valid <= 1'b0;
					end
					`SET_CHARGE_TIME, `SET_TDC_WIN, `SET_HV_REF, `SET_MOTOR_PWM,`SET_ANGLE_OFFSET, `SET_ZERO_OFFSET, 
					`SET_UP_PARA,`SET_FIXED_VALUE,`SET_DIRT_SWITCH: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd11)
							r_cmd_valid <= 1'b0;
					end
					`SET_TIMESTAMP: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd19)
							r_cmd_valid <= 1'b0;
					end
					`SET_ANGLE: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd18)
							r_cmd_valid <= 1'b0;
					end
					`SET_TIME_SWITCH, `SET_RSSI_SWITCH, `SET_TRAIL_SWITCH, `SET_CALI_SWITCH, `SET_LASING_SWITCH,`SET_OPTO_PERIOD, 
					`SET_FILTER_SWITCH, `SET_COMP_SWITCH, `SET_0_SWITCH,`SET_TDC_SWITCH: begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd10)
							r_cmd_valid <= 1'b0;
					end
					`ONCE_DATA,`CALI_DATA:begin
						if (r_opt_code != `METHOD_DOWN || r_byte_size != 16'd9)
							r_cmd_valid <= 1'b0;
					end
					`SET_COE,`SET_RSSI_COE,`SET_CODE:begin
						if (r_opt_code != `WRITE_DOWN || r_byte_size != 16'd1035)
							r_cmd_valid <= 1'b0;
					end
					`GET_COE:begin
						if (r_opt_code != `READ_DOWN || r_byte_size != 16'd11)
							r_cmd_valid <= 1'b0;
					end
					default: r_cmd_valid <= 1'b0;
				endcase
			end
		end
	end

	//Analyze the received data and output it to the corresponding interface
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			o_get_para0 <= 32'h0;
			o_get_para1 <= 32'h0;
			o_get_para2 <= 32'h0;
			o_get_para3 <= 32'h0;
			o_get_para4 <= 32'h0;
			o_get_para5 <= 32'h0;
			o_get_para6 <= 32'h0;
		end
		else if (r_byte_cnt >= 16'd7 && r_rw == 1'b0) begin
			case(o_get_cmd_code)
				`LOGIN, `SET_PASSWORD, `CHECK_PASSWORD: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para1[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd10)
						o_get_para1[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd11)
						o_get_para1[7:0] <= i_data_in;
				end
				`MEAS_SWITCH, `SET_TIME_SWITCH, `SET_RSSI_SWITCH, `SET_TRAIL_SWITCH, `LOOP_DATA_SWITCH, 
				`SET_CALI_SWITCH, `SET_LASING_SWITCH,`SET_OPTO_PERIOD, `SET_FILTER_SWITCH, `SET_COMP_SWITCH, `SET_0_SWITCH,`SET_TDC_SWITCH: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
				end
				`SET_DEV_NAME, `SET_SN: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd8)
						o_get_para0[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para0[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd10)
						o_get_para0[7:0] <= i_data_in;
				end
				`SET_IP, `SET_GATEWAY, `SET_SUBNET,`SET_TEMP_DIST: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para1 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd9)
						o_get_para2 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para3 <= {24'h0, i_data_in};
				end
				`SET_MAC: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para1 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd9)
						o_get_para2 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para3 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd11)
						o_get_para4 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd12)
						o_get_para5 <= {24'h0, i_data_in};
				end
				`SET_CHARGE_TIME, `SET_HV_REF, `SET_MOTOR_PWM, `SET_UP_PARA,`SET_FIXED_VALUE: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
				end
				`SET_TEMP_COE: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para1[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd11)
						o_get_para2[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd12)
						o_get_para2[7:0] <= i_data_in;
				end
				`SET_ANGLE: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para1[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd10)
						o_get_para1[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd11)
						o_get_para1[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd12)
						o_get_para2[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd13)
						o_get_para2[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd14)
						o_get_para2[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd15)
						o_get_para2[7:0] <= i_data_in;
				end
				`SET_TIMESTAMP: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para2 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd11)
						o_get_para3 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd12)
						o_get_para4 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd13)
						o_get_para5 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd14)
						o_get_para6[31:16] <= {8'h0, i_data_in};
					else if (r_byte_cnt == 16'd15)
						o_get_para6[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd16)
						o_get_para6[7:0] <= i_data_in;
				end
				`SET_DIST_LMT: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[31:8] <= {16'h0, i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para1[7:0] <= i_data_in;
				end
				`SET_DIRT_SWITCH:begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd8)
						o_get_para1[7:0] <= i_data_in;
				end					
				`SET_TDC_WIN, `SET_ANGLE_OFFSET, `SET_ZERO_OFFSET: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para1 <= {24'h0, i_data_in};
				end
				`SET_RESOLUTION: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'd0,i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[31:8] <= {16'd0,i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para1[7:0] <= i_data_in;
					end
				`SET_COE_PARA: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'd0,i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd9)
						o_get_para1[31:8] <= {16'd0,i_data_in};
					else if (r_byte_cnt == 16'd10)
						o_get_para1[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd11)
						o_get_para2[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd12)
						o_get_para2[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd13)
						o_get_para2[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd14)
						o_get_para2[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd15)
						o_get_para3[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd16)
						o_get_para3[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd17)
						o_get_para3[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd18)
						o_get_para3[7:0] <= i_data_in;
					else if (r_byte_cnt == 16'd19)
						o_get_para4[31:24] <= i_data_in;
					else if (r_byte_cnt == 16'd20)
						o_get_para4[23:16] <= i_data_in;
					else if (r_byte_cnt == 16'd21)
						o_get_para4[15:8] <= i_data_in;
					else if (r_byte_cnt == 16'd22)
						o_get_para4[7:0] <= i_data_in;
					end
				`SET_COE, `SET_RSSI_COE, `SET_CODE, `GET_COE: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0[31:8] <= {16'd0,i_data_in};
					else if (r_byte_cnt == 16'd8)
						o_get_para0[7:0]<= i_data_in;
				end
				`SAVE_CODE: begin
					if (r_byte_cnt == 16'd7)
						o_get_para0 <= {24'h0, i_data_in};
				end
			endcase
		end
	end
	
	reg				r_eth_data_wren = 1'b0; 
	reg		[9:0]	r_eth_wraddr = 10'd0;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_eth_wraddr <= 10'd0;
		else if (r_state == IN_DATA && (o_get_cmd_code == `SET_COE || o_get_cmd_code == `SET_RSSI_COE || o_get_cmd_code == `SET_CODE) && r_byte_cnt >= 16'd10 && r_byte_cnt + 2'd3 <= r_byte_size && r_rw == 1'b0)
			r_eth_wraddr <= r_eth_wraddr + 1'b1;
		else if (r_state == IDLE)
			r_eth_wraddr <= 10'd0;
	end
		
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_eth_data_wren	<= 1'b0;
		else if (r_state == IN_DATA && (o_get_cmd_code == `SET_COE || o_get_cmd_code == `SET_RSSI_COE || o_get_cmd_code == `SET_CODE) && r_byte_cnt >= 16'd9 && r_byte_cnt + 2'd3 <= r_byte_size && r_rw == 1'b0)
			r_eth_data_wren	<= 1'b1;
		else
			r_eth_data_wren	<= 1'b0;	
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_get_cmd_code <= `ERROR;
		else if (r_state == IN_DATA && r_byte_cnt == 16'd6)
			o_get_cmd_code <= i_data_in;
		else if (r_state == DONE && (r_check_sum != i_data_in || r_cmd_valid == 1'b0))
			o_get_cmd_code <= `ERROR;
	end
	
	
	reg		r_code_right;
	reg		r_code_seque_one;	
	
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_code_seque_one <= 1'd1;
		else if(o_get_para0[15:0] == 16'd0 && o_get_cmd_code == `SET_CODE)
			r_code_seque_one <= 1'd1;			
	//	else if(o_get_para0[15:0] == 16'd1 && o_get_cmd_code == `SET_CODE)	
	//		r_code_seque_one <= 1'd0;
		else
			r_code_seque_one <= 1'd0;
	end
			
	//r_code_right = 1'd1;//�ļ���ȷ��
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_code_right <= 1'd1;
		else if(r_code_seque_one)begin
			if(r_eth_wraddr == 16'h14F && i_data_in != 8'hFF && r_state == DELAY)
				r_code_right <= 1'd0;
			else if(r_eth_wraddr == 16'h150 && i_data_in != 8'hFF && r_state == DELAY)
				r_code_right <= 1'd0;
			else if(r_eth_wraddr == 16'h151 && i_data_in != 8'hBD && r_state == DELAY)
				r_code_right <= 1'd0;			
			else if(r_eth_wraddr == 16'h152 && i_data_in != 8'hB3 && r_state == DELAY)
				r_code_right <= 1'd0;
		end
		else
			r_code_right <= 1'd1;
	end
			
	assign	o_code_right = r_code_right ;
			
	
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_state <= IDLE;
		else
			r_state <= r_next_state;
	end

	always @(*) begin
		if (!rst_n)
			r_next_state = IDLE;
		else begin
			case(r_state)
				IDLE: r_next_state = READY;
				READY: begin
					if (i_cmd_make == 1'b1)
						r_next_state = MAKE_DATA;
					else if (i_cmd_parse == 1'b1)
						r_next_state = RDEN;
					else
						r_next_state = READY;
				end
				RDEN:
					r_next_state = SHIFT;
				SHIFT:
					r_next_state	= PARSE_DATA;
				MAKE_DATA: begin
					if (r_byte_cnt >= r_byte_size - 16'd1)
						r_next_state = DONE;
					else
						r_next_state = OUT_DATA;
				end
				OUT_DATA: r_next_state = MAKE_DATA;
				PARSE_DATA: begin
					if (r_byte_cnt >= r_byte_size - 16'd1 || r_cmd_valid == 1'b0)
						r_next_state = DONE;
					else
						r_next_state = DELAY;
				end
				DELAY:  r_next_state = IN_DATA;				
				IN_DATA: r_next_state = PARSE_DATA;
				DONE: r_next_state = IDLE;
				default : r_next_state = IDLE;
			endcase
		end
	end
	
	eth_data_ram U1
	(
		.WrClock				(clk), 
		.WrClockEn				(r_eth_data_wren),
		.WrAddress				(r_eth_wraddr), 
		.Data					(i_data_in), 
		.WE						(1'b1), 
		.RdClock				(~clk),  
		.RdClockEn				(1'b1),
		.RdAddress				(i_eth_rdaddr),
		.Q						(o_eth_data),
		.Reset					(1'b0)
	);
	
	packet_data_ram U2
	(
		.WrClock				(clk), 
		.WrClockEn				(i_packet_wren & i_packet_pingpang),
		.WrAddress				(i_packet_wraddr), 
		.Data					(i_packet_wrdata), 
		.WE						(1'b1), 
		.RdClock				(~clk),  
		.RdClockEn				(~i_packet_pingpang),
		.RdAddress				(r_packet_rdaddr),
		.Q						(w_packet_rddata1),
		.Reset					(1'b0)
	);
	
	packet_data_ram U3
	(
		.WrClock				(clk), 
		.WrClockEn				(i_packet_wren & ~i_packet_pingpang),
		.WrAddress				(i_packet_wraddr), 
		.Data					(i_packet_wrdata), 
		.WE						(1'b1), 
		.RdClock				(~clk),  
		.RdClockEn				(i_packet_pingpang),
		.RdAddress				(r_packet_rdaddr),
		.Q						(w_packet_rddata2),
		.Reset					(1'b0)
	);
	
	assign	w_packet_rddata = (i_packet_pingpang)?w_packet_rddata2:w_packet_rddata1;
	
	packet_data_ram U4
	(
		.WrClock				(clk), 
		.WrClockEn				(i_calib_wren & i_calib_pingpang),
		.WrAddress				(i_calib_wraddr), 
		.Data					(i_calib_wrdata), 
		.WE						(1'b1), 
		.RdClock				(~clk),  
		.RdClockEn				(~i_calib_pingpang),
		.RdAddress				(r_calib_rdaddr),
		.Q						(w_calib_rddata1),
		.Reset					(1'b0)
	);
	
	packet_data_ram U5
	(
		.WrClock				(clk), 
		.WrClockEn				(i_calib_wren & ~i_calib_pingpang),
		.WrAddress				(i_calib_wraddr), 
		.Data					(i_calib_wrdata), 
		.WE						(1'b1), 
		.RdClock				(~clk),  
		.RdClockEn				(i_calib_pingpang),
		.RdAddress				(r_calib_rdaddr),
		.Q						(w_calib_rddata2),
		.Reset					(1'b0)
	);
	
	assign	w_calib_rddata = (i_calib_pingpang)?w_calib_rddata2:w_calib_rddata1;

endmodule