//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udpcom_datagram_parser
// Date Created 	: 2024/10/23 
// Version 			: V1.0
//--------------------------------------------------------------------------------------------------
// File description	:udpcom_datagram_parser
//				upstream and downstream data interaction
//				1、Receive udp communication data 
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
module udpcom_datagram_parser
#(  
	parameter DEV_TYPE				= 16'h0001,
	parameter FIRMWARE_VERSION		= 32'h25041515,
    parameter DDR_DW       			= 64,
    parameter DDR_AW       			= 27
)
(
	input					    		i_clk,
	input					    		i_rst_n,

    //udp communication 		
    input					    		i_udp_rxdone,
	output					    		o_udp_rxram_rden,
	output [10:0]			    		o_udp_rxram_rdaddr,
	input  [ 7:0]			    		i_udp_rxram_data,
	input  [15:0]			    		i_udp_rxbyte_num,

	input								i_udpcom_busy,
    output 				        		o_udp_send_req,
    input  [10:0]               		i_udp_txram_rdaddr,
    output [7:0]                		o_udp_txram_rddata,
    output [15:0]			    		o_udp_txbyte_num,
	output [15:0]						o_udpsend_srcport,
	output [15:0]						o_udpsend_desport,

	output [31:0]						o_get_para0,
	output [31:0]						o_get_para1,
	output [31:0]						o_get_para2,
	output [31:0]						o_get_para3,
	output [31:0]						o_get_para4,
	output [31:0]						o_get_para5,
	output [31:0]						o_get_para6,
	output [15:0]						o_rxcheck_code,
	output								o_parse_done,
	output [15:0]						o_get_cmd_id,
	output								o_udpfifo_rden,
	input								i_udpfifo_empty,
	input  [47:0]						i_udpfifo_rdata,
	//parameter cfg
	input  [31:0]						i_serial_number,
	input  [47:0]						i_lidar_mac,
	input  [31:0]						i_lidar_ip,
	input  [15:0]						i_config_mode,
	input  [15:0]						i_motor_switch,
	input  [15:0]						i_freq_motor1,
	input  [15:0]						i_freq_motor2,
	input  [15:0]						i_angle_offset1,
	input  [15:0]						i_angle_offset2,
	input  [31:0]						i_coe_version,
	input  [15:0]						i_rise_divid,
	input  [31:0]						i_pulse_start,
	input  [31:0]						i_pulse_divid,
	input  [15:0]						i_temp_apdhv_base,
	input  [15:0]						i_temp_temp_base,
	input  [15:0]						i_hvcomp_switch,
	//ddr interface
	output								o_rddr_usercmd,
	output                              o_ddr2para_rden,
	input  [DDR_AW-1:0]                 i_ddr_addr_base,
    output [DDR_AW-1:0]                 o_para2ddr_addr,
	output								o_ddr2para_fifo_rden,
    input                              	i_ddr2para_fifo_empty,
    input  [DDR_DW-1:0]					i_ddr2para_fifo_data,
	//cache for need write to ddr
	input  [9:0]						i_cache_rdaddr,
	output [7:0]						o_cache_rddata,
	//code ram		
	input								i_code_wren1,
	input [6:0]							i_code_wraddr1,
	input [31:0]						i_code_wrdata1,
	input								i_code_wren2,
	input [6:0]							i_code_wraddr2,
	input [31:0]						i_code_wrdata2,
	//loop		
	input  [15:0]						i_loop_points,
	input  [31:0]						i_lidar_state,
	input								i_loop_pingpang,
	input								i_loop_wren,
	input  [7:0]						i_loop_wrdata,
	input  [9:0]						i_loop_wraddr,
	//cali		
	input  [15:0]						i_calib_points,
	input								i_calib_pingpang,
	input								i_calib_wren,
	input  [7:0]						i_calib_wrdata,
	input  [9:0]						i_calib_wraddr
);
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam HEAD_SIZE						= 16'd10;
    localparam USER_PASS_WORD                   = 80'h6672_6565_6F70_7469_6353;
	// localparam READ_DDR_NUM  					= 10'd16;
	localparam READ_DDR_NUM  					= 10'd128;
	// localparam READ_DDR_NUM  					= 10'd112;
	localparam FACTPARA_ACK_DATA_SIZE			= 11'd12;

	localparam	ST_DDR_IDLE   					= 8'b0000_0000,
				ST_DDR_READY					= 8'b0000_0001,
				ST_DDR_BASEADDR					= 8'b0000_0010,
				ST_DDR_RDEN						= 8'b0000_0100,
				ST_ADDR_INCR					= 8'b0000_1000,
				ST_DDR_DELAY					= 8'b0001_0000,
				ST_WAIT_DDR						= 8'b0010_0000,
				ST_DDR_RDDONE					= 8'b0100_0000;

	localparam	ST_RX_IDLE   					= 8'b0000_0000,
				ST_RX_READY						= 8'b0000_0001,
				ST_RXRAM_PARSEDATA				= 8'b0000_0010,
				ST_RXRAM_RDADDR					= 8'b0000_0100,
				ST_RXRAM_RDDATA					= 8'b0000_1000,
				ST_RXRAM_RDDONE					= 8'b0001_0000;

	localparam	ST_TX_IDLE   					= 12'b0000_0000_0000,
				ST_TX_READY						= 12'b0000_0000_0001,
				ST_RDFIFO_BEAT					= 12'b0000_0000_0010,
				ST_RDFIFO						= 12'b0000_0000_0100,
				ST_WAIT_SEND					= 12'b0000_0000_1000,
				ST_TXRAM_START					= 12'b0000_0001_0000,
				ST_TXRAM_WRADDR					= 12'b0000_0010_0000,
				ST_TXRAM_DATA					= 12'b0000_0100_0000,
				ST_WAIT_FIFO					= 12'b0000_1000_0000,
				ST_TXRAM_DONE					= 12'b0001_0000_0000,
				ST_WAIT_UDPCOM					= 12'b0010_0000_0000;
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg  [7:0]				r_rddr_state			= ST_DDR_IDLE;
	reg 					r_rddr_usercmd			= 1'b0;
	reg  [3:0]				r_rddr_reg				= 4'h0;
	reg						r_rddr_flag				= 1'b0;
	reg  [15:0]				r_ddr_rdcnt				= 8'd0;
	reg  [31:0]				r_waitddr_delay			= 32'd0;
	reg  [3:0]				r_shift_num				= 4'd0;
	//udp logic
	reg  [15:0]				r_lidar_port			= 16'd55000;
    //UDP RX RAM
    reg  [7:0]         		r_rx_state              = ST_RX_IDLE;
	reg  [11:0]         	r_tx_state              = ST_TX_IDLE;
    reg                 	r_parse_start           = 1'b0;
	reg						r_cmd_ack				= 1'b0;
	reg  [7:0]				r_cmd_type				= `CMD;
    reg  [15:0]         	r_udpcom_byte_size      = 16'd0;
    reg  [10:0]         	r_udp_rxram_rdaddr      = 11'd0;
    reg  [10:0]         	r_byte_rxcnt            = 11'd0;
	reg  [10:0]         	r_byte_txcnt            = 11'd0;
    reg                 	r_parse_done            = 1'b0;
    reg  [3:0]          	r_ack_reg               = 4'h0;
    wire                	w_ack_flag;

	reg						r_udpfifo_rden			= 1'b0;
	reg	 [15:0]				r_get_cmd_id 			= 16'h0;
	reg  [15:0]				r_set_cmd_id			= 16'h0;
	reg	 [31:0]				r_get_para0 			= 32'h0;
	reg	 [31:0]				r_get_para1 			= 32'h0;
	reg	 [31:0]				r_get_para2 			= 32'h0;
	reg	 [31:0]				r_get_para3 			= 32'h0;
	reg	 [31:0]				r_get_para4 			= 32'h0;
	reg	 [31:0]				r_get_para5 			= 32'h0;
	reg	 [31:0]				r_get_para6 			= 32'h0;
	reg  [15:0]				r_coe_sernum			= 16'd0;
	// DDR interface
	reg                 	r_ddr2para_rden			= 1'b0;
    reg  [DDR_AW-1:0]   	r_para2ddr_addr			= {DDR_AW{1'b0}};
	reg						r_ddr2para_fifo_rden	= 1'b0;
	// cache data
	reg 					r_cacheram_wren			= 1'b0;
	reg  [9:0]				r_cacheram_wraddr		= 10'd0;
	
	reg  [15:0]				r_seq_num				= 16'h0;
	reg  [15:0]				r_recsum_header			= 16'h0;
	reg  [15:0]				r_recsum_data			= 16'h0;
	reg  [15:0]				r_header_rxcheck		= 16'h0;
	reg  [15:0]				r_data_rxcheck			= 16'h0;
	reg  [15:0]				r_header_txcheck		= 16'h0;
	reg  [15:0]				r_data_txcheck			= 16'h0;
	reg  [15:0]				r_rxcheck_code			= 16'h0000;
	reg  [15:0]				r_ret_code				= 16'h0000;
	reg  [15:0]				r_udpsend_srcport		= 16'd55000;
	reg  [15:0]				r_udpsend_desport		= 16'd65000;
	//UDP TX RAM
    reg                 	r_udp_send_req          = 1'b0;
    reg                 	r_udp_sendram_flag      = 1'b0;
    reg                 	r_udp_txram_wren        = 1'b0;
    reg  [7:0]          	r_udp_txram_wrdata      = 8'h0;
    reg  [10:0]         	r_udp_txram_wraddr      = 11'd0;

	reg  [8:0]				r_code_rdaddr1 			= 9'd0;
	wire [7:0]				w_code_rddata1;
	reg  [8:0]				r_code_rdaddr2 			= 9'd0;
	wire [7:0]				w_code_rddata2;
	//loop ram	
	reg	[9:0]				r_loop_rdaddr 			= 10'd0;
	wire[7:0]				w_loop_rddata;
	wire[7:0]				w_loop_rddata1;
	wire[7:0]				w_loop_rddata2;
	//cali ram			
	reg	[9:0]				r_calib_rdaddr 			= 10'd0;
	wire[7:0]				w_calib_rddata;
	wire[7:0]				w_calib_rddata1;
	wire[7:0]				w_calib_rddata2;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_ack_reg 	<= 4'h0;
		end else begin
			r_ack_reg 	<= {r_ack_reg[2:0], r_cmd_ack};
		end
	end
    assign w_ack_flag 	= r_ack_reg[2] && (~r_ack_reg[3]);//rising

    //r_udp_sendram_flag define
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_udp_sendram_flag 	<= 1'b0;
		else if(r_set_cmd_id == `GET_COE)
			r_udp_sendram_flag	<= r_rddr_flag;
		else if(r_tx_state == ST_WAIT_SEND && w_ack_flag )
			r_udp_sendram_flag 	<= 1'b1;
		else
			r_udp_sendram_flag 	<= 1'b0;
	end

	//r_get_cmd_id
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_get_cmd_id <= `ERROR;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt >= 16'd6 &&  r_byte_rxcnt <= 16'd7))
			r_get_cmd_id <= {r_get_cmd_id[7:0], i_udp_rxram_data};
	end

	//r_seq_num
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_seq_num <= 16'h0;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt >= 16'd8 &&  r_byte_rxcnt <= 16'd9))
			r_seq_num <= {r_seq_num[7:0], i_udp_rxram_data};
	end

	//r_recsum_header
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_recsum_header <= 16'h0000;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt >= 16'd10 &&  r_byte_rxcnt <= 16'd11))
			r_recsum_header <= {r_recsum_header[7:0], i_udp_rxram_data};
	end

	//r_recsum_data
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_recsum_data <= 16'h0000;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt + 2'd2 >= r_udpcom_byte_size &&  r_byte_rxcnt + 2'd1 <= r_udpcom_byte_size))
			r_recsum_data <= {r_recsum_data[7:0], i_udp_rxram_data};
	end
	
    //r_parse_start, r_udpcom_byte_size
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_parse_start 		<= 1'b0;
			r_udpcom_byte_size 	<= 16'd0;
		end else if (r_rx_state == ST_RX_READY && i_udp_rxdone) begin
			r_parse_start		<= 1'b1;
			r_udpcom_byte_size 	<= i_udp_rxbyte_num;
		end else if (r_tx_state == ST_WAIT_SEND && r_cmd_ack == 1'b1) begin
			if((r_ret_code != 16'h0000) || (r_set_cmd_id[11:8] == 4'h1)) begin
				if(r_set_cmd_id == `UDP_BROADCAST)
					r_udpcom_byte_size <= HEAD_SIZE + 16'd22;
				else
					r_udpcom_byte_size <= HEAD_SIZE + 16'd6;
			end else begin
				case(r_set_cmd_id)
					`GET_MOTOR_SWITCH: begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd8;
					end
					`GET_INFO_IP, `GET_INFO_FIRMWARE, `GET_MOTOR_FREQ: begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd10;
					end
					`GET_INFO_MAC, `GET_HVCOMP_PARA:begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd12;
					end
					`GET_COE_PARA: begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd18;
					end
					`ONCE_DATA, `LOOP_DATA_SWITCH: begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd808;
					end
					`CALI_DATA: begin
						r_udpcom_byte_size <= {i_calib_points[12:0],3'b000};
					end
					`GET_COE, `GET_RSSI_COE: begin
						r_udpcom_byte_size <= HEAD_SIZE + 16'd2 + READ_DDR_NUM*8;
					end
					`GET_CODE1, `GET_CODE2: begin
						r_udpcom_byte_size <= 16'd400;
					end
					`GET_HVCP_DATA, `GET_DICP_DATA:begin
						r_udpcom_byte_size <= 16'd191;
					end
					default: r_udpcom_byte_size <= 16'd0;
				endcase
			end
		end else
			r_parse_start 		<= 1'b0;
	end
	//----------------------------------------------------------------------------------------------
	// communication state machine
	// read data from ddr according to read cmd
	//----------------------------------------------------------------------------------------------
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_rddr_state	<= ST_DDR_IDLE;
			r_ddr2para_rden <= 1'b0;
			r_rddr_flag		<= 1'b0;
			r_ddr_rdcnt		<= 16'd0;
		end else begin
			case(r_rddr_state)
				ST_DDR_IDLE: begin
					r_rddr_state	<= ST_DDR_READY;
					r_ddr_rdcnt		<= 16'd0;
					r_rddr_flag		<= 1'b0;
					r_ddr2para_rden <= 1'b0;
				end
				ST_DDR_READY: begin
					r_ddr2para_rden <= 1'b0;
					if(r_cmd_ack && (r_set_cmd_id == `GET_COE)) begin
						r_rddr_state	<= ST_DDR_BASEADDR;
					end else begin
						r_rddr_state	<= ST_DDR_READY;
					end
				end
				ST_DDR_BASEADDR: r_rddr_state	<= ST_DDR_RDEN;
				ST_DDR_RDEN: begin
					r_ddr2para_rden <= 1'b1;
					if(r_ddr_rdcnt + 1'b1 >= READ_DDR_NUM)
						r_rddr_state	<= ST_WAIT_DDR;
					else
						r_rddr_state	<= ST_ADDR_INCR;
				end	
				ST_ADDR_INCR: begin
					r_ddr2para_rden <= 1'b0;
					r_rddr_state	<= ST_DDR_DELAY;
					r_ddr_rdcnt		<= r_ddr_rdcnt + 1'b1;
				end
				ST_DDR_DELAY: r_rddr_state	<= ST_DDR_RDEN;
				ST_WAIT_DDR: begin
					if(~i_ddr2para_fifo_empty) begin
						r_rddr_flag		<= 1'b1;
						r_rddr_state	<= ST_DDR_RDDONE;
					end else begin
						r_rddr_flag		<= 1'b0;
						r_rddr_state	<= ST_WAIT_DDR;
					end
				end
				ST_DDR_RDDONE: begin
					r_ddr2para_rden <= 1'b0;
					r_rddr_flag		<= 1'b0;
					r_rddr_state	<= ST_DDR_IDLE;
				end
				default : r_rddr_state <= ST_DDR_IDLE;
			endcase
		end
	end

	//r_para2ddr_addr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_para2ddr_addr <= {DDR_AW{1'b0}};
		else if(r_rddr_state == ST_DDR_IDLE)
			r_para2ddr_addr <= {DDR_AW{1'b0}};
		else if(r_rddr_state == ST_DDR_BASEADDR)
			r_para2ddr_addr <= i_ddr_addr_base;
		else if(r_rddr_state == ST_ADDR_INCR)
			r_para2ddr_addr <= r_para2ddr_addr + 4'd4;
	end
    //----------------------------------------------------------------------------------------------
	// communication state machine
	// send data to ram, ready to opt send
	//----------------------------------------------------------------------------------------------
	// RX state machine
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_rx_state 			<= ST_RX_IDLE;
			r_parse_done 		<= 1'b0;
			r_udp_rxram_rdaddr  <= 11'd0;
			r_byte_rxcnt		<= 11'd0;
		end else begin
			case(r_rx_state)
				ST_RX_IDLE: begin
					r_rx_state 			<= ST_RX_READY;
					r_parse_done 		<= 1'b0;
					r_udp_rxram_rdaddr  <= 11'd0;
					r_byte_rxcnt		<= 11'd0;
				end
				ST_RX_READY: begin
					if (r_parse_start)
						r_rx_state <= ST_RXRAM_PARSEDATA;
					else
						r_rx_state <= ST_RX_READY;
				end
				ST_RXRAM_PARSEDATA: begin
					if (r_byte_rxcnt >= r_udpcom_byte_size - 1'b1)
						r_rx_state <= ST_RXRAM_RDDONE;
					else
						r_rx_state <= ST_RXRAM_RDADDR;
				end
				ST_RXRAM_RDADDR: begin  
					r_rx_state             <= ST_RXRAM_RDDATA;
					r_udp_rxram_rdaddr  <= r_udp_rxram_rdaddr + 1'b1;
				end				
				ST_RXRAM_RDDATA: begin
					r_rx_state			<= ST_RXRAM_PARSEDATA;
					r_byte_rxcnt	<= r_byte_rxcnt + 1'b1;
				end
				ST_RXRAM_RDDONE: begin
                    r_parse_done	<= 1'b1;
					r_rx_state 		<= ST_RX_IDLE;
				end
				default : r_rx_state <= ST_RX_IDLE;
			endcase
		end
	end

	// TX state machine
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_tx_state		<= ST_TX_IDLE;
			r_udpfifo_rden	<= 1'b0;
			r_set_cmd_id	<= 16'h0;
			r_ret_code		<= 16'h0;
			r_udpsend_srcport	<= 16'd55000;
			r_cmd_ack		<= 1'b0;
			r_byte_txcnt	<= 11'd0;
            r_udp_send_req	<= 1'b0;
			r_waitddr_delay	<= 32'd0;
		end else begin
			r_cmd_ack	<= 1'b0;
			case(r_tx_state)
				ST_TX_IDLE: begin
					r_udpfifo_rden	<= 1'b0;
					r_byte_txcnt	<= 11'd0;
                    r_udp_send_req  <= 1'b0;
					r_waitddr_delay	<= 32'd0;
					if(~i_udpcom_busy)
						r_tx_state	<= ST_TX_READY;
					else
						r_tx_state	<= ST_TX_IDLE;
				end
				ST_TX_READY: begin
					if(i_udpfifo_empty) begin
						r_udpfifo_rden	<= 1'b0;
						r_tx_state		<= ST_TX_READY;
					end else begin
						r_udpfifo_rden	<= 1'b1;
						r_tx_state		<= ST_RDFIFO_BEAT;
					end
				end
				ST_RDFIFO_BEAT: begin
					r_udpfifo_rden	<= 1'b0;
					r_tx_state		<= ST_RDFIFO;
				end
				ST_RDFIFO: begin
					r_set_cmd_id	  <= i_udpfifo_rdata[15:0];
					r_ret_code		  <= i_udpfifo_rdata[31:16];
					r_udpsend_srcport <= i_udpfifo_rdata[47:32];
					r_cmd_ack		  <= 1'b1;
					r_tx_state		  <= ST_WAIT_SEND;
				end
				ST_WAIT_SEND: begin
					if(r_udp_sendram_flag)
						r_tx_state	<= ST_TXRAM_START;
					else
						r_tx_state <= ST_WAIT_SEND;
				end
				ST_TXRAM_START: begin
					r_waitddr_delay	<= 32'd0;
					if (r_byte_txcnt >= r_udpcom_byte_size - 1'b1)
						r_tx_state <= ST_TXRAM_DONE;
					else
						r_tx_state <= ST_TXRAM_WRADDR;	
				end
				ST_TXRAM_WRADDR: begin
					r_tx_state	<= ST_TXRAM_DATA;
				end
				ST_TXRAM_DATA: begin
					r_byte_txcnt  <= r_byte_txcnt + 1'b1;
					if(r_set_cmd_id == `GET_COE && (r_byte_txcnt + 11'd9 < r_udpcom_byte_size))
						r_tx_state	<= ST_WAIT_FIFO;
					else
						r_tx_state	<= ST_TXRAM_START;
				end
				ST_WAIT_FIFO: begin
					if(i_ddr2para_fifo_empty) begin
						r_waitddr_delay	<= r_waitddr_delay + 1'b1;
						if(r_waitddr_delay >= 32'd10_000_000)
							r_tx_state	<= ST_TXRAM_START;
						else
							r_tx_state	<= ST_WAIT_FIFO;
					end else
						r_tx_state	<= ST_TXRAM_START;
				end
				ST_TXRAM_DONE: begin
					r_tx_state 		<= ST_WAIT_UDPCOM;
					r_byte_txcnt	<= 11'd0;
                    r_udp_send_req  <= 1'b1;
				end
				ST_WAIT_UDPCOM: begin
					if(i_udpcom_busy)
						r_tx_state <= ST_TX_IDLE;
					else
						r_tx_state <= ST_WAIT_UDPCOM;
				end
				default : r_tx_state <= ST_TX_IDLE;
			endcase
		end
	end

	//r_udpsend_desport
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_udpsend_desport	<= 16'd65000;
		else if(r_udpsend_srcport == 16'd55500)
			r_udpsend_desport	<= 16'd64000;
		else
			r_udpsend_desport	<= 16'd65000;
	end

	//r_cmd_type
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_cmd_type	<= `CMD;
		else if(r_udpsend_srcport == 16'd55000 || r_udpsend_srcport == 16'd55300)
			r_cmd_type	<= `MSG;
		else
			r_cmd_type	<= `ACK;
	end
    //----------------------------------------------------------------------------------------------
	// RX: receive data from user
	//----------------------------------------------------------------------------------------------
	//Analyze the received data and output it to the corresponding interface
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_get_para0 	<= 32'h0;
			r_get_para1 	<= 32'h0;
			r_get_para2 	<= 32'h0;
			r_get_para3 	<= 32'h0;
			r_get_para4 	<= 32'h0;
			r_get_para5 	<= 32'h0;
			r_get_para6 	<= 32'h0;
			r_coe_sernum	<= 16'd0;
		end else if (r_byte_rxcnt >= 16'd12 && r_rx_state == ST_RXRAM_PARSEDATA) begin
			case(r_get_cmd_id)
				`SET_LASER_SERNUM, `LOOP_DATA_SWITCH: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0	<= {24'h0, i_udp_rxram_data};
				end
				`SET_MOTOR_SWITCH, `CALI_DATA: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0[31:8]	<= {16'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd13)
						r_get_para0[7:0] <= i_udp_rxram_data;
				end
				`LINK_REQ: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0[15:8] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd13)
						r_get_para0[7:0] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd14)
						r_get_para1[31:24] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd15)
						r_get_para1[23:16] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd16)
						r_get_para1[15:8] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd17)
						r_get_para1[7:0] <= i_udp_rxram_data;
				end
				`SET_INFO_IP, `SET_INFO_DEVNAME, `SET_INFO_SN, `SET_MOTOR_FREQ, `SET_MOTOR_PWM, `SET_ANGLE_OFFSET: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0[31:24] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd13)
						r_get_para0[23:16] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd14)
						r_get_para0[15:8] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd15)
						r_get_para0[7:0] <= i_udp_rxram_data;
				end
				`SET_INFO_MAC: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0 <= {24'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd13)
						r_get_para1 <= {24'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd14)
						r_get_para2 <= {24'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd15)
						r_get_para3 <= {24'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd16)
						r_get_para4 <= {24'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd17)
						r_get_para5 <= {24'h0, i_udp_rxram_data};
				end
				`SET_HVCOMP_PARA: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0[31:8] <= {16'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd13)
						r_get_para0[7:0] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd14)
						r_get_para1[31:8] <= {16'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd15)
						r_get_para1[7:0] <= i_udp_rxram_data;
					else if (r_byte_rxcnt == 16'd16)
						r_get_para2[31:8] <= {16'h0, i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd17)
						r_get_para2[7:0] <= i_udp_rxram_data;
				end
				`SET_ANGLE, `SET_DIST_LMT: begin
					if (r_byte_rxcnt >= 16'd12 && r_byte_rxcnt < 16'd16)
						r_get_para0 <= {r_get_para0[23:0], i_udp_rxram_data};
					else if (r_byte_rxcnt >= 16'd12 && r_byte_rxcnt < 16'd16)
						r_get_para1 <= {r_get_para1[23:0], i_udp_rxram_data};
				end
				`SET_COE_PARA: begin
					if (r_byte_rxcnt >= 16'd12 && r_byte_rxcnt < 16'd16)
						r_get_para0 <= {r_get_para0[23:0], i_udp_rxram_data};
					else if (r_byte_rxcnt >= 16'd16 && r_byte_rxcnt < 16'd20)
						r_get_para1 <= {r_get_para1[23:0], i_udp_rxram_data};
					else if (r_byte_rxcnt >= 16'd20 && r_byte_rxcnt < 16'd24)
						r_get_para2 <= {r_get_para2[23:0], i_udp_rxram_data};
					else if (r_byte_rxcnt >= 16'd24 && r_byte_rxcnt < 16'd28)
						r_get_para3 <= {r_get_para3[23:0], i_udp_rxram_data};
					end
				`SET_COE, `SET_CODE, `SET_RSSI_COE: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0[31:8] <= {16'd0,i_udp_rxram_data};
					else if (r_byte_rxcnt == 16'd13)
						r_get_para0[7:0]<= i_udp_rxram_data;
				end
				`GET_COE, `GET_RSSI_COE: begin
					if (r_byte_rxcnt == 16'd12) begin
						r_coe_sernum[15:8]	<= i_udp_rxram_data;
						r_get_para0[31:8] <= {16'd0,i_udp_rxram_data};
					end else if (r_byte_rxcnt == 16'd13) begin
						r_coe_sernum[7:0]	<= i_udp_rxram_data;
						r_get_para0[7:0]<= i_udp_rxram_data;
					end
				end
				`SAVE_CODE: begin
					if (r_byte_rxcnt == 16'd12)
						r_get_para0 <= {24'h0, i_udp_rxram_data};
				end
			endcase
		end
	end
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_cacheram_wren	<= 1'b0;
		else if(r_rx_state == ST_RXRAM_PARSEDATA && (o_get_cmd_id == `SET_COE || o_get_cmd_id == `SET_RSSI_COE || o_get_cmd_id == `SET_CODE || o_get_cmd_id == `SET_HVCP_DATA || o_get_cmd_id == `SET_DICP_DATA)) begin
			if(r_byte_rxcnt >= 16'd10 && r_byte_rxcnt + 2'd2 <= r_udpcom_byte_size)
				r_cacheram_wren <= 1'b1;
		end else
			r_cacheram_wren <= 1'b0;	
	end
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_cacheram_wraddr <= 10'd0;
		else if(r_rx_state == ST_RXRAM_RDADDR && (o_get_cmd_id == `SET_COE || o_get_cmd_id == `SET_RSSI_COE || o_get_cmd_id == `SET_CODE || o_get_cmd_id == `SET_HVCP_DATA || o_get_cmd_id == `SET_DICP_DATA)) begin
			if(r_byte_rxcnt >= 16'd10 && r_byte_rxcnt + 2'd2 <= r_udpcom_byte_size)
				r_cacheram_wraddr <= r_cacheram_wraddr + 1'b1;
		end else if(r_rx_state == ST_RX_IDLE)
			r_cacheram_wraddr <= 10'd0;
	end
    //----------------------------------------------------------------------------------------------
	// TX: generate data to opt_communication module sendram
	//----------------------------------------------------------------------------------------------
	//r_rddr_usercmd
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_rddr_usercmd <= 1'b0;
		else if(r_tx_state	== ST_TX_IDLE)
			r_rddr_usercmd <= 1'b0;
		else if (r_cmd_ack && (r_set_cmd_id == `GET_COE))
			r_rddr_usercmd <= 1'b1;
		else if (r_tx_state == ST_TXRAM_DONE)
			r_rddr_usercmd <= 1'b0;
		else
			r_rddr_usercmd <= r_rddr_usercmd;
	end

	//r_shift_num
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_shift_num	<= 4'd0;
		else if(r_tx_state == ST_TX_IDLE)
			r_shift_num	<= 4'd0;
		else if(r_tx_state == ST_TXRAM_DATA && r_byte_txcnt >= 12'd10) begin
			if(r_shift_num == 4'd7)
				r_shift_num	<= 4'd0;
			else
				r_shift_num	<= r_shift_num + 1'b1;
		end
	end

	//r_ddr2para_fifo_rden
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_ddr2para_fifo_rden	<= 1'b0;
		else if(r_rddr_flag && (r_set_cmd_id == `GET_COE))
			r_ddr2para_fifo_rden	<= 1'b1;
		else if (r_tx_state == ST_TXRAM_START && (r_set_cmd_id == `GET_COE)) begin
			if(r_byte_txcnt >= 12'd10 && r_shift_num == 4'd7)
				r_ddr2para_fifo_rden	<= 1'b1;
			else
				r_ddr2para_fifo_rden	<= 1'b0;
		end else
			r_ddr2para_fifo_rden	<= 1'b0;
	end

	//r_code_rdaddr1
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_code_rdaddr1 <= 9'd0;
		else if(r_tx_state == ST_TX_IDLE)
			r_code_rdaddr1 <= 9'd0;
		else if(r_tx_state == ST_TXRAM_WRADDR && r_set_cmd_id == `GET_CODE1)
			r_code_rdaddr1 <= r_code_rdaddr1 + 1'b1;
	end

	//r_code_rdaddr2
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_code_rdaddr2 <= 9'd0;
		else if(r_tx_state == ST_TX_IDLE)
			r_code_rdaddr2 <= 9'd0;
		else if(r_tx_state == ST_TXRAM_WRADDR && r_set_cmd_id == `GET_CODE2)
			r_code_rdaddr2 <= r_code_rdaddr2 + 1'b1;
	end

	//r_loop_rdaddr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_loop_rdaddr <= 10'd0;
		else if(r_tx_state == ST_TX_IDLE)
			r_loop_rdaddr <= 10'd0;
		else if(r_tx_state == ST_TXRAM_WRADDR && (r_set_cmd_id == `LOOP_DATA_SWITCH)) begin
			if(r_byte_txcnt >= 10'd16 && r_byte_txcnt + 4'd3 <= r_udpcom_byte_size)
				r_loop_rdaddr <= r_loop_rdaddr + 1'b1;
		end else if(r_tx_state == ST_TXRAM_WRADDR && (r_set_cmd_id == `ONCE_DATA))
			r_loop_rdaddr <= r_loop_rdaddr + 1'b1;
	end

	//r_calib_rdaddr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_calib_rdaddr <= 10'd0;
		else if(r_tx_state == ST_TX_IDLE)
			r_calib_rdaddr <= 10'd0;
		else if(r_tx_state == ST_TXRAM_WRADDR && r_set_cmd_id == `CALI_DATA)
			r_calib_rdaddr <= r_calib_rdaddr + 1'b1;
	end

	//r_header_rxcheck
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_header_rxcheck <= 16'h0;
		else if (r_rx_state == ST_RX_IDLE)
			r_header_rxcheck <= 16'h0;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt < HEAD_SIZE))
			r_header_rxcheck <= r_header_rxcheck + i_udp_rxram_data;
	end

	//r_data_rxcheck
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_data_rxcheck <= 16'h0;
		else if (r_rx_state == ST_RX_IDLE)
			r_data_rxcheck <= 16'h0;
		else if (r_rx_state == ST_RXRAM_PARSEDATA && (r_byte_rxcnt >= 8'd12 && r_byte_rxcnt + 2'd2 < r_udpcom_byte_size))
			r_data_rxcheck <= r_data_rxcheck + i_udp_rxram_data;
	end

	//r_header_txcheck
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_header_txcheck <= 16'h0;
		else if (r_tx_state == ST_TX_IDLE)
			r_header_txcheck <= 16'h0;
		else if (r_tx_state == ST_TXRAM_DATA && r_byte_txcnt < HEAD_SIZE)
			r_header_txcheck <= r_header_txcheck + r_udp_txram_wrdata;
	end

	//r_data_txcheck
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_data_txcheck <= 16'h0;
		else if (r_tx_state == ST_TX_IDLE)
			r_data_txcheck <= 16'h0;
		else if (r_tx_state == ST_TXRAM_DATA && (r_byte_txcnt >= 8'd12 && r_byte_txcnt + 2'd2 < r_udpcom_byte_size))
			r_data_txcheck <= r_data_txcheck + r_udp_txram_wrdata;
	end

	//r_rxcheck_code
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_rxcheck_code	<= 16'h0000;
		else if(r_rx_state == ST_RXRAM_RDDONE) begin
			if(r_header_rxcheck != r_recsum_header)
				r_rxcheck_code	<= 16'h0102;
			else if(r_data_rxcheck != r_recsum_data)
				r_rxcheck_code	<= 16'h0103;
			else
				r_rxcheck_code	<= 16'h0000;
		end
	end

	//r_udp_txram_wren
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_udp_txram_wren <= 1'b0;
		else if (r_tx_state == ST_TXRAM_START)
			r_udp_txram_wren <= 1'b1;
		 else 
			r_udp_txram_wren <= 1'b0;
	end

    //r_udp_txram_wraddr
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) 
			r_udp_txram_wraddr <= 11'd0;
		else if(r_tx_state == ST_TXRAM_WRADDR)
			r_udp_txram_wraddr <= r_udp_txram_wraddr + 1'b1;
		else if(r_tx_state == ST_TX_IDLE)
			r_udp_txram_wraddr <= 11'd0;
	end

	//When make data, output data to ram
	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_udp_txram_wrdata <= 8'h0;
		else if(r_set_cmd_id == `LOOP_DATA_SWITCH && r_ret_code == 16'h0000) begin
			if (r_tx_state == ST_TXRAM_START) begin
				if (r_byte_txcnt <= 16'd1)
					r_udp_txram_wrdata <= 8'h04;
				else if (r_byte_txcnt == 16'd2)
					r_udp_txram_wrdata <= 8'h02;
				else if (r_byte_txcnt == 16'd3)
					r_udp_txram_wrdata <= 8'h01;
				else if (r_byte_txcnt == 16'd4)
					r_udp_txram_wrdata <= i_loop_points[15:8];
				else if (r_byte_txcnt == 16'd5)
					r_udp_txram_wrdata <= i_loop_points[7:0];
				else if (r_byte_txcnt == 16'd6)
					r_udp_txram_wrdata <= 8'h00;
				else if (r_byte_txcnt == 16'd7)
					r_udp_txram_wrdata <= 8'h00;
				else if (r_byte_txcnt == 16'd8)
					r_udp_txram_wrdata <= r_udpcom_byte_size[15:8];
				else if (r_byte_txcnt == 16'd9)
					r_udp_txram_wrdata <= r_udpcom_byte_size[7:0];
				else if (r_byte_txcnt == 16'd10)
					r_udp_txram_wrdata <= r_header_txcheck[15:8];
				else if (r_byte_txcnt == 16'd11)
					r_udp_txram_wrdata <= r_header_txcheck[7:0];
				else if (r_byte_txcnt == 16'd12)
					r_udp_txram_wrdata <= i_lidar_state[31:24];
				else if (r_byte_txcnt == 16'd13)
					r_udp_txram_wrdata <= i_lidar_state[23:16];
				else if (r_byte_txcnt == 16'd14)
					r_udp_txram_wrdata <= i_lidar_state[15:8];
				else if (r_byte_txcnt == 16'd15)
					r_udp_txram_wrdata <= i_lidar_state[7:0];
				else if (r_byte_txcnt + 2'd2 == r_udpcom_byte_size)
					r_udp_txram_wrdata <= r_data_txcheck[15:8];
				else if (r_byte_txcnt + 2'd1 == r_udpcom_byte_size)
					r_udp_txram_wrdata <= r_data_txcheck[7:0];
				else if(r_byte_txcnt >= 16'd16 && r_byte_txcnt + 4'd3 <= r_udpcom_byte_size)
					r_udp_txram_wrdata <= w_loop_rddata;
			end
		end else if((r_set_cmd_id[15:12] == 4'h0) || r_ret_code != 16'h0000)begin
			if (r_tx_state == ST_TXRAM_START) begin
				if (r_byte_txcnt <= 16'd1)
					r_udp_txram_wrdata <= 8'h03;
				else if (r_byte_txcnt == 16'd2)
					r_udp_txram_wrdata <= 8'h00;
				else if (r_byte_txcnt == 16'd3)
					r_udp_txram_wrdata <= r_udpcom_byte_size[15:8];
				else if (r_byte_txcnt == 16'd4)
					r_udp_txram_wrdata <= r_udpcom_byte_size[7:0];
				else if (r_byte_txcnt == 16'd5)
					r_udp_txram_wrdata <= r_cmd_type;
				else if (r_byte_txcnt == 16'd6)
					r_udp_txram_wrdata <= r_set_cmd_id[15:8];
				else if (r_byte_txcnt == 16'd7)
					r_udp_txram_wrdata <= r_set_cmd_id[7:0];
				else if (r_byte_txcnt == 16'd8)
					r_udp_txram_wrdata <= r_seq_num[15:8];
				else if (r_byte_txcnt == 16'd9)
					r_udp_txram_wrdata <= r_seq_num[7:0];
				else if (r_byte_txcnt == 16'd10)
					r_udp_txram_wrdata <= r_header_txcheck[15:8];
				else if (r_byte_txcnt == 16'd11)
					r_udp_txram_wrdata <= r_header_txcheck[7:0];
				else if(r_byte_txcnt == 16'd12)
					r_udp_txram_wrdata <= r_ret_code[15:8];
				else if(r_byte_txcnt == 16'd13)
					r_udp_txram_wrdata <= r_ret_code[7:0];
				else if (r_byte_txcnt + 2'd2 == r_udpcom_byte_size)
					r_udp_txram_wrdata <= r_data_txcheck[15:8];
				else if (r_byte_txcnt + 2'd1 == r_udpcom_byte_size)
					r_udp_txram_wrdata <= r_data_txcheck[7:0];
				else begin
					case(r_set_cmd_id)
						`UDP_BROADCAST: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= DEV_TYPE[15:8];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= DEV_TYPE[7:0];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_serial_number[31:24];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_serial_number[23:16];
							else if (r_byte_txcnt == 16'd18)
								r_udp_txram_wrdata <= i_serial_number[15:8];
							else if (r_byte_txcnt == 16'd19)
								r_udp_txram_wrdata <= i_serial_number[7:0];
							else if (r_byte_txcnt == 16'd20)
								r_udp_txram_wrdata <= i_lidar_ip[31:24];
							else if (r_byte_txcnt == 16'd21)
								r_udp_txram_wrdata <= i_lidar_ip[23:16];
							else if (r_byte_txcnt == 16'd22)
								r_udp_txram_wrdata <= i_lidar_ip[15:8];
							else if (r_byte_txcnt == 16'd23)
								r_udp_txram_wrdata <= i_lidar_ip[7:0];
							else if (r_byte_txcnt == 16'd24)
								r_udp_txram_wrdata <= i_lidar_mac[47:40];
							else if (r_byte_txcnt == 16'd25)
								r_udp_txram_wrdata <= i_lidar_mac[39:32];
							else if (r_byte_txcnt == 16'd26)
								r_udp_txram_wrdata <= i_lidar_mac[31:24];
							else if (r_byte_txcnt == 16'd27)
								r_udp_txram_wrdata <= i_lidar_mac[23:16];
							else if (r_byte_txcnt == 16'd28)
								r_udp_txram_wrdata <= i_lidar_mac[15:8];
							else if (r_byte_txcnt == 16'd29)
								r_udp_txram_wrdata <= i_lidar_mac[7:0];
						end
						`GET_INFO_IP: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_lidar_ip[31:24];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_lidar_ip[23:16];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_lidar_ip[15:8];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_lidar_ip[7:0];
						end
						`GET_INFO_MAC: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_lidar_mac[47:40];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_lidar_mac[39:32];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_lidar_mac[31:24];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_lidar_mac[23:16];
							else if (r_byte_txcnt == 16'd18)
								r_udp_txram_wrdata <= i_lidar_mac[15:8];
							else if (r_byte_txcnt == 16'd19)
								r_udp_txram_wrdata <= i_lidar_mac[7:0];
						end
						`GET_INFO_FIRMWARE: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= FIRMWARE_VERSION[31:24];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= FIRMWARE_VERSION[23:16];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= FIRMWARE_VERSION[15:8];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= FIRMWARE_VERSION[7:0];
						end
						`GET_MOTOR_SWITCH: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_motor_switch[15:8];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_motor_switch[7:0];
						end
						`GET_MOTOR_FREQ: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_freq_motor1[15:8];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_freq_motor1[7:0];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_freq_motor2[15:8];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_freq_motor2[7:0];
						end
						`GET_HVCOMP_PARA: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_temp_apdhv_base[15:8];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_temp_apdhv_base[7:0];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_temp_temp_base[15:8];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_temp_temp_base[7:0];
							else if (r_byte_txcnt == 16'd18)
								r_udp_txram_wrdata <= i_hvcomp_switch[15:8];
							else if (r_byte_txcnt == 16'd19)
								r_udp_txram_wrdata <= i_hvcomp_switch[7:0];
						end
						`GET_COE_PARA: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= i_pulse_start[31:24];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= i_pulse_start[23:16];
							else if (r_byte_txcnt == 16'd16)
								r_udp_txram_wrdata <= i_pulse_start[15:8];
							else if (r_byte_txcnt == 16'd17)
								r_udp_txram_wrdata <= i_pulse_start[7:0];
							else if (r_byte_txcnt == 16'd18)
								r_udp_txram_wrdata <= i_pulse_divid[31:24];
							else if (r_byte_txcnt == 16'd19)
								r_udp_txram_wrdata <= i_pulse_divid[23:16];
							else if (r_byte_txcnt == 16'd20)
								r_udp_txram_wrdata <= i_pulse_divid[15:8];
							else if (r_byte_txcnt == 16'd21)
								r_udp_txram_wrdata <= i_pulse_divid[7:0];
							else if (r_byte_txcnt == 16'd22)
								r_udp_txram_wrdata <= i_coe_version[31:24];
							else if (r_byte_txcnt == 16'd23)
								r_udp_txram_wrdata <= i_coe_version[23:16];
							else if (r_byte_txcnt == 16'd24)
								r_udp_txram_wrdata <= i_coe_version[15:8];
							else if (r_byte_txcnt == 16'd25)
								r_udp_txram_wrdata <= i_coe_version[7:0];
							else if (r_byte_txcnt == 16'd26)
								r_udp_txram_wrdata <= i_serial_number[31:24];
							else if (r_byte_txcnt == 16'd27)
								r_udp_txram_wrdata <= i_serial_number[23:16];
							else if (r_byte_txcnt == 16'd28)
								r_udp_txram_wrdata <= i_serial_number[15:8];
							else if (r_byte_txcnt == 16'd29)
								r_udp_txram_wrdata <= i_serial_number[7:0];
						end
						`GET_COE: begin
							if (r_byte_txcnt == 16'd14)
								r_udp_txram_wrdata <= r_coe_sernum[15:8];
							else if (r_byte_txcnt == 16'd15)
								r_udp_txram_wrdata <= r_coe_sernum[7:0];
							else if(r_byte_txcnt >= 16'd16 && r_byte_txcnt + 4'd2 <= r_udpcom_byte_size) begin
								case(r_shift_num)
									4'd0: r_udp_txram_wrdata <= i_ddr2para_fifo_data[63:56];
									4'd1: r_udp_txram_wrdata <= i_ddr2para_fifo_data[55:48];
									4'd2: r_udp_txram_wrdata <= i_ddr2para_fifo_data[47:40];
									4'd3: r_udp_txram_wrdata <= i_ddr2para_fifo_data[39:32];
									4'd4: r_udp_txram_wrdata <= i_ddr2para_fifo_data[31:24];
									4'd5: r_udp_txram_wrdata <= i_ddr2para_fifo_data[23:16];
									4'd6: r_udp_txram_wrdata <= i_ddr2para_fifo_data[15:8];
									4'd7: r_udp_txram_wrdata <= i_ddr2para_fifo_data[7:0];
									default:;
								endcase
							end
						end
					endcase
				end
			end
		end else if(r_set_cmd_id == `GET_CODE1) begin
			if (r_tx_state == ST_TXRAM_START)
				r_udp_txram_wrdata <= w_code_rddata1;
			else
				r_udp_txram_wrdata <= r_udp_txram_wrdata;
		end else if(r_set_cmd_id == `GET_CODE2) begin
			if (r_tx_state == ST_TXRAM_START)
				r_udp_txram_wrdata <= w_code_rddata2;
			else
				r_udp_txram_wrdata <= r_udp_txram_wrdata;
		end else if(r_set_cmd_id == `CALI_DATA) begin
			if (r_tx_state == ST_TXRAM_START)
				r_udp_txram_wrdata <= w_calib_rddata;
			else
				r_udp_txram_wrdata <= r_udp_txram_wrdata;
		end else if(r_set_cmd_id == `ONCE_DATA) begin
			if(r_byte_txcnt >= 16'd0 && r_byte_txcnt + 4'd1 <= r_udpcom_byte_size)
				r_udp_txram_wrdata <= w_loop_rddata;
		end 
	end
	//--------------------------------------------------------------------------------------------------
	// inst domain
	//--------------------------------------------------------------------------------------------------
    dataram_2048x8 udprx_dataram(
		.WrClock		        ( i_clk                     ), 
		.WrClockEn		        ( r_udp_txram_wren          ),
		.WrAddress		        ( r_udp_txram_wraddr        ), 
		.Data			        ( r_udp_txram_wrdata        ), 
		.WE				        ( 1'b1 						), 
		.RdClock		        ( i_clk                     ),  
		.RdClockEn		        ( 1'b1 						),
		.RdAddress		        ( i_udp_txram_rdaddr        ),
		.Q				        ( o_udp_txram_rddata        ),
		.Reset			        ( 1'b0 						)
	);

	dataram_1024x8 u_cache_data
	(
		.WrClock				( i_clk						), 
		.WrClockEn				( r_cacheram_wren			),
		.WrAddress				( r_cacheram_wraddr			), 
		.Data					( i_udp_rxram_data			), 
		.WE						( 1'b1						), 
		.RdClock				( i_clk						),  
		.RdClockEn				( 1'b1						),
		.RdAddress				( i_cache_rdaddr			),
		.Q						( o_cache_rddata			),
		.Reset					( 1'b0						)
	);

	dataram_1024x8 u_loop_data1
	(
		.WrClock				( i_clk						), 
		.WrClockEn				( i_loop_wren & i_loop_pingpang),
		.WrAddress				( i_loop_wraddr				), 
		.Data					( i_loop_wrdata				), 
		.WE						( 1'b1						), 
		.RdClock				( i_clk						),  
		.RdClockEn				( ~i_loop_pingpang			),
		.RdAddress				( r_loop_rdaddr				),
		.Q						( w_loop_rddata1			),
		.Reset					( 1'b0						)
	);
	
	dataram_1024x8 u_loop_data2
	(
		.WrClock				( i_clk						), 
		.WrClockEn				( i_loop_wren & ~i_loop_pingpang),
		.WrAddress				( i_loop_wraddr				), 
		.Data					( i_loop_wrdata				), 
		.WE						( 1'b1						), 
		.RdClock				( i_clk						),  
		.RdClockEn				( i_loop_pingpang			),
		.RdAddress				( r_loop_rdaddr				),
		.Q						( w_loop_rddata2			),
		.Reset					( 1'b0						)
	);
	
	assign	w_loop_rddata = (i_loop_pingpang)?w_loop_rddata2:w_loop_rddata1;

	dataram_1024x8 u_calib_data1
	(
		.WrClock				( i_clk						), 
		.WrClockEn				( i_calib_wren & i_calib_pingpang),
		.WrAddress				( i_calib_wraddr			), 
		.Data					( i_calib_wrdata			), 
		.WE						( 1'b1						), 
		.RdClock				( i_clk						),  
		.RdClockEn				( ~i_calib_pingpang			),
		.RdAddress				( r_calib_rdaddr			),
		.Q						( w_calib_rddata1			),
		.Reset					( 1'b0						)
	);
	
	dataram_1024x8 u_calib_data2
	(
		.WrClock				( i_clk						), 
		.WrClockEn				( i_calib_wren & ~i_calib_pingpang),
		.WrAddress				( i_calib_wraddr			), 
		.Data					( i_calib_wrdata			), 
		.WE						( 1'b1						), 
		.RdClock				( i_clk						),  
		.RdClockEn				( i_calib_pingpang			),
		.RdAddress				( r_calib_rdaddr			),
		.Q						( w_calib_rddata2			),
		.Reset					( 1'b0						)
	);
	
	assign	w_calib_rddata = (i_calib_pingpang)?w_calib_rddata2:w_calib_rddata1;

	code_ram128x32 code1_ram (
  		.Data					( i_code_wrdata1			),	// input [31:0]
  		.WrAddress				( i_code_wraddr1			),	// input [6:0]
  		.WrClockEn				( i_code_wren1				),	// input
  		.WrClock				( i_clk						),	// input
  		.WE						( 1'b1						),	// input
		.RdClock				( i_clk						),	// input
		.RdClockEn		        ( 1'b1 						),
  		.RdAddress				( r_code_rdaddr1			),	// input  [8:0]
  		.Q						( w_code_rddata1			),	// output [7:0]
  		.Reset					( 1'b0						) 	// input
	);

	code_ram128x32 code2_ram (
  		.Data					( i_code_wrdata2			),	// input [31:0]
  		.WrAddress				( i_code_wraddr2			),	// input [6:0]
  		.WrClockEn				( i_code_wren2				),	// input
  		.WrClock				( i_clk						),	// input
  		.WE						( 1'b1						),	// input
		.RdClock				( i_clk						),	// input
		.RdClockEn		        ( 1'b1 						),
  		.RdAddress				( r_code_rdaddr2			),	// input  [8:0]
  		.Q						( w_code_rddata2			),	// output [7:0]
  		.Reset					( 1'b0						) 	// input
	);
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_udp_rxram_rdaddr	= r_udp_rxram_rdaddr;
    assign o_udp_txbyte_num 	= r_udpcom_byte_size;
	assign o_parse_done			= r_parse_done;
	assign o_rxcheck_code		= r_rxcheck_code;
	assign o_get_cmd_id			= r_get_cmd_id;
	assign o_get_para0			= r_get_para0;
	assign o_get_para1			= r_get_para1;
	assign o_get_para2			= r_get_para2;
	assign o_get_para3			= r_get_para3;
	assign o_get_para4			= r_get_para4;
	assign o_get_para5			= r_get_para5;
	assign o_get_para6			= r_get_para6;
	assign o_udpfifo_rden		= r_udpfifo_rden;
	assign o_rddr_usercmd		= r_rddr_usercmd;
    assign o_udp_send_req   	= r_udp_send_req;
	assign o_ddr2para_rden		= r_ddr2para_rden;
	assign o_para2ddr_addr		= r_para2ddr_addr;
	assign o_ddr2para_fifo_rden	= r_ddr2para_fifo_rden;
	assign o_udpsend_srcport	= r_udpsend_srcport;
	assign o_udpsend_desport	= r_udpsend_desport;
endmodule