`timescale 1ns / 1ps

`include "w5500_reg_defines.v"
`include "w5500_cmd_defines.v"

module spi_w5500_cmd
(
	input					clk,
	input					rst_n,

	output 				o_spi_cs,
	output 				o_spi_dclk,
	output				o_spi_mosi,
	input					i_spi_miso,

	input			[ 2:0]i_sock_num,
	input					i_rw,

	input			[15:0]i_clk_div,
	input			[ 7:0]i_cmd,
	input					i_cmd_valid,
	output reg			o_cmd_ack = 1'b0,

	input			[15:0]i_addr,
	input			[15:0]i_byte_size,

	output reg			o_data_req = 1'b0,
	output reg		[10:0]o_send_rdaddr = 11'd0,
	input			[ 7:0]i_data_in,
	output		[ 7:0]o_data_out,
	output reg			o_data_valid
);

	localparam IDLE   		= 0;
	localparam CS_LOW 		= 1;
	localparam CS_HIGH 		= 2;
	localparam ADDR			= 3;
	localparam ADDR_ACK		= 4;
	localparam CMD   			= 5;
	localparam CMD_ACK		= 6;
	localparam BYTE 			= 7;
	localparam BYTE_ACK		= 8;

	wire					w_wr_ack;

	reg					r_cs_ctrl = 1'b1;
	reg					r_wr_req = 1'b0;

	reg			[15:0]r_addr = 16'h0;
	reg			[ 7:0]r_cmd = 8'h0;
	reg			[ 7:0]r_data_in = 8'h0;

	reg			[16:0]r_byte_size = 17'd0;
	reg			[15:0]r_byte_cnt = 16'd0;
	reg			[ 3:0]r_state = IDLE;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_byte_size <= 17'd0;
			r_addr <= 16'h00;
			r_cmd <= 8'h0;
		end
		else if (r_state == CS_LOW) begin
			case (i_cmd)
				/*General Register command*/
				`GATEWAY: begin
					r_byte_size <= 17'd3 + 17'd4;
					r_addr <= `GAR0;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				`NETMASK: begin
					r_byte_size <= 17'd3 + 17'd4;
					r_addr <= `SUBR0;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				`SMAC: begin
					r_byte_size <= 17'd3 + 17'd6;
					r_addr <= `SHAR0;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				`SIP: begin
					r_byte_size <= 17'd3 + 17'd4;
					r_addr <= `SIPR0;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				`PHY_STATE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `PHYCFG;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				/*Socket Register command*/
				`SOCK_MODE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_MR;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_CMD: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_CR;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_INT: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_IR;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_STATE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_SR;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_SPORT: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_PORT0;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_RBUF_SIZE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_RXMEM_SIZE;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_TBUF_SIZE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_TXMEM_SIZE;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_TX_FSIZE: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_TX_FSR0;
					r_cmd <= {i_sock_num, 2'b01, `READ, 2'b00};
				end
				`SOCK_TX_WPOINT: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_TX_WR0;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_RX_SIZE: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_RX_RSR0;
					r_cmd <= {i_sock_num, 2'b01, `READ, 2'b00};
				end
				`SOCK_RX_RPOINT: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_RX_RD0;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_KEEPALIVE: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_KPALVTR;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_RTR: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_RTR0;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				`SOCK_RCR: begin
					r_byte_size <= 17'd3 + 17'd1;
					r_addr <= `Sn_RCR;
					r_cmd <= {5'b00000, i_rw, 2'b00};
				end
				/*Socket Buffer command*/
				`SOCK_BUF: begin
					r_byte_size <= 17'd3 + i_byte_size;
					r_addr <= i_addr;
					if (i_rw == `WRITE)
						r_cmd <= {i_sock_num, 2'b10, `WRITE, 2'b00};
					else if (i_rw == `READ)
						r_cmd <= {i_sock_num, 2'b11, `READ, 2'b00};
				end
				`SOCK_DIP: begin
					r_byte_size <= 17'd3 + 17'd4;
					r_addr <= `Sn_DIPR0;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				`SOCK_DPORT: begin
					r_byte_size <= 17'd3 + 17'd2;
					r_addr <= `Sn_DPORT0;
					r_cmd <= {i_sock_num, 2'b01, i_rw, 2'b00};
				end
				default: begin
					r_byte_size <= 17'd0;
					r_addr <= 16'h0;
					r_cmd <= 8'h00;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_cs_ctrl <= 1'b1;
		else if (r_state == CS_LOW)
			r_cs_ctrl <= 1'b0;
		else if (r_state == CS_HIGH)
			r_cs_ctrl <= 1'b1;
		else
			r_cs_ctrl <= r_cs_ctrl;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_wr_req <= 1'b0;
		else if (r_state == ADDR || r_state == CMD || r_state == BYTE)
			r_wr_req <= 1'b1;
		else
			r_wr_req <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_data_in <= 8'h0;
		else if (r_state == ADDR) begin
			if (r_byte_cnt == 16'd0)
				r_data_in <= r_addr[15:8];
			else if (r_byte_cnt == 16'd1)
				r_data_in <= r_addr[7:0];
		end
		else if (r_state == CMD)
			r_data_in <= r_cmd;
		else if (r_state == BYTE_ACK) begin
			if (r_cmd[2] == `WRITE)
				r_data_in <= i_data_in;
			else if (r_cmd[2] == `READ)
				r_data_in <= 8'd0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_byte_cnt <= 16'd0;
		else if (r_state == IDLE)
			r_byte_cnt <= 16'd0;
		else if (w_wr_ack == 1'b1)
			r_byte_cnt <= r_byte_cnt + 16'd1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_valid <= 1'b0;
		else if (r_state == BYTE_ACK && w_wr_ack == 1'b1 && r_cmd[2] == 1'b0)
			o_data_valid <= 1'b1;
		else
			o_data_valid <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_cmd_ack <= 1'b0;
		else if (r_state == CS_HIGH)
			o_cmd_ack <= 1'b1;
		else
			o_cmd_ack <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_data_req <= 1'b0;
		else if (r_state == BYTE_ACK && w_wr_ack == 1'b1 && r_cmd[2] == 1'b1 && r_byte_cnt < r_byte_size - 17'd1) begin
			o_data_req <= 1'b1;
		end
		else
			o_data_req <= 1'b0;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			o_send_rdaddr <= 11'd0;
		else if (r_state == BYTE_ACK && w_wr_ack == 1'b1 && r_cmd[2] == 1'b1 && r_byte_cnt < r_byte_size - 17'd1) begin
			o_send_rdaddr <= o_send_rdaddr + 1'b1;
		end
		else if (r_state == IDLE)
			o_send_rdaddr <= 11'd0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_state <= IDLE;
		else begin
			case(r_state)
				IDLE:
					if (i_cmd_valid)
						r_state <= CS_LOW;
					else
						r_state <= IDLE;
				CS_LOW:
					r_state <= ADDR;
				CS_HIGH:
					r_state <= IDLE;
				ADDR:
					if (r_byte_size == 17'd0)
						r_state <= IDLE;
					else
						r_state <= ADDR_ACK;
				ADDR_ACK:
					if (w_wr_ack == 1'b1) begin
						if (r_byte_cnt < 16'd1)
							r_state <= ADDR;
						else
							r_state <= CMD;
					end
					else
						r_state <= ADDR_ACK;
				CMD:
					r_state <= CMD_ACK;
				CMD_ACK:
					if (w_wr_ack == 1'b1)
						r_state <= BYTE;
					else
						r_state <= CMD_ACK;
				BYTE:
					r_state <= BYTE_ACK;
				BYTE_ACK:
					if (w_wr_ack == 1'b1) begin
						if (r_byte_cnt < r_byte_size - 17'd1)
							r_state <= BYTE;
						else
							r_state <= CS_HIGH;
					end
					else
						r_state <= BYTE_ACK;
			endcase
		end
	end

	spi_master_eth u1(
		.clk 				( clk ),
		.rst_n			( rst_n ),

		.o_spi_cs		( o_spi_cs ),
		.o_spi_dclk		( o_spi_dclk ),
		.o_spi_mosi		( o_spi_mosi ),
		.i_spi_miso		( i_spi_miso ),

		.i_cs_ctrl		( r_cs_ctrl ),
		.i_clk_div		( i_clk_div ),
		.i_wr_req		( r_wr_req ),
		.o_wr_ack		( w_wr_ack ),
		.i_data_in		( r_data_in ),
		.o_data_out		( o_data_out )
	);

endmodule
