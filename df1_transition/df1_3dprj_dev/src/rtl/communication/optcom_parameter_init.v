//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: optcom_parameter_init
// Date Created 	: 2023/12/18 
// Version 			: V2.0
//--------------------------------------------------------------------------------------------------
// File description	:optcom_parameter_init
// 				1、The parameters in the flash are loaded into the sram during initial power-on
//				2、The parameters are read out of the sram and output to the individual modules
//				3、Process the information of the parser module received through the network port
//				4、Output some parameter information to be returned to the data parsing module
// -------------------------------------------------------------------------------------------------
// Revision History :			
//			V1.0: 2023.10.31
//				  	new communication agreement
//			V1.1: 2023.11.23
//					add code read data
//			V1.2: 2023.11.29 0_00_01_013
//					add retrans when loop data mode, delete once loop
//			V2.0: 2023.12.18
//					add ddr3 logic
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
`include "datagram_cmd_defines.v"
`include "parameter_addr_define.v"

module optcom_parameter_init
#(
	parameter LOOP_PACKET_BYTE_NUM		= 16'd400,
	parameter CALI_PACKET_BYTE_NUM		= 16'd800,
	parameter LOOP_ERR_PERMIT_NUM		= 8'd6,
	parameter DDR_ADDR_BASE_LOOPPACKET1	= 32'h800000,//8M
	parameter DDR_ADDR_BASE_LOOPPACKET2	= 32'h810000,//8M+64K
	parameter DDR_ADDR_BASE_CALIPACKET1	= 32'h900000,//9M
	parameter DDR_ADDR_BASE_CALIPACKET2	= 32'h910000,//9M+64K
	parameter USER_DW       			= 16,
	parameter AXI_WBL					= 16,//write channel BURST LENGTH = AWLEN/AWLEN+1
    parameter AXI_RBL					= 16,//read channel BURST LENGTH = AWLEN/ARLEN+1
	parameter AXI_AW 		    		= 32,
	parameter AXI_DW 		    		= 64
)
(
	input						i_clk_50m,
	input						i_rst_n,
	input						i_flash_initload_done,
	input						i_flash_save_done,

	//ddr ctrl siganl	
	output						o_wrfifo_en,
	output [USER_DW-1:0]		o_wrfifo_data,
	output						o_ddr_rden,
	output						o_fifo_rden,
	input  [USER_DW-1:0]		i_fifo_rddata,
	output [AXI_AW-1:0]     	o_rdddr_addr_base,
	input						i_rdfifo_empty,

	//optcom_datagram_parser communication siganl
	output						o_ack_cmd,
	input						i_parse_done/*synthesis PAP_MARK_DEBUG="true"*/,
	output [AXI_AW-1:0]			o_looppacket_raddr,
	output [AXI_AW-1:0]			o_calipacket_raddr,
	output [5:0]				o_time_ram_rdaddr,
	input						i_opt_recv_ack,
	input						i_cali_addr_incr,
	input  [7:0]				i_get_cmd_code,
	input  [AXI_AW-1:0]			i_wrddr_addr_base, 
	input  [23:0]				i_optcom_bit_flag,
	output [15:0]				o_looppackdot_ordnum,
	output [15:0]				o_calipackdot_ordnum,

	output						o_cache_rden,
	output [10:0]				o_cache_rdaddr,
	input  [7:0]				i_cache_rddata,

	input						i_cycle_make_done/*synthesis PAP_MARK_DEBUG="true"*/,
	input						i_packet_make,
	input						i_packet_pingpang,
	input						i_calib_pingpang,
	input						i_calib_make,
	input						i_connect_state,

	input  [15:0]				i_code_angle,
	//temperature compensation
	input  [6:0]				i_hvcp_ram_rdaddr,
	output [15:0]				o_hvcp_rddata,

	input  [6:0]				i_dicp_ram_rdaddr,
	output [15:0]				o_dicp_rddata,

	//encode compensation	
	input	[7:0]				i_compen_rdaddr/*synthesis PAP_MARK_DEBUG="true"*/,
	output	[15:0]				o_compen_rddata/*synthesis PAP_MARK_DEBUG="true"*/,
	output	[15:0]				o_code_rddata,

	//data out the parameters required by the upper layer
	output [ 3:0]				o_reso_mode,
	output [ 1:0]				o_freq_mode,
	output [15:0]				o_config_mode,
	output [15:0]				o_scan_freqence,
	output [15:0]				o_angle_reso,
	output [15:0]				o_tdc_window,
	output [15:0]				o_angle_offset,
	output [15:0]				o_distance_min,
	output [15:0]				o_distance_max,
	output [15:0]				o_temp_apdhv_base,
	output [15:0]				o_temp_temp_base,
	output [15:0]				o_dist_diff,
	output [15:0]				o_rssi_minval,
	output [15:0]				o_rssi_maxval,
	output [15:0]				o_start_index,
	output [15:0]				o_stop_index,
	output [15:0]				o_index_num,
	
	//FIT PARA
	output [15:0]				o_rise_divid,
	output [15:0]				o_pulse_start,
	output [15:0]				o_pulse_divid,

	//JUMP PARA
	output [15:0]				o_jump_para1,
	output [15:0]				o_jump_para2,
	output [15:0]				o_jump_para3,
	output [15:0]				o_jump_para4,
	output [15:0]				o_jump_para5,

	//TAIL PARA	
	output [15:0]				o_tail_para1,
	output [15:0]				o_tail_para2,
	output [15:0]				o_tail_para3,
	output [15:0]				o_tail_para4,
	output [15:0]				o_tail_polar,
	output [15:0]				o_cluster_dist,
	output [15:0]				o_cluster_pulse,

	output [1:0]				o_telegram_flag,
	output						o_calibrate_switch,
	output						o_program_n,
	output						o_init_load_done,
	output						o_rst_n				
);
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg [23:0]				r_para_state 			= 24'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [7:0]				r_cali_state 			= 8'h0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [7:0]				r_calitrans_cnt			= 8'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [31:0]				r_delay_cnt				= 32'd0;
	reg						r_init_load_done		= 1'b0;

	reg						r_wrfifo_en				= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [USER_DW-1:0]		r_wrfifo_data			= {USER_DW{1'b0}}/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [AXI_AW-1:0]    	r_wrddr_addr_base		= {AXI_AW{1'b0}}/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [ 9:0]				r_write_cnt				= 10'd0;
	reg						r_ddr_rden				= 1'b0;
	reg						r_fifo_rden				= 1'b0;
	reg [AXI_AW-1:0]    	r_rdddr_addr_base		= {AXI_AW{1'b0}}/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [31:0]				r_read_cnt				= 32'd0/*synthesis PAP_MARK_DEBUG="true"*/;

	reg	[15:0] 				r_hvcp_wrdata 			= 16'd0;
	reg	[6:0] 				r_hvcp_ram_wraddr 		= 7'd0;
	reg		 				r_hvcp_ram_wren 		= 1'b0;
	reg [6:0] 				r_hvcp_ram_rdaddr 		= 7'd0;
	reg						r_hvcp_set_flag 		= 1'b0;

	reg	[15:0] 				r_dicp_wrdata 			= 16'd0;
	reg	[6:0] 				r_dicp_ram_wraddr 		= 7'd0;
	reg		 				r_dicp_ram_wren 		= 1'b0;
	reg [6:0] 				r_dicp_ram_rdaddr 		= 7'd0;
	reg						r_dicp_set_flag 		= 1'b0;

	reg	[15:0] 				r_opt_wrdata 			= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg	[7:0] 				r_opt_ram_wraddr 		= 8'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg	[7:0] 				r_opt_ram_rdaddr 		= 8'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg		 				r_opt_ram_wren1 		= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg		 				r_opt_ram_wren2 		= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;

	reg [8:0]				r_sram_addr_para 		= 9'd0;
	reg 					r_tabledata_flag 		= 1'b0;

	reg 					r_rssi_set_flag 		= 1'b0;
	reg 					r_code_set_flag 		= 1'b0;
	
	
	reg						r_login_state_02 		= 1'b0;
	reg						r_login_state_03 		= 1'b0;
	reg						r_check_pass_state 		= 1'b0;
	reg [10:0]				r_cache_rdaddr 			= 11'd0;

	reg						r_init_flag 			= 1'b0;
	reg [15:0]				r_rdsram_check_sum		= 16'd0;
	reg 					r_check_sum_flag 		= 1'b0;

	reg [31:0]				r_start_angle			= 32'hFFF24460;
	reg [31:0]				r_stop_angle			= 32'h002932E0;

	reg [ 7:0]				r_device_mode			= 8'b1100_0000;

	reg [15:0]				r_rise_divid			= 16'd0;
	reg [15:0]				r_pulse_start			= 16'd0;
	reg [15:0]				r_pulse_divid			= 16'd0;
	
	reg	[ 3:0]				r_reso_mode 			= 4'h0;
	reg	[ 1:0]				r_freq_mode 			= 2'h0;
	reg	[15:0]				r_config_mode 			= 16'h01/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [15:0]				r_scan_freqence			= 16'd3000;
	reg [15:0]				r_angle_reso			= 16'd1000;
	reg [15:0]				r_tdc_window			= 16'h4A50;
	reg [15:0]				r_angle_offset			= 16'h0000;
	reg [15:0]				r_distance_min			= 16'd50;
	reg [15:0]				r_distance_max			= 16'd50000;
	reg [15:0]				r_temp_apdhv_base		= 16'h5B4;
	reg [15:0]				r_temp_temp_base		= 16'd35;
	reg [15:0]				r_dist_diff				= 16'd0;
	reg [15:0]				r_rssi_minval			= 16'd1;
	reg [15:0]				r_rssi_maxval			= 16'd4095;
	reg [15:0]				r_start_index			= 16'd0;
	reg [15:0]				r_stop_index			= 16'd3600;
	reg [255:0]				r_jump_filter_para		= 256'h0;
	reg [255:0]				r_tail_filter_para		= 256'h0;
	reg [255:0]				r_smooth_filter_para	= 256'h0;
	reg [255:0]				r_tdc_coe_para			= 256'h0;
	reg [255:0]				r_fit_coe_para			= 256'h0;

	reg [63:0]				r_time_stamp_set		= 64'd0;
	reg 					r_time_stamp_sig		= 1'b0;

	reg [1:0] 				r_telegram_flag 		= 2'b00/*synthesis PAP_MARK_DEBUG="true"*/;

	reg 					r_rst_n		  			= 1'b0;
	reg 					r_measure_switch 		= 1'b1;

	reg [31:0]				r_program_cnt 			= 32'd0;
	reg 					r_program_n	  			= 1'b1;

	reg						r_code_conti_flag 		= 1'b1;
	reg						r_code_integ_flag 		= 1'b0;
	reg [15:0]				r_code_seque_reg  		= 16'd0;

	reg						r_packet_make			= 1'b0;
	reg [7:0]				r_set_cmd_code			= 8'd0;

	reg [23:0]				r_optcom_bit_flag		= 24'h0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg						r_calibrate_switch		= 1'b0;
	reg						r_cmd_make				= 1'b0;
	reg	[7:0]				r_cmd_ack				= 8'h0;

	reg [7:0]				r_opt_ack_done			= 8'h0;		
	reg [7:0]				r_trans_err_times		= 8'd0;
	reg [AXI_AW-1:0]		r_looppacket_rdaddr_base= {AXI_AW{1'b0}};
	reg [AXI_AW-1:0]		r_calipacket_rdaddr_base= {AXI_AW{1'b0}};
	reg [AXI_AW-1:0]		r_packet_rdaddr_cache	= {AXI_AW{1'b0}};
	reg [5:0]				r_time_ram_rdaddr		= 6'd0;
	reg [5:0]				r_time_rdaddr_cache		= 6'd0;
	reg [15:0]				r_looppackdot_ordnum	= 16'd0;
	reg [15:0]				r_calipackdot_ordnum	= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [15:0]				r_looppackdot_cache		= 16'd0;

	wire					w_cmd_ack_rise/*synthesis PAP_MARK_DEBUG="true"*/;
	wire					w_opt_ack_fall;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam ADDR_WIDTH = $clog2(AXI_DW/8);
	localparam CALI_TRANS_NUM_CYLCLE	= 8'd36;
	localparam CALI_TRANS_DELAY			= 32'd46300;

	localparam DATA_BYTE_1K 			= 10'd512;
	localparam SRAM_HVCP_ADDR_START		= 18'h200;
	localparam SRAM_HVCP_ADDR_END		= 18'h259;
	localparam SRAM_DICP_ADDR_START		= 18'h400;
	localparam SRAM_DICP_ADDR_END		= 18'h459;
	localparam SRAM_CDCP_ADDR_START		= 18'h600;
	localparam SRAM_CDCP_ADDR_END		= 18'h6B3;
	localparam SRAM_CODE_ADDR_START		= 18'h800;
	localparam SRAM_CODE_ADDR_END		= 18'h8B3;

	localparam CALI_IDLE				= 8'b0000_0000,
			   CALI_WAIT				= 8'b0000_0001,
			   CALI_TRANS_START			= 8'b0000_0010,
			   CALI_TRANS_EN			= 8'b0000_0100,
			   CALI_TRANS_CYCLE			= 8'b0000_1000,
			   CALI_TRANS_DONE			= 8'b0001_0000;

	localparam PARA_IDLE				= 24'b0000_0000_0000_0000_0000_0000,
			   PARA_WAIT				= 24'b0000_0000_0000_0000_0000_0001,
			   READ_DDR_EN				= 24'b0000_0000_0000_0000_0000_0010,
			   READ_DDR_FIFO			= 24'b0000_0000_0000_0000_0000_0100,
			   READ_FIFO_EN				= 24'b0000_0000_0000_0000_0000_1000,
			   READ_FIFO_DATA			= 24'b0000_0000_0000_0000_0001_0000,
			   PARA_DATA_WRITE			= 24'b0000_0000_0000_0000_0010_0000,
			   PARA_DATA_CNT			= 24'b0000_0000_0000_0000_0100_0000,
			   READ_CACHE				= 24'b0000_0000_0000_0000_1000_0000,
			   READ_CACHE_MSB			= 24'b0000_0000_0000_0001_0000_0000,
			   READ_CACHE_ADDR1			= 24'b0000_0000_0000_0010_0000_0000,
			   READ_CACHE_BEAT			= 24'b0000_0000_0000_0100_0000_0000,
			   READ_CACHE_LSB			= 24'b0000_0000_0000_1000_0000_0000,
			   WRITE_DDR_FIFO			= 24'b0000_0000_0001_0000_0000_0000,
			   READ_CACHE_ADDR2			= 24'b0000_0000_0010_0000_0000_0000,
			   WRITE_DDR_FIFO_SHIFT		= 24'b0000_0000_0100_0000_0000_0000,
			   PARA_END					= 24'b0000_0000_1000_0000_0000_0000;
	//---------------------------------------------------------------------------------------------- 
	// input the siganl of parse_done
	// contral the flag siganl of tx data to down
	//----------------------------------------------------------------------------------------------
	//r_cmd_ack
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_cmd_ack	<= 8'h0;
		else 
			r_cmd_ack	<= {r_cmd_ack[6:0], i_parse_done};	
	end
			
	assign	w_cmd_ack_rise = r_cmd_ack[5] & ~r_cmd_ack[6];

	//r_opt_ack_done
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_opt_ack_done	<= 8'h0;
		else 
			r_opt_ack_done	<= {r_opt_ack_done[6:0], i_opt_recv_ack};	
	end
			
	assign	w_opt_ack_fall = ~r_opt_ack_done[4] & r_opt_ack_done[5];
	//----------------------------------------------------------------------------------------------
	// ethnet communication prepare
	// CALI_CMD、LOOP_CMD package siganl control
	//----------------------------------------------------------------------------------------------	
	//r_set_cmd_code
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_set_cmd_code	<= 8'd0;
		else if(r_cmd_ack[2])
			r_set_cmd_code	<= i_get_cmd_code;
		else
			r_set_cmd_code	<= r_set_cmd_code;
	end	

	//r_optcom_bit_flag
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_optcom_bit_flag	<= 24'h0;
		else if(i_get_cmd_code != `ERROR && r_cmd_ack[2])
			r_optcom_bit_flag	<= i_optcom_bit_flag;
		else
			r_optcom_bit_flag	<= r_optcom_bit_flag;
	end

	//r_calibrate_switch
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calibrate_switch	<= 1'b0;
		else if (r_set_cmd_code == `CALI_SWITCH_CMD && r_optcom_bit_flag[3:2] == 2'b10)
			r_calibrate_switch	<= 1'b1;
		else if (r_optcom_bit_flag[3:2] == 2'b00)
			r_calibrate_switch	<= 1'b0;
	end

	//r_telegram_flag
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_telegram_flag	<= 2'b00;
		else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:2] == 2'b01)
			r_telegram_flag	<= 2'b01;
		else if(r_set_cmd_code == `CALI_DATA_CMD && r_optcom_bit_flag[3:2] == 2'b10 && r_cmd_ack[4])
			r_telegram_flag	<= 2'b10;
		else if(r_set_cmd_code == `LOOP_SWITCH_CMD && r_optcom_bit_flag[3:2] == 2'b00)
			r_telegram_flag	<= 2'b00;
		else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:2] == 2'b00)
			r_telegram_flag	<= 2'b00;
		else
			r_telegram_flag	<= 2'b00;
	end	

	//r_trans_err_times
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_trans_err_times	<= 8'd0;
		else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b011 && r_cmd_ack[4])
			r_trans_err_times	<= r_trans_err_times + 1'b1;
		else if(i_cycle_make_done)
			r_trans_err_times	<= 8'd0;
	end

	//r_cmd_make
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_cmd_make	<= 1'b0;
		else if(r_set_cmd_code == `LOOP_DATA_CMD && i_opt_recv_ack) begin
			if(r_looppacket_rdaddr_base >= 32'd400 && r_looppacket_rdaddr_base <32'd14400) begin
				if(w_cmd_ack_rise)
					r_cmd_make	<= 1'b1;
				else
					r_cmd_make	<= 1'b0;
			end else if(r_looppacket_rdaddr_base == 32'd0 && r_optcom_bit_flag[3:1] == 3'b011) begin
				if(w_cmd_ack_rise)
					r_cmd_make	<= 1'b1;
				else
					r_cmd_make	<= 1'b0;
			end else
				r_cmd_make <= i_cycle_make_done;
		end else if(r_set_cmd_code == `CALI_DATA_CMD) begin
			if(r_packet_make)
				r_cmd_make	<= 1'b1;
			else
				r_cmd_make	<= 1'b0;
		end else if(r_set_cmd_code == `SAVE_FLASH_CMD || r_set_cmd_code == `SAVE_PARA_FACT) begin
			if(i_flash_save_done)
				r_cmd_make	<= 1'b1;
			else
				r_cmd_make	<= 1'b0;
		end else begin
			if(w_cmd_ack_rise)
				r_cmd_make	<= 1'b1;
			else
				r_cmd_make	<= 1'b0;
		end
	end	

	//r_looppacket_rdaddr_base
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_looppacket_rdaddr_base	<= {AXI_AW{1'b0}};
			r_packet_rdaddr_cache	<= {AXI_AW{1'b0}};
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_looppacket_rdaddr_base < 32'd14400) begin
			if(r_optcom_bit_flag[3:1] == 3'b010 && w_opt_ack_fall) begin
				r_packet_rdaddr_cache	<= r_looppacket_rdaddr_base;
				r_looppacket_rdaddr_base	<= r_looppacket_rdaddr_base + LOOP_PACKET_BYTE_NUM;			
			end else if(r_optcom_bit_flag[3:1] == 3'b011 && w_cmd_ack_rise) begin
				if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
					r_looppacket_rdaddr_base	<= r_packet_rdaddr_cache;
				else	
					r_looppacket_rdaddr_base	<= r_packet_rdaddr_cache + LOOP_PACKET_BYTE_NUM;
			end else if(r_optcom_bit_flag[3:1] == 3'b011 && w_opt_ack_fall)	begin
				if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
					r_looppacket_rdaddr_base	<= r_looppacket_rdaddr_base + LOOP_PACKET_BYTE_NUM;
				else
					r_looppacket_rdaddr_base	<= r_looppacket_rdaddr_base;
			end
		end else begin
			r_looppacket_rdaddr_base	<= {AXI_AW{1'b0}};
			r_packet_rdaddr_cache	<= {AXI_AW{1'b0}};
		end
	end	

	//r_time_ram_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_time_ram_rdaddr	<= 6'd0;
			r_time_rdaddr_cache <= 6'd0;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b010 && w_opt_ack_fall) begin
			r_time_rdaddr_cache	<= r_time_ram_rdaddr;
			r_time_ram_rdaddr	<= r_time_ram_rdaddr + 1'b1;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b011 && w_cmd_ack_rise) begin
			if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
				r_time_ram_rdaddr	<= r_time_rdaddr_cache;
			else	
				r_time_ram_rdaddr	<= r_time_rdaddr_cache + 1'b1;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b011 && w_opt_ack_fall) begin
			if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
				r_time_ram_rdaddr	<= r_time_ram_rdaddr + 1'b1;
			else	
				r_time_ram_rdaddr	<= r_time_ram_rdaddr;
		end else if(i_cycle_make_done) begin
			r_time_ram_rdaddr	<= 6'd0;
			r_time_rdaddr_cache <= 6'd0;
		end
	end

	//r_looppackdot_ordnum
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_looppackdot_ordnum	<= 16'd0;
			r_looppackdot_cache		<= 16'd0;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b010 && w_opt_ack_fall) begin
			r_looppackdot_cache		<= r_looppackdot_ordnum;
			r_looppackdot_ordnum	<= r_looppackdot_ordnum + 1'b1;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b011 && w_cmd_ack_rise) begin
			if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
				r_looppackdot_ordnum	<= r_looppackdot_cache;
			else	
				r_looppackdot_ordnum	<= r_looppackdot_cache + 1'b1;
		end else if(r_set_cmd_code == `LOOP_DATA_CMD && r_optcom_bit_flag[3:1] == 3'b011 && w_opt_ack_fall) begin
			if(r_trans_err_times <= LOOP_ERR_PERMIT_NUM)
				r_looppackdot_ordnum	<= r_looppackdot_ordnum + 1'b1;
			else	
				r_looppackdot_ordnum	<= r_looppackdot_ordnum;
		end else if(i_cycle_make_done) begin
			r_looppackdot_ordnum	<= 16'd0;
			r_looppackdot_cache		<= 16'd0;
		end
	end

	//r_tabledata_flag
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_tabledata_flag		<= 1'b0;
		else if(r_set_cmd_code == `WRITE_DDR_CMD && r_cmd_ack[4])
			r_tabledata_flag		<= 1'b1;
		else
			r_tabledata_flag		<= 1'b0;
	end	
	//----------------------------------------------------------------------------------------------
	// State machine transition condition
	//----------------------------------------------------------------------------------------------
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_cali_state	<= CALI_IDLE;
			r_packet_make	<= 1'b0;
		end else begin
			case(r_cali_state)
				CALI_IDLE: begin
					r_packet_make	<= 1'b0;
					r_cali_state	<= CALI_WAIT;
				end
				CALI_WAIT: begin
					if(r_telegram_flag[1] && r_calibrate_switch)
						r_cali_state	<= CALI_TRANS_START;
					else
						r_cali_state	<= CALI_WAIT;
				end
				CALI_TRANS_START: r_cali_state	<= CALI_TRANS_EN;
				CALI_TRANS_EN: begin
					r_packet_make	<= 1'b1;
					if(r_calitrans_cnt >= (CALI_TRANS_NUM_CYLCLE - 1'b1))
						r_cali_state	<= CALI_TRANS_DONE;
					else
						r_cali_state	<= CALI_TRANS_CYCLE;
				end
				CALI_TRANS_CYCLE: begin
					r_packet_make	<= 1'b0;
					if(r_delay_cnt >= (CALI_TRANS_DELAY - 1'b1))
						r_cali_state	<= CALI_TRANS_EN;
					else
						r_cali_state	<= CALI_TRANS_CYCLE;
				end
				CALI_TRANS_DONE: begin
					r_packet_make	<= 1'b0;
					r_cali_state	<= CALI_IDLE;
				end
				default: begin
					r_packet_make	<= 1'b0;
					r_cali_state	<= CALI_IDLE;
				end
			endcase
		end
	end

	//r_calitrans_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calitrans_cnt	<= 8'd0;
		else if(r_cali_state == CALI_TRANS_EN)
			r_calitrans_cnt	<= r_calitrans_cnt + 1'b1;
		else if(r_cali_state == CALI_IDLE)
			r_calitrans_cnt	<= 8'd0;
	end	

	//r_delay_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_delay_cnt	<= 32'd0;
		else if(r_cali_state == CALI_TRANS_CYCLE)
			r_delay_cnt	<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt	<= 32'd0;
	end	

	//r_calipacket_rdaddr_base
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calipacket_rdaddr_base	<= {AXI_AW{1'b0}};
		else if(r_cali_state == CALI_WAIT && i_cali_addr_incr)
			r_calipacket_rdaddr_base	<= {AXI_AW{1'b0}};
		else if(r_set_cmd_code == `CALI_DATA_CMD && i_cali_addr_incr)
			r_calipacket_rdaddr_base	<= r_calipacket_rdaddr_base + CALI_PACKET_BYTE_NUM;	
		else
			r_calipacket_rdaddr_base	<= r_calipacket_rdaddr_base;
	end

	//r_calipackdot_ordnum
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_calipackdot_ordnum	<= 16'd0;
		else if(r_cali_state == CALI_WAIT && i_cali_addr_incr)
			r_calipackdot_ordnum	<= 16'd0;
		else if(r_set_cmd_code == `CALI_DATA_CMD && i_cali_addr_incr)
			r_calipackdot_ordnum	<= r_calipackdot_ordnum + 1'b1;
		else
			r_calipackdot_ordnum	<= r_calipackdot_ordnum;
	end
	//----------------------------------------------------------------------------------------------
	// State machine load parameter
	//----------------------------------------------------------------------------------------------			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_para_state	<= PARA_IDLE;
		else begin
			case(r_para_state)
				PARA_IDLE: begin
					r_para_state	<= PARA_WAIT;
					end
				PARA_WAIT: begin
					if(i_flash_initload_done)
						r_para_state	<= READ_DDR_EN;
					else if(r_tabledata_flag)
						r_para_state	<= READ_CACHE;
					end
				READ_DDR_EN:r_para_state	<= READ_DDR_FIFO;
				READ_DDR_FIFO: begin
					if(~i_rdfifo_empty)
						r_para_state	<= READ_FIFO_EN;
					else
						r_para_state	<= READ_DDR_FIFO;
				end
				READ_FIFO_EN: begin
					r_para_state	<= READ_FIFO_DATA;
				end
				READ_FIFO_DATA: begin
					r_para_state	<= PARA_DATA_WRITE;
				end
				PARA_DATA_WRITE: begin
					r_para_state	<= PARA_DATA_CNT;
				end
				PARA_DATA_CNT: begin
					if(r_read_cnt >= 16'hFFF)
						r_para_state	<= PARA_END;
					else begin
						if(i_rdfifo_empty)
							r_para_state	<= READ_DDR_EN;
						else
							r_para_state	<= READ_FIFO_EN;
					end
				end
				READ_CACHE: begin
					r_para_state	<= READ_CACHE_MSB;
				end
				READ_CACHE_MSB: begin
					r_para_state	<= READ_CACHE_ADDR1;
				end	
				READ_CACHE_ADDR1: begin
					r_para_state	<= READ_CACHE_BEAT;
				end	
				READ_CACHE_BEAT: begin
					r_para_state	<= READ_CACHE_LSB;
				end
				READ_CACHE_LSB: begin
					r_para_state	<= WRITE_DDR_FIFO;
				end
				WRITE_DDR_FIFO: begin
					r_para_state	<= READ_CACHE_ADDR2;
				end
				READ_CACHE_ADDR2: begin
					r_para_state	<= WRITE_DDR_FIFO_SHIFT;
				end
				WRITE_DDR_FIFO_SHIFT: begin
					if(r_write_cnt >= DATA_BYTE_1K - 1'b1)
						r_para_state	<= PARA_END;
					else
						r_para_state	<= READ_CACHE;
				end
				PARA_END: begin
					r_para_state	<= PARA_WAIT;
				end
				default:r_para_state	<= PARA_IDLE;
				endcase
			end
	//----------------------------------------------------------------------------------------------
	// ddr3 sram communication domain
	//----------------------------------------------------------------------------------------------	
	//r_read_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_read_cnt		<= 32'd0;
		else if(r_para_state == PARA_IDLE)
			r_read_cnt		<= 32'd0;
		else if(r_para_state == PARA_DATA_CNT)
			r_read_cnt		<= r_read_cnt + 1'b1;
		else if(r_para_state == PARA_END)
			r_read_cnt		<= 32'd0;
	end

	//r_write_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == PARA_IDLE)
			r_write_cnt		<= 10'd0;
		else if(r_para_state == WRITE_DDR_FIFO_SHIFT)
			r_write_cnt		<= r_write_cnt + 1'b1;
		else if(r_para_state == PARA_END)
			r_write_cnt		<= 10'd0;
	end

	//r_ddr_rden active hign
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddr_rden	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_ddr_rden	<= 1'b0;
		else if(r_para_state == READ_DDR_EN)
			r_ddr_rden	<= 1'b1;
		else
			r_ddr_rden	<= 1'b0;
	end

	//r_rdddr_addr_base
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_rdddr_addr_base	<= {AXI_AW{1'b0}};
		else if(r_para_state == PARA_IDLE)
			r_rdddr_addr_base	<= {AXI_AW{1'b0}};
		else if(r_para_state == PARA_DATA_CNT && i_rdfifo_empty)
			r_rdddr_addr_base	<= r_rdddr_addr_base + (AXI_RBL << ADDR_WIDTH);
		else if(r_para_state == PARA_END)
			r_rdddr_addr_base	<= {AXI_AW{1'b0}};
		else
			r_rdddr_addr_base	<= r_rdddr_addr_base;
	end

	//r_fifo_rden active hign
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_fifo_rden	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_fifo_rden	<= 1'b0;
		else if(r_para_state == READ_FIFO_EN)
			r_fifo_rden	<= 1'b1;
		else
			r_fifo_rden	<= 1'b0;
	end

	//r_cache_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_cache_rdaddr	<= 11'd0;
		else if(r_para_state == PARA_IDLE || r_para_state == PARA_END)
			r_cache_rdaddr	<= 11'd0;
		else if(r_para_state == READ_CACHE_ADDR1)
			r_cache_rdaddr	<= r_cache_rdaddr + 1'b1;
		else if(r_para_state == READ_CACHE_ADDR2)
			r_cache_rdaddr	<= r_cache_rdaddr + 1'b1;			
	end

	//r_wrfifo_data 
	//write data to ddr fifo from cache
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_wrfifo_data		<= {USER_DW{1'b0}};
		else if(r_para_state == PARA_END)
			r_wrfifo_data		<= {USER_DW{1'b0}};
		else if(r_para_state == READ_CACHE_MSB)
			r_wrfifo_data[15:8] <= i_cache_rddata;
		else if(r_para_state == READ_CACHE_LSB)
			r_wrfifo_data[ 7:0] <= i_cache_rddata;
	end

	//r_wrfifo_en Active hign
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_wrfifo_en	<= 1'b0;
		else if(r_para_state == PARA_IDLE)
			r_wrfifo_en	<= 1'b0;
		else if(r_para_state == WRITE_DDR_FIFO)
			r_wrfifo_en	<= 1'b1;
		else
			r_wrfifo_en	<= 1'b0;
	end

	//r_rst_n
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)begin
			r_init_load_done	<= 1'b0;
		end else if(r_para_state == PARA_DATA_CNT && (r_read_cnt >= 16'hFFF)) begin
			r_init_load_done	<= 1'b1;
		end
	end	

	//----------------------------------------------------------------------------------------------
	// The parameters are read out from the sram and output assign to use
	//----------------------------------------------------------------------------------------------
	//r_config_mode
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_config_mode			<= 16'h01;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `DEVICE_MODE_CFG && i_fifo_rddata != 16'hFFFF)
			r_config_mode			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `DEVICE_MODE_CFG && i_wrddr_addr_base == 32'h0)
			r_config_mode			<= r_wrfifo_data;
	end	

	//r_scan_freqence
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_scan_freqence			<= 16'd3000;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `SCAN_FREQUENCY && i_fifo_rddata != 16'hFFFF)
			r_scan_freqence			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `SCAN_FREQUENCY && i_wrddr_addr_base == 32'h0)
			r_scan_freqence			<= r_wrfifo_data;
	end	

	//r_freq_mode
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_freq_mode			<= 2'h0;
		else if(r_scan_freqence == 16'd3000)
			r_freq_mode			<= 2'h0;
		else if(r_scan_freqence == 16'd1500)
			r_freq_mode			<= 2'h1;
		else if(r_scan_freqence == 16'd5000)
			r_freq_mode			<= 2'h2;
		else
			r_freq_mode			<= 2'h0;
	end	

	//r_angle_reso
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_angle_reso			<= 16'd1000;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `ANGLE_RESOLUTION && i_fifo_rddata != 16'hFFFF)
			r_angle_reso			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `ANGLE_RESOLUTION && i_wrddr_addr_base == 32'h0)
			r_angle_reso			<= r_wrfifo_data;
	end

	//r_reso_mode   0:0.1     1:0.05
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_reso_mode			<= 4'h0;
		else if(r_angle_reso == 16'd1000)
			r_reso_mode			<= 4'h0;
		else if(r_angle_reso == 16'd500)
			r_reso_mode			<= 4'h1;
		else
			r_reso_mode			<= 4'h0;
	end

	//r_start_index, r_stop_index
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_start_index		<= 16'd0;
			r_stop_index		<= 16'd3599;
		end else if(r_angle_reso == 16'd1000) begin
			r_start_index		<= 16'd0;
			r_stop_index		<= 16'd3599;
		end else if(r_angle_reso == 16'd500) begin
			r_start_index		<= 16'd0;
			r_stop_index		<= 16'd7199;
		end else begin
			r_start_index		<= 16'd0;
			r_stop_index		<= 16'd3599;
		end
	end

	//r_tdc_window
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_tdc_window			<= 16'h4A50;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `TDC_WINDOW && i_fifo_rddata != 16'hFFFF)
			r_tdc_window			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `TDC_WINDOW && i_wrddr_addr_base == 32'h0)
			r_tdc_window			<= r_wrfifo_data;
	end

	//r_angle_offset
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_angle_offset			<= 16'h0E00;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `ANGLE_OFFSET && i_fifo_rddata != 16'hFFFF)
			r_angle_offset			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `ANGLE_OFFSET && i_wrddr_addr_base == 32'h0)
			r_angle_offset			<= r_wrfifo_data;
	end

	//r_distance_min
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_distance_min			<= 16'd50;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `DIST_MIN && i_fifo_rddata != 16'hFFFF)
			r_distance_min			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `DIST_MIN && i_wrddr_addr_base == 32'h0)
			r_distance_min			<= r_wrfifo_data;
	end

	//r_distance_max
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_distance_max			<= 16'd25000;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `DIST_MAX && i_fifo_rddata != 16'hFFFF)
			r_distance_max			<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `DIST_MAX && i_wrddr_addr_base == 32'h0)
			r_distance_max			<= r_wrfifo_data;
	end

	//r_temp_apdhv_base
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_temp_apdhv_base		<= 16'h333;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `TEMP_APDHV_BASE && i_fifo_rddata != 16'hFFFF)
			r_temp_apdhv_base		<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `TEMP_APDHV_BASE && i_wrddr_addr_base == 32'h0)
			r_temp_apdhv_base		<= r_wrfifo_data;
	end

	//r_temp_temp_base
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_temp_temp_base		<= 16'd35;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `TEMP_TEMP_BASE && i_fifo_rddata != 16'hFFFF)
			r_temp_temp_base		<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `TEMP_TEMP_BASE && i_wrddr_addr_base == 32'h0)
			r_temp_temp_base		<= r_wrfifo_data;
	end

	//r_dist_diff
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_dist_diff				<= 16'd0;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `DIST_DIFF && i_fifo_rddata != 16'hFFFF)
			r_dist_diff				<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `DIST_DIFF&& i_wrddr_addr_base == 32'h0)
			r_dist_diff				<= r_wrfifo_data;
	end	

	//r_rssi_minval
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_rssi_minval				<= 16'd1;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `RSSI_MINVAL && i_fifo_rddata != 16'hFFFF)
			r_rssi_minval				<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `RSSI_MINVAL&& i_wrddr_addr_base == 32'h0)
			r_rssi_minval				<= r_wrfifo_data;
	end

	//r_rssi_maxval
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_rssi_maxval				<= 16'd4095;
		else if(r_para_state == PARA_DATA_WRITE && r_read_cnt == `RSSI_MAXVAL && i_fifo_rddata != 16'hFFFF)
			r_rssi_maxval				<= i_fifo_rddata;
		else if(r_para_state == WRITE_DDR_FIFO && r_write_cnt == `RSSI_MAXVAL&& i_wrddr_addr_base == 32'h0)
			r_rssi_maxval				<= r_wrfifo_data;
	end

	//r_jump_filter_para
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_jump_filter_para				<= 256'h0;
		else if(r_para_state == PARA_DATA_WRITE) begin
			if(r_read_cnt >= `JUMP_PARA_0 && r_read_cnt <= `JUMP_PARA_F )
				r_jump_filter_para				<= {r_jump_filter_para[239:0], i_fifo_rddata};
		end else if(r_para_state == WRITE_DDR_FIFO)
			if(r_write_cnt >= `JUMP_PARA_0 && r_write_cnt <= `JUMP_PARA_F && i_wrddr_addr_base == 32'h0)
				r_jump_filter_para				<= {r_jump_filter_para[239:0], r_wrfifo_data};
	end	

	//r_tail_filter_para
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_tail_filter_para				<= 256'h0;
		else if(r_para_state == PARA_DATA_WRITE) begin
			if(r_read_cnt >= `TAIL_PARA_0 && r_read_cnt <= `TAIL_PARA_F )
				r_tail_filter_para				<= {r_tail_filter_para[239:0], i_fifo_rddata};
		end else if(r_para_state == WRITE_DDR_FIFO)
			if(r_write_cnt >= `TAIL_PARA_0 && r_write_cnt <= `TAIL_PARA_F && i_wrddr_addr_base == 32'h0)
				r_tail_filter_para				<= {r_tail_filter_para[239:0], r_wrfifo_data};
	end	

	//r_smooth_filter_para
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_smooth_filter_para				<= 256'h0;
		else if(r_para_state == PARA_DATA_WRITE) begin
			if(r_read_cnt >= `SMOOTH_PARA_0 && r_read_cnt <= `SMOOTH_PARA_F)
				r_smooth_filter_para				<= {r_smooth_filter_para[239:0], i_fifo_rddata};
		end else if(r_para_state == WRITE_DDR_FIFO)
			if(r_write_cnt >= `SMOOTH_PARA_0 && r_write_cnt <= `SMOOTH_PARA_F && i_wrddr_addr_base == 32'h0)
				r_smooth_filter_para				<= {r_smooth_filter_para[239:0], r_wrfifo_data};
	end	

	//r_tdc_coe_para
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_tdc_coe_para				<= 256'h0;
		else if(r_para_state == PARA_DATA_WRITE) begin
			if(r_read_cnt >= `TDC_PARA_0 && r_read_cnt <= `TDC_PARA_F )
				r_tdc_coe_para				<= {r_tdc_coe_para[239:0], i_fifo_rddata};
		end else if(r_para_state == WRITE_DDR_FIFO)
			if(r_write_cnt >= `TDC_PARA_0 && r_write_cnt <= `TDC_PARA_F && i_wrddr_addr_base == 32'h0)
				r_tdc_coe_para				<= {r_tdc_coe_para[239:0], r_wrfifo_data};
	end	

	//r_fit_coe_para
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_fit_coe_para				<= 256'h0;
		else if(r_para_state == PARA_DATA_WRITE) begin
			if(r_read_cnt >= `FIT_PARA_0 && r_read_cnt <= `FIT_PARA_F )
				r_fit_coe_para				<= {r_fit_coe_para[239:0], i_fifo_rddata};
		end else if(r_para_state == WRITE_DDR_FIFO)
			if(r_write_cnt >= `FIT_PARA_0 && r_write_cnt <= `FIT_PARA_F && i_wrddr_addr_base == 32'h0)
				r_fit_coe_para				<= {r_fit_coe_para[239:0], r_wrfifo_data};
	end

	//----------------------------------------------------------------------------------------------
	// High voltage temperature compensation and distance temperature compensation area
	//----------------------------------------------------------------------------------------------		
	//r_hvcp_ram_wren
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_hvcp_ram_wren <= 1'd0;
		else if(r_para_state == PARA_DATA_WRITE)begin
			if(r_read_cnt >= SRAM_HVCP_ADDR_START && r_read_cnt <= SRAM_HVCP_ADDR_END)
				r_hvcp_ram_wren <= 1'd1;
			else
				r_hvcp_ram_wren <= 1'd0;
		end else 
			r_hvcp_ram_wren <= 1'd0;

	//r_hvcp_ram_wraddr	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_hvcp_ram_wraddr <= 7'd0;
		else if(r_para_state == PARA_DATA_CNT)begin
			if(r_read_cnt >= SRAM_HVCP_ADDR_START && r_read_cnt <= SRAM_HVCP_ADDR_END)
				r_hvcp_ram_wraddr <= r_hvcp_ram_wraddr + 1'b1;
			else
				r_hvcp_ram_wraddr <= 7'd0;
		end else if(r_para_state == PARA_END)
			r_hvcp_ram_wraddr <= 7'd0;

	//r_hvcp_wrdata		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_hvcp_wrdata <= 16'd0 ;		
		else if(r_para_state == PARA_DATA_WRITE)
			r_hvcp_wrdata <= i_fifo_rddata;

	//r_hvcp_ram_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_hvcp_ram_rdaddr <= 7'd0;
		else
			r_hvcp_ram_rdaddr <= i_hvcp_ram_rdaddr;		

	//r_dicp_ram_wren
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dicp_ram_wren <= 1'd0;
		else if(r_para_state == PARA_DATA_WRITE)begin
			if(r_read_cnt >= SRAM_DICP_ADDR_START && r_read_cnt <= SRAM_DICP_ADDR_END)
				r_dicp_ram_wren <= 1'd1;
			else
				r_dicp_ram_wren <= 1'd0;
		end
		else 
			r_dicp_ram_wren <= 1'd0;

	//r_dicp_ram_wraddr	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dicp_ram_wraddr <= 7'd0;
		else if(r_para_state == PARA_DATA_CNT)begin
			if(r_read_cnt >= SRAM_DICP_ADDR_START && r_read_cnt <= SRAM_DICP_ADDR_END)
				r_dicp_ram_wraddr <= r_dicp_ram_wraddr + 1'b1;
			else
				r_dicp_ram_wraddr <= 7'd0;
		end
		else if(r_para_state == PARA_END)
			r_dicp_ram_wraddr <= 7'd0;

	//r_dicp_wrdata		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dicp_wrdata <= 16'd0 ;		
		else if(r_para_state == PARA_DATA_WRITE)
			r_dicp_wrdata <= i_fifo_rddata;

	//r_dicp_ram_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dicp_ram_rdaddr <= 7'd0;
		else
			r_dicp_ram_rdaddr <= i_dicp_ram_rdaddr;	

	//----------------------------------------------------------------------------------------------
	// encode compensation parameter
	//----------------------------------------------------------------------------------------------
	//r_opt_ram_wren1
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opt_ram_wren1 <= 1'd0;
		else if(r_para_state == PARA_DATA_WRITE)begin
			if(r_read_cnt >= SRAM_CDCP_ADDR_START && r_read_cnt <= SRAM_CDCP_ADDR_END)
				r_opt_ram_wren1 <= 1'd1;
			else
				r_opt_ram_wren1 <= 1'd0;
		end
		else 
			r_opt_ram_wren1 <= 1'd0;	
	
	//r_opt_ram_wren2
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opt_ram_wren2 <= 1'd0;
		else if(r_para_state == PARA_DATA_WRITE)begin
			if(r_read_cnt >= SRAM_CODE_ADDR_START && r_read_cnt <= SRAM_CODE_ADDR_END)
				r_opt_ram_wren2 <= 1'd1;
			else
				r_opt_ram_wren2 <= 1'd0;
		end
		else 
			r_opt_ram_wren2 <= 1'd0;
			
	//r_opt_wrdata		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opt_wrdata <= 16'd0 ;		
		else if(r_para_state == PARA_DATA_WRITE)
			r_opt_wrdata <= i_fifo_rddata;
			
	//r_opt_ram_wraddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opt_ram_wraddr <= 8'd0;
		else if(r_para_state == PARA_DATA_CNT)begin
			if(r_read_cnt >= SRAM_CDCP_ADDR_START && r_read_cnt <= SRAM_CODE_ADDR_END)
				r_opt_ram_wraddr <= r_opt_ram_wraddr + 1'b1;
			else
				r_opt_ram_wraddr <= 8'd0;
		end
		else if(r_para_state == PARA_END)
			r_opt_ram_wraddr <= 8'd0;
	
	//r_opt_ram_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opt_ram_rdaddr <= 8'd0;
		else
			r_opt_ram_rdaddr <= i_compen_rdaddr;								
	//----------------------------------------------------------------------------------------------
	// assign define output
	//----------------------------------------------------------------------------------------------
	assign		o_set_cmd_code 		= r_set_cmd_code;
	assign		o_ack_cmd 			= r_cmd_make;
	assign		o_looppacket_raddr	= i_packet_pingpang ? (r_looppacket_rdaddr_base+DDR_ADDR_BASE_LOOPPACKET2):(r_looppacket_rdaddr_base+DDR_ADDR_BASE_LOOPPACKET1);
	assign		o_calipacket_raddr	= i_calib_pingpang ? (r_calipacket_rdaddr_base+DDR_ADDR_BASE_CALIPACKET2):(r_calipacket_rdaddr_base+DDR_ADDR_BASE_CALIPACKET1);
	assign		o_time_ram_rdaddr	= r_time_ram_rdaddr;
	assign		o_looppackdot_ordnum= r_looppackdot_ordnum;
	assign		o_calipackdot_ordnum= r_calipackdot_ordnum;

	assign		o_cache_rden 		= 1'b1;
	assign		o_cache_rdaddr 		= r_cache_rdaddr;

	assign		o_wrfifo_en 		= r_wrfifo_en;
	assign		o_wrfifo_data 		= r_wrfifo_data;
	assign		o_ddr_rden 			= r_ddr_rden;
	assign		o_fifo_rden 		= r_fifo_rden;
	assign		o_rdddr_addr_base	= r_rdddr_addr_base;
	
	//the parameters required by the upper layer
	assign     	o_reso_mode			= r_reso_mode;
	assign     	o_freq_mode			= r_freq_mode;
	assign		o_config_mode 		= r_config_mode;
	assign		o_scan_freqence		= r_scan_freqence;
	assign		o_angle_reso		= r_angle_reso;
	assign		o_tdc_window 		= r_tdc_window;
	assign		o_angle_offset 		= r_angle_offset;
	assign		o_distance_min 		= r_distance_min;
	assign		o_distance_max 		= r_distance_max;
	assign		o_temp_apdhv_base 	= r_temp_apdhv_base;
	assign		o_temp_temp_base 	= r_temp_temp_base;
	assign		o_dist_diff 		= r_dist_diff;
	assign		o_rssi_minval		= r_rssi_minval;
	assign		o_rssi_maxval		= r_rssi_maxval;
	assign		o_start_index		= r_start_index;
	assign		o_stop_index		= r_stop_index;
	
	assign		o_rise_divid 		= r_fit_coe_para[255:240];
	assign		o_pulse_start 		= r_fit_coe_para[239:224];
	assign		o_pulse_divid 		= r_fit_coe_para[223:208];

	assign		o_jump_para1		= r_jump_filter_para[255:240];
	assign		o_jump_para2		= r_jump_filter_para[239:224];
	assign		o_jump_para3		= r_jump_filter_para[223:208];
	assign		o_jump_para4		= r_jump_filter_para[207:192];
	assign		o_jump_para5		= r_jump_filter_para[191:176];
	
	assign		o_tail_para1		= r_tail_filter_para[255:240];
	assign		o_tail_para2		= r_tail_filter_para[239:224];
	assign		o_tail_para3		= r_tail_filter_para[223:208];
	assign		o_tail_para4		= r_tail_filter_para[207:192];
	assign		o_tail_polar		= r_tail_filter_para[191:176];
	assign		o_cluster_dist		= r_tail_filter_para[175:160];
	assign		o_cluster_pulse		= r_tail_filter_para[159:144];

	assign		o_telegram_flag 	= r_telegram_flag;
	assign		o_calibrate_switch	= r_calibrate_switch;
	assign		o_program_n 		= r_program_n;
	assign		o_rst_n	 			= r_rst_n;
	assign		o_init_load_done	= r_init_load_done;
	
	//--------------------------------------------------------------------------------------------------
	//ip instance
	//--------------------------------------------------------------------------------------------------
	cp_ram16x128 u1_hvcp_ram_inst (
  		.wr_data		( r_hvcp_wrdata				),	// input [15:0]
  		.wr_addr		( r_hvcp_ram_wraddr			),	// input [6:0]
  		.wr_en			( r_hvcp_ram_wren			),	// input
  		.wr_clk			( i_clk_50m					),	// input
  		.wr_rst			( 1'b0						),	// input
  		.rd_addr		( r_hvcp_ram_rdaddr			),	// input [6:0]
  		.rd_data		( o_hvcp_rddata				),	// output [15:0]
  		.rd_clk			( i_clk_50m					),	// input
  		.rd_rst			( 1'b0						) 	// input
	);

	cp_ram16x128 u2_dicp_ram_inst (
  		.wr_data		( r_dicp_wrdata				),	// input [15:0]
  		.wr_addr		( r_dicp_ram_wraddr			),	// input [6:0]
  		.wr_en			( r_dicp_ram_wren			),	// input
  		.wr_clk			( i_clk_50m					),	// input
  		.wr_rst			( 1'b0						),	// input
  		.rd_addr		( r_dicp_ram_rdaddr			),	// input [6:0]
  		.rd_data		( o_dicp_rddata				),	// output [15:0]
  		.rd_clk			( i_clk_50m					),	// input
  		.rd_rst			( 1'b0						) 	// input
	);

	opto_ram16x256 u3_opt_ram_data1 (
  		.wr_data		( r_opt_wrdata				),  // input [15:0]
  		.wr_addr		( r_opt_ram_wraddr			),  // input [7:0]
  		.wr_en			( r_opt_ram_wren1			),  // input
  		.wr_clk			( i_clk_50m					),  // input
  		.wr_rst			( 1'b0						),  // input
  		.rd_addr		( r_opt_ram_rdaddr			),  // input [7:0]
  		.rd_data		( o_compen_rddata			),  // output [15:0]
  		.rd_clk			( i_clk_50m					),  // input
  		.rd_rst			( 1'b0						)   // input
	);

	opto_ram16x256 u4_opt_ram_data2 (
  		.wr_data		( r_opt_wrdata				),  // input [15:0]
  		.wr_addr		( r_opt_ram_wraddr			),  // input [7:0]
  		.wr_en			( r_opt_ram_wren2			),  // input
  		.wr_clk			( i_clk_50m					),  // input
  		.wr_rst			( 1'b0						),  // input
  		.rd_addr		( r_opt_ram_rdaddr			),  // input [7:0]
  		.rd_data		( o_code_rddata				),  // output [15:0]
  		.rd_clk			( i_clk_50m					),  // input
  		.rd_rst			( 1'b0						)   // input
	);
	
endmodule 