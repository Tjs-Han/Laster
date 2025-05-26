//**************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: flash_control
// Date Created 	: 2024/11/19 
// Version 			: V1.1
//--------------------------------------------------------------------------------------------------
// FLASH VERSION	: df1 prj
//			W25Q256JVEIQ
//				The memory is organized as:
//				- 8,388,608 Bytes
//				- 128 blocks of 64K-Byte
//				- 2,048 sectors of 4K-Byte
//				- 32,768 pages (256 Bytes each)
//--------------------------------------------------------------------------------------------------
// File description	:flash_control
//				general control flash module
//				1、load data from flash to ddr when power on 
//				2、save ddr data to flash as order
// FLASH ADDR ASSIGN:
//				24'h00_0000~~~24'h1F_FFFF     	//2M bytes fpga firmware storage
//				24'h20_0000~~~24'h21_FFFF		//128k bytes parameters
//				24'h22_0000~~~24'h3F_FFFF		//2M-128K bytes coe table
//				24'h40_0000~~~24'h5F_FFFF		//2M backup data
//--------------------------------------------------------------------------------------------------
// Revision History :V1.0
//**************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module flash_control
#(  
    parameter DDR_DW        = 64,
    parameter DDR_AW        = 27,
	parameter USER_RDW      = 16
)
(
	input								i_clk,
	input								i_rst_n,

	output								o_flash_cs,
	output								o_flash_mosi,
	input								i_flash_miso,

	output                              o_flash2ddr_wren,
    output                              o_ddr2flash_rden,
    output [DDR_AW-1:0]                 o_flash2ddr_addr,
    output [DDR_DW-1:0]                 o_flash2ddr_data,
	output								o_ddr2flash_fifo_rden,
    input                              	i_ddr2flash_fifo_empty,
    input  [USER_RDW-1:0]				i_ddr2flash_fifo_data,

	input								i_factory_sig,
	input								i_parameter_read,
	input								i_parameter_sig,
	input								i_cal_coe_sig,
	input								i_code_data_sig,
	input [2:0]							i_code_packet_num,

	output								o_read_complete_sig	
);
    //----------------------------------------------------------------------------------------------
    // parameter adn localparam define 
    //----------------------------------------------------------------------------------------------
	localparam PARA_DDRBASE_ADDR		= 32'h0000_0000;	//base 0
	localparam COE_DDRBASE_ADDR			= 32'h0002_0000;	//base 128k
	localparam FIRM_DDRBASE_ADDR		= 32'h0020_0000;	//base 2M
	localparam PARA_FLASHBASE_ADDR		= 32'h0020_0000;	//base 2M
	localparam COE_FLASHBASE_ADDR		= 32'h0022_0000;	//base 2M+128k
	localparam FACT_FLASHBASE_ADDR		= 32'h0040_0000;	//base 4M

	localparam FLASH_INIT_PAGENUM		= 16'd2048;//512K
	localparam SET_PARA_PAGENUM			= 16'd256;//64K
	localparam COE_TABLE_PAGENUM		= 16'd2048;//512K

	parameter		FLASH_IDLE			= 24'b0000_0000_0000_0000_0000_0000,
					FLASH_READ			= 24'b0000_0000_0000_0000_0000_0001,
					FLASH_READ_ACK		= 24'b0000_0000_0000_0000_0000_0010,
					FLASH_READ_ASSIGN	= 24'b0000_0000_0000_0000_0000_0100,
					FLASH_READ_DATA		= 24'b0000_0000_0000_0000_0000_1000,
					FLASH_WDDR_ADDR		= 24'b0000_0000_0000_0000_0001_0000,
					FLASH_READ_SHIFT	= 24'b0000_0000_0000_0000_0010_0000,
					FLASH_READ_DELAY	= 24'b0000_0000_0000_0000_0100_0000,
					FLASH_WAIT			= 24'b0000_0000_0000_0000_1000_0000,
					FLASH_ERASE			= 24'b0000_0000_0000_0001_0000_0000,
					FLASH_ERASE_ACK		= 24'b0000_0000_0000_0010_0000_0000,
					FLASH_ERASE_DELAY	= 24'b0000_0000_0000_0100_0000_0000,
					FLASH_RDDR_EN		= 24'b0000_0000_0000_1000_0000_0000,
					FLASH_RDDR_ADDR		= 24'b0000_0000_0001_0000_0000_0000,
					FLASH_WRITE_CMD		= 24'b0000_0000_0010_0000_0000_0000,
					FLASH_RDFIFO_EN		= 24'b0000_0000_0100_0000_0000_0000,
					FLASH_RDFIFO_DATA	= 24'b0000_0000_1000_0000_0000_0000,
					FLASH_WRITE_MSB		= 24'b0000_0001_0000_0000_0000_0000,
					FLASH_WRITE_LSB		= 24'b0000_0010_0000_0000_0000_0000,
					FLASH_WRITE_WAIT	= 24'b0000_0100_0000_0000_0000_0000,
					FLASH_WRITE_ACK		= 24'b0000_1000_0000_0000_0000_0000,
					FLASH_WRITE_SHIFT	= 24'b0001_0000_0000_0000_0000_0000,
					FLASH_WRITE_DELAY	= 24'b0010_0000_0000_0000_0000_0000,
					FLASH_END			= 24'b0100_0000_0000_0000_0000_0000;
					
    //----------------------------------------------------------------------------------------------
    // reg and wire define 
    //----------------------------------------------------------------------------------------------
	reg  [23:0]			r_flash_state 		= 24'd0;
	wire				w_flash_clk;
	reg					r_flash_clk_n = 1'b1;
	//flash interface
	wire				w_cmd_ack;
	wire [7:0]  		w_data_out;
	wire				w_data_valid;
	wire				w_data_req;
	//ddr interface
	reg                 r_flash2ddr_wren;
    reg                 r_ddr2flash_rden;
    reg  [DDR_AW-1:0]   r_flash2ddr_addr;
    reg  [DDR_DW-1:0]   r_flash2ddr_data;
	reg					r_ddr2flash_fifo_rden;
	reg  [7:0]			r_ddren_cnt_flash;
	
	reg  [7:0]			r_flash_cmd 		= 8'd0;
	reg	 				r_cmd_valid 		= 1'b0;
	reg  [23:0]			r_flash_addr		= PARA_FLASHBASE_ADDR;
	reg  [23:0]			r_flash_rdaddr		= PARA_FLASHBASE_ADDR;
	reg  [15:0]			r_page_num			= FLASH_INIT_PAGENUM;
	reg  [15:0]			r_page_rdnum		= FLASH_INIT_PAGENUM;
	reg  [15:0]			r_page_cnt			= 16'd0;
	reg	 				r_erase_flag		= 1'b0;
	reg  [31:0]			r_delay_cnt			= 32'd0;
	reg					r_read_complete_sig	= 1'b0;
	reg  [7:0]			r_data_in			= 8'd0;

	reg	 				r_cmd_ack			= 1'b0;
	reg	 [3:0]			r_read_cnt			= 4'd0;
    //----------------------------------------------------------------------------------------------
    // FSM(finite-state machine)
    //----------------------------------------------------------------------------------------------
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash_state	<= FLASH_IDLE;
		else begin
			case(r_flash_state)
				FLASH_IDLE: begin
					r_flash_state	<= FLASH_READ;
				end
				FLASH_READ: begin
					r_flash_state	<= FLASH_READ_ACK;
				end
				FLASH_READ_ACK: begin
					if(w_data_valid)
						r_flash_state	<= FLASH_READ_ASSIGN;
					else if(r_cmd_ack || w_cmd_ack)
						r_flash_state	<= FLASH_READ_SHIFT;
					else
						r_flash_state	<= FLASH_READ_ACK;
				end
				FLASH_READ_ASSIGN: begin
					if(r_read_cnt >= 4'd7)
						r_flash_state	<= FLASH_READ_DATA;
					else
						r_flash_state	<= FLASH_READ_ACK;
				end
				FLASH_READ_DATA: r_flash_state	<= FLASH_WDDR_ADDR;
				FLASH_WDDR_ADDR: r_flash_state	<= FLASH_READ_ACK;
				FLASH_READ_SHIFT: begin
					if(r_page_cnt + 1'b1 >= r_page_num)
						r_flash_state	<= FLASH_READ_DELAY;
					else
						r_flash_state	<= FLASH_READ;
				end
				FLASH_READ_DELAY: begin
					if((r_delay_cnt - 32'd249) == 32'd0)
						r_flash_state	<= FLASH_WAIT;
					else
						r_flash_state	<= FLASH_READ_DELAY;
				end
				FLASH_WAIT: begin
					if(i_parameter_sig || i_cal_coe_sig || i_code_data_sig || i_factory_sig)
						r_flash_state		<= FLASH_ERASE;
					else if(i_parameter_read)
						r_flash_state	<= FLASH_READ;
					else
						r_flash_state	<= FLASH_WAIT;
				end
				FLASH_ERASE: begin
					r_flash_state	<= FLASH_ERASE_ACK;
				end
				FLASH_ERASE_ACK: begin
					if(w_cmd_ack)
						r_flash_state	<= FLASH_ERASE_DELAY;
					else
						r_flash_state	<= FLASH_ERASE_ACK;
				end
				FLASH_ERASE_DELAY: begin
					if(r_erase_flag)
						r_flash_state	<= FLASH_RDDR_EN;
					else
						r_flash_state	<= FLASH_ERASE;
				end
				FLASH_RDDR_EN: r_flash_state	<= FLASH_RDDR_ADDR;
                FLASH_RDDR_ADDR: begin
                    if(r_ddren_cnt_flash == 8'd32) 
                        r_flash_state		<= FLASH_WRITE_CMD;
                    else
                        r_flash_state		<= FLASH_RDDR_EN;
                end
				FLASH_WRITE_CMD: begin
					r_flash_state		<= FLASH_RDFIFO_EN;
				end
				FLASH_RDFIFO_EN: begin
					r_flash_state		<= FLASH_RDFIFO_DATA;
				end
				FLASH_RDFIFO_DATA: begin
					r_flash_state		<= FLASH_WRITE_MSB;
				end
				FLASH_WRITE_MSB: begin
					r_flash_state		<= FLASH_WRITE_LSB;
				end
				FLASH_WRITE_LSB: begin
					if(w_data_req)
						r_flash_state		<= FLASH_WRITE_WAIT;						
					else
						r_flash_state		<= FLASH_WRITE_LSB;
				end
				FLASH_WRITE_WAIT: r_flash_state		<= FLASH_WRITE_ACK;	
				FLASH_WRITE_ACK: begin
					if(w_cmd_ack)
						r_flash_state		<= FLASH_WRITE_SHIFT;
					else if(w_data_req)
						r_flash_state		<= FLASH_WRITE_LSB;
					else
						r_flash_state		<= FLASH_WRITE_ACK;
				end
				FLASH_WRITE_SHIFT: begin
					if(r_page_cnt + 1'b1 >= r_page_num)
						r_flash_state		<= FLASH_WRITE_DELAY;
					else if(r_page_cnt[7:0] == 8'hFF)
						r_flash_state		<= FLASH_ERASE;
					else
						r_flash_state		<= FLASH_RDDR_EN;
				end
				FLASH_WRITE_DELAY: begin
					if((r_delay_cnt - 32'd12_500_000) == 32'd0)
						r_flash_state		<= FLASH_END;
					else
						r_flash_state		<= FLASH_WRITE_DELAY;
				end
				FLASH_END: begin
					if(r_page_rdnum > 16'd0)
						r_flash_state		<= FLASH_READ;
					else
						r_flash_state		<= FLASH_WAIT;
				end
				default:r_flash_state	<= FLASH_IDLE;
			endcase
		end
	end
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------			
	//r_flash_clk_n
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash_clk_n	<= 1'b1;
		else if(r_flash_state == FLASH_WAIT)
			r_flash_clk_n	<= 1'b1;
		else if(r_flash_state == FLASH_WRITE_DELAY)
			r_flash_clk_n	<= 1'b1;
		else
			r_flash_clk_n	<= 1'b0;
	end

	//r_flash_cmd
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash_cmd 	<= 8'h00;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_cmd 	<= 8'h00;
		else if(r_flash_state == FLASH_READ)
			r_flash_cmd 	<= 8'h03;
		else if(r_flash_state == FLASH_ERASE)
			r_flash_cmd 	<= 8'hD8;
		else if(r_flash_state == FLASH_WRITE_CMD)
			r_flash_cmd 	<= 8'h02;
	end

	//r_cmd_valid
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_cmd_valid 	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_cmd_valid 	<= 1'b0;
		else if(r_flash_state == FLASH_READ)
			r_cmd_valid 	<= 1'b1;
		else if(r_flash_state == FLASH_ERASE)
			r_cmd_valid 	<=1'b1;
		else if(r_flash_state == FLASH_WRITE_CMD)
			r_cmd_valid 	<= 1'b1;
		else
			r_cmd_valid 	<= 1'b0;
	end

	//r_flash_rdaddr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig)
				r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
			else if(i_factory_sig)
				r_flash_rdaddr	<= 24'h0B0000;
			else if(i_cal_coe_sig)
				r_flash_rdaddr	<= 24'h0C0000;
			else
				r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
			end
	end

	//r_flash_addr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash_addr	<= PARA_FLASHBASE_ADDR;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_addr	<= PARA_FLASHBASE_ADDR;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig)
				r_flash_addr	<= PARA_FLASHBASE_ADDR;
			else if(i_factory_sig)
				r_flash_addr	<= 24'h0B0000;
			else if(i_cal_coe_sig)
				r_flash_addr	<= 24'h0C0000;
			else if(i_code_data_sig)
				r_flash_addr	<= i_code_packet_num * 21'h020000;
			else if(i_parameter_read)
				r_flash_addr	<= PARA_FLASHBASE_ADDR;
			else
				r_flash_addr	<= PARA_FLASHBASE_ADDR;
			end
		else if(r_flash_state == FLASH_READ_SHIFT)
			r_flash_addr	<= r_flash_addr + 24'h000100;
		else if(r_flash_state == FLASH_WRITE_SHIFT)
			r_flash_addr	<= r_flash_addr + 24'h000100;
		else if(r_flash_state == FLASH_END)
			r_flash_addr	<= r_flash_rdaddr;
	end

	//r_page_rdnum
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_page_rdnum	<= FLASH_INIT_PAGENUM;
		else if(r_flash_state == FLASH_IDLE)
			r_page_rdnum	<= FLASH_INIT_PAGENUM;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || i_factory_sig)
				r_page_rdnum	<= 16'd256;
			else if(i_cal_coe_sig)
				r_page_rdnum	<= 16'd1536;
			else
				r_page_rdnum	<= 16'd0;
			end
	end

	//r_page_num
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_page_num		<= FLASH_INIT_PAGENUM;
		else if(r_flash_state == FLASH_IDLE)
			r_page_num		<= FLASH_INIT_PAGENUM;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_factory_sig || i_parameter_sig)
				r_page_num		<= 16'd256;
			else if(i_code_data_sig || i_parameter_read)
				r_page_num		<= 16'd512;
			else if(i_cal_coe_sig)
				r_page_num		<= 16'd1536;
			end
		else if(r_flash_state == FLASH_END)
			r_page_num		<= r_page_rdnum;
	end

	//r_page_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_page_cnt		<= 16'd0;
		else if(r_flash_state == FLASH_READ_SHIFT)
			r_page_cnt		<= r_page_cnt + 1'b1;
		else if(r_flash_state == FLASH_WRITE_SHIFT)
			r_page_cnt		<= r_page_cnt + 1'b1;
		else if(r_flash_state == FLASH_IDLE || r_flash_state == FLASH_WAIT || r_flash_state == FLASH_END)
			r_page_cnt		<= 16'd0;
	end

	//r_erase_flag
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_erase_flag	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_erase_flag	<= 1'b0;
		else if(r_flash_state == FLASH_ERASE_DELAY)
			r_erase_flag	<= ~r_erase_flag;
	end


			

	//----------------------------------------------------------------------------------------------
	// Power-on read data from flash domain
	//----------------------------------------------------------------------------------------------
	// //r_flash_rdaddr
	// always@(posedge i_clk or negedge i_rst_n) begin
	// 	if(i_rst_n == 0)
	// 		r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;//baseaddr 2M
	// 	else if(r_flash_state == FLASH_IDLE)
	// 		r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
	// 	else if(r_flash_state == FLASH_WAIT && i_load_fact_para)
	// 		r_flash_rdaddr	<= FACT_FLASHBASE_ADDR;
	// 	else if(r_flash_state == FLASH_WAIT && i_ddr2flash_wrsig)begin
	// 		if(i_save_fact_para == 1'b0) begin
	// 			if(i_ddr2flash_addr_base == PARA_DDRBASE_ADDR)
	// 				r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
	// 			else if(i_ddr2flash_addr_base == COE_DDRBASE_ADDR)
	// 				r_flash_rdaddr	<= COE_FLASHBASE_ADDR;
	// 			else
	// 				r_flash_rdaddr	<= PARA_FLASHBASE_ADDR;
	// 		end else if(i_save_fact_para == 1'b1) begin
	// 				r_flash_rdaddr	<= FACT_FLASHBASE_ADDR;
	// 		end	
	// 	end
	// end	

	//r_read_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_read_cnt	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE || r_flash_state == FLASH_READ_DATA)
			r_read_cnt	<= 1'b0;
		else if(r_flash_state == FLASH_READ_ASSIGN)
			r_read_cnt	<= r_read_cnt + 1'b1;
	end

	//r_flash2ddr_wren
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash2ddr_wren	<= 1'b0;
		else if(r_flash_state == FLASH_READ_DATA)
			r_flash2ddr_wren	<= 1'b1;
		else 
			r_flash2ddr_wren	<= 1'b0;
	end

	//r_flash2ddr_addr
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash2ddr_addr	<= {DDR_AW{1'b0}};
		else if(r_flash_state == FLASH_WAIT) begin
			r_flash2ddr_addr	<= {DDR_AW{1'b0}};
		end
		else if(r_flash_state == FLASH_WDDR_ADDR)
			r_flash2ddr_addr	<= r_flash2ddr_addr + 4'd4;
		else if(r_flash_state == FLASH_RDDR_ADDR)
			r_flash2ddr_addr	<= r_flash2ddr_addr + 4'd4;
	end

	//r_flash2ddr_data
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_flash2ddr_data	<= {DDR_DW{1'b0}};
		else if(r_flash_state == FLASH_IDLE)
			r_flash2ddr_data	<= {DDR_DW{1'b0}};
		else if(r_flash_state == FLASH_READ_ASSIGN)
			r_flash2ddr_data	<= {r_flash2ddr_data[DDR_DW-9:0], w_data_out};
	end

	//r_delay_cnt
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_delay_cnt		<= 32'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_delay_cnt		<= 32'd0;
		else if(r_flash_state == FLASH_WRITE_DELAY)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else if(r_flash_state == FLASH_READ_DELAY)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt		<= 32'd0;
	end

	//r_read_complete_sig
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_read_complete_sig	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_read_complete_sig	<= 1'b0;
		else if(r_flash_state == FLASH_READ_DELAY && r_delay_cnt >= 32'd249)
			r_read_complete_sig	<= 1'b1;
		else
			r_read_complete_sig	<= 1'b0;
	end
	
	//----------------------------------------------------------------------------------------------
	// write data from ddr to flash domain
	//----------------------------------------------------------------------------------------------
	//r_ddren_cnt_flash
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddren_cnt_flash   <= 8'd0;
		else if(r_flash_state == FLASH_RDDR_EN)
			r_ddren_cnt_flash   <= r_ddren_cnt_flash + 1'b1;
		else if(r_flash_state == FLASH_WRITE_CMD)
			r_ddren_cnt_flash		<= 8'd0;
    end	

	//r_ddr2flash_rden
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddr2flash_rden	<= 1'b0;
		else if(r_flash_state == FLASH_RDDR_EN)
			r_ddr2flash_rden	<= 1'b1;
		else
			r_ddr2flash_rden	<= 1'b0;
	end	

	//r_ddr2flash_fifo_rden
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_ddr2flash_fifo_rden	<= 1'b0;
		else if(r_flash_state == FLASH_RDFIFO_EN || r_flash_state == FLASH_WRITE_WAIT) begin
			if(~i_ddr2flash_fifo_empty)
				r_ddr2flash_fifo_rden	<= 1'b1;		
		end else
			r_ddr2flash_fifo_rden	<= 1'b0;
	end	
			
	//r_data_in
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_data_in	<= 8'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_data_in	<= 8'd0;
		else if(r_flash_state == FLASH_WRITE_MSB)
			r_data_in	<= i_ddr2flash_fifo_data[15:8];
		else if(r_flash_state == FLASH_WRITE_LSB && w_data_req)
			r_data_in	<= i_ddr2flash_fifo_data[7:0];
		else if(r_flash_state == FLASH_WRITE_ACK && w_data_req)
			r_data_in	<= i_ddr2flash_fifo_data[15:8];
	end

	//r_cmd_ack
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_READ_ACK)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_WRITE_ACK)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_ERASE_ACK)
			r_cmd_ack	<= 1'b0;
		else if(w_cmd_ack)
			r_cmd_ack	<= 1'b1;
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_flash2ddr_wren		= r_flash2ddr_wren;
	assign o_ddr2flash_rden		= r_ddr2flash_rden;
	assign o_flash2ddr_addr		= r_flash2ddr_addr;
	assign o_flash2ddr_data		= r_flash2ddr_data;
	assign o_ddr2flash_fifo_rden= r_ddr2flash_fifo_rden;
	assign o_read_complete_sig	= r_read_complete_sig;
		
	USRMCLK u1 (.USRMCLKI(w_flash_clk), .USRMCLKTS(r_flash_clk_n) /* synthesis syn_noprune=1 */);
	
	spi_flash_top u_spi_flash_top
	(
		.clk			( i_clk					),
		.rst_n			( i_rst_n				),

		.o_spi_cs		( o_flash_cs			),
		.o_spi_dclk		( w_flash_clk			),//(o_flash_clk),
		.o_spi_mosi		( o_flash_mosi			),
		.i_spi_miso		( i_flash_miso			),

		.i_clk_div		( 16'd16				),
		.i_cmd			( r_flash_cmd			),
		.i_cmd_valid	( r_cmd_valid			),
		.o_cmd_ack		( w_cmd_ack				),

		.i_addr			( r_flash_addr			),
		.i_byte_size	( 9'd256				),

		.o_data_req		( w_data_req			),
		.i_data_in		( r_data_in				),
		.o_data_out		( w_data_out			),
		.o_data_valid	( w_data_valid			)
	);

endmodule 