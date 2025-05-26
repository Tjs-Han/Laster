module time_stamp
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_time_stamp_sig,
	input	[63:0]	i_time_stamp_set,
	
	output	reg[63:0]	o_time_stamp_get
); 

	reg		[7:0]	r_us_cnt = 8'd0;
	reg		[31:0]	r_16s_cnt = 32'd0;

	always @(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_us_cnt	<= 8'd0;
		else if(i_time_stamp_sig)
			r_us_cnt	<= 8'd0;
		else if(r_us_cnt >= 8'd49)
			r_us_cnt	<= 8'd0;
		else 
			r_us_cnt	<= r_us_cnt + 1'b1;
	end
	
/*	always @(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_16s_cnt	<= 32'd0;
		else if(r_16s_cnt >= 32'd799_999_999)
			r_16s_cnt	<= 32'd0;
		else
			r_16s_cnt	<= r_16s_cnt + 1'b1;
	end
	
	always @(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			o_time_stamp_sig	<= 1'b0;
		else if(r_16s_cnt >= 32'd799_999_999)
			o_time_stamp_sig	<= 1'b1;
		else
			o_time_stamp_sig	<= 1'b0;
			
	end*/
	
	always @(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			o_time_stamp_get	<= 64'd0;
		else if(i_time_stamp_sig)
			o_time_stamp_get	<= i_time_stamp_set;
		else if(r_us_cnt >= 8'd49)
			o_time_stamp_get	<= o_time_stamp_get + 64'd4295;
	end

endmodule 