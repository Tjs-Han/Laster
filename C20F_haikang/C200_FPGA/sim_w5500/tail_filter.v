module tail_filter
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[15:0]	i_code_angle 		,//角度值
	input	[15:0]	i_dist_data			,
	input	[15:0]	i_rssi_data			,
	input			i_dist_new_sig		,
	
	input			i_tail_switch		,
	input	[15:0]	i_tail_parameter	,
	input	[15:0]	i_tail_diffmin		,
	input	[15:0]	i_tail_diffmax		,
	
	output	[15:0]	o_code_angle 		,//角度值
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		
);

	
	reg		[15:0]	r_code_angle = 16'd0;//角度值
	reg		[19:0]	r_dist_data = 20'd0;
	reg		[15:0]	r_rssi_data = 16'd0;
	reg				r_dist_new_sig = 1'b0;
	
	reg		[15:0]	r_filter_state = 16'd0;
	
	reg		[15:0]	r_dist_data1 = 16'd0;
	reg		[15:0]	r_dist_data2 = 16'd0;
	reg		[15:0]	r_dist_data3 = 16'd0;
	reg		[15:0]	r_dist_data4 = 16'd0;
	
	reg		[15:0]	r_rssi_data1 = 16'd0;
	reg		[15:0]	r_rssi_data2 = 16'd0;
	reg		[15:0]	r_rssi_data3 = 16'd0;
	reg		[15:0]	r_rssi_data4 = 16'd0;
	
	reg		[15:0]	r_dist_diff1 = 16'd0;
	reg		[15:0]	r_dist_diff2 = 16'd0;
	reg		[15:0]	r_dist_diff3 = 16'd0;
	
	reg				r_diff1_polar = 1'b0;
	reg				r_diff2_polar = 1'b0;
	reg				r_diff3_polar = 1'b0;
	
	reg		[15:0]	r_tail_diff	= 16'd0;
	reg		[23:0]	r_tail_mult	= 24'd0;
	reg		[15:0]	r_tail_dist	= 16'd0;
	
	reg		[7:0]	r_delay_cnt = 8'd0;
	
	reg				r_mult_en = 1'b0;
	wire	[31:0]	w_tail_mult;
	
	parameter		FILTER_IDLE		= 16'b0000_0000_0000_0000,
					FILTER_WAIT		= 16'b0000_0000_0000_0010,
					FILTER_ASSIGN	= 16'b0000_0000_0000_0100,
					FILTER_SHIFT	= 16'b0000_0000_0000_1000,
					FILTER_SUB		= 16'b0000_0000_0001_0000,
					FILTER_COMP1	= 16'b0000_0000_0010_0000,
					FILTER_MULT		= 16'b0000_0000_0100_0000,
					FILTER_DELAY	= 16'b0000_0000_1000_0000,
					FILTER_COMP2	= 16'b0000_0001_0000_0000,
					FILTER_COMP3	= 16'b0000_0010_0000_0000,
					FILTER_CAL1		= 16'b0000_0100_0000_0000,
					FILTER_CAL2		= 16'b0000_1000_0000_0000,
					FILTER_END		= 16'b0001_0000_0000_0000,
					FILTER_OVER		= 16'b0010_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_dist_data1 <= r_dist_data2;
			r_dist_data2 <= r_dist_data3;
			r_dist_data3 <= r_dist_data4;
			r_dist_data4 <= i_dist_data;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_rssi_data1 <= r_rssi_data2;
			r_rssi_data2 <= r_rssi_data3;
			r_rssi_data3 <= r_rssi_data4;
			r_rssi_data4 <= i_rssi_data;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_SUB)begin
			if(r_dist_data2 >= r_dist_data1)
				r_dist_diff1	<= r_dist_data2 - r_dist_data1;
			else
				r_dist_diff1	<= r_dist_data1 - r_dist_data2;
			if(r_dist_data3 >= r_dist_data2)
				r_dist_diff2	<= r_dist_data3 - r_dist_data2;
			else
				r_dist_diff2	<= r_dist_data2 - r_dist_data3;
			if(r_dist_data4 >= r_dist_data3)
				r_dist_diff3	<= r_dist_data4 - r_dist_data3;
			else
				r_dist_diff3	<= r_dist_data3 - r_dist_data4;
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_diff1_polar <= 1'b0;
			r_diff2_polar <= 1'b0;
			r_diff3_polar <= 1'b0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_diff1_polar <= 1'b0;
			r_diff2_polar <= 1'b0;
			r_diff3_polar <= 1'b0;
			end
		else if(r_filter_state	== FILTER_SUB)begin
			if(r_dist_data2 >= r_dist_data1)
				r_diff1_polar <= 1'b1;
			else
				r_diff1_polar <= 1'b0;
			if(r_dist_data3 >= r_dist_data2)
				r_diff2_polar <= 1'b1;
			else
				r_diff2_polar <= 1'b0;
			if(r_dist_data4 >= r_dist_data3)
				r_diff3_polar <= 1'b1;
			else
				r_diff3_polar <= 1'b0;
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_tail_diff	<= 16'd0;
			r_tail_dist	<= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_tail_diff	<= 16'd0;
			r_tail_dist	<= 16'd0;
			end
		else if(r_filter_state	== FILTER_COMP1)begin
			if(r_dist_diff1 >= i_tail_diffmin && r_dist_diff2 >= i_tail_diffmin && r_diff1_polar == 1'b1 && r_diff2_polar == 1'b1)begin
				r_tail_diff	<= r_dist_diff1 + r_dist_diff2;
				r_tail_dist	<= r_dist_data1;
				end
			else if(r_dist_diff1 >= i_tail_diffmin && r_dist_diff2 >= i_tail_diffmin && r_diff1_polar == 1'b0 && r_diff2_polar == 1'b0)begin
				r_tail_diff	<= r_dist_diff1 + r_dist_diff2;
				r_tail_dist	<= r_dist_data3;
				end
			else if(r_dist_diff2 >= i_tail_diffmin && r_dist_diff3 >= i_tail_diffmin && r_diff2_polar == 1'b1 && r_diff3_polar == 1'b1)begin
				r_tail_diff	<= r_dist_diff2 + r_dist_diff3;
				r_tail_dist	<= r_dist_data2;
				end
			else if(r_dist_diff2 >= i_tail_diffmin && r_dist_diff3 >= i_tail_diffmin && r_diff2_polar == 1'b0 && r_diff3_polar == 1'b0)begin
				r_tail_diff	<= r_dist_diff2 + r_dist_diff3;
				r_tail_dist	<= r_dist_data4;
				end
			else begin
				r_tail_diff	<= 16'd0;
				r_tail_dist	<= 16'd0;
				end
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_mult_en <= 1'b0;
		else if(r_filter_state	== FILTER_MULT)
			r_mult_en <= 1'b1;
		else if(r_filter_state	== FILTER_COMP2)
			r_mult_en <= 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_tail_mult	<= 24'd0;
		else if(r_filter_state	== FILTER_DELAY && r_delay_cnt >= 8'd5)
			r_tail_mult	<= w_tail_mult[23:0];
			
	//r_delay_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_delay_cnt	<= 8'd0;
		else if(r_filter_state	== FILTER_DELAY)
			r_delay_cnt	<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt	<= 8'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL1)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL2)
			r_dist_data	<= r_dist_data3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL1)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_CAL2)
			r_rssi_data	<= r_rssi_data3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_code_angle <= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_code_angle <= 16'd0;
		else if(r_filter_state == FILTER_END)begin
			if(i_code_angle >= 16'd1)
				r_code_angle <= i_code_angle - 1'b1;
			else
				r_code_angle <= i_code_angle;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_new_sig <= 1'b0;
		else if(r_filter_state == FILTER_OVER)
			r_dist_new_sig <= 1'b1;
		else
			r_dist_new_sig <= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_filter_state	<= FILTER_IDLE;
		else begin
			case(r_filter_state)
				FILTER_IDLE	:
					r_filter_state	<= FILTER_WAIT;
				FILTER_WAIT	:begin
					if(i_dist_new_sig)
						r_filter_state	<= FILTER_ASSIGN;
					else
						r_filter_state	<= FILTER_WAIT;
					end
				FILTER_ASSIGN:
					r_filter_state	<= FILTER_SHIFT;
				FILTER_SHIFT:begin
					if(i_tail_switch)
						r_filter_state	<= FILTER_SUB;
					else
						r_filter_state	<= FILTER_CAL2;
					end
				FILTER_SUB	:
					r_filter_state	<= FILTER_COMP1;
				FILTER_COMP1:begin
					if(r_dist_diff1 >= i_tail_diffmin && r_dist_diff2 >= i_tail_diffmin && r_diff1_polar == r_diff2_polar)
						r_filter_state	<= FILTER_MULT;
					else if(r_dist_diff2 >= i_tail_diffmin && r_dist_diff3 >= i_tail_diffmin && r_diff2_polar == r_diff3_polar)
						r_filter_state	<= FILTER_MULT;
					else
						r_filter_state	<= FILTER_COMP3;
					end
				FILTER_MULT	:
					r_filter_state	<= FILTER_DELAY;
				FILTER_DELAY:begin	
					if(r_delay_cnt >= 8'd5)
						r_filter_state	<= FILTER_COMP2;
					else
						r_filter_state	<= FILTER_DELAY;
					end
				FILTER_COMP2:begin
					if(r_tail_mult >= r_tail_dist)
						r_filter_state	<= FILTER_CAL1;
					else
						r_filter_state	<= FILTER_COMP3;
					end
				FILTER_COMP3:begin
					if(r_dist_diff2 >= i_tail_diffmax && r_dist_diff3 >= i_tail_diffmax && r_diff2_polar == r_diff3_polar)
						r_filter_state	<= FILTER_CAL1;
					else if(r_dist_diff2 >= i_tail_diffmax && r_dist_data4 == 16'd0)
						r_filter_state	<= FILTER_CAL1;
					else if(r_dist_diff3 >= i_tail_diffmax && r_dist_data2 == 16'd0)
						r_filter_state	<= FILTER_CAL1;
					else
						r_filter_state	<= FILTER_CAL2;
					end
				FILTER_CAL1,FILTER_CAL2:
					r_filter_state	<= FILTER_END;
				FILTER_END:
					r_filter_state	<= FILTER_OVER;
				FILTER_OVER:
					r_filter_state	<= FILTER_WAIT;
				default:r_filter_state	<= FILTER_IDLE;
				endcase
			end
			
	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_tail_diff), 
		.DataB				(i_tail_parameter), 
		.Result				(w_tail_mult)
	);
			
	assign	o_code_angle 	= r_code_angle;//角度值
	assign	o_dist_data 	= r_dist_data[15:0];
	assign	o_rssi_data 	= r_rssi_data;
	assign	o_dist_new_sig 	= r_dist_new_sig;
				

endmodule 