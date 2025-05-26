module adc_to_dist
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_dac_set_sig	,
	input	[7:0]	i_device_temp	,
	
	input	[31:0]	i_dist_coe_para	,
	input	[15:0]	i_dist_diff		,

	output	[15:0]	o_dist_compen	
);
	
	reg		[15:0]	r_dist_temp_coe = 16'd600;
	reg		[7:0]	r_dist_temp_base = 8'd35;
	reg				r_dist_temp_mode = 1'b0;
	reg				r_dist_diff_polar = 1'b0;
	reg		[14:0]	r_dist_diff_dist = 15'd0;
	
	reg		[7:0]	r_dist_state = 8'd0;
	reg				r_dist_temp_polar = 1'b0;
	reg		[15:0]	r_dist_temp_dist = 16'd0;
	reg		[15:0]	r_dist_compen_pre = 16'd0;
	reg				r_dist_polar_pre = 1'b0;
	reg		[7:0]	r_delay_cnt = 8'd0;
	
	reg 	[15:0]	r_mult1_dataA = 16'd0;
	reg 	[7:0]	r_mult1_dataB = 8'd0;
	reg				r_mult_en	  = 1'b0;
    wire	[31:0]	w_mult1_result;
	
	parameter		IDLE	= 8'b0000_0000,
					ASSIGN	= 8'b0000_0010,
					JUDGE	= 8'b0000_0100,
					CAL1	= 8'b0000_1000,
					DELAY	= 8'b0001_0000,
					CAL2	= 8'b0010_0000,
					END		= 8'b0100_0000;
	
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_state	<= IDLE;
		else begin
			case(r_dist_state)
				IDLE	:begin
					if(i_dac_set_sig)
						r_dist_state	<= ASSIGN;
					else
						r_dist_state	<= IDLE;
				end
				ASSIGN	:begin
					r_dist_state	<= JUDGE;
				end
				JUDGE	:begin
					if(r_dist_temp_mode)
						r_dist_state	<= CAL1;
					else
						r_dist_state	<= CAL2;
				end
				CAL1	:begin
					r_dist_state	<= DELAY;
				end
				DELAY	:begin
					if(r_delay_cnt >= 8'd10)
						r_dist_state	<= CAL2;
					else
						r_dist_state	<= DELAY;
				end
				CAL2	:begin
					r_dist_state	<= END;
				end
				END		:begin
					r_dist_state	<= IDLE;
				end
				default	:begin
					r_dist_state	<= IDLE;
				end
			endcase
		end
		
	//r_dist_temp_coe
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_temp_coe <= 16'd600;
		else if(r_dist_state == ASSIGN)
			r_dist_temp_coe <= i_dist_coe_para[15:0];
			
	//r_dist_temp_base
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_temp_base <= 8'd35;
		else if(r_dist_state == ASSIGN)
			r_dist_temp_base <= i_dist_coe_para[23:16];
			
	//r_dist_temp_mode
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_temp_mode	<= 1'b0;
		else if(r_dist_state == ASSIGN)
			r_dist_temp_mode	<= i_dist_coe_para[24];
			
	//r_dist_diff_polar
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_diff_polar	<= 1'b0;
		else if(r_dist_state == ASSIGN)
			r_dist_diff_polar	<= i_dist_diff[15];

	//r_dist_diff_dist
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_diff_dist	<= 16'd0;
		else if(r_dist_state == ASSIGN)
			r_dist_diff_dist	<= i_dist_diff[14:0];
			
	//r_mult1_dataA
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult1_dataA	<= 16'd0;
		else if(r_dist_state == CAL1)
			r_mult1_dataA	<= r_dist_temp_coe;
			
			
	//r_mult1_dataB
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_mult1_dataB	<= 8'd0;
		else if(r_dist_state == CAL1)begin
			if(i_device_temp[7] == 1'b1)
				r_mult1_dataB	<= r_dist_temp_base[7:0] - i_device_temp;
			else if(i_device_temp >= r_dist_temp_base[7:0])
				r_mult1_dataB	<= i_device_temp - r_dist_temp_base[7:0];
			else
				r_mult1_dataB	<= r_dist_temp_base[7:0] - i_device_temp;
			end
		
	//r_mult_en	  = 1'b0;
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	
			r_mult_en	  <= 1'b0;
		else if(r_dist_state == CAL1 || r_dist_state == DELAY)
			r_mult_en	  <= 1'b1;
		else
			r_mult_en	  <= 1'b0;
			
	//r_dist_temp_polar
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_temp_polar	<= 1'b0;
		else if(r_dist_state == IDLE)
			r_dist_temp_polar	<= 1'b1;
		else if(r_dist_state == CAL1)begin
			if(i_device_temp[7] == 1'b1)
				r_dist_temp_polar	<= 1'b1;
			else if(i_device_temp >= r_dist_temp_base[7:0])
				r_dist_temp_polar	<= 1'b0;
			else
				r_dist_temp_polar	<= 1'b1;
			end
			
	//r_dist_temp_dist
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_temp_dist	<= 16'd0;
		else if(r_dist_state == IDLE)
			r_dist_temp_dist	<= 16'd0;
		else if(r_dist_state == DELAY && r_delay_cnt >= 8'd10)
			r_dist_temp_dist	<= w_mult1_result[25:10];
			
	//r_delay_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_delay_cnt		<= 8'd0;
		else if(r_dist_state == DELAY)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt		<= 8'd0;

	//r_dist_compen_pre
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_compen_pre	<= 16'd0;
		else if(r_dist_state == CAL2)begin
			if(r_dist_temp_polar == r_dist_diff_polar)
				r_dist_compen_pre	<= r_dist_temp_dist + r_dist_diff_dist;
			else begin
				if(r_dist_diff_dist >= r_dist_temp_dist)
					r_dist_compen_pre	<= r_dist_diff_dist - r_dist_temp_dist;
				else
					r_dist_compen_pre	<= r_dist_temp_dist - r_dist_diff_dist;
			end
		end
				
	//r_dist_polar_pre
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_polar_pre	<= 1'b0;
		else if(r_dist_state == CAL2)begin
			if(r_dist_temp_polar == r_dist_diff_polar)
				r_dist_polar_pre	<= r_dist_temp_polar;
			else begin
				if(r_dist_diff_dist >= r_dist_temp_dist)
					r_dist_polar_pre	<= r_dist_diff_polar;
				else
					r_dist_polar_pre	<= r_dist_temp_polar;
			end

		end
		
	assign	o_dist_compen = {r_dist_polar_pre,r_dist_compen_pre[14:0]};
			
	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult1_dataA), 
		.DataB				({8'd0,r_mult1_dataB}), 
		.Result				(w_mult1_result)
	);
	
endmodule 