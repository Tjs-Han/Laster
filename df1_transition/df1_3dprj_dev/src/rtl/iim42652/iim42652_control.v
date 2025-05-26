// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: iim42652_control
// Date Created 	: 2024/08/21 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:iim42652_control
//				SPI Operational Features
//				1. Data is delivered MSB first and LSB last
//				2. Data is latched on the rising edge of SCLK
//				3. Data should be transitioned on the falling edge of SCLK
//				4. The maximum frequency of SCLK is 24 MHz
//				5. SPI read operations are completed in 16 or more clock cycles (two or more bytes). The first byte contains
//				the SPI Address, and the following byte(s) contain(s) the SPI data. The first bit of the first byte contains the
//				Read/Write bit and indicates the Read (1) operation. The following 7 bits contain the Register Address. In
//				cases of multiple-byte Reads, data is two or more bytes
//						SPI Address format + SPI Data format	
//							
//		| MSB | ----------------------------| LSB| | MSB| ----------------------------| LSB|
//		| R/W | A6 | A5 | A4 | A3 | A2 | A1 | A0 | | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 |
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
`include "iim42652_reg_map.v"
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module iim42652_control
#(
	parameter IIM_CLK_DIV_NUM	= 2
)
(
	input					i_clk,
	input					i_rst_n,

	input					i_angle_sync,
	
	output 					o_spi_cs,
	output  				o_spi_dclk,
	output					o_spi_mosi,
	input					i_spi_miso
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
	localparam IIM_MODEN_DLYCNT		= 32'd2500_000;//50M clk~50ms
	// localparam IIM_MODEN_DLYCNT		= 32'd250_000_000;//50M clk~5s
	localparam IIM_KKEPON_DLYCNT	= 32'd2500_000;//50M clk~50ms
	localparam IIM_OPCODE			= 8'h0;
	localparam IIM_BANK_SEL0		= 8'h0;
	localparam IIM_BANK_SEL1		= 8'h1;
	localparam IIM_BANK_SEL2		= 8'h2;
	localparam IIM_BANK_SEL3		= 8'h3;

	localparam IIM_GYRO_CONFIG0		= 8'h06;
	localparam IIM_ACCEL_CONFIG0	= 8'h06;

	localparam ST_IDLE        		= 8'd0;
	localparam ST_BANK_SEL        	= 8'd1;
	localparam ST_GYRO_WRCFG0		= 8'd2;
	localparam ST_ACCEL_WRCFG0		= 8'd3;
	localparam ST_GYRO_RDCFG0		= 8'd4;
	localparam ST_ACCEL_RDCFG0		= 8'd5;
	localparam ST_PWRON				= 8'd6;
	localparam ST_GYRO_KEEPON		= 8'd7;
	localparam ST_WAIT				= 8'd8;
	localparam ST_IIM_RDATA			= 8'd9;			
	localparam ST_RDATA_DONE		= 8'd10;					
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
	reg [7:0]	    r_curr_state			= ST_IDLE;
    reg [7:0]	    r_next_state			= ST_IDLE;
	reg				r_regcfg_valid			= 1'b0;
	reg				r_iim_moden				= 1'b0;
	reg [31:0]		r_moden_dlycnt			= 32'd0;
	reg	 			r_wr_req				= 1'b1;
	wire			w_spicom_ready;		
	wire 			w_wr_ack;			
	reg  [7:0]		r_gyroreg_data			= 8'h0;
	reg  [7:0]		r_accreg_data			= 8'h0;
	reg	 [6:0]		r_iim_regaddr			= `ACCX_DATA_MSB;
	reg  [15:0]  	r_spi_wdata				= 16'h0;
	reg  [95:0]		r_iim_data				= 96'h0;
	wire 			w_rdata_valid;
	wire [7:0]		w_spi_rdata;
	reg  [19:0]		r_pwron_dlycnt			= 20'd0;
	reg  [31:0]		r_gyro_keepon_dlycnt	= 32'd0;
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_iim_moden 	<= 1'b0;
			r_moden_dlycnt	<= 32'd0;
		end else if(r_moden_dlycnt >= IIM_MODEN_DLYCNT) begin
            r_iim_moden 	<= 1'b1;
			r_moden_dlycnt	<= r_moden_dlycnt;
		end else begin
			r_iim_moden 	<= 1'b0;
			r_moden_dlycnt	<= r_moden_dlycnt + 1'b1;
		end
    end
	//--------------------------------------------------------------------------------------------------
	/*
		The only register settings that user can modify during sensor operation are for ODR selection, FSR selection, and
		sensor mode changes (register parameters GYRO_ODR, ACCEL_ODR, GYRO_FS_SEL, ACCEL_FS_SEL, GYRO_MODE, ACCEL_MODE). 
		User must not modify any other register values during sensor operation. The following procedure must be used for 
		other register values modification.
		1、Turn Accel and Gyro Off
		2、Modify register values
		3、Turn Accel and/or Gyro On

		Gyroscope needs to be kept ON for a minimum of 45ms. 
		When transitioning from OFF to any of the other modes,do not issue any register writes for 200µs.
	*/
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_curr_state <= ST_IDLE;
		else 
            r_curr_state <= r_next_state;
    end

    always@(*) begin
        case(r_curr_state)
            ST_IDLE: begin
				if(r_iim_moden)
					r_next_state = ST_BANK_SEL;
				else
					r_next_state = ST_IDLE;
			end
            ST_BANK_SEL: begin
                if(w_wr_ack)
                    r_next_state = ST_GYRO_WRCFG0;
                else
                    r_next_state = ST_BANK_SEL;  
            end
            ST_GYRO_WRCFG0: begin
                if(w_wr_ack)
                    r_next_state = ST_ACCEL_WRCFG0;
                else    
                    r_next_state = ST_GYRO_WRCFG0;
            end
            ST_ACCEL_WRCFG0: begin
                if(w_wr_ack)
                    r_next_state = ST_GYRO_RDCFG0;
                else    
                    r_next_state = ST_ACCEL_WRCFG0;
            end
            ST_GYRO_RDCFG0: begin
                if(w_wr_ack)
                    r_next_state = ST_ACCEL_RDCFG0;
                else    
                    r_next_state = ST_GYRO_RDCFG0;
            end
			ST_ACCEL_RDCFG0: begin
                if(w_wr_ack)
                    r_next_state = ST_PWRON;
                else    
                    r_next_state = ST_ACCEL_RDCFG0;
            end
			ST_PWRON: begin
				if(w_wr_ack)
                    r_next_state = ST_GYRO_KEEPON;
                else    
                    r_next_state = ST_PWRON;
			end
			ST_GYRO_KEEPON: begin
				if(r_gyro_keepon_dlycnt >= IIM_KKEPON_DLYCNT)
					r_next_state = ST_WAIT;
				else
					r_next_state = ST_GYRO_KEEPON;
			end
			ST_WAIT: begin
                if(i_angle_sync)
                    r_next_state = ST_IIM_RDATA;
                else    
                    r_next_state = ST_WAIT;
            end
			ST_IIM_RDATA: begin
				if(r_iim_regaddr >= (`GYROZ_DATA_LSB + 1))
					r_next_state = ST_RDATA_DONE;
                else    
                    r_next_state = ST_IIM_RDATA;
			end
			ST_RDATA_DONE: r_next_state = ST_WAIT;
            default: r_next_state = ST_IDLE;
        endcase
    end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_wr_req				<= 1'b0;
			r_spi_wdata				<= 16'h00;
			r_gyroreg_data			<= 8'h0;
			r_accreg_data			<= 8'h0;
			r_gyro_keepon_dlycnt	<= 32'd0;
			r_iim_regaddr			<= 	`ACCX_DATA_MSB;
			r_iim_data				<= 96'h0;
		end else begin
            case (r_curr_state)
                ST_IDLE: begin
					r_wr_req				<= 1'b0;
					r_spi_wdata				<= 16'h00;
					r_gyroreg_data			<= 8'h0;
					r_accreg_data			<= 8'h0;
					r_gyro_keepon_dlycnt	<= 32'd0;
					r_iim_regaddr			<= 	`ACCX_DATA_MSB;
					r_iim_data				<= 96'h0;
				end
				ST_BANK_SEL: begin
					r_spi_wdata	<= {`WR_REG_FLAG, `BANK_SEL, IIM_BANK_SEL0};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
				end
				ST_GYRO_WRCFG0: begin
					r_spi_wdata	<= {`WR_REG_FLAG, `GYRO_CFG0, IIM_GYRO_CONFIG0};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
				end
				ST_ACCEL_WRCFG0: begin
					r_spi_wdata	<= {`WR_REG_FLAG, `ACCEL_CFG0, IIM_ACCEL_CONFIG0};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
				end
				ST_GYRO_RDCFG0: begin
					r_spi_wdata	<= {`RD_REG_FLAG, `GYRO_CFG0, IIM_OPCODE};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
					if(w_rdata_valid)
						r_gyroreg_data	<= w_spi_rdata;
					else
						r_gyroreg_data	<= r_gyroreg_data;
				end
				ST_ACCEL_RDCFG0: begin
					r_spi_wdata	<= {`RD_REG_FLAG, `ACCEL_CFG0, IIM_OPCODE};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
					if(w_rdata_valid)
						r_accreg_data	<= w_spi_rdata;
					else
						r_accreg_data	<= r_accreg_data;
				end
				ST_PWRON: begin
					r_spi_wdata	<= {`WR_REG_FLAG, `PWR_MGMT0, 8'h0f};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
				end
				ST_GYRO_KEEPON: begin
					if(r_gyro_keepon_dlycnt >= IIM_KKEPON_DLYCNT)
						r_gyro_keepon_dlycnt	<= 32'd0;
					else
						r_gyro_keepon_dlycnt <= r_gyro_keepon_dlycnt + 1'b1;
				end
				ST_WAIT: begin
					r_wr_req		<= 1'b0;
					r_iim_regaddr	<= 	`ACCX_DATA_MSB;
					r_spi_wdata		<= 16'h00;
				end
				ST_IIM_RDATA: begin
					if(w_rdata_valid) begin
						r_iim_regaddr	<= r_iim_regaddr + 1'b1;
						r_iim_data		<= {r_iim_data[87:0], w_spi_rdata};
					end else begin
						r_iim_data		<= r_iim_data;
						r_iim_regaddr	<= r_iim_regaddr;
					end
					r_spi_wdata	<= {`RD_REG_FLAG, r_iim_regaddr, 8'h00};
					if(w_spicom_ready)
						r_wr_req	<= 1'b1;
					else
						r_wr_req	<= 1'b0;
					
				end
				ST_RDATA_DONE: begin
					r_iim_data		<= r_iim_data;
					r_wr_req		<= 1'b0;
					r_iim_regaddr	<= 	`ACCX_DATA_MSB;
					r_spi_wdata		<= 16'h00;
				end
				default: begin
					r_wr_req	<= 1'b0;
					r_spi_wdata	<= 16'h00;
				end
			endcase
		end
    end
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	//r_regcfg_valid
	always@(posedge i_clk or negedge i_rst_n) begin
		if(~i_rst_n) 
			r_regcfg_valid	<= 1'b0;
		else if(r_curr_state == ST_PWRON) begin
			if(r_gyroreg_data == IIM_GYRO_CONFIG0 && r_accreg_data == IIM_ACCEL_CONFIG0)
				r_regcfg_valid	<= 1'b1;
			else
				r_regcfg_valid	<= 1'b0;
		end else
			r_regcfg_valid	<= r_regcfg_valid;
	end
	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------
	iim_spi_master #(
        .IIM_CLK_DIV_NUM	( IIM_CLK_DIV_NUM		)
    )
	u_iim_spi_master
	(
		.i_clk 				( i_clk					),
		.i_rst_n			( i_rst_n 				),

		.o_spi_cs			( o_spi_cs 				),
		.o_spi_dclk			( o_spi_dclk 			),
		.o_spi_mosi			( o_spi_mosi 			),
		.i_spi_miso			( i_spi_miso 			),

		.i_wr_req			( r_wr_req 				),
		.o_spicom_ready		( w_spicom_ready		),
		.o_wr_ack			( w_wr_ack 				),
		.i_spi_wdata		( r_spi_wdata 			),
		.o_rdata_valid		( w_rdata_valid			),
		.o_data_out			( w_spi_rdata 			)
	);

endmodule 