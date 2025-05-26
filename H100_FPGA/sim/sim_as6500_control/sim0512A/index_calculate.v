module index_calculate
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input	[15:0]	i_angle_reso	,
	input	[31:0]	i_start_angle	,
	input	[31:0]	i_stop_angle	,
	
	output	[15:0]	o_start_index	,
	output	[15:0]	o_stop_index	,
	output	[15:0]	o_index_num	
);

	reg		[15:0]	r_start_index = 16'd450;
	reg		[15:0]	r_stop_index = 16'd3150;	
	reg		[15:0]	r_index_num = 16'd2701;
	
	reg				r_cal_sig = 1'b0;
	reg 	[31:0] r_dividend = 32'd0;
	reg 	[15:0] r_divisor = 16'd0;
	wire	[15:0]	w_quotient;
	wire			w_cal_done;
	
	reg		[15:0]	r_angle_reso = 16'd1000;
	reg		[31:0]	r_start_angle = 32'hFFF92230;
	reg		[31:0]	r_stop_angle = 32'h00225510;
	
	reg		[31:0]	r_start_angle_c = 32'h0;
	reg		[31:0]	r_stop_angle_c = 32'h002932E0;
	
	reg		[15:0]	r_start_index1 = 16'd450;
	reg		[15:0]	r_stop_index1 = 16'd3150;	
	
	reg		[15:0]	r_start_index2 = 16'd450;
	reg		[15:0]	r_stop_index2 = 16'd3150;
	
	reg		[7:0]	r_index_state = 8'd0;
	
	parameter		IDLE	= 8'b0000_0000,
					ASSIGN	= 8'b0000_0010,
					START	= 8'b0000_0100,
					STOP	= 8'b0000_1000,
					END		= 8'b0001_0000; 
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_angle_reso <= 16'd1000;
			r_start_angle <= 32'hFFF92230;
			r_stop_angle <= 32'h00225510;
			end
		else begin
			r_angle_reso <= i_angle_reso;
			r_start_angle <= i_start_angle;
			r_stop_angle <= i_stop_angle;
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_start_index 	<= 16'd450;
			r_stop_index	<= 16'd3150;	
			r_index_num 	<= 16'd2701;
			r_cal_sig 		<= 1'b0;
			r_dividend 		<= 32'd0;
			r_divisor 		<= 16'd0;
			r_start_angle_c <= 32'h0;
			r_stop_angle_c 	<= 32'h002932E0;
			r_index_state	<= IDLE;
			end
		else begin
			case(r_index_state)
				IDLE	:begin
					r_cal_sig 		<= 1'b0;
					r_dividend 		<= 32'd0;
					r_divisor 		<= 16'd0;
					r_index_state	<= ASSIGN;
					end
				ASSIGN	:begin
					r_start_angle_c <= r_start_angle + 32'h000DBBA0;
					r_stop_angle_c 	<= r_stop_angle  + 32'h000DBBA0;
					r_index_state	<= START;
					end
				START	:begin
					r_cal_sig 		<= 1'b1;
					r_dividend	 	<= r_start_angle_c;
					r_divisor 		<= r_angle_reso;
					if(w_cal_done)begin
						r_cal_sig 		<= 1'b0;
						r_start_index	<= w_quotient;
						r_index_state	<= STOP;
						end
					end
				STOP	:begin
					r_cal_sig 		<= 1'b1;
					r_dividend	 	<= r_stop_angle_c;
					r_divisor 		<= r_angle_reso;
					if(w_cal_done)begin
						r_cal_sig 		<= 1'b0;
						r_stop_index	<= w_quotient;
						r_index_state	<= END;
						end
					end
				END		:begin
					if(r_stop_index >= r_start_index)
						r_index_num		<= r_stop_index - r_start_index + 1'b1;
					else
						r_index_num		<= r_start_index - r_stop_index + 1'b1;
					r_index_state	<= IDLE;
					end
				default	:r_index_state	<= IDLE;
				endcase
			end
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_start_index1 	<= 16'd450;
			r_stop_index1 	<= 16'd3150;
			r_start_index2 	<= 16'd450;
			r_stop_index2 	<= 16'd3150;
			end
		else begin
			r_start_index1 	<= r_start_index;
			r_stop_index1 	<= r_stop_index;
			r_start_index2 	<= r_start_index1;
			r_stop_index2 	<= r_stop_index1;
			end
		
	assign	o_start_index = r_start_index2;
	assign	o_stop_index = r_stop_index2;
	assign	o_index_num = r_index_num;
	
	division U1
	(
		.i_clk_50m			(i_clk_50m)	,
		.i_rst_n			(i_rst_n)	,
		
		.i_cal_sig			(r_cal_sig)	,
		.i_dividend			(r_dividend),
		.i_divisor			(r_divisor)	,
		
		
		.o_remainder		()			,
		.o_quotient			(w_quotient),
		.o_cal_done			(w_cal_done)
	);

endmodule 