module ms1004_spi
(
	input			i_clk_25m		,
	input			i_rst_n			,
	input			i_spi_miso		,
	input			i_cmd_tdcwr		,
	input			i_cmd_tdcrd		,
	input			i_cmd_tdc1byte	,
	input	[7:0]	i_tdc_cmd		,
	input	[5:0] 	i_tdc_num		,
	input	[31:0]	i_tdc_wrdata	,
	
	output			o_spi_sck		,
	output			o_spi_ssn		,
	output			o_spi_mosi		,
	output	[31:0]	o_tdc_rddata	,
	output			o_tdc_cmddone

);

	reg			r_spi_sck		= 1'b0;
	reg			r_spi_ssn		= 1'b1;
	reg			r_spi_mosi		= 1'b0;
	reg	[31:0]	r_tdc_rddata	= 32'd0;
	reg			r_tdc_cmddone	= 1'b0;
	
	reg	[7:0]	r_tdc_state		= 8'd0;
	reg			r_spi_clk_en	= 1'b0;
	reg	[5:0]	r_tdc_wrnum		= 6'd0;
	reg	[5:0]	r_tdc_rdnum		= 6'd0;
	reg	[5:0]	r_tdc_wrcnt		= 6'd0;
	reg	[5:0]	r_tdc_rdcnt		= 6'd0;
	reg	[39:0]	r_tdc_wrdata	= 40'd0;
	
	parameter	TDC_IDLE	= 8'b0000_0000,
				TDC_WAIT	= 8'b0000_0010,
				TDC_SSNDN	= 8'b0000_0100,
				TDC_WRITE	= 8'b0000_1000,
				TDC_SHIFT	= 8'b0001_0000,
				TDC_READ	= 8'b0010_0000,
				TDC_SSNUP	= 8'b0100_0000,
				TDC_END		= 8'b1000_0000;
				

	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_state		<= TDC_IDLE;
		else begin
			case(r_tdc_state)
				TDC_IDLE	:
					r_tdc_state		<= TDC_WAIT;
				TDC_WAIT	:begin
					if(i_cmd_tdc1byte || i_cmd_tdcwr || i_cmd_tdcrd)
						r_tdc_state		<= TDC_SSNDN;
					end
				TDC_SSNDN	:
					r_tdc_state		<= TDC_WRITE;
				TDC_WRITE	:begin
					if(r_tdc_wrcnt >= r_tdc_wrnum)
						r_tdc_state		<= TDC_SHIFT;
					else
						r_tdc_state		<= TDC_WRITE;
					end
				TDC_SHIFT	:begin
					if(i_cmd_tdcrd)
						r_tdc_state		<= TDC_READ;
					else
						r_tdc_state		<= TDC_SSNUP;
					end
				TDC_READ	:begin
					if(r_tdc_rdcnt >= r_tdc_rdnum)
						r_tdc_state		<= TDC_SSNUP;
					else
						r_tdc_state		<= TDC_READ;
					end
				TDC_SSNUP	:
					r_tdc_state		<= TDC_END;
				TDC_END		:
					r_tdc_state		<= TDC_IDLE;
				default:r_tdc_state		<= TDC_IDLE;
				endcase
			end
			
	//r_spi_clk_en
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_spi_clk_en	<= 1'b0;
		else if(r_tdc_state == TDC_IDLE)
			r_spi_clk_en	<= 1'b0;
		else if(r_tdc_state == TDC_WRITE)
			r_spi_clk_en	<= 1'b1;
		else if(r_tdc_state == TDC_SHIFT && ~i_cmd_tdcrd)
			r_spi_clk_en	<= 1'b0;
		else if(r_tdc_state == TDC_READ)begin
			if(r_tdc_rdcnt + 1'b1 >= r_tdc_rdnum)
				r_spi_clk_en	<= 1'b0;
			else
				r_spi_clk_en	<= 1'b1;
			end
		
	//r_spi_ssn
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_spi_ssn	<= 1'b1;
		else if(r_tdc_state == TDC_IDLE)
			r_spi_ssn	<= 1'b1;
		else if(r_tdc_state == TDC_SSNDN)
			r_spi_ssn	<= 1'b0;
		else if(r_tdc_state == TDC_SSNUP)
			r_spi_ssn	<= 1'b1;
		
	//r_spi_mosi
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_spi_mosi	<= 1'b0;
		else if(r_tdc_state == TDC_WRITE)
			r_spi_mosi	<= r_tdc_wrdata[6'd39 - r_tdc_wrcnt];
			
	//r_tdc_wrdata
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wrdata	<= 40'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_wrdata	<= 40'd0;
		else if(r_tdc_state == TDC_WAIT)
			r_tdc_wrdata	<= {i_tdc_cmd,i_tdc_wrdata};
			
	//r_tdc_rddata
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_rddata	<= 32'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_rddata	<= 32'd0;
		else if(r_tdc_state == TDC_READ)
			r_tdc_rddata <= {r_tdc_rddata[30:0],i_spi_miso};
			
	//r_tdc_wrcnt
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wrcnt		<= 6'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_wrcnt		<= 6'd0;
		else if(r_tdc_state == TDC_WRITE)
			r_tdc_wrcnt		<= r_tdc_wrcnt + 1'b1;
		else
			r_tdc_wrcnt		<= 6'd0;
			
	//r_tdc_wrnum
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wrnum		<= 6'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_wrnum		<= 6'd0;
		else if(r_tdc_state == TDC_WAIT)begin
			if(i_cmd_tdc1byte || i_cmd_tdcrd)
				r_tdc_wrnum		<= 6'd7;
			else if(i_cmd_tdcwr)
				r_tdc_wrnum		<= 6'd8 + i_tdc_num;
			end
			
	//r_tdc_rdcnt
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_rdcnt		<= 6'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_rdcnt		<= 6'd0;
		else if(r_tdc_state == TDC_READ)
			r_tdc_rdcnt		<= r_tdc_rdcnt + 1'b1;
		else
			r_tdc_rdcnt		<= 6'd0;
			
	//r_tdc_rdnum
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_rdnum		<= 6'd0;
		else if(r_tdc_state == TDC_IDLE)
			r_tdc_rdnum		<= 6'd0;
		else if(r_tdc_state == TDC_WAIT)begin
			if(i_cmd_tdc1byte || i_cmd_tdcwr)
				r_tdc_rdnum		<= 6'd0;
			else if(i_cmd_tdcrd)
				r_tdc_rdnum		<= i_tdc_num + 1'b1;
			end
			
	//r_tdc_cmddone
	always@(posedge i_clk_25m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_cmddone	<= 1'b0;
		else if(r_tdc_state == TDC_END)
			r_tdc_cmddone	<= 1'b1;
		else
			r_tdc_cmddone	<= 1'b0;
			
	
	assign	o_spi_sck 		= (r_spi_clk_en) ? i_clk_25m : 1'b0;
	assign	o_spi_ssn 		= r_spi_ssn;
	assign	o_spi_mosi		= r_spi_mosi;
	assign	o_tdc_rddata	= r_tdc_rddata;
	assign	o_tdc_cmddone	= r_tdc_cmddone;

endmodule 