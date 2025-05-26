module ms1004_control_fall
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
		
	input			i_angle_sync 		,//码盘信号标志，用以标志充电与出光
	
	input			i_tdc_init 			,
	input			i_tdc_spi_miso		,
	output			o_tdc_spi_mosi		,
	output			o_tdc_spi_ssn 		,
	output			o_tdc_spi_clk 		,
	output			o_tdc_reset   		,

	output	[15:0]	o_fall_data			,//上升沿
	output			o_tdc_err_sig		,
	output			o_tdc_new_sig		
);

	reg		[15:0]	r_fall_data		= 16'd0;
	reg				r_tdc_new_sig	= 1'b0;
	reg				r_tdc_err_sig	= 1'b1;
	reg				r_tdc_reset		= 1'b1;
	
	reg				r_cmd_tdc_wr	= 1'b0;
	reg				r_cmd_tdc_rd	= 1'b0;
	reg				r_cmd_tdc_byte	= 1'b0;
	reg		[5:0]	r_tdc_num		= 6'd0;
	reg		[7:0]	r_tdc_cmd		= 8'd0;
	reg		[31:0]	r_tdc_wr_data	= 32'd0;
	
	reg		[11:0]	r_msr_state		= 12'd0;
	reg		[31:0]	r_msr_cnt		= 32'd0;
	
	wire	[31:0]	w_tdc_rd_data;
	wire			w_tdc_cmd_done;
	
	reg				r_tdc_init1		= 1'b1;
	reg				r_tdc_init2		= 1'b1;
	
	reg		[23:0]	r_tdc_state		= 24'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_tdc_init1		<= 1'b1;
			r_tdc_init2		<= 1'b1;
			end
		else begin
			r_tdc_init1		<= i_tdc_init;
			r_tdc_init2		<= r_tdc_init1;
			end
	
	parameter   	CONFIG   	= 32'h024A_2250;//32'h22021250;//32'h222A_2450;
			
	parameter 		MSR_IDLE        	= 12'b0000_0000_0000,
					MSR_PORH        	= 12'b0000_0000_0010,
					MSR_PORR        	= 12'b0000_0000_0100,
					MSR_DELAY       	= 12'b0000_0000_1000,
					MSR_CONFIG	     	= 12'b0000_0001_0000,
					MSR_DELAY2      	= 12'b0000_0010_0000,
					MSR_INIT        	= 12'b0000_0100_0000,
					MSR_WAITL2H     	= 12'b0000_1000_0000,
					MSR_WAIT0       	= 12'b0001_0000_0000,
					MSR_RSTAUS      	= 12'b0010_0000_0000,
					MSR_READ        	= 12'b0100_0000_0000,
					MSR_END         	= 12'b1000_0000_0000;
			
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
					r_fall_data			<= 16'd0;
					r_tdc_new_sig		<= 1'b0;
					r_tdc_err_sig		<= 1'b0;
					r_msr_cnt			<= 32'd0;
					r_tdc_state			<= 24'd0;
					r_msr_state			<= MSR_PORH;
					end
				MSR_PORH	:begin
					if((r_msr_cnt - 32'd1000) == 32'd0)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_PORR;
						end
					else if((r_msr_cnt - 32'd600) == 32'd0)begin
						r_tdc_reset			<= 1'b1;
						r_msr_cnt			<= r_msr_cnt + 1'b1;
						end
					else if((r_msr_cnt - 32'd500) == 32'd0)begin
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
					if((r_msr_cnt - 32'd100_000) == 32'd0)begin
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
					if((r_msr_cnt - 32'd100) == 32'd0)begin
						r_msr_cnt			<= 32'd0;
						r_msr_state			<= MSR_INIT;
						end
					else
						r_msr_cnt			<= r_msr_cnt + 1'b1;
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
					else if((r_msr_cnt - 32'd199) == 32'd0)begin
						r_msr_cnt			<= 32'd0;
						r_fall_data			<= 16'd0;
						r_tdc_new_sig		<= 1'b1;
						r_msr_state        	<= MSR_END;
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
						r_tdc_new_sig 		<= 1'b1;
						r_cmd_tdc_rd      	<= 1'b0;
						r_tdc_cmd        	<= 8'h00;
						r_tdc_num        	<= 6'd0;
						if(r_tdc_state[8:5] > 4'd0)
							r_fall_data 		<= w_tdc_rd_data[24:9];
						else
							r_fall_data 		<= 16'd0;
						r_msr_state        	<= MSR_END;
						end
					end
				MSR_END    :begin
					r_tdc_new_sig 		<= 1'b0;
					r_tdc_state        	<= 24'd0;
					r_msr_state        	<= MSR_INIT;
					end	
				default		:r_msr_state        	<= MSR_IDLE;
				endcase
			end
			
	assign o_fall_data 		= r_fall_data;
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


endmodule 