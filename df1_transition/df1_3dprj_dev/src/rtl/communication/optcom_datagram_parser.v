//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: optcom_datagram_parser
// Date Created 	: 2023/10/31 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:optcom_datagram_parser
//				upstream and downstream data interaction
//				1、Receive optical communication data 
//				2、parse out instructions and required parameter data
//				3、Output the necessary data to Bottom FPGA according to the protocol requirements
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
`include "datagram_cmd_defines.v"
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module optcom_datagram_parser
#(
	parameter FIRMWARE_VERSION		= 32'h23110312,
	parameter LOOP_PACKET_BYTE_NUM	= 16'd400,
	parameter CALI_PACKET_BYTE_NUM	= 16'd800,
	parameter USER_DW       		= 8,
	parameter FIFO_WDW      		= 32,
    parameter FIFO_RDW      		= 8,
	parameter AXI_WBL				= 16,//write channel BURST LENGTH = AWLEN/AWLEN+1
    parameter AXI_RBL				= 1,//read channel BURST LENGTH = AWLEN/ARLEN+1
	parameter AXI_WBL2				= 8,//write channel BURST LENGTH = AWLEN/AWLEN+1
    parameter AXI_RBL2				= 2,//read channel BURST LENGTH = AWLEN/ARLEN+1
	parameter AXI_AW 		    	= 32,
	parameter AXI_DW 		    	= 64
)
(
	input					i_clk,
	input					i_rst_n,

	//optcom_parameter_init communication siganl
	input					i_ack_cmd,
	input  [AXI_AW-1:0]		i_looppacket_raddr_base,
	input  [AXI_AW-1:0]		i_calipacket_raddr_base,
	output 					o_parse_done,
	output					o_opt_recv_ack,
	output					o_cali_addr_incr,
	output [ 7:0]			o_get_cmd_code,
	output [23:0]			o_optcom_bit_flag,
	output [AXI_AW-1:0]		o_ddr_wraddr_base,

	//save data from sram to flash
	output 					o_ddr2flash_wrsig,
	output					o_save_fact_para,
	output					o_load_fact_para,
	output [AXI_AW-1:0]		o_ddr2flash_addr_base,
	output [23:0]			o_flash_addr_offset,

	//read ddr to user
	output					o_rddr_usercmd,
	output					o_ddr_rden,
	output					o_fifo_rden,
	input  [USER_DW-1:0]	i_fifo_rddata,
	output [AXI_AW-1:0]     o_rdddr_addr_base,
	input					i_fifo_empty,
	input					i_alfull_ddrdata_opt,

	output                  o_ddr_rden2,
    output					o_fifo_rden2,
    input  [FIFO_RDW-1:0]	i_fifo_rddata2/*synthesis PAP_MARK_DEBUG="true"*/,
    output [AXI_AW-1:0]     o_rdddr_addr_base2,
    input                  	i_rdfifo_empty2,
    input                  	i_rdfifo_alfull2,
    input                  	i_rddr_ready2,

	//cache for need write to sram
	input					i_cache_rden,
	input  [10:0]			i_cache_rdaddr,
	output [7:0]			o_cache_rddata,

	//check return
	input  [15:0]			i_device_temp,
	input  [15:0]			i_apd_hv_value,
	input  [15:0]			i_apd_temp_value,
	input  [15:0]			i_dac_value,
	input  [15:0]			i_dicp_value,

	//packet data
	input  [15:0]			i_config_mode,
	input  [15:0]			i_status_code,
	input  [15:0]			i_looppackdot_ordnum,
	input  [15:0]			i_scan_freqence,
	input  [15:0]			i_angle_reso,
	input  [31:0]			i_start_angle,
	input  [31:0]			i_stop_angle,
	input					i_packet_pingpang,

	input					i_time_ram_wren,
	input [5:0]				i_time_ram_wraddr,
	input [127:0]			i_time_ram_wrdata,
	input [5:0]				i_time_ram_rdaddr,

	//calibrated access
	input  [15:0]			i_calipackdot_ordnum,

	//code ram
	input [7:0]				i_code_wraddr,
	input [15:0]			i_code_wrdata,
	input					i_code_wren,

	//optics communication
	output					o_optrecv_rden,
	output [10:0]			o_optrecv_rdaddr,
	input  [ 7:0]			i_optrecv_data,
	input  [11:0]			i_optrecv_num,
	input					i_optrecv_done,

	output 					o_optsend_wren,	
	output [10:0]			o_optsend_wraddr,
	output [7:0]			o_optsend_wrdata,	
	output 					o_optsend_req,		
	output [11:0]			o_optsend_num,

	output					o_busy
);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam  ADDR_WIDTH 						= $clog2(AXI_DW/8);
	localparam	DDR_READ_BYTE1K  				= 16'd1024;

	localparam	HEADER_SIZE 					= 16'd4;
	localparam	HEADER_CODE						= 8'h02;

	localparam	GENERAL_ACK_DATA_SIZE  			= 16'd16;
	localparam	FACTPARA_ACK_DATA_SIZE			= 16'd12;
	localparam	LOOP_SW_ACK_DATA_SIZE  			= 16'd12;
	localparam	ERROR_ACK_DATA_SIZE  			= 16'd12;
	localparam	CALI_SWACK_DATA_SIZE  			= 16'd12;
	localparam	RDSRAM_ACK_DATA_SIZE  			= 16'd1040;
	localparam	CAIL_PACK_DATA_SIZE  			= 16'd814;
	localparam	LOOP_PACK_DATA_SIZE  			= 16'd480;
	localparam	CHECK_UPPER_DATA_SIZE  			= 16'd1040;
	localparam	CHECK_LOWER_DATA_SIZE  			= 16'd36;

	localparam	PACKET_IDLE   					= 8'b0000_0000,
				PACKET_READY					= 8'b0000_0001,
				PACKET_WAIT						= 8'b0000_0010,
				PACKET_READ						= 8'b0000_0100,
				PACKET_BEAT						= 8'b0000_1000,
				PACKET_READ_DONE				= 8'b0001_0000;

	localparam	DDR_IDLE   						= 8'b0000_0000,
				DDR_READY						= 8'b0000_0001,
				DDR_DELAY						= 8'b0000_0010,
				DDR_READ						= 8'b0000_0100,
				DDR_BEAT						= 8'b0000_1000,
				DDR_READ_DONE					= 8'b0001_0000;

	localparam	IDLE   							= 16'b0000_0000_0000_0000,
				READY							= 16'b0000_0000_0000_0001,
				RXRAM_RDEN						= 16'b0000_0000_0000_0010,
				RXRAM_PARSEDATA					= 16'b0000_0000_0000_0100,
				RXRAM_RDADDR					= 16'b0000_0000_0000_1000,
				RXRAM_RDDATA					= 16'b0000_0000_0001_0000,
				RXRAM_RDDONE					= 16'b0000_0000_0010_0000,
				RXRAM_RDJUDGE					= 16'b0000_0000_0100_0000,
				RXRAM_RDDELAY					= 16'b0000_0000_1000_0000,
				RXRAM_RDEND						= 16'b0000_0001_0000_0000,
				TXRAM_START						= 16'b0000_0010_0000_0000,
				TXRAM_WRADDR					= 16'b0000_0100_0000_0000,
				TXRAM_DATA						= 16'b0000_1000_0000_0000,
				WAIT_FIFO						= 16'b0001_0000_0000_0000,
				LOOP_FIFO						= 16'b0010_0000_0000_0000,
				TXRAM_DONE						= 16'b0100_0000_0000_0000;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg [15:0] 			r_cali_txcnt			= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [7:0]			rddr_state 				= DDR_IDLE/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [15:0]			state_r 				= IDLE/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [7:0]			packet_state			= PACKET_IDLE/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					busy_r					= 1'b0;
	reg 				cali_addr_incr_r		= 1'b0;
	reg					r_write_num 			= 1'b0;
	reg	[15:0]			r_recv_delay			= 16'd0;
	reg	[31:0]			r_waitddr_delay			= 32'd0;

	reg					r_rddr_usercmd			= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_ddr_rden				= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_fifo_rden				= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg  [AXI_AW-1:0]   r_rdddr_addr			= {AXI_AW{1'b0}}/*synthesis PAP_MARK_DEBUG="true"*/;
	reg  [15:0]			r_ddrbyte_cnt			= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;

	reg					r_ddr_rden2				= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_fifo_rden2			= 1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg  [AXI_AW-1:0]   r_rdddr_addr2			= {AXI_AW{1'b0}}/*synthesis PAP_MARK_DEBUG="true"*/;
	reg  [15:0]			r_ddrbyte_cnt2			= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;

	reg [AXI_AW-1:0]  	ddr_wraddr_base_r		= {AXI_AW{1'b0}};
	reg [AXI_AW-1:0]  	ddr_rdaddr_base_r		= {AXI_AW{1'b0}};

	reg	[ 7:0]			get_cmd_type_r 			= `ERROR;
	reg [ 7:0]			opt_occupy_st_r			= 8'h0;	

	reg 				cache_ram_wren			= 1'b0;
	reg [10:0]			cache_ram_wraddr		= 11'd0;
	reg [7:0]			cache_ram_wrdata		= 8'h0;

	reg					time_ram_rden_r			= 1'b0;
	reg [5:0]			time_ram_rdaddr_r		= 6'd0;
	reg [7:0]			time_ram_rddata_r		= 8'h0;

	reg [23:0]			optcom_bit_flag_r		= 24'h0;

	reg					parse_done_r			= 1'b0;
	reg					opt_recv_ack_r			= 1'b0;
	reg					opt_send_en_r			= 1'b0;	
	reg					opt_send_flag_r			= 1'b0;				
	reg [ 3:0]  		optcom_mode_r			= 4'h0;
	reg 				optsend_ram_wren_r		= 1'b0;	
	reg [10:0]			optsend_ram_wraddr_r	= 11'd0;
	reg [7:0]			optsend_ram_wrdata_r	= 8'h0/*synthesis PAP_MARK_DEBUG="true"*/;	
	reg 				optsend_req_r			= 1'b0;		
	reg [11:0]			optsend_num_r			= 12'd0;

	reg	[10:0]			rxram_rdaddr_r 			= 11'd0;
	reg					parse_start_r			= 1'b0;

	reg [11:0]			optcom_byte_size_r 		= 12'd0;
	reg [11:0]			byte_cnt_r 				= 12'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [11:0]			byte_index 				= 12'd0;
	reg [11:0]			rx_byte_cnt_r 			= 12'd0;
	reg [11:0]			tx_byte_cnt_r 			= 12'd0;
	reg [15:0]			data_check_sum_r 		= 16'h0;
	reg 				r_cmd_valid 			= 1'b1;
	reg [ 7:0]			r_opt_code 				= 8'h0;

	reg					ddr2flash_wrsig_r		= 1'b0;
	reg					save_fact_para_r		= 1'b0;
	reg					load_fact_para_r		= 1'b0;
	reg [31:0]			ddr2flash_addr_base_r	= 32'd0;
	reg [31:0]  		flash_addr_offset_r		= 32'd0;

	reg	[13:0]			r_packet_rdaddr 		= 14'd0;
	wire[7:0]			w_packet_rddata;
	wire[7:0]			w_packet_rddata1;
	wire[7:0]			w_packet_rddata2;

	wire[127:0]			w_time_ram_rddata;
	wire[127:0]			w_time_ram_rddata1;
	wire[127:0]			w_time_ram_rddata2;

	reg [8:0]			r_code_rdaddr 			= 9'd0;
	wire[7:0]			w_code_rddata;

	//----------------------------------------------------------------------------------------------
	// get command type
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			get_cmd_type_r <= `ERROR;
		else if (state_r == RXRAM_RDADDR && byte_cnt_r == 12'd6)
			get_cmd_type_r <= i_optrecv_data;
		else if (state_r == RXRAM_RDDONE && (data_check_sum_r[7:0] != i_optrecv_data))
			get_cmd_type_r <= `ERROR;
	end

	//o_busy
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			busy_r	<= 1'b0;
		else if(state_r == READY)
			busy_r	<= 1'b0;
		else
			busy_r	<= 1'b1;
	end
	//----------------------------------------------------------------------------------------------
	// up to down ack flag signal set
	// Set the number of bytes received or send
	//----------------------------------------------------------------------------------------------
	//opt_send_flag_r define
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			opt_send_flag_r 	<= 1'b0;
		else if(state_r == READY && i_ack_cmd )
			opt_send_flag_r 	<= 1'b1;
		else
			opt_send_flag_r 	<= 1'b0;
	end

	//optcom_byte_size_r define
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			parse_start_r 		<= 1'b0;
			optcom_byte_size_r 	<= 12'd0;
		end else if (state_r == READY && i_optrecv_done) begin
			parse_start_r		<= 1'b1;
			optcom_byte_size_r 	<= i_optrecv_num;
		end else if (state_r == READY && i_ack_cmd) begin
			case(get_cmd_type_r)
				`WRITE_DDR_CMD, `SAVE_FLASH_CMD: begin
					optcom_byte_size_r 		<= GENERAL_ACK_DATA_SIZE;
				end
				`LOAD_PARA_FACT, `SAVE_PARA_FACT: begin
					optcom_byte_size_r 		<= FACTPARA_ACK_DATA_SIZE;
				end
				`READ_DDR_CMD: begin
					optcom_byte_size_r 		<= RDSRAM_ACK_DATA_SIZE;
				end
				`CHECK_STATE_CMD: begin
					optcom_byte_size_r 		<= CHECK_UPPER_DATA_SIZE;
				end
				`CALI_SWITCH_CMD: begin
					optcom_byte_size_r 		<= CALI_SWACK_DATA_SIZE;
				end
				`CALI_DATA_CMD: begin
					optcom_byte_size_r 		<= CAIL_PACK_DATA_SIZE;
				end
				`LOOP_SWITCH_CMD: begin
					optcom_byte_size_r 		<= LOOP_SW_ACK_DATA_SIZE;
				end
				`LOOP_DATA_CMD, `ONCE_SWITCH_CMD: begin
					optcom_byte_size_r 		<= LOOP_PACK_DATA_SIZE;
				end
				`ERROR: begin
					optcom_byte_size_r		<= ERROR_ACK_DATA_SIZE;
				end
				default: optcom_byte_size_r 	<= 12'd0;
			endcase
		end else
			parse_start_r 		<= 1'b0;
	end
	//----------------------------------------------------------------------------------------------
	// communication state machine
	// read data from ddr according to read cmd
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_ddr_rden			<= 1'b0;
			rddr_state			<= DDR_IDLE;
			r_rdddr_addr		<= {AXI_AW{1'b0}};
			r_ddrbyte_cnt		<= 16'd0;
		end else begin
			case(rddr_state)
				DDR_IDLE: begin
					r_ddr_rden			<= 1'b0;
					rddr_state			<= DDR_READY;
					r_rdddr_addr		<= {AXI_AW{1'b0}};
					r_ddrbyte_cnt		<= 16'd0;
				end
				DDR_READY: begin
					if(opt_send_flag_r && (get_cmd_type_r == `READ_DDR_CMD)) begin
						r_rdddr_addr	<= ddr_rdaddr_base_r;
						rddr_state		<= DDR_DELAY;
					end else begin
						rddr_state		<= DDR_READY;
					end
				end
				DDR_DELAY: rddr_state	<= DDR_READ;
				DDR_READ: begin
					if(r_ddrbyte_cnt >= DDR_READ_BYTE1K)
						rddr_state	<= DDR_READ_DONE;
					else if(~i_alfull_ddrdata_opt) begin
						r_ddr_rden	<= 1'b1;
						rddr_state	<= DDR_BEAT;
					end else
						rddr_state	<= DDR_READ;
				end	
				DDR_BEAT: begin
					r_ddr_rden		<= 1'b0;
					rddr_state		<= DDR_READ;
					r_ddrbyte_cnt	<= r_ddrbyte_cnt + (AXI_RBL << ADDR_WIDTH);
					r_rdddr_addr	<= r_rdddr_addr + (AXI_RBL << ADDR_WIDTH);
				end
				DDR_READ_DONE: rddr_state	<= DDR_IDLE;
				default : rddr_state <= DDR_IDLE;
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// loop packet data
	// read data from ddr
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_ddr_rden2			<= 1'b0;
			packet_state			<= PACKET_IDLE;
			r_rdddr_addr2		<= {AXI_AW{1'b0}};
			r_ddrbyte_cnt2		<= 16'd0;
		end else begin
			case(packet_state)
				PACKET_IDLE: begin
					r_ddr_rden2			<= 1'b0;
					packet_state			<= PACKET_READY;
					r_rdddr_addr2		<= {AXI_AW{1'b0}};
					r_ddrbyte_cnt2		<= 16'd0;
				end
				PACKET_READY: begin
					if(opt_send_flag_r && (get_cmd_type_r == `LOOP_DATA_CMD)) begin
						r_rdddr_addr2	<= i_looppacket_raddr_base;
						packet_state	<= PACKET_WAIT;
					end else if(opt_send_flag_r && (get_cmd_type_r == `CALI_DATA_CMD)) begin
						r_rdddr_addr2	<= i_calipacket_raddr_base;
						packet_state	<= PACKET_WAIT;
					end else begin
						packet_state	<= PACKET_READY;
					end
				end
				PACKET_WAIT: begin
					if(i_rddr_ready2)
						packet_state	<= PACKET_READ;
					else
						packet_state	<= PACKET_WAIT;
				end
				PACKET_READ: begin
					if(get_cmd_type_r == `LOOP_DATA_CMD && r_ddrbyte_cnt2 >= LOOP_PACKET_BYTE_NUM)
						packet_state	<= PACKET_READ_DONE;
					else if(get_cmd_type_r == `CALI_DATA_CMD && r_ddrbyte_cnt2 >= CALI_PACKET_BYTE_NUM)
						packet_state	<= PACKET_READ_DONE;
					else begin
							r_ddr_rden2		<= 1'b1;
							packet_state	<= PACKET_BEAT;
					end
				end	
				PACKET_BEAT: begin
					r_ddr_rden2		<= 1'b0;
					packet_state	<= PACKET_WAIT;
					r_ddrbyte_cnt2	<= r_ddrbyte_cnt2 + (AXI_RBL2 << ADDR_WIDTH);
					r_rdddr_addr2	<= r_rdddr_addr2 + (AXI_RBL2 << ADDR_WIDTH);
				end
				PACKET_READ_DONE: packet_state	<= PACKET_IDLE;
				default : packet_state <= PACKET_IDLE;
			endcase
		end
	end
	//----------------------------------------------------------------------------------------------
	// communication state machine
	// send data to ram, ready to opt send
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			state_r 			<= IDLE;
			parse_done_r 		<= 1'b0;
			opt_recv_ack_r		<= 1'b0;
			rxram_rdaddr_r		<= 11'd0;
			byte_cnt_r			<= 12'd0;
			r_recv_delay		<= 16'd0;
			r_waitddr_delay		<= 32'd0;
		end else begin
			case(state_r)
				IDLE: begin
					state_r 			<= READY;
					parse_done_r 		<= 1'b0;
					rxram_rdaddr_r		<= 11'd0;
					byte_cnt_r			<= 12'd0;
					r_recv_delay		<= 16'd0;
					r_waitddr_delay		<= 32'd0;
				end
				READY: begin
					if (parse_start_r)
						state_r <= RXRAM_RDEN;
					else if(opt_send_flag_r)
						state_r	<= TXRAM_START;
					else
						state_r <= READY;
				end
				RXRAM_RDEN:
					state_r <= RXRAM_PARSEDATA;		
				RXRAM_PARSEDATA: begin
					if (byte_cnt_r >= optcom_byte_size_r - 12'd1)
						state_r <= RXRAM_RDDONE;
					else
						state_r <= RXRAM_RDADDR;
				end
				RXRAM_RDADDR: begin  
					state_r 		<= RXRAM_RDDATA;
					rxram_rdaddr_r	<= rxram_rdaddr_r + 1'b1;
				end				
				RXRAM_RDDATA: begin
					state_r 		<= RXRAM_PARSEDATA;
					byte_cnt_r		<= byte_cnt_r + 1'b1;
				end
				RXRAM_RDDONE: begin
					state_r 		<= RXRAM_RDJUDGE;
				end
				RXRAM_RDJUDGE: begin
					if(get_cmd_type_r != `LOOP_DATA_CMD)begin
						state_r 		<= RXRAM_RDDELAY;
					end
					else begin
						state_r 		<= RXRAM_RDEND;
					end
				end
				RXRAM_RDDELAY:begin
					if(r_recv_delay >= 16'd14999)begin
						r_recv_delay	<= 16'd0;
						state_r 		<= RXRAM_RDEND;
					end else begin
						r_recv_delay	<= r_recv_delay + 1'b1;
						state_r 		<= RXRAM_RDDELAY;
					end
				end
				RXRAM_RDEND:begin
					state_r 		<= IDLE;
					parse_done_r 	<= 1'b1;
					opt_recv_ack_r	<= 1'b1;
					byte_cnt_r		<= 12'd0;
				end
				TXRAM_START: begin
					r_waitddr_delay	<= 32'd0;
					if (byte_cnt_r >= optcom_byte_size_r - 12'd1)
						state_r <= TXRAM_DONE;
					else
						state_r <= TXRAM_WRADDR;	
				end
				TXRAM_WRADDR: begin
					state_r	<= TXRAM_DATA;
				end
				TXRAM_DATA: begin	
					byte_cnt_r	<= byte_cnt_r + 1'b1;
					if(get_cmd_type_r == `READ_DDR_CMD && byte_cnt_r < 12'd1035)
						state_r	<= WAIT_FIFO;
					else if(get_cmd_type_r == `LOOP_DATA_CMD) begin
						if(byte_cnt_r>=12'd76 && byte_cnt_r<12'd475)
							state_r	<= LOOP_FIFO;
						else
							state_r	<= TXRAM_START;
					end else if(get_cmd_type_r == `CALI_DATA_CMD) begin
						if(byte_cnt_r>=12'd10 && byte_cnt_r<12'd809)
							state_r	<= LOOP_FIFO;
						else
							state_r	<= TXRAM_START;
					end else
						state_r	<= TXRAM_START;
				end
				WAIT_FIFO: begin
					if(i_fifo_empty) begin
						r_waitddr_delay	<= r_waitddr_delay + 1'b1;
						if(r_waitddr_delay >= 32'd10_000_000)
							state_r	<= TXRAM_START;
						else
							state_r	<= WAIT_FIFO;
					end else
						state_r	<= TXRAM_START;
				end
				LOOP_FIFO: begin
					if(i_rdfifo_empty2)
						state_r	<= LOOP_FIFO;
					else
						state_r	<= TXRAM_START;
				end
				TXRAM_DONE: begin
					state_r 		<= IDLE;
					opt_recv_ack_r	<= 1'b0;
					byte_cnt_r		<= 12'd0;
				end
				default : state_r <= IDLE;
			endcase
		end
	end

	//cali_addr_incr_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			cali_addr_incr_r	<= 1'b0;
		else if(get_cmd_type_r == `CALI_DATA_CMD && state_r == TXRAM_DONE)
			cali_addr_incr_r	<= 1'b1;
		else
			cali_addr_incr_r 	<= 1'b0;
	end
	//----------------------------------------------------------------------------------------------
	// data sum check
	//----------------------------------------------------------------------------------------------
	// data check 
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			data_check_sum_r <= 16'h0;
		else if (state_r == IDLE)
			data_check_sum_r <= 16'h0;
		else if (state_r == TXRAM_DATA && byte_cnt_r < optcom_byte_size_r - 12'd2)
			data_check_sum_r <= data_check_sum_r + optsend_ram_wrdata_r;
		else if (state_r ==RXRAM_RDADDR && byte_cnt_r < optcom_byte_size_r - 12'd2)
			data_check_sum_r <= data_check_sum_r + i_optrecv_data;
	end

	//ddr2flash_wrsig_r、save_fact_para_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			ddr2flash_wrsig_r	<= 1'b0;
			save_fact_para_r	<= 1'b0;
		end else if (state_r == RXRAM_RDDONE) begin
			if(get_cmd_type_r == `SAVE_FLASH_CMD) begin
				ddr2flash_wrsig_r 	<= 1'b1;
				save_fact_para_r	<= 1'b0;
			end else if(get_cmd_type_r == `SAVE_PARA_FACT) begin
				ddr2flash_wrsig_r 	<= 1'b1;
				save_fact_para_r	<= 1'b1;
			end else begin
				ddr2flash_wrsig_r	<= 1'b0;
				save_fact_para_r	<= 1'b0;
			end
		end else begin
			ddr2flash_wrsig_r 	<= 1'b0;
			save_fact_para_r	<= 1'b0;
		end
	end

	//load_fact_para_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			load_fact_para_r <= 1'b0;
		else if (state_r == RXRAM_RDDONE && get_cmd_type_r == `LOAD_PARA_FACT)
			load_fact_para_r <= 1'b1;
		else
			load_fact_para_r <= 1'b0;
	end

	//----------------------------------------------------------------------------------------------
	// opt send ram
	//----------------------------------------------------------------------------------------------
	//r_rddr_usercmd
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_rddr_usercmd <= 1'b0;
		else if(state_r	== IDLE)
			r_rddr_usercmd <= 1'b0;
		else if (state_r == TXRAM_START && (get_cmd_type_r == `READ_DDR_CMD))
			r_rddr_usercmd <= 1'b1;
		else if (state_r == TXRAM_DONE)
			r_rddr_usercmd <= 1'b0;
		else
			r_rddr_usercmd <= r_rddr_usercmd;
	end

	//r_write_num
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_write_num <= 1'b1;
		else if (state_r == IDLE)
			r_write_num <= 1'b1;
		else if (state_r == TXRAM_START && byte_cnt_r >= 16'd13)
			r_write_num <= ~r_write_num;
	end

	//r_fifo_rden ddr data
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_fifo_rden	<= 1'b0;
		else if (state_r == TXRAM_START && (get_cmd_type_r == `READ_DDR_CMD)) begin
			if(byte_cnt_r >= 12'd13 && byte_cnt_r <= 12'd1036 && r_write_num)
				r_fifo_rden <= 1'b1;
			else
				r_fifo_rden <= 1'b0;
		end else
			r_fifo_rden <= 1'b0;
	end

	//optsend_ram_wren_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			optsend_ram_wren_r <= 1'b0;
			optsend_num_r		<= 12'd0;
		end else if (state_r == TXRAM_START) begin
			optsend_ram_wren_r <= 1'b1;
			optsend_num_r		<= optcom_byte_size_r;
		end else begin
			optsend_ram_wren_r <= 1'b0;
			optsend_num_r		<= optsend_num_r;
		end
	end
	//optsend_ram_wraddr_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			optsend_ram_wraddr_r <= 11'd0;
		else if (state_r == TXRAM_WRADDR)
			optsend_ram_wraddr_r <= optsend_ram_wraddr_r + 1'b1;
		else if(state_r == IDLE)
			optsend_ram_wraddr_r <= 11'd0;
	end
	//optsend_req_r
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			optsend_req_r <= 1'b0;
		else if (state_r == TXRAM_DONE)
			optsend_req_r <= 1'b1;
		else
			optsend_req_r <= 1'b0;
	end

	//----------------------------------------------------------------------------------------------
	// code tooth period
	//----------------------------------------------------------------------------------------------
	//r_code_rdaddr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_code_rdaddr <= 9'd0;
		else if(state_r == TXRAM_WRADDR && get_cmd_type_r == `CHECK_STATE_CMD &&
				byte_cnt_r >= 12'd318 && byte_cnt_r <= 12'd677)
			r_code_rdaddr <= r_code_rdaddr + 1'b1;
		else if(state_r == IDLE)
			r_code_rdaddr <= 9'd0;
	end

	//----------------------------------------------------------------------------------------------
	// RX:	analyze the received data and output it to the corresponding interface
	//		extract valid data
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			optcom_bit_flag_r		<= 24'h0;
			ddr_wraddr_base_r		<= 32'd0;
			ddr_rdaddr_base_r		<= 32'd0;
			flash_addr_offset_r		<= 32'd0;
			ddr2flash_addr_base_r	<= 32'd0;
		end else if (byte_cnt_r >= 12'd7 && state_r == RXRAM_RDADDR) begin
			case(get_cmd_type_r)
				`WRITE_DDR_CMD: begin
					if (byte_cnt_r >= 12'd7 && byte_cnt_r <= 12'd9)
						optcom_bit_flag_r <= {optcom_bit_flag_r[15:0], i_optrecv_data};
					else if (byte_cnt_r >= 12'd10 && byte_cnt_r <= 12'd13)
						ddr_wraddr_base_r <= {ddr_wraddr_base_r[23:0], i_optrecv_data};
				end
				`SAVE_FLASH_CMD: begin
					if (byte_cnt_r >= 12'd7 && byte_cnt_r <= 12'd9)
						optcom_bit_flag_r <= {optcom_bit_flag_r[15:0], i_optrecv_data};
					else if (byte_cnt_r >= 12'd10 && byte_cnt_r <= 12'd13)
						ddr2flash_addr_base_r <= {ddr2flash_addr_base_r[23:0], i_optrecv_data};
					else if (byte_cnt_r >= 12'd14 && byte_cnt_r <= 12'd17)
						flash_addr_offset_r <= {flash_addr_offset_r[23:0], i_optrecv_data};
				end
				`READ_DDR_CMD: begin
					if (byte_cnt_r >= 12'd7 && byte_cnt_r <= 12'd9)
						optcom_bit_flag_r <= {optcom_bit_flag_r[15:0], i_optrecv_data};
					else if (byte_cnt_r >= 12'd10 && byte_cnt_r <= 12'd13)
						ddr_rdaddr_base_r <= {ddr_rdaddr_base_r[23:0], i_optrecv_data};
				end
				`CHECK_STATE_CMD, `LOOP_SWITCH_CMD, `LOOP_DATA_CMD, `CALI_SWITCH_CMD, `CALI_DATA_CMD,
				`ONCE_SWITCH_CMD, `SAVE_PARA_FACT, `LOAD_PARA_FACT: begin
					if (byte_cnt_r >= 12'd7 && byte_cnt_r <= 12'd9)
						optcom_bit_flag_r <= {optcom_bit_flag_r[15:0], i_optrecv_data};
				end
			endcase
		end
	end	

	//----------------------------------------------------------------------------------------------
	// TX: generate data to opt_communication module sendram
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			optsend_ram_wrdata_r 	<= 8'h0;
			r_cali_txcnt			<= 16'd0;	
		end else begin
			if(state_r == TXRAM_START) begin
				if (byte_cnt_r  <= HEADER_SIZE - 1'b1)
					optsend_ram_wrdata_r <= HEADER_CODE;
				else if (byte_cnt_r == 12'd4)
					optsend_ram_wrdata_r <= {4'h0, optcom_byte_size_r[11:8]};
				else if (byte_cnt_r == 12'd5)
					optsend_ram_wrdata_r <= optcom_byte_size_r[7:0];
				else if (byte_cnt_r + 12'd2 == optcom_byte_size_r)
					optsend_ram_wrdata_r <= data_check_sum_r[15:8];
				else if (byte_cnt_r + 12'd1 == optcom_byte_size_r)
					optsend_ram_wrdata_r <= data_check_sum_r[7:0];
				else begin
					case(get_cmd_type_r)
						`WRITE_DDR_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `WRITE_DDR_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if (byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= ddr_wraddr_base_r[31:24];
							else if (byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= ddr_wraddr_base_r[23:16];
							else if (byte_cnt_r == 12'd12)
								optsend_ram_wrdata_r <= ddr_wraddr_base_r[15:8];
							else if (byte_cnt_r == 12'd13)
								optsend_ram_wrdata_r <= ddr_wraddr_base_r[7:0];
						end
						`SAVE_FLASH_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `SAVE_FLASH_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if (byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= ddr2flash_addr_base_r[31:24];
							else if (byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= ddr2flash_addr_base_r[23:16];
							else if (byte_cnt_r == 12'd12)
								optsend_ram_wrdata_r <= ddr2flash_addr_base_r[15:8];
							else if (byte_cnt_r == 12'd13)
								optsend_ram_wrdata_r <= ddr2flash_addr_base_r[7:0];
						end
						`LOAD_PARA_FACT: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `LOAD_PARA_FACT;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
						end
						`SAVE_PARA_FACT: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `SAVE_PARA_FACT;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
						end
						`READ_DDR_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `READ_DDR_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if (byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= ddr_rdaddr_base_r[31:24];
							else if (byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= ddr_rdaddr_base_r[23:16];
							else if (byte_cnt_r == 12'd12)
								optsend_ram_wrdata_r <= ddr_rdaddr_base_r[15:8];
							else if (byte_cnt_r == 12'd13)
								optsend_ram_wrdata_r <= ddr_rdaddr_base_r[7:0];
							else if (byte_cnt_r >= 12'd14 && byte_cnt_r <= 12'd1037)begin	
								if(r_write_num)
									optsend_ram_wrdata_r <= i_fifo_rddata[7:0];
								else
									optsend_ram_wrdata_r <= i_fifo_rddata[15:8];
							end
						end
						`CHECK_STATE_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `CHECK_STATE_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if (byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= i_status_code[15:8];//lidar status
							else if (byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= i_status_code[7:0];
							else if (byte_cnt_r == 12'd12)
								optsend_ram_wrdata_r <= i_device_temp[15:8];//lidar temp
							else if (byte_cnt_r == 12'd13)
								optsend_ram_wrdata_r <= i_device_temp[7:0];
							else if (byte_cnt_r == 12'd14)
								optsend_ram_wrdata_r <= i_apd_hv_value[15:8];//hv ad vaule
							else if (byte_cnt_r == 12'd15)
								optsend_ram_wrdata_r <= i_apd_hv_value[7:0];
							else if (byte_cnt_r == 12'd16)
								optsend_ram_wrdata_r <= i_apd_temp_value[15:8];//temp ad vaule
							else if (byte_cnt_r == 12'd17)
								optsend_ram_wrdata_r <= i_apd_temp_value[7:0];
							else if (byte_cnt_r == 12'd18)
								optsend_ram_wrdata_r <= i_dac_value[15:8];//hv da vaule
							else if (byte_cnt_r == 12'd19)
								optsend_ram_wrdata_r <= i_dac_value[7:0];
							else if (byte_cnt_r == 12'd20)
								optsend_ram_wrdata_r <= i_dicp_value[15:8];//dist compensation vaule
							else if (byte_cnt_r == 12'd21)
								optsend_ram_wrdata_r <= i_dicp_value[7:0];
							else if (byte_cnt_r == 12'd22)
								optsend_ram_wrdata_r <= FIRMWARE_VERSION[31:24];
							else if (byte_cnt_r == 12'd23)
								optsend_ram_wrdata_r <= FIRMWARE_VERSION[23:16];
							else if (byte_cnt_r == 12'd24)
								optsend_ram_wrdata_r <= FIRMWARE_VERSION[15:8];
							else if (byte_cnt_r == 12'd25)
								optsend_ram_wrdata_r <= FIRMWARE_VERSION[7:0];
							else if (byte_cnt_r == 12'd26)
								optsend_ram_wrdata_r <= 8'hff;
							else if (byte_cnt_r == 12'd27)
								optsend_ram_wrdata_r <= 8'hff;
							else if (byte_cnt_r >= 12'd28 && byte_cnt_r <= 12'd317)
								optsend_ram_wrdata_r <= 8'hff;
							else if (byte_cnt_r >= 12'd318 && byte_cnt_r <= 12'd677)
								optsend_ram_wrdata_r <= w_code_rddata;
							else if (byte_cnt_r >= 12'd678 && byte_cnt_r <= 12'd1037)begin
								optsend_ram_wrdata_r <= 8'h0;
							end
						end
						`LOOP_SWITCH_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `LOOP_SWITCH_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
						end
						`LOOP_DATA_CMD: begin
							if (byte_cnt_r == 12'd6)
								optsend_ram_wrdata_r <= `LOOP_DATA_CMD;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if	(byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= ~i_looppackdot_ordnum[7:0];//i_looppackdot_ordnum[15:8];
							else if	(byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= i_looppackdot_ordnum[7:0];
							else if	(byte_cnt_r == 12'd12)
								optsend_ram_wrdata_r <= w_time_ram_rddata[127:120];
							else if	(byte_cnt_r == 12'd13)
								optsend_ram_wrdata_r <= w_time_ram_rddata[119:112];
							else if	(byte_cnt_r == 12'd14)
								optsend_ram_wrdata_r <= w_time_ram_rddata[111:104];
							else if	(byte_cnt_r == 12'd15)
								optsend_ram_wrdata_r <= w_time_ram_rddata[103:96];
							else if	(byte_cnt_r == 12'd16)
								optsend_ram_wrdata_r <= w_time_ram_rddata[95:88];
							else if	(byte_cnt_r == 12'd17)
								optsend_ram_wrdata_r <= w_time_ram_rddata[87:80];
							else if	(byte_cnt_r == 12'd18)
								optsend_ram_wrdata_r <= w_time_ram_rddata[79:72];
							else if	(byte_cnt_r == 12'd19)
								optsend_ram_wrdata_r <= w_time_ram_rddata[71:64];
							else if (byte_cnt_r == 12'd20)
								optsend_ram_wrdata_r <= i_status_code[15:8];
							else if (byte_cnt_r == 12'd21)
								optsend_ram_wrdata_r <= i_status_code[7:0];
							else if (byte_cnt_r == 12'd22)
								optsend_ram_wrdata_r <= i_config_mode[15:8];
							else if (byte_cnt_r == 12'd23)
								optsend_ram_wrdata_r <= i_config_mode[7:0];
							else if (byte_cnt_r == 12'd24)
								optsend_ram_wrdata_r <= i_scan_freqence[15:8];
							else if (byte_cnt_r == 12'd25)
								optsend_ram_wrdata_r <= i_scan_freqence[7:0];
							else if (byte_cnt_r == 12'd26)
								optsend_ram_wrdata_r <= i_angle_reso[15:8];
							else if (byte_cnt_r == 12'd27)
								optsend_ram_wrdata_r <= i_angle_reso[7:0];
							else if (byte_cnt_r == 12'd28)
								optsend_ram_wrdata_r <= i_start_angle[31:24];
							else if (byte_cnt_r == 12'd29)
								optsend_ram_wrdata_r <= i_start_angle[23:16];
							else if (byte_cnt_r == 12'd30)
								optsend_ram_wrdata_r <= i_start_angle[15:8];
							else if (byte_cnt_r == 12'd31)
								optsend_ram_wrdata_r <= i_start_angle[7:0];
							else if (byte_cnt_r == 12'd32)
								optsend_ram_wrdata_r <= i_stop_angle[31:24];
							else if (byte_cnt_r == 12'd33)
								optsend_ram_wrdata_r <= i_stop_angle[23:16];
							else if (byte_cnt_r == 12'd34)
								optsend_ram_wrdata_r <= i_stop_angle[15:8];
							else if (byte_cnt_r == 12'd35)
								optsend_ram_wrdata_r <= i_stop_angle[7:0];
							else if (byte_cnt_r == 12'd36)
								optsend_ram_wrdata_r <= i_device_temp[15:8];
							else if (byte_cnt_r == 12'd37)
								optsend_ram_wrdata_r <= i_device_temp[7:0];
							else if (byte_cnt_r == 12'd38)
								optsend_ram_wrdata_r <= i_apd_hv_value[15:8];
							else if (byte_cnt_r == 12'd39)
								optsend_ram_wrdata_r <= i_apd_hv_value[7:0];
							else if (byte_cnt_r == 12'd40)
								optsend_ram_wrdata_r <= i_apd_temp_value[15:8];
							else if (byte_cnt_r == 12'd41)
								optsend_ram_wrdata_r <= i_apd_temp_value[7:0];
							else if (byte_cnt_r == 12'd42)
								optsend_ram_wrdata_r <= i_dac_value[15:8];
							else if (byte_cnt_r == 12'd43)
								optsend_ram_wrdata_r <= i_dac_value[7:0];
							else if (byte_cnt_r == 12'd44)
								optsend_ram_wrdata_r <= i_dicp_value[15:8];
							else if (byte_cnt_r == 12'd45)
								optsend_ram_wrdata_r <= i_dicp_value[7:0];
							else if (byte_cnt_r == 12'd46)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd47)
								optsend_ram_wrdata_r <= 8'h0;
							else if	(byte_cnt_r == 12'd48)
								optsend_ram_wrdata_r <= w_time_ram_rddata[63:56];
							else if	(byte_cnt_r == 12'd49)
								optsend_ram_wrdata_r <= w_time_ram_rddata[55:48];
							else if	(byte_cnt_r == 12'd50)
								optsend_ram_wrdata_r <= w_time_ram_rddata[47:40];
							else if	(byte_cnt_r == 12'd51)
								optsend_ram_wrdata_r <= w_time_ram_rddata[39:32];
							else if	(byte_cnt_r == 12'd52)
								optsend_ram_wrdata_r <= w_time_ram_rddata[31:24];
							else if	(byte_cnt_r == 12'd53)
								optsend_ram_wrdata_r <= w_time_ram_rddata[23:16];
							else if	(byte_cnt_r == 12'd54)
								optsend_ram_wrdata_r <= w_time_ram_rddata[15:8];
							else if	(byte_cnt_r == 12'd55)
								optsend_ram_wrdata_r <= w_time_ram_rddata[7:0];
							else if (byte_cnt_r >= 12'd56 && byte_cnt_r <= 12'd77)
								optsend_ram_wrdata_r <= 8'h0;	
							else if (byte_cnt_r >= 12'd78 && byte_cnt_r + 12'd3 <= optcom_byte_size_r)
								optsend_ram_wrdata_r <= i_fifo_rddata2;
						end
						`CALI_SWITCH_CMD: begin
							if (byte_cnt_r == 12'd6) begin
								optsend_ram_wrdata_r <= `CALI_SWITCH_CMD;
							end else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
						end

						`CALI_DATA_CMD: begin
							if (byte_cnt_r == 12'd6) begin
								optsend_ram_wrdata_r <= `CALI_DATA_CMD;
							end else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h0;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= {optcom_bit_flag_r[7:1], 1'b0};
							else if	(byte_cnt_r == 12'd10)
								optsend_ram_wrdata_r <= i_calipackdot_ordnum[15:8];
							else if	(byte_cnt_r == 12'd11)
								optsend_ram_wrdata_r <= i_calipackdot_ordnum[7:0];
							else if	(byte_cnt_r >= 12'd12 && byte_cnt_r + 12'd3 <= optcom_byte_size_r)
								optsend_ram_wrdata_r <= i_fifo_rddata2;
						end
						
						`ERROR: begin
							if (byte_cnt_r == 16'd6)
								optsend_ram_wrdata_r <= `ERROR;
							else if (byte_cnt_r == 12'd7)
								optsend_ram_wrdata_r <= 8'h00;
							else if (byte_cnt_r == 12'd8)
								optsend_ram_wrdata_r <= 8'h01;
							else if (byte_cnt_r == 12'd9)
								optsend_ram_wrdata_r <= 8'h00;
						end
					endcase	
				end	 
			end
		end
	end
	//----------------------------------------------------------------------------------------------
	// Cache the data that needs to be saved to sram into ram
	// calculate the ram addr of calibration data and loop data send to down
	//----------------------------------------------------------------------------------------------
	//cache_ram_wren
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			cache_ram_wren	<= 1'b0;
		else if (state_r == RXRAM_PARSEDATA && get_cmd_type_r == `WRITE_DDR_CMD && 
				 byte_cnt_r >= 12'd14 && byte_cnt_r + 12'd3 <= optcom_byte_size_r) begin
			cache_ram_wren	<= 1'b1;
		end else
			cache_ram_wren	<= 1'b0;	
	end

	//cache_ram_wraddr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			cache_ram_wraddr <= 11'd0;
		else if (state_r == RXRAM_RDADDR && get_cmd_type_r == `WRITE_DDR_CMD && 
				 byte_cnt_r >= 12'd14 && byte_cnt_r + 12'd3 <= optcom_byte_size_r) begin
			cache_ram_wraddr <= cache_ram_wraddr + 1'b1;
		end else if (state_r == IDLE)
			cache_ram_wraddr <= 11'd0;
	end


	// //r_packet_rdaddr
	// always @(posedge i_clk or negedge i_rst_n) begin
	// 	if (!i_rst_n)
	// 		r_packet_rdaddr <= 14'd0;
	// 	else if(state_r == TXRAM_WRADDR && (get_cmd_type_r == `LOOP_DATA_CMD || get_cmd_type_r == `ONCE_SWITCH_CMD) &&
	// 			byte_cnt_r >= 12'd78 && byte_cnt_r + 2'd3 <= optcom_byte_size_r) begin
	// 		r_packet_rdaddr <= r_packet_rdaddr + 1'b1;
	// 	end else if (state_r == READY)
	// 		r_packet_rdaddr <= i_packet_rdaddr_base;
	// end

	//r_fifo_rden2 ddr data
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_fifo_rden2	<= 1'b0;
		else if (state_r == TXRAM_START && (get_cmd_type_r == `LOOP_DATA_CMD)) begin
			if(byte_cnt_r >= 12'd77 && byte_cnt_r + 12'd4 <= optcom_byte_size_r)
				r_fifo_rden2 <= 1'b1;
			else
				r_fifo_rden2 <= 1'b0;
		end else if (state_r == TXRAM_START && (get_cmd_type_r == `CALI_DATA_CMD)) begin
			if(byte_cnt_r >= 12'd11 && byte_cnt_r + 12'd4 <= optcom_byte_size_r)
				r_fifo_rden2 <= 1'b1;
			else
				r_fifo_rden2 <= 1'b0;
		end else
			r_fifo_rden2 <= 1'b0;
	end

	// //r_calib_rdaddr
	// always @(posedge i_clk or negedge i_rst_n) begin
	// 	if (!i_rst_n)
	// 		r_calib_rdaddr <= 10'd0;
	// 	else if(state_r == TXRAM_WRADDR && get_cmd_type_r == `CALI_SWITCH_CMD &&
	// 			byte_cnt_r >= 12'd12 && byte_cnt_r + 12'd3 <= optcom_byte_size_r) begin
	// 		r_calib_rdaddr <= r_calib_rdaddr + 1'b1;
	// 	end else if (state_r == IDLE)
	// 		r_calib_rdaddr <= 10'd0;
	// end
	//----------------------------------------------------------------------------------------------
	// ram define
	//----------------------------------------------------------------------------------------------
	cache_dataram8x2048 u1_cache_dataram8x2048 (
  		.wr_data		( i_optrecv_data			),    // input [7:0]
  		.wr_addr		( cache_ram_wraddr			),    // input [10:0]
  		.wr_en			( cache_ram_wren			),    // input
  		.wr_clk			( i_clk						),    // input
  		.wr_rst			( 1'b0						),    // input
  		.rd_addr		( i_cache_rdaddr			),    // input [10:0]
  		.rd_data		( o_cache_rddata			),    // output [7:0]
  		.rd_clk			( i_clk						),    // input
  		.rd_rst			( 1'b0						)     // input
	);

	code_ram u5_code_ram (
  		.wr_data		( i_code_wrdata				),	// input [15:0]
  		.wr_addr		( i_code_wraddr				),	// input [7:0]
  		.wr_en			( i_code_wren				),	// input
  		.wr_clk			( i_clk						),	// input
  		.wr_rst			( 1'b0						),	// input
  		.rd_addr		( r_code_rdaddr				),	// input [8:0]
  		.rd_data		( w_code_rddata				),	// output [7:0]
  		.rd_clk			( i_clk						),	// input
  		.rd_rst			( 1'b0						) 	// input
	);
	
	time_ram128x64 u6_time_ram128x64 (
        .wr_data    	( i_time_ram_wrdata     	),    // input [127:0]
        .wr_addr    	( i_time_ram_wraddr     	),    // input [5:0]
        .wr_en      	( i_time_ram_wren & i_packet_pingpang),    // input
        .wr_clk     	( i_clk        				),    // input
        .wr_rst     	( 1'b0              		),    // input
        .rd_addr    	( i_time_ram_rdaddr     	),    // input [5:0]
        .rd_data    	( w_time_ram_rddata1     	),    // output [127:0]
        .rd_clk     	( i_clk        				),    // input
        .rd_rst     	( 1'b0              		)     // input
    );

	time_ram128x64 u7_time_ram128x64 (
        .wr_data    	( i_time_ram_wrdata     	),    // input [127:0]
        .wr_addr    	( i_time_ram_wraddr     	),    // input [5:0]
        .wr_en      	( i_time_ram_wren & ~i_packet_pingpang),    // input
        .wr_clk     	( i_clk        				),    // input
        .wr_rst     	( 1'b0              		),    // input
        .rd_addr    	( i_time_ram_rdaddr     	),    // input [5:0]
        .rd_data    	( w_time_ram_rddata2     	),    // output [127:0]
        .rd_clk     	( i_clk        				),    // input
        .rd_rst     	( 1'b0              		)     // input
    );
	assign	w_time_ram_rddata = (i_packet_pingpang)?w_time_ram_rddata2:w_time_ram_rddata1;
	//----------------------------------------------------------------------------------------------
	// assign define
	//----------------------------------------------------------------------------------------------
	assign		o_optcom_bit_flag		= optcom_bit_flag_r;
	assign		o_ddr2flash_wrsig		= ddr2flash_wrsig_r;
	assign		o_save_fact_para		= save_fact_para_r;
	assign		o_load_fact_para		= load_fact_para_r;
	assign		o_ddr2flash_addr_base	= ddr2flash_addr_base_r;
	assign		o_flash_addr_offset		= flash_addr_offset_r[23:0];

	assign		o_rddr_usercmd			= r_rddr_usercmd;
	assign		o_ddr_rden				= r_ddr_rden;
	assign		o_fifo_rden				= r_fifo_rden;
	assign		o_rdddr_addr_base		= r_rdddr_addr;

	assign		o_ddr_rden2				= r_ddr_rden2;
	assign		o_fifo_rden2			= r_fifo_rden2;
	assign		o_rdddr_addr_base2		= r_rdddr_addr2;

	assign		o_busy					= busy_r;
	assign		o_cali_addr_incr		= cali_addr_incr_r;

	assign 		o_optsend_wren			= optsend_ram_wren_r;
	assign 		o_optsend_wraddr		= optsend_ram_wraddr_r;
	assign 		o_optsend_wrdata		= optsend_ram_wrdata_r;
	assign 		o_optsend_req			= optsend_req_r;		
	assign 		o_optsend_num			= optsend_num_r;	

	assign 		o_optrecv_rden 			= 1'b1;
	assign 		o_optrecv_rdaddr		= rxram_rdaddr_r;

	assign 		o_ddr_wraddr_base		= ddr_wraddr_base_r;
	assign 		o_get_cmd_code			= get_cmd_type_r;
	assign 		o_parse_done			= parse_done_r;
	assign		o_opt_recv_ack			= opt_recv_ack_r;
endmodule 