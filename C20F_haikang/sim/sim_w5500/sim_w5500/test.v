module test
(
	input				i_clk				,
	input				i_clk_50m			,
	
	input				i_packet_make		,
	input				i_send_req 			,
	input				i_cmd_make			,
	
	output	reg			o_packet_make = 1'b0,
	output	reg			o_send_req = 1'b0	,
	output	reg			o_cmd_make = 1'b0	
);

	reg		[7:0]	r_delayp_cnt = 8'd255;
	reg		[7:0]	r_delays_cnt = 8'd255;
	reg		[7:0]	r_delayc_cnt = 8'd255;
	
	reg				r_packet_make = 1'b0;
	reg				r_send_req = 1'b0;
	reg				r_cmd_make = 1'b0;	
	
	always@(posedge i_clk_50m)
		if(r_delayp_cnt >= 8'd255)begin
			if(i_packet_make)
				r_delayp_cnt	<= 8'd0;
			end
		else
			r_delayp_cnt	<= r_delayp_cnt + 1'b1;
			
	always@(posedge i_clk_50m)
		if(r_delayp_cnt	<= 8'd49)
			r_packet_make	<= 1'b1;
		else
			r_packet_make	<= 1'b0;
			
	always@(posedge i_clk)
		o_packet_make	<= r_packet_make;
		
	always@(posedge i_clk_50m)
		if(r_delays_cnt >= 8'd255)begin
			if(i_send_req)
				r_delays_cnt	<= 8'd0;
			end
		else
			r_delays_cnt	<= r_delays_cnt + 1'b1;
			
	always@(posedge i_clk_50m)
		if(r_delays_cnt	<= 8'd49)
			r_send_req	<= 1'b1;
		else
			r_send_req	<= 1'b0;
			
	always@(posedge i_clk)
		o_send_req	<= r_send_req;
		
	always@(posedge i_clk_50m)
		if(r_delayc_cnt >= 8'd255)begin
			if(i_cmd_make)
				r_delayc_cnt	<= 8'd0;
			end
		else
			r_delayc_cnt	<= r_delayc_cnt + 1'b1;
			
	always@(posedge i_clk_50m)
		if(r_delayc_cnt	<= 8'd49)
			r_cmd_make	<= 1'b1;
		else
			r_cmd_make	<= 1'b0;
			
	always@(posedge i_clk)
		o_cmd_make	<= r_cmd_make;

endmodule 