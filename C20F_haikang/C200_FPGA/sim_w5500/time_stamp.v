module time_stamp
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_send_sig		,
	input			i_time_stamp_sig,
	
	input	[79:0]	i_time_stamp_set,
	output	[79:0]	o_time_stamp_get	
);

	reg   	[15:0]	r_tsyear_pre   = 16'd1970;
	reg   	[7:0]	r_tsmonth_pre  = 8'd1;
	reg   	[7:0]	r_tsdate_pre   = 8'd1;
	reg   	[7:0]	r_tshour_pre   = 8'd8;
	reg   	[7:0]	r_tsminute_pre = 8'd0;
	reg   	[7:0]	r_tssecond_pre = 8'd0;
	reg   	[23:0]	r_tsmicsec_pre = 24'd0;
	
	reg   	[23:0]	r_tsmicsec_pre_r = 24'd0;
	
	reg		[7:0]	r_micsec_cnt   = 8'd0;
	reg				r_4years_sig   = 1'b0;

	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
			r_micsec_cnt <= 8'd0;
		else if(i_time_stamp_sig)
			r_micsec_cnt <= 8'd0;
		else if(r_micsec_cnt >= 8'd24)
			r_micsec_cnt <= 8'd0;
		else
			r_micsec_cnt <= r_micsec_cnt + 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
			r_tsmicsec_pre <= 24'd0;
		else if(i_time_stamp_sig)
			r_tsmicsec_pre <= i_time_stamp_set[23:0];
//		else if(i_send_sig)
//			r_tsmicsec_pre <= 24'd0;
		else if(r_micsec_cnt >= 8'd24)begin
			if(r_tsmicsec_pre >= 24'd999_999)
				r_tsmicsec_pre <= 24'd0; 
			else
				r_tsmicsec_pre <= r_tsmicsec_pre + 1'b1;
			end
		else
		  r_tsmicsec_pre <= r_tsmicsec_pre ;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_tsmicsec_pre_r 	<= 24'd0;
		else if(i_send_sig)
			r_tsmicsec_pre_r	<= r_tsmicsec_pre;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)
			r_tssecond_pre <= 8'd0;
		else if(i_time_stamp_sig)
			r_tssecond_pre <= i_time_stamp_set[31:24];
		else if(r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)begin
			if(r_tssecond_pre >= 8'd59)
				r_tssecond_pre <= 8'd0;
			else
				r_tssecond_pre <= r_tssecond_pre + 1'b1;
			end
		
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)		
			r_tsminute_pre <= 8'd0;
		else if(i_time_stamp_sig)
			r_tsminute_pre <= i_time_stamp_set[39:32];
		else if(r_tssecond_pre >= 8'd59 && r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)begin
			if(r_tsminute_pre >= 8'd59)
				r_tsminute_pre <= 8'd0;
			else
				r_tsminute_pre <= r_tsminute_pre + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)	
			r_tshour_pre <= 8'd8;
		else if(i_time_stamp_sig)
			r_tshour_pre <= i_time_stamp_set[47:40];
		else if(r_tsminute_pre >= 8'd59 && r_tssecond_pre >= 8'd59 && r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)begin
			if(r_tshour_pre >= 8'd23)
				r_tshour_pre <= 8'd0;
			else
				r_tshour_pre <= r_tshour_pre + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
	   if(i_rst_n == 0)		
			r_4years_sig <= 1'b0;
		else if(r_tsyear_pre % 3'd4 == 16'd0)
			r_4years_sig <= 1'b1;
		else
			r_4years_sig <= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tsdate_pre <= 8'd1;
		else if(i_time_stamp_sig)
			r_tsdate_pre <= i_time_stamp_set[55:48];
		else if(r_tshour_pre >= 8'd23 && r_tsminute_pre >= 8'd59 && r_tssecond_pre >= 8'd59 && r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)begin
			if((r_tsmonth_pre == 8'd1 || r_tsmonth_pre == 8'd3 || r_tsmonth_pre == 8'd5 || r_tsmonth_pre == 8'd7 || r_tsmonth_pre == 8'd8 || r_tsmonth_pre == 8'd10 || r_tsmonth_pre == 8'd12) && r_tsdate_pre >= 8'd31)
				r_tsdate_pre <= 8'd1;
			else if((r_tsmonth_pre == 8'd4 || r_tsmonth_pre == 8'd6 || r_tsmonth_pre == 8'd9 || r_tsmonth_pre == 8'd11) && r_tsdate_pre >= 8'd30)
				r_tsdate_pre <= 8'd1;
			else if(r_4years_sig == 1'b1 && r_tsmonth_pre == 8'd2 && r_tsdate_pre >= 8'd29)
				r_tsdate_pre <= 8'd1;
			else if(r_4years_sig == 1'b0 && r_tsmonth_pre == 8'd2 && r_tsdate_pre >= 8'd28)
				r_tsdate_pre <= 8'd1;
			else
				r_tsdate_pre <= r_tsdate_pre + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_tsmonth_pre <= 8'd1;
		else if(i_time_stamp_sig)
			r_tsmonth_pre <= i_time_stamp_set[63:56];
		else if(r_tshour_pre >= 8'd23 && r_tsminute_pre >= 8'd59 && r_tssecond_pre >= 8'd59 && r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)begin
			if((r_tsmonth_pre == 8'd1 || r_tsmonth_pre == 8'd3 || r_tsmonth_pre == 8'd5 || r_tsmonth_pre == 8'd7 || r_tsmonth_pre == 8'd8 || r_tsmonth_pre == 8'd10) && r_tsdate_pre >= 8'd31)
				r_tsmonth_pre <= r_tsmonth_pre + 1'b1;
			else if(r_tsmonth_pre == 8'd12 && r_tsdate_pre >= 8'd31)
				r_tsmonth_pre <= 8'd1;
			else if((r_tsmonth_pre == 8'd4 || r_tsmonth_pre == 8'd6 || r_tsmonth_pre == 8'd9 || r_tsmonth_pre == 8'd11) && r_tsdate_pre >= 8'd30)
				r_tsmonth_pre <= r_tsmonth_pre + 1'b1;
			else if(r_4years_sig == 1'b1 && r_tsmonth_pre == 8'd2 && r_tsdate_pre >= 8'd29)
				r_tsmonth_pre <= r_tsmonth_pre + 1'b1;
			else if(r_4years_sig == 1'b0 && r_tsmonth_pre == 8'd2 && r_tsdate_pre >= 8'd28)
				r_tsmonth_pre <= r_tsmonth_pre + 1'b1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)	
			r_tsyear_pre <= 16'd1970;
		else if(i_time_stamp_sig)
			r_tsyear_pre <= i_time_stamp_set[79:64];
		else if(r_tsmonth_pre >= 8'd12 && r_tsdate_pre >= 8'd31 && r_tshour_pre >= 8'd23 && r_tsminute_pre >= 8'd59 && r_tssecond_pre >= 8'd59 && r_tsmicsec_pre >= 24'd999_999 && r_micsec_cnt >= 8'd24)
			r_tsyear_pre <= r_tsyear_pre + 1'b1;

	
	assign	o_time_stamp_get = {r_tsyear_pre,r_tsmonth_pre,r_tsdate_pre,r_tshour_pre,r_tsminute_pre,r_tssecond_pre,r_tsmicsec_pre};

endmodule 