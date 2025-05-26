`timescale 1ns / 1ps

`include "w5500_reg_defines.v"
`include "w5500_cmd_defines.v"

module spi_w5500_top
(
	input					clk,
	input					rst_n,

	output 				o_spi_cs,
	output 				o_spi_dclk,
	output				o_spi_mosi,
	input					i_spi_miso,
	output reg			o_w5500_rst = 1'b0,

	input			[31:0]i_ip,
	input			[31:0]i_netmask,
	input			[31:0]i_gateway,
	input			[47:0]i_mac,
	input			[15:0]i_port,

	input			[15:0]i_clk_div,

	input					i_send_data_req,
	input			[ 7:0]i_send_data,
	input					i_send_req,
	input			[10:0]i_send_wraddr,	
	input			[15:0]i_send_num,
    
	input					i_recv_data_req,
	output		[ 7:0]o_recv_data,
	output 		[15:0]o_recv_num,
	output reg			o_recv_ack,
	
	input           i_motor_state,
	
	input			i_cmd_done,
	
	output	reg		o_send_sig = 1'b0,

	output reg 			o_connect_state = 1'b0
);

	localparam IDLE   				= 0;
	localparam RESET	 			= 1;
	localparam SET_MAC				= 2;
	localparam SET_NETMASK			= 3;
	localparam SET_GATEWAY			= 4;
	localparam SET_IP				= 5;
	localparam SET_KEEP_ALIVE		= 6;
    localparam SET_RCR		        = 7;
	localparam SET_RTR       		= 8;
	localparam SET_RXMEM_SIZE		= 9;
	localparam SET_TXMEM_SIZE		= 10;
	localparam GET_LINK				= 11;
	localparam SOCK_STATE			= 12;
	localparam GET_SOCK_CMD			= 13;
	localparam SET_TCP				= 14;
	localparam SET_PORT				= 15;
	localparam SOCK_OPEN			= 16;
	localparam SOCK_LISTEN			= 17;
	localparam SOCK_DISCON			= 18;
	localparam SOCK_CLOSE 			= 19;
	localparam SOCK_RECV			= 20;
	localparam SOCK_SEND			= 21;
	localparam CLR_SOCK_INT			= 22;
	localparam GET_CON_INT			= 23;
	localparam CLR_CON_INT			= 24;
	localparam GET_RECV_NUM1		= 25;
	localparam GET_RECV_NUM2		= 26;
	localparam GET_RECV_PTR			= 27;
	localparam SET_RECV_PTR			= 28;
	localparam GET_RECV_DATA		= 29;
	localparam GET_SEND_FSIZE		= 30;
	localparam GET_SEND_PTR			= 31;
	localparam SET_SEND_PTR 		= 32;
	localparam SET_SEND_DATA		= 33;
	localparam GET_SEND_INT			= 34;
	localparam CLR_SEND_INT			= 35;


	reg			[ 2:0]r_sock_num = `TCP_SOCK;
	reg					r_rw = `READ;
	reg			[ 7:0]r_cmd = 8'h0;
	reg 					r_cmd_valid = 1'b0;
	reg			[15:0]r_addr = 16'h0;
	reg			[15:0]r_byte_size = 16'd0;
	reg			[ 7:0]r_data_in = 8'h0;

	wire 					w_cmd_ack;
	wire					w_data_req;
	wire 			[10:0]w_send_rdaddr;
	wire 			[ 7:0]w_data_out;
	wire 					w_data_valid;
	
	wire			[ 7:0]w_tcp_send_fifo_dataout;

	reg			[ 5:0]r_state = IDLE;
	reg 			[31:0]r_rst_cnt =32'd0;
	reg			[15:0]r_byte_cnt = 16'd0;
	reg 			[15:0]r_recv_num1 = 16'd0;
	reg 			[15:0]r_recv_num2 = 16'd0;
	reg 			[15:0]r_recv_ptr = 16'h0;
	reg 			[15:0]r_send_fsize = 16'd0;
	reg 			[15:0]r_send_ptr = 16'h0;
	reg 					r_send_flag = 1'b0;
	reg				[10:0]r_send_rdaddr = 11'd0;
	
	
	reg       [1:0]  r_cnt1;  //连接断开计数
	reg       [1:0]  r_cnt2;  //连接断开计数
	
	
	
	assign o_recv_num[15:12] = 4'b0000;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_w5500_rst <= 1'b0;
		else if (r_rst_cnt >= 16'd50_000)
			o_w5500_rst <= 1'b1;
		else
			o_w5500_rst <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_rst_cnt <= 32'd0;
		else if (r_state == IDLE)
			r_rst_cnt <= 32'd0;
		else if (r_state == RESET) begin
			if (r_rst_cnt < 32'd150_000)
				r_rst_cnt <= r_rst_cnt + 32'd1;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_cnt <= 16'd0;
		else if (w_cmd_ack == 1'b1)
			r_byte_cnt <= 16'd0;
		else if (w_data_req == 1'b1)
			r_byte_cnt <= r_byte_cnt + 16'd1;
		else if (w_data_valid == 1'b1)
			r_byte_cnt <= r_byte_cnt + 16'd1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_connect_state <= 1'b0;
		else if (r_state == SOCK_OPEN && w_cmd_ack == 1'b1) begin
			o_connect_state <= 1'b1;
		end
		else if (r_state == SOCK_CLOSE && w_cmd_ack == 1'b1) begin
			o_connect_state <= 1'b0;
		end
		else if	(r_state == SOCK_STATE && w_cmd_ack == 1'b1) begin
			if	(w_data_out == `SOCK_CLOSED)
				o_connect_state <= 1'b0;
		end
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_recv_ack <= 1'b0;
		else if (r_state == GET_SOCK_CMD && w_cmd_ack == 1'b1 && r_data_in == `RECV)
			o_recv_ack <= 1'b1;
		else
			o_recv_ack <= 1'b0;
	end
			  

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_send_flag <= 1'b0;
		else if (i_send_req == 1'b1)
			r_send_flag <= 1'b1;
		else if (r_state == GET_SEND_FSIZE)
			r_send_flag <= 1'b0;	
		end
	
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_state <= IDLE;
			r_cmd <= 7'h00;
			r_cmd_valid <= 1'b0;
			r_rw <= `READ;
			r_data_in <= 8'h0;
			r_sock_num <= `TCP_SOCK;
			r_recv_num1 <= 16'd0;
			r_recv_num2 <= 16'd0;
			r_recv_ptr <= 16'h0;
			r_send_ptr <= 16'h0;
			r_addr <= 16'h0;
			r_byte_size <= 16'd0;
			r_send_fsize <= 16'd0;
			r_cnt1 <= 3'd0;
			r_cnt2 <= 3'd0;
		end
		else begin
			case(r_state)
				IDLE: begin
					r_state <= RESET;
					r_cmd <= 7'h00;
					r_cmd_valid <= 1'b0;
				end
				RESET:
					if (r_rst_cnt >= 32'd150_000) begin
						r_state <= SET_MAC;
						r_cmd <= `SMAC;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= i_mac[47:40];
					end
					else
						r_state <= RESET;
				SET_MAC: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_data_in <= i_mac[39:32];
						else if (r_byte_cnt == 16'd1)
							r_data_in <= i_mac[31:24];
						else if (r_byte_cnt == 16'd2)
							r_data_in <= i_mac[23:16];
						else if (r_byte_cnt == 16'd3)
							r_data_in <= i_mac[15:8];
						else if (r_byte_cnt == 16'd4)
							r_data_in <= i_mac[7:0];
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_NETMASK;
						r_cmd <= `NETMASK;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= i_netmask[31:24];
					end
					else
						r_state <= SET_MAC;
				end
				SET_NETMASK: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_data_in <= i_netmask[23:16];
						else if (r_byte_cnt == 16'd1)
							r_data_in <= i_netmask[15:8];
						else if (r_byte_cnt == 16'd2)
							r_data_in <= i_netmask[7:0];
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_GATEWAY;
						r_cmd <= `GATEWAY;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= i_gateway[31:24];
					end
					else
						r_state <= SET_NETMASK;
				end
				SET_GATEWAY: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_data_in <= i_gateway[23:16];
						else if (r_byte_cnt == 16'd1)
							r_data_in <= i_gateway[15:8];
						else if (r_byte_cnt == 16'd2)
							r_data_in <= i_gateway[7:0];
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_IP;
						r_cmd <= `SIP;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= i_ip[31:24];
					end
					else
						r_state <= SET_GATEWAY;
				end
				SET_IP: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_data_in <= i_ip[23:16];
						else if (r_byte_cnt == 16'd1)
							r_data_in <= i_ip[15:8];
						else if (r_byte_cnt == 16'd2)
							r_data_in <= i_ip[7:0];
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_KEEP_ALIVE;
						r_cmd <= `SOCK_KEEPALIVE;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= 8'd1;
					end
					else
						r_state <= SET_IP;
				end
				
				SET_KEEP_ALIVE:begin
				   r_cmd_valid <= 1'b0;
				   if (w_cmd_ack == 1'b1) begin
						r_state <= SET_RTR;
						r_cmd <= `SOCK_RTR;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= 8'h03;
					end   
				   else
						r_state <= SET_KEEP_ALIVE;
				end
		       SET_RTR:begin
                    r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1)
						r_data_in <= 8'hE3;
					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_RCR;
						r_cmd <= `SOCK_RCR;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= 8'd2;
					end
					else
						r_state <= SET_RTR;
				end
				SET_RCR:begin
				   r_cmd_valid <= 1'b0;
				   if (w_cmd_ack == 1'b1) begin
						r_state <= SET_RXMEM_SIZE;
						r_cmd <= `SOCK_RBUF_SIZE;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= 8'd16;
					end   
				   else
						r_state <= SET_RCR;
				end
				SET_RXMEM_SIZE: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_TXMEM_SIZE;
						r_cmd <= `SOCK_TBUF_SIZE;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= 8'd16;
					end
					else
						r_state <= SET_RXMEM_SIZE;
				end
				SET_TXMEM_SIZE: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_LINK;
						r_cmd <= `PHY_STATE;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
					end
					else
						r_state <= SET_TXMEM_SIZE;
				end
				GET_LINK: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						if (w_data_out[0] == 1'b1) begin
							r_state <= SOCK_STATE;
							r_cmd <= `SOCK_STATE;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
						else begin
							if (o_connect_state == 1'b1&&r_cnt1 == 1'd1) begin
								r_state <= SOCK_DISCON;
								r_cmd <= `SOCK_CMD;
								r_cmd_valid <= 1'b1;
								r_rw <= `WRITE;
								r_data_in <= `DISCON;
								r_sock_num <= `TCP_SOCK;
							end
							else begin
								r_cnt1 <= r_cnt1 + 1'd1;								
								r_state <= GET_LINK;
								r_cmd <= `PHY_STATE;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
							end
						end
					end
					else
						r_state <= GET_LINK;
				end
				SOCK_STATE: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						if (w_data_out == `SOCK_CLOSED) begin
							r_state <= SET_TCP;
							r_cmd <= `SOCK_MODE;
							r_cmd_valid <= 1'b1;
							r_rw <= `WRITE;
							r_data_in <= 8'h01;//8'h21;
							r_sock_num <= `TCP_SOCK;
						end
						else if (w_data_out == `SOCK_INIT) begin
							r_state <= SOCK_LISTEN;
							r_cmd <= `SOCK_CMD;
							r_cmd_valid <= 1'b1;
							r_rw <= `WRITE;
							r_data_in <= `LISTEN;
							r_sock_num <= `TCP_SOCK;
						end
						else if (w_data_out == `SOCK_ESTABLISHED) begin
							r_state <= GET_CON_INT;
							r_cmd <= `SOCK_INT;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
						else if (w_data_out == `SOCK_CLOSE_WAIT&&r_cnt2==1'd1) begin
							r_state <= SOCK_DISCON;
							r_cmd <= `SOCK_CMD;
							r_cmd_valid <= 1'b1;
							r_rw <= `WRITE;
							r_data_in <= `DISCON;
							r_sock_num <= `TCP_SOCK;
						end
						else begin
							r_cnt2 <= r_cnt2 + 1'd1;
							r_state <= GET_LINK;
							r_cmd <= `PHY_STATE;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
						end
					end
					else
						r_state <= SOCK_STATE;
				end
				SET_TCP: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_PORT;
						r_cmd <= `SOCK_SPORT;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= i_port[15:8];
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= SET_TCP;
				end
				SET_PORT: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1)
						r_data_in <= i_port[7:0];

					if (w_cmd_ack == 1'b1) begin
						r_state <= SOCK_OPEN;
						r_cmd <= `SOCK_CMD;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= `OPEN;
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= SET_PORT;
				end
				SOCK_OPEN, SOCK_LISTEN, SOCK_DISCON, SOCK_CLOSE, SOCK_RECV, SOCK_SEND: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_SOCK_CMD;
						r_cmd <= `SOCK_CMD;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
						r_sock_num <= `TCP_SOCK;
						r_cnt1 <= 3'd0;
						r_cnt2 <= 3'd0;
					end
					else
						r_state <= r_state;
				end
				GET_SOCK_CMD: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						if (w_data_out == 8'h0) begin
							if (r_data_in == `OPEN || r_data_in == `LISTEN) begin
								r_state <= GET_LINK;
								r_cmd <= `PHY_STATE;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
							end
							else if (r_data_in == `DISCON) begin
								r_state <= SOCK_CLOSE;
								r_cmd <= `SOCK_CMD;
								r_cmd_valid <= 1'b1;
								r_rw <= `WRITE;
								r_data_in <= `CLOSE;
								r_sock_num <= `TCP_SOCK;
							end
							else if (r_data_in == `CLOSE) begin
								r_state <= CLR_SOCK_INT;
								r_cmd <= `SOCK_INT;
								r_cmd_valid <= 1'b1;
								r_rw <= `WRITE;
								r_data_in <= 8'hff;
								r_sock_num <= `TCP_SOCK;
							end
							else if (r_data_in == `RECV || r_data_in == `SEND) begin
								r_state <= GET_LINK;
								r_cmd <= `PHY_STATE;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
							end
/*							else if (r_data_in == `SEND) begin
								r_state <= GET_SEND_INT;
								r_cmd <= `SOCK_INT;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
								r_sock_num <= `TCP_SOCK;
							end*/
						end
						else begin
							r_state <= GET_SOCK_CMD;
							r_cmd <= `SOCK_CMD;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
					end
					else
						r_state <= GET_SOCK_CMD;
				end
				CLR_SOCK_INT: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_LINK;
						r_cmd <= `PHY_STATE;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= CLR_SOCK_INT;
				end
				GET_CON_INT: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						if (w_data_out[0] == 1'b1) begin
							r_state <= CLR_CON_INT;
							r_cmd <= `SOCK_INT;
							r_cmd_valid <= 1'b1;
							r_rw <= `WRITE;
							r_data_in <= 8'h01;
							r_sock_num <= `TCP_SOCK;
						end
						else begin
							r_state <= GET_RECV_NUM1;
							r_cmd <= `SOCK_RX_SIZE;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
					end
					else
						r_state <= GET_CON_INT;
				end
				CLR_CON_INT: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_RECV_NUM1;
						r_cmd <= `SOCK_RX_SIZE;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= CLR_CON_INT;
				end
				GET_RECV_NUM1: begin
					r_cmd_valid <= 1'b0;
					if (w_data_valid == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_recv_num1[15:8] <= w_data_out;
						else if (r_byte_cnt == 16'd1)
							r_recv_num1[7:0] <= w_data_out;
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_RECV_NUM2;
						r_cmd <= `SOCK_RX_SIZE;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= GET_RECV_NUM1;
				end
				GET_RECV_NUM2: begin
					r_cmd_valid <= 1'b0;
					if (w_data_valid == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_recv_num2[15:8] <= w_data_out;
						else if (r_byte_cnt == 16'd1)
							r_recv_num2[7:0] <= w_data_out;
					end

					if (w_cmd_ack == 1'b1) begin
						if (r_recv_num1 == r_recv_num2 && r_recv_num1 != 16'd0) begin
							r_state <= GET_RECV_PTR;
							r_cmd <= `SOCK_RX_RPOINT;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
						else if (r_recv_num1 == r_recv_num2 && r_recv_num1 == 16'd0) begin
							if (r_send_flag == 1'b1) begin
								r_state <= GET_SEND_FSIZE;
								r_cmd <= `SOCK_TX_FSIZE;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
								r_sock_num <= `TCP_SOCK;
							end
							else begin
								r_state <= GET_LINK;
								r_cmd <= `PHY_STATE;
								r_cmd_valid <= 1'b1;
								r_rw <= `READ;
							end
						end
						else begin
							r_recv_num1 <= 16'd0;
							r_recv_num2 <= 16'd0;
							r_state <= GET_RECV_NUM1;
							r_cmd <= `SOCK_RX_SIZE;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
					end
					else
						r_state <= GET_RECV_NUM2;
				end
				GET_RECV_PTR: begin
					r_cmd_valid <= 1'b0;
					if (w_data_valid == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_recv_ptr[15:8] <= w_data_out;
						else if (r_byte_cnt == 16'd1)
							r_recv_ptr[7:0] <= w_data_out;
					end

					if (w_cmd_ack == 1'b1) begin
						r_recv_ptr[7:0] <= w_data_out;
						r_state <= GET_RECV_DATA;
						r_cmd <= `SOCK_BUF;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
						r_sock_num <= `TCP_SOCK;
						r_addr <= r_recv_ptr;
						r_byte_size <= r_recv_num1;
					end
					else
						r_state <= GET_RECV_PTR;
				end
				GET_RECV_DATA: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_RECV_PTR;
						r_cmd <= `SOCK_RX_RPOINT;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= (r_recv_ptr + r_recv_num1) >> 8;
						r_byte_size <= 16'd0;
					end
					else
						r_state <= GET_RECV_DATA;
				end
				SET_RECV_PTR: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1)
						r_data_in <= (r_recv_ptr + r_recv_num1);

					if (w_cmd_ack == 1'b1) begin
						r_state <= SOCK_RECV;
						r_cmd <= `SOCK_CMD;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= `RECV;
						r_sock_num <= `TCP_SOCK;
					end
					else
						r_state <= SET_RECV_PTR;
				end
				GET_SEND_FSIZE: begin
					r_cmd_valid <= 1'b0;
					if (w_data_valid == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_send_fsize[15:8] <= w_data_out;
						else if (r_byte_cnt == 16'd1)
							r_send_fsize[7:0] <= w_data_out;
					end

					if (w_cmd_ack == 1'b1) begin
						//if (r_send_fsize >= 16'd1024) begin
							r_state <= GET_SEND_PTR;
							r_cmd <= `SOCK_TX_WPOINT;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						/*end
						else begin
							r_state <= GET_SEND_FSIZE;
							r_cmd <= `SOCK_TX_FSIZE;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end*/
					end
					else
						r_state <= GET_SEND_FSIZE;
				end
				GET_SEND_PTR: begin
					r_cmd_valid <= 1'b0;
					if (w_data_valid == 1'b1) begin
						if (r_byte_cnt == 16'd0)
							r_send_ptr[15:8] <= w_data_out;
						else if (r_byte_cnt == 16'd1)
							r_send_ptr[7:0] <= w_data_out;
					end

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_SEND_DATA;
						r_cmd <= `SOCK_BUF;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= w_tcp_send_fifo_dataout;
						r_addr <= r_send_ptr;
						r_byte_size <= {5'b00000, i_send_num};
					end
					else
						r_state <= GET_SEND_PTR;
				end
				SET_SEND_DATA: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1)
						r_data_in <= w_tcp_send_fifo_dataout;

					if (w_cmd_ack == 1'b1) begin
						r_state <= SET_SEND_PTR;
						r_cmd <= `SOCK_TX_WPOINT;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_sock_num <= `TCP_SOCK;
						r_data_in <= (r_send_ptr + r_byte_size) >> 8;
					end
					else
						r_state <= SET_SEND_DATA;
				end
				SET_SEND_PTR: begin
					r_cmd_valid <= 1'b0;
					if (w_data_req == 1'b1)
						r_data_in <= (r_send_ptr + r_byte_size);

					if (w_cmd_ack == 1'b1) begin
						r_state <= SOCK_SEND;
						r_cmd <= `SOCK_CMD;
						r_cmd_valid <= 1'b1;
						r_rw <= `WRITE;
						r_data_in <= `SEND;
						r_sock_num <= `TCP_SOCK;
						r_byte_size <= 16'd0;
					end
					else
						r_state <= SET_SEND_PTR;
				end
				GET_SEND_INT: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						if (w_data_out[4] == 1'b1) begin
							r_state <= CLR_SEND_INT;
							r_cmd <= `SOCK_INT;
							r_cmd_valid <= 1'b1;
							r_rw <= `WRITE;
							r_data_in <= 8'h10;
							r_sock_num <= `TCP_SOCK;
						end
						else begin
							r_state <= GET_SEND_INT;
							r_cmd <= `SOCK_INT;
							r_cmd_valid <= 1'b1;
							r_rw <= `READ;
							r_sock_num <= `TCP_SOCK;
						end
					end
					else
						r_state <= GET_SEND_INT;
				end
				CLR_SEND_INT: begin
					r_cmd_valid <= 1'b0;
					if (w_cmd_ack == 1'b1) begin
						r_state <= GET_LINK;
						r_cmd <= `PHY_STATE;
						r_cmd_valid <= 1'b1;
						r_rw <= `READ;
					end
					else
						r_state <= CLR_SEND_INT;
				end
			endcase
		end
	end
	
	//o_send_sig
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_send_sig	<= 1'b0;
		else if(r_state == SET_SEND_PTR && w_cmd_ack == 1'b1)
			o_send_sig	<= 1'b1;
		else
			o_send_sig	<= 1'b0;
	end
	
	reg	[11:0] r_tcp_wr_addr;
	reg	[11:0] r_tcp_rd_addr;
	reg	[11:0] r_recv_num;	

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_tcp_rd_addr <= 12'd0;
		else if(i_cmd_done)
			r_tcp_rd_addr <= 12'd0;
		else if(i_recv_data_req && r_tcp_rd_addr < r_recv_num - 1'd1)
			r_tcp_rd_addr <= r_tcp_rd_addr + 1'd1;
//		else
//			r_tcp_rd_addr <= 12'd0;
		end
		
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_tcp_wr_addr <= 12'd0;
		else if(r_state == GET_RECV_DATA )begin
			if(w_data_valid)
				r_tcp_wr_addr <= r_tcp_wr_addr + 1'd1;
			else
				r_tcp_wr_addr <= r_tcp_wr_addr;
			end
		else
			r_tcp_wr_addr <= 12'd0;
		end
			
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)	
			r_recv_num <= 12'd0;
		else if(r_state == IDLE)
			r_recv_num <= 12'd0;
		else if(r_state == GET_RECV_DATA)
			r_recv_num <= r_tcp_wr_addr;
		end
		
	assign o_recv_num = r_recv_num;
		
	

	spi_w5500_cmd u1(
		.clk 				( clk ),
		.rst_n			( rst_n ),

		.o_spi_cs		( o_spi_cs ),
		.o_spi_dclk		( o_spi_dclk ),
		.o_spi_mosi		( o_spi_mosi ),
		.i_spi_miso		( i_spi_miso ),

		.i_sock_num		( r_sock_num ),
		.i_rw				( r_rw ),

		.i_clk_div		( i_clk_div ),
		.i_cmd 			( r_cmd ),
		.i_cmd_valid	( r_cmd_valid ),
		.o_cmd_ack		( w_cmd_ack ),

		.i_addr			( r_addr ),
		.i_byte_size	( r_byte_size ),

		.o_data_req		( w_data_req ),
		.o_send_rdaddr	( w_send_rdaddr ),
		.i_data_in		( r_data_in ),
		.o_data_out		( w_data_out ),
		.o_data_valid	( w_data_valid )
	);
	
/*	tcp_recv_fifo u2(
		.Data			( w_data_out ), 
		.Clock			( ~clk ), 
		.WrEn			( r_state == GET_RECV_DATA && w_data_valid ), 
		.RdEn			( i_recv_data_req ), 
		.Reset			( r_state == GET_RECV_PTR && w_cmd_ack ), 
		.Q				( o_recv_data ), 
		.WCNT			( o_recv_num[11:0] ), 
		.Empty			(  ), 
		.Full			(  )
	);

	packet_data_fifo u2(
		.Data			( w_data_out ), 
		.Clock			( ~clk ), 
		.WrEn			( r_state == GET_RECV_DATA && w_data_valid ), 
		.RdEn			( i_recv_data_req ), 
		.Reset			( r_state == GET_RECV_PTR && w_cmd_ack ), 
		.Q				( o_recv_data ), 
		.WCNT			( o_recv_num[11:0] ), 
		.Empty			(  ), 
		.Full			(  )
	);*/
	
	tcp_recv_ram u2(
		.WrClock				(clk), 
		.WrClockEn				(r_state == GET_RECV_DATA && w_data_valid),
		.WrAddress				(r_tcp_wr_addr), 
		.Data					(w_data_out), 
		.WE						(1'b1), 
		.RdClock				(clk),  
		.RdClockEn				(1'd1),
		.RdAddress				(r_tcp_rd_addr),
		.Q						(o_recv_data),
		.Reset					(1'b0)
	) ;
	
	
	eth_send_ram U3
	(
		.WrClock		( clk ), 
		.WrClockEn		( i_send_data_req ),
		.WrAddress		( i_send_wraddr ), 
		.Data			( i_send_data ), 
		.WE				( 1'b1 ), 
		.RdClock		( ~clk ),  
		.RdClockEn		( 1'b1 ),//(w_data_req),
		.RdAddress		( w_send_rdaddr ),
		.Q				( w_tcp_send_fifo_dataout ),
		.Reset			( ~rst_n )
	);

endmodule
