module gp22_control
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
		
	input			i_angle_sync 		,//码盘信号标志，用以标志充电与出光
	input	[15:0]	i_code_angle 		,//角度值
	input	[15:0]	i_zero_angle		,
	input			i_measure_en		,//1 = 调速完成 0 = 调速未完成
	input	[1:0]	i_reso_mode			,//分辨率
	input	[15:0]	i_stop_index		,
	input	[15:0]	i_zero_offset		,
	
	input			i_gp22_init 		,
	input			i_gp22_spi_miso		,
	output			o_gp22_spi_mosi		,
	output			o_gp22_spi_ssn 		,
	output			o_gp22_spi_clk 		,
	output			o_gp22_reset   		,
	
	output			o_apd_err			,

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
	
	reg				r_cmd_tdc_wr	= 1'b0;
	reg				r_cmd_tdc_rd	= 1'b0;
	reg				r_cmd_tdc_byte	= 1'b0;
	reg		[5:0]	r_tdc_num		= 6'd0;
	reg		[7:0]	r_tdc_cmd		= 8'd0;
	reg		[31:0]	r_tdc_wr_data	= 32'd0;
	
	reg		[31:0]	r_msr_state		= 32'd0;
	reg		[31:0]	r_msr_cnt		= 32'd0;
	
	wire	[31:0]	w_tdc_rd_data;
	wire			w_tdc_cmd_done;
	
	reg				r_gp22_init1	= 1'b1;
	reg				r_gp22_init2	= 1'b1;
	
	reg		[2:0]	r_hit1sin		= 3'd0;
	reg		[2:0]	r_hit2sin		= 3'd0;
	
	reg		[15:0]	r_angle_begin	= 16'd0;
	reg		[15:0]	r_zero_angle	= 16'd0;
	
	reg		[7:0]	r_angle_reso = 8'd0;
	wire	[31:0]	w_mult1_result;
	
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
			r_zero_angle <= w_mult1_result[15:0] + i_zero_offset[3:0];
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_gp22_init1		<= 1'b1;
			r_gp22_init2		<= 1'b1;
			end
		else begin
			r_gp22_init1		<= i_gp22_init;
			r_gp22_init2		<= r_gp22_init1;
			end
	
	parameter   	CONFIG0   	= 32'h0004_2400,
					CONFIG1   	= 32'h0149_0000,
					CONFIG1_2 	= 32'h0949_0000,
					CONFIG2   	= 32'hC000_0000,
					CONFIG3   	= 32'h2000_0000,
					CONFIG4   	= 32'h2000_0000,
					CONFIG5   	= 32'h0000_0000,
					CONFIG6   	= 32'h0000_0000;
			
	parameter 		MSR_IDLE        	= 32'b0000_0000_0000_0000_0000_0000_0000_0000,
					MSR_PORH        	= 32'b0000_0000_0000_0000_0000_0000_0000_0010,
					MSR_PORR        	= 32'b0000_0000_0000_0000_0000_0000_0000_0100,
					MSR_DELAY       	= 32'b0000_0000_0000_0000_0000_0000_0000_1000,
					MSR_TESTW       	= 32'b0000_0000_0000_0000_0000_0000_0001_0000,
					MSR_TESTR       	= 32'b0000_0000_0000_0000_0000_0000_0010_0000,
					MSR_DELAY2      	= 32'b0000_0000_0000_0000_0000_0000_0100_0000,
					MSR_CONFIG0     	= 32'b0000_0000_0000_0000_0000_0000_1000_0000,
					MSR_CONFIG1     	= 32'b0000_0000_0000_0000_0000_0001_0000_0000,
					MSR_CONFIG2     	= 32'b0000_0000_0000_0000_0000_0010_0000_0000,
					MSR_CONFIG3     	= 32'b0000_0000_0000_0000_0000_0100_0000_0000,
					MSR_CONFIG4     	= 32'b0000_0000_0000_0000_0000_1000_0000_0000,
					MSR_CONFIG5    		= 32'b0000_0000_0000_0000_0001_0000_0000_0000,
					MSR_CONFIG6     	= 32'b0000_0000_0000_0000_0010_0000_0000_0000,
					MSR_DELAY3      	= 32'b0000_0000_0000_0000_0100_0000_0000_0000,
					MSR_CIDLE       	= 32'b0000_0000_0000_0000_1000_0000_0000_0000,
					MSR_INIT        	= 32'b0000_0000_0000_0001_0000_0000_0000_0000,
					MSR_WAITL2H     	= 32'b0000_0000_0000_0010_0000_0000_0000_0000,
					MSR_WAIT0       	= 32'b0000_0000_0000_0100_0000_0000_0000_0000,
					MSR_RSTAUS      	= 32'b0000_0000_0000_1000_0000_0000_0000_0000,
					MSR_READ        	= 32'b0000_0000_0001_0000_0000_0000_0000_0000,
					MSR_CONFIG1_TWO 	= 32'b0000_0000_0010_0000_0000_0000_0000_0000,
					MSR_WAIT0_TWO   	= 32'b0000_0000_0100_0000_0000_0000_0000_0000,
					MSR_READ_TWO    	= 32'b0000_0000_1000_0000_0000_0000_0000_0000,
					MSR_CONFIG1_TRD 	= 32'b0000_0001_0000_0000_0000_0000_0000_0000,
					MSR_SHIFT        	= 32'b0000_0010_0000_0000_0000_0000_0000_0000,
					MSR_END         	= 32'b0000_0100_0000_0000_0000_0000_0000_0000,
					MSR_CALB        	= 32'b0000_1000_0000_0000_0000_0000_0000_0000,
					MSR_TESTR2      	= 32'b0001_0000_0000_0000_0000_0000_0000_0000,
					MSR_OVER        	= 32'b0010_0000_0000_0000_0000_0000_0000_0000;
			
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
					r_tdc_err_sig		<= 1'b1;
					r_msr_cnt			<= 32'd0;
					r_hit1sin			<= 3'd0;
					r_hit2sin			<= 3'd0;
					r_msr_state			<= MSR_PORH;
					end
				MSR_PORH	:begin
					if(r_msr_cnt >= 32'd1000)begin
						r_tdc_reset			<= 1'b1;
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_PORR;
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
						r_msr_state			<= MSR_TESTW;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_TESTW	:begin
					r_cmd_tdc_wr 		<= 1'b1;
					r_tdc_cmd        	<= 8'h81; //-----------WR CR1 Test
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= 32'hAB00_0000;
					if(w_tdc_cmd_done) begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state        	<= MSR_TESTR;
						end
					end
				MSR_TESTR  	:begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB5; //-----------RD CR1 Test
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00; //-----------RD CR1 Test
						r_tdc_num        	<= 6'd0;
						if(w_tdc_rd_data[31:24]==8'hAB)begin
							r_tdc_err_sig    	<= 1'b0;
							r_msr_state        	<= MSR_DELAY2;
							end
						else 
							r_msr_state        	<= MSR_PORH;
						end
					end
				MSR_DELAY2	:begin
					if(r_msr_cnt >= 32'd100)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_CONFIG0;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_CONFIG0	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h80; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG0;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG1;
						end
					end
				MSR_CONFIG1	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h81; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG1;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG2;
						end
					end
				MSR_CONFIG2	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h82; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG2;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG3;
						end
					end
				MSR_CONFIG3	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h83; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG3;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG4;
						end
					end
				MSR_CONFIG4	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h84; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG4;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG5;
						end
					end
				MSR_CONFIG5	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h85; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG5;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_CONFIG6;
						end
					end
				MSR_CONFIG6	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h86; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG6;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_DELAY3;
						end
					end
				MSR_DELAY3	:begin
					if(r_msr_cnt >= 32'd100)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_CIDLE;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_CIDLE	:begin
					if(i_measure_en && i_code_angle == 16'd0)
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
					if(r_gp22_init2 == 1'b0)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state        	<= MSR_RSTAUS;
						end
					else if(r_msr_cnt >= 32'd174)begin
						r_msr_cnt			<= 32'd0;
						r_rise_data			<= 16'hFFFF;
						r_fall_data			<= 16'hFFFF;
						r_tdc_new_sig		<= 1'b1;
						r_msr_state        	<= MSR_SHIFT;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
					end
				MSR_RSTAUS :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB4;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done) begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_hit2sin        	<= w_tdc_rd_data[24:22];
						r_hit1sin        	<= w_tdc_rd_data[21:19];
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
						if(r_hit1sin >= 3'd1)
							r_rise_data 		<= w_tdc_rd_data[16:1];
						else
							r_rise_data 		<= 16'd0;
						r_msr_state        	<= MSR_CONFIG1_TWO;
						end
					end
				MSR_CONFIG1_TWO	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h81; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG1_2;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_msr_state 		<= MSR_WAIT0_TWO;
						end
					end
				MSR_WAIT0_TWO	:begin
					if(r_msr_cnt >= 32'd99)begin
						r_msr_cnt        	<= 32'd0;	
						r_msr_state        	<= MSR_READ_TWO;
						end
					else 
						r_msr_cnt        	<= r_msr_cnt + 1'b1;
					end
				MSR_READ_TWO:begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB1;
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						if(r_hit2sin >= 3'd1)
							r_fall_data 		<= w_tdc_rd_data[16:1];
						else
							r_fall_data 		<= 16'd0;
						r_msr_state        	<= MSR_CONFIG1_TRD;
						end
					end
				MSR_CONFIG1_TRD	:begin
					r_cmd_tdc_wr      	<= 1'b1;
					r_tdc_cmd        	<= 8'h81; //-----------WR CONFIGRegister 0
					r_tdc_num        	<= 6'd31;
					r_tdc_wr_data     	<= CONFIG1;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_wr      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						r_tdc_wr_data     	<= 32'd0;
						r_tdc_new_sig		<= 1'b1;
						r_msr_state 		<= MSR_SHIFT;
						end
					end
				MSR_SHIFT  :
					r_msr_state 		<= MSR_END;
				MSR_END    :begin
					r_tdc_new_sig 		<= 1'b0;
					r_hit1sin        	<= 3'd0;
					r_hit2sin        	<= 3'd0;
					if(i_code_angle >= 16'd1053)
						r_msr_state        	<= MSR_TESTR2;
					else
						r_msr_state        	<= MSR_INIT;
					end
				MSR_TESTR2 :begin
					r_cmd_tdc_rd      	<= 1'b1;
					r_tdc_cmd        	<= 8'hB5; //-----------RD CR1 Test
					r_tdc_num        	<= 6'd7;
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00; //-----------RD CR1 Test
						r_tdc_num        	<= 6'd0;
						if(w_tdc_rd_data[31:24] == 8'h01)
							r_msr_state        	<= MSR_CALB;
						else begin
							r_tdc_err_sig    	<= 1'b1;
							r_msr_state        	<= MSR_IDLE;
							end
						end
					end		
				MSR_CALB   :begin
					r_cmd_tdc_byte   	<= 1'b1;
					r_tdc_cmd        	<= 8'h04; //--------------Calbration
					if(w_tdc_cmd_done)begin
						r_cmd_tdc_byte   	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_msr_state        	<= MSR_OVER;
						end
					end
				MSR_OVER   :begin
					r_msr_state        	<= MSR_CIDLE;
					end
				default		:r_msr_state        	<= MSR_IDLE;
				endcase
			end
			
	reg		[7:0] r_no_echo_cnt ;
	reg			   r_apd_err ;		
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_no_echo_cnt <= 8'd0;
		else if(i_code_angle >= 16'd1032 && i_code_angle <= 16'd1052)begin
			if(r_msr_state == MSR_END && r_rise_data == 16'd0 && r_fall_data == 16'd0)
				r_no_echo_cnt <= r_no_echo_cnt + 1'd1 ;
			else 
				r_no_echo_cnt <= r_no_echo_cnt ;
		end
		else
			r_no_echo_cnt <= 8'd0 ;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_apd_err <= 1'd0;
		else if(i_code_angle == 16'd1052)begin
			if(r_no_echo_cnt >= 8'd16)
				r_apd_err <= 1'd1;
			else
				r_apd_err <= 1'd0;
			end
		else
			r_apd_err <= r_apd_err ;
			
			
			
			
	//r_pulse_get
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_get		<= 16'd0;
		else if(r_tdc_new_sig )begin
			if(r_fall_data >= r_rise_data)
				r_pulse_get		<= r_fall_data - r_rise_data;
			else
				r_pulse_get		<= r_pulse_get;
			end
			

			
	assign o_rise_data 		= r_rise_data;
	assign o_fall_data 		= r_fall_data;
	assign o_pulse_get		= r_pulse_get;
	assign o_pulse_rise		= r_pulse_rise;
	assign o_pulse_fall		= r_pulse_fall;
	assign o_tdc_new_sig  	= r_tdc_new_sig;
	assign o_tdc_err_sig 	= r_tdc_err_sig;

	assign o_gp22_reset		= r_tdc_reset;
	
	assign o_apd_err 		= r_apd_err ;	
				
	gp22_spi U1
	(
		.clk           	(i_clk_50m),
		.SPI_SO        	(i_gp22_spi_miso),
		.CMD_TDCwr     	(r_cmd_tdc_wr),
		.CMD_TDCrd     	(r_cmd_tdc_rd),
		.CMD_TDC1byte  	(r_cmd_tdc_byte),
		.TDC_CMD       	(r_tdc_cmd),
		.TDC_Num       	(r_tdc_num),
		.TDC_WRdata    	(r_tdc_wr_data),
		
		.SPI_SCK       	(o_gp22_spi_clk),
		.SPI_SSN       	(o_gp22_spi_ssn),
		.SPI_SI        	(o_gp22_spi_mosi),
		.TDC_CMDack    	(          ),
		.TDC_RDdata    	(w_tdc_rd_data),
		.TDC_CMDdone   	(w_tdc_cmd_done)
	);		
	
	multiplier U2
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				({4'd0,i_zero_offset[15:4]}), 
		.DataB				({8'd0,r_angle_reso}), 
		.Result				(w_mult1_result)
	);

endmodule 