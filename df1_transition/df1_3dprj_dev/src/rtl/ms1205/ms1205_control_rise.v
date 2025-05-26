// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: ms1205_control_rise
// Date Created 	: 2023/08/15 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:ms1205_control_rise
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module ms1205_control_rise
(
	input				i_clk_50m,
	input				i_rst_n,
		
	input				i_angle_sync/*synthesis PAP_MARK_DEBUG="true"*/,
	input				i_motor_state/*synthesis PAP_MARK_DEBUG="true"*/,
	
	input				i_tdc_init/*synthesis PAP_MARK_DEBUG="true"*/,
	input				i_tdc_spi_miso,
	output				o_tdc_spi_mosi,
	output				o_tdc_spi_ssn,
	output				o_tdc_spi_clk,
	output				o_tdc_reset,

	output [15:0]		o_rise_data,
	output				o_tdc_err_sig,
	output				o_tdc_new_sig		
);
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg [15:0]			r_rise_data		= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_tdc_new_sig	=  1'b0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_tdc_err_sig	=  1'b1/*synthesis PAP_MARK_DEBUG="true"*/;
	reg					r_tdc_reset		=  1'b1/*synthesis PAP_MARK_DEBUG="true"*/;

	reg					r_cmd_tdc_wr	= 1'b0;
	reg					r_cmd_tdc_rd	= 1'b0;
	reg					r_cmd_tdc_byte	= 1'b0;
	reg [5:0]			r_tdc_num		= 6'd0;
	reg [7:0]			r_tdc_cmd		= 8'd0;
	reg [31:0]			r_tdc_wr_data	= 32'd0;

	reg [7:0]			r_msr_state		= 8'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg [15:0]			r_msr_cnt		= 16'd0/*synthesis PAP_MARK_DEBUG="true"*/;

	reg [7:0]			r_tdc_config	= 8'hD0;
	reg					r_tdc_init1		= 1'b1;
	reg					r_tdc_init2		= 1'b1;
	reg [23:0]			r_tdc_state		= 24'd0;
	reg [23:0]			r_cal_time 		= 24'd0;

	reg          		r_tdc_reset_sig = 1'b0;
	reg	[7:0]			r_error_cnt 	= 8'd0/*synthesis PAP_MARK_DEBUG="true"*/;
	reg	[15:0]			r_sig_cnt 		= 16'd0;
	reg	[15:0]			r_sig_cnt_reg 	= 16'd0;
	reg	[15:0]			r_sig_cnt2 		= 16'd0;
	reg					r_reset_flag 	= 1'b0;
	reg					r_tdc_new_sig2 	= 1'b0;

	wire [31:0]			w_tdc_rd_data;
	wire				w_tdc_cmd_done;

	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------		
	localparam  	TDC_REG_CONFIG   	= 32'h025F_2090;
	parameter 		MSR_IDLE        	= 8'd0,
					MSR_PORH        	= 8'd1,
					MSR_PORR        	= 8'd2,
					MSR_DELAY       	= 8'd3,
					MSR_CONFIG	     	= 8'd4,
					MSR_DELAY2      	= 8'd5,
					MSR_READ_CONFIG		= 8'd6,					
					MSR_CIDLE       	= 8'd7,
					MSR_INIT        	= 8'd8,
					MSR_DELAY4        	= 8'd9,					
					MSR_WAITL2H     	= 8'd10,
					MSR_WAIT0       	= 8'd11,
					MSR_READ        	= 8'd12,
					MSR_DELAY3      	= 8'd13,
					MSR_END         	= 8'd14,
					MSR_OVER        	= 8'd15;

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)begin
			r_tdc_init1		<= 1'b1;
			r_tdc_init2		<= 1'b1;
		end else begin
			r_tdc_init1		<= i_tdc_init;
			r_tdc_init2		<= r_tdc_init1;
		end
	end		
					
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_msr_state			<= MSR_IDLE;
		else if(r_tdc_reset_sig)
			r_msr_state			<= MSR_IDLE;
		else begin
			case(r_msr_state)
				MSR_IDLE	:begin
					r_tdc_reset			<= 1'b1;
					r_cmd_tdc_wr		<= 1'b0;
					r_cmd_tdc_rd		<= 1'b0;
					r_cmd_tdc_byte		<= 1'b0;
					r_tdc_num			<= 6'd0;
					r_tdc_cmd			<= 8'd0;
					r_tdc_wr_data		<= 32'd0;
					r_rise_data			<= 16'd0;
					r_tdc_new_sig		<= 1'b0;
					r_tdc_err_sig		<= 1'b0;
					r_msr_cnt			<= 16'd0;
					r_tdc_state			<= 24'd0;
					r_tdc_config		<= 8'h90;
					r_error_cnt			<= 8'd0;
					r_msr_state			<= MSR_PORH;
					end
				MSR_PORH	:begin
					if(r_msr_cnt >= 16'd9)begin
						r_msr_cnt			<= 16'd0;
						r_msr_state			<= MSR_PORR;
						end
					else if(r_msr_cnt >= 16'd4)begin
						r_tdc_reset			<= 1'b1;
						r_msr_cnt			<= r_msr_cnt + 1'b1;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_PORR	:begin
					r_cmd_tdc_byte		<= 1'b1;
					r_tdc_cmd        	<= 8'h50;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_byte		<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_msr_state			<= MSR_DELAY;
						end
					end
				MSR_DELAY	:begin
					if(r_msr_cnt >= 16'd10)begin
						r_msr_cnt			<= 16'd0;
						r_msr_state			<= MSR_CONFIG;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_CONFIG	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h80; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= TDC_REG_CONFIG;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_DELAY2;
						end
					end
				MSR_DELAY2	:begin
					if(r_msr_cnt >= 16'd20)begin
						r_msr_cnt			<= 16'd0;
						r_msr_state			<= MSR_READ_CONFIG;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_READ_CONFIG: begin					
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hBC;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done) begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						if(w_tdc_rd_data[31:24] != 8'h90)
							r_tdc_err_sig		<= 1'b1;
						else
							r_tdc_err_sig		<= 1'b0;
						r_msr_state        	<= MSR_CIDLE;
					end
				end
				MSR_CIDLE	:begin
					if(i_motor_state)
						r_msr_state			<= MSR_INIT;
					end
				MSR_INIT	:begin
					r_cmd_tdc_byte   	<= 1'b1;
					r_tdc_cmd        	<= 8'h70;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_byte   	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_msr_state        	<= MSR_DELAY4;
						end
					end
				MSR_DELAY4	:begin
					if(r_msr_cnt >= 16'd10)begin
						r_msr_cnt			<= 16'd0;
						r_msr_state			<= MSR_WAITL2H;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end				
				MSR_WAITL2H	:begin
					if(i_angle_sync)
						r_msr_state        	<= MSR_WAIT0;
					end
				MSR_WAIT0	:begin
					if(r_tdc_init2 == 1'b0)begin
						r_msr_cnt			<= 16'd0;
						r_msr_state        	<= MSR_READ;
						end
					else if(r_msr_cnt >= 16'd299)begin
						r_msr_cnt			<= 16'd0;
						r_rise_data			<= 16'hFFFF;
						r_tdc_new_sig		<= 1'b1;					
						r_msr_state        	<= MSR_DELAY3;
						end 
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end				
				MSR_READ   :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB0;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_tdc_new_sig 		<= 1'b1;
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_rise_data 		<= w_tdc_rd_data[24:9];
						r_msr_state        	<= MSR_DELAY3;
						end
					end			
				MSR_DELAY3 :begin
					if(r_rise_data == 16'hFFFF)
						r_error_cnt			<= r_error_cnt + 1'b1;
					else
						r_error_cnt			<= 8'd0;
					r_msr_state        	<= MSR_END;
					end
				MSR_END    :begin
					r_tdc_new_sig 		<= 1'b0;
					r_tdc_state        	<= 24'd0;
					r_msr_state        	<= MSR_OVER;
					end	
				MSR_OVER   :begin
					r_msr_state        	<= MSR_WAITL2H;
					end
				default		:r_msr_state        	<= MSR_IDLE;
				endcase
			end

	//r_tdc_reset_sig
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)	
			r_tdc_reset_sig	<= 1'b0;
		else if(r_msr_state	== MSR_IDLE)
			r_tdc_reset_sig	<= 1'b0;
		else if(r_error_cnt >= 8'd50)
			r_tdc_reset_sig	<= 1'b1;
	end	

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_reset_flag	<= 1'b0;
		else if(r_tdc_reset_sig)
			r_reset_flag	<= 1'b1;
		else if(r_msr_state	== MSR_WAITL2H && i_angle_sync)
			r_reset_flag	<= 1'b0;
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_sig_cnt	<= 16'd0;
		else if(r_msr_state	== MSR_DELAY3)
			r_sig_cnt	<= 16'd0;
		else
			r_sig_cnt	<= r_sig_cnt + 1'b1;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_sig_cnt_reg	<= 16'd0;
		else if(r_msr_state	== MSR_DELAY3)
			r_sig_cnt_reg	<= r_sig_cnt;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_sig_cnt2	<= 16'd0;
		else if(r_sig_cnt2 >= r_sig_cnt_reg)
			r_sig_cnt2	<= 16'd0;
		else if(r_reset_flag)
			r_sig_cnt2	<= r_sig_cnt2 + 1'b1;
		else
			r_sig_cnt2	<= 16'd0;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_tdc_new_sig2	<= 1'b0;
		else if(r_sig_cnt2 + 1'b1 >= r_sig_cnt_reg)
			r_tdc_new_sig2	<= 1'b1;
		else
			r_tdc_new_sig2	<= 1'b0;
	end

	assign o_rise_data 		= r_rise_data << 1'd1;
	assign o_tdc_new_sig  	= (r_reset_flag)?r_tdc_new_sig2:r_tdc_new_sig;
	assign o_tdc_err_sig 	= r_tdc_err_sig;
	assign o_tdc_reset		= r_tdc_reset;
				
	TDC_SPI_ms1004_2 u1
	(
		.clk           	( i_clk_50m				),
		.i_rst_n		( i_rst_n				),
		
		.CMD_TDCwr     	( r_cmd_tdc_wr			),
		.CMD_TDCrd     	( r_cmd_tdc_rd			),
		.CMD_TDC1byte  	( r_cmd_tdc_byte		),
		.TDC_CMD       	( r_tdc_cmd				),
		.TDC_Num       	( r_tdc_num				),
		.TDC_WRdata    	( r_tdc_wr_data			),
		
		.SPI_SCK       	( o_tdc_spi_clk			),
		.SPI_SSN       	( o_tdc_spi_ssn			),
		.SPI_SI        	( o_tdc_spi_mosi		),
		.SPI_SO        	( i_tdc_spi_miso		),
		.TDC_CMDack    	(           			),
		.TDC_RDdata    	( w_tdc_rd_data			),
		.TDC_CMDdone   	( w_tdc_cmd_done		)
	);

endmodule 