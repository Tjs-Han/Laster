module tdc_control
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
		
	input			i_angle_sync 		,//码盘信号标志，用以标志充电与出光
	input	[15:0]	i_code_angle 		,//角度值
	input			i_measure_en		,//1 = 调速完成 0 = 调速未完成
	input	[1:0]	i_reso_mode			,//分辨率
	input	[15:0]	i_stop_index		,
	input	[15:0]	i_zero_offset		,
	
	input			i_tdc_init 			,
	input			i_tdc_spi_miso		,
	output			o_tdc_spi_mosi		,
	output			o_tdc_spi_ssn 		,
	output			o_tdc_spi_clk 		,
	output			o_tdc_reset   		,

	output	[15:0]	o_rise_data			,//上升沿
	output	[15:0]	o_fall_data			,//下降沿
	output	[15:0]	o_pulse_get			,
	output	[15:0]	o_pulse_rise		,
	output	[15:0]	o_pulse_fall		,
	output			o_tdc_err_sig		,
	output			o_tdc_new_sig		
);

	reg		[15:0]	r_rise_data		= 16'd0;
	reg		[15:0]	r_fall_data		= 16'd0;
	reg		[15:0]	r_pulse_get		= 16'd0;
	reg		[15:0]	r_pulse_rise	= 16'd0;
	reg		[15:0]	r_pulse_fall	= 16'd0;
	reg				r_tdc_new_sig	= 1'b0;
	reg				r_tdc_err_sig	= 1'b1;
	reg				r_tdc_reset		= 1'b1;
	
	reg		[15:0]	r_zero_angle	= 16'd0;
	
	reg				r_cmd_tdc_wr	= 1'b0;
	reg				r_cmd_tdc_rd	= 1'b0;
	reg				r_cmd_tdc_byte	= 1'b0;
	reg		[5:0]	r_tdc_num		= 6'd0;
	reg		[7:0]	r_tdc_cmd		= 8'd0;
	reg		[31:0]	r_tdc_wr_data	= 32'd0;
	
	reg		[19:0]	r_msr_state		= 20'd0;
	reg		[31:0]	r_msr_cnt		= 32'd0;
	
	wire	[31:0]	w_tdc_rd_data;
	wire			w_tdc_cmd_done;
	
	reg				r_tdc_init1		= 1'b1;
	reg				r_tdc_init2	= 1'b1;
	
	reg		[23:0]	r_tdc_state		= 24'd0;
	
	reg		[15:0]	r_angle_begin		= 16'd0;
	
	reg	[7:0]	r_angle_reso = 8'd0;
	wire[15:0]	w_mult1_result;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso	<= 8'd0;
		else begin
			case(i_reso_mode)
				2'd0:r_angle_reso <= 8'd5;
				2'd1:r_angle_reso <= 8'd4;
				2'd2:r_angle_reso <= 8'd3;
				2'd3:r_angle_reso <= 8'd2;
				endcase
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_zero_angle <= 16'd0;
		else 
			r_zero_angle <= w_mult1_result + i_zero_offset[7:0];
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_begin		<= 16'd1053;
		else if(i_reso_mode == 2'd0)
			r_angle_begin   	<= 16'd1755;
		else if(i_reso_mode == 2'd1)
			r_angle_begin   	<= 16'd1404;
		else if(i_reso_mode == 2'd2)
			r_angle_begin   	<= 16'd1053;
		else if(i_reso_mode == 2'd3)
			r_angle_begin 		<= 16'd702;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_tdc_init1		<= 1'b1;
			r_tdc_init2		<= 1'b1;
			end
		else begin
			r_tdc_init1		<= i_tdc_init;
			r_tdc_init2		<= r_tdc_init1;
			end
	
	parameter   	CONFIG   	= 32'h224A_2450;//32'h22021250;//32'h222A_2450;
			
	parameter 		MSR_IDLE        	= 20'b0000_0000_0000_0000_0000,
					MSR_PORH        	= 20'b0000_0000_0000_0000_0010,
					MSR_PORR        	= 20'b0000_0000_0000_0000_0100,
					MSR_DELAY       	= 20'b0000_0000_0000_0000_1000,
					MSR_CONFIG	     	= 20'b0000_0000_0000_0001_0000,
					MSR_DELAY2      	= 20'b0000_0000_0000_0010_0000,
					MSR_CIDLE       	= 20'b0000_0000_0000_0100_0000,
					MSR_INIT        	= 20'b0000_0000_0000_1000_0000,
					MSR_WAITL2H     	= 20'b0000_0000_0001_0000_0000,
					MSR_WAIT0       	= 20'b0000_0000_0010_0000_0000,
					MSR_RSTAUS      	= 20'b0000_0000_0100_0000_0000,
					MSR_READ        	= 20'b0000_0000_1000_0000_0000,
					MSR_READ2       	= 20'b0000_0001_0000_0000_0000,
					MSR_END         	= 20'b0000_0010_0000_0000_0000,
					MSR_CALB        	= 20'b0000_0100_0000_0000_0000,
					MSR_DELAY3      	= 20'b0000_1000_0000_0000_0000,
					MSR_OVER        	= 20'b0001_0000_0000_0000_0000;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
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
					r_fall_data			<= 16'd0;
					r_tdc_new_sig		<= 1'b0;
					r_tdc_err_sig		<= 1'b0;
					r_msr_cnt			<= 32'd0;
					r_tdc_state			<= 24'd0;
					r_msr_state			<= MSR_PORH;
					end
				MSR_PORH	:begin
					if(r_msr_cnt >= 32'd1000)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_PORR;
						end
					else if(r_msr_cnt >= 32'd600)begin
						r_tdc_reset			<= 1'b1;
						r_msr_cnt			<= r_msr_cnt + 1'b1;
						end
					else if(r_msr_cnt >= 32'd500)begin
						r_tdc_reset			<= 1'b0;
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
					if(r_msr_cnt >= 32'd100_000)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_CONFIG;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_CONFIG	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h80; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_DELAY2;
						end
					end
				MSR_DELAY2	:begin
					if(r_msr_cnt >= 32'd100)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_CIDLE;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_CIDLE	:begin
					if(i_measure_en && i_code_angle == r_angle_begin)
						r_msr_state			<= MSR_INIT;
					end
				MSR_INIT	:begin
					r_cmd_tdc_byte   	<= 1'b1;
					r_tdc_cmd        	<= 8'h70;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_byte   	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_msr_state        	<= MSR_WAITL2H;
						end
					end
				MSR_WAITL2H	:begin
					if(i_angle_sync)
						r_msr_state        	<= MSR_WAIT0;
					end
				MSR_WAIT0	:begin
					if(r_tdc_init2 == 1'b0)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state        	<= MSR_RSTAUS;
						end
					else if(r_msr_cnt >= 32'd349)begin
						r_msr_cnt			<= 32'd0;
						r_rise_data			<= 16'd0;
						r_fall_data			<= 16'd0;
						r_tdc_new_sig		<= 1'b1;
						r_msr_state        	<= MSR_DELAY3;
						end 
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_RSTAUS :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hBD;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done) begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_state			<= w_tdc_rd_data[31:8];
						r_msr_state        	<= MSR_READ;
						end
					end
				MSR_READ   :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB0;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						if(r_tdc_state[8:5] > 4'd0)
							r_rise_data 		<= w_tdc_rd_data[24:9];
						else
							r_rise_data 		<= 16'd0;
						r_msr_state        	<= MSR_READ2;
						end
					end
				MSR_READ2  :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hC0;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_new_sig		<= 1'b1;
						if(r_tdc_state[12:9] > 4'd0)
							r_fall_data 		<= w_tdc_rd_data[24:9];
						else
							r_fall_data 		<= 16'd0;
						r_msr_state        	<= MSR_DELAY3;
						end
					end
				MSR_DELAY3 :begin
					r_msr_state        	<= MSR_END;
					end
				MSR_END    :begin
					r_tdc_new_sig 		<= 1'b0;
					r_tdc_state        	<= 24'd0;
					if(i_code_angle >= i_stop_index + 4'd10)
						r_msr_state        	<= MSR_OVER;
					else
						r_msr_state        	<= MSR_INIT;
					end	
				MSR_OVER   :begin
					r_msr_state        	<= MSR_CIDLE;
					end
				default		:r_msr_state        	<= MSR_IDLE;
				endcase
			end
			
	//r_pulse_get
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_get		<= 16'd0;
		else if(r_tdc_new_sig && i_code_angle == r_zero_angle)
			r_pulse_get		<= r_fall_data - r_rise_data;
			
	//r_pulse_rise
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_rise		<= 16'd0;
		else if(r_tdc_new_sig && i_code_angle == r_zero_angle)
			r_pulse_rise		<= r_rise_data;
			
	//r_pulse_fall
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_fall		<= 16'd0;
		else if(r_tdc_new_sig && i_code_angle == r_zero_angle)
			r_pulse_fall		<= r_fall_data;
			
	assign o_rise_data 		= r_rise_data;
	assign o_fall_data 		= r_fall_data;
	assign o_pulse_get		= r_pulse_get;
	assign o_pulse_rise		= r_pulse_rise;
	assign o_pulse_fall		= r_pulse_fall;
	assign o_tdc_new_sig  	= r_tdc_new_sig;
	assign o_tdc_err_sig 	= r_tdc_err_sig;

	assign o_tdc_reset		= r_tdc_reset;
				
	TDC_SPI_ms1004_2 U1
	(
		.clk           	(i_clk_50m),
		.i_rst_n		(i_rst_n),
		.SPI_SO        	(i_tdc_spi_miso),
		.CMD_TDCwr     	(r_cmd_tdc_wr),
		.CMD_TDCrd     	(r_cmd_tdc_rd),
		.CMD_TDC1byte  	(r_cmd_tdc_byte),
		.TDC_CMD       	(r_tdc_cmd),
		.TDC_Num       	(r_tdc_num),
		.TDC_WRdata    	(r_tdc_wr_data),
		
		.SPI_SCK       	(o_tdc_spi_clk),
		.SPI_SSN       	(o_tdc_spi_ssn),
		.SPI_SI        	(o_tdc_spi_mosi),
		.TDC_CMDack    	(          ),
		.TDC_RDdata    	(w_tdc_rd_data),
		.TDC_CMDdone   	(w_tdc_cmd_done)
	);			
	multiplier3 U2
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(i_zero_offset[15:8]), 
		.DataB				(r_angle_reso), 
		.Result				(w_mult1_result)
	);


endmodule 