module time_stamp_ntp
(
	input				i_clk 			,
	input				i_rst_n 		,
	
	output	reg	[63:0]	o_ntp_get		,
	input		[63:0]	i_ntp_set		,
	output	reg			o_ntp_sig		,
	input				i_ntp_set_sig	
);

	reg		[7:0]	r_us_cnt ;
	reg		[31:0]	r_16s_cnt ;

	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_us_cnt	<= 8'd0;
		else if(i_ntp_set_sig)
			r_us_cnt	<= 8'd0;
		else if(r_us_cnt >= 8'd49)
			r_us_cnt	<= 8'd0;
		else 
			r_us_cnt	<= r_us_cnt + 1'b1;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_16s_cnt	<= 32'd0;
		else if(r_16s_cnt >= 32'd799_999_999)
			r_16s_cnt	<= 32'd0;
		else
			r_16s_cnt	<= r_16s_cnt + 1'b1;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			o_ntp_sig	<= 1'b0;
		else if(r_16s_cnt >= 32'd799_999_999)
			o_ntp_sig	<= 1'b1;
		else
			o_ntp_sig	<= 1'b0;
	end
	
	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			o_ntp_get	<= 64'd0;
		else if(i_ntp_set_sig)
			o_ntp_get	<= i_ntp_set;
		else if(r_us_cnt >= 8'd49)
			o_ntp_get	<= o_ntp_get + 64'd4295;
	end

endmodule 