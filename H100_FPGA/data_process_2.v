module data_process_2
(
	input				i_clk_50m    	,
	input				i_rst_n      	,
	
//	input				i_angle_sync	,
	input				i_opto_fall		,
	input				i_zero_sign		,
	input	[7:0]		i_fall_cnt		,
	input	[15:0]		i_angle_zero	,
	input	[3:0]		i_reso_mode		,
	
	input				i_dist_sig		,
	input	[15:0]		i_rise_data		,//ÉÏÉıÑØ
	input	[15:0]		i_fall_data		,//ÏÂ½µÑØ
	input	[15:0]		i_dist_data		,
	input	[15:0]		i_rssi_data		,
	
	output				o_dist_sig		,
	output	[15:0]		o_code_angle	,
	output	[63:0]		o_edge_data			
);

	reg		[7:0]		r_point_num		= 8'd0;
	reg					r_dist_wren		= 1'b0;
	reg		[7:0]		r_dist_wraddr	= 8'd0;
	reg		[63:0]		r_dist_wrdata	= 64'd0;
	reg					r_pingorpang	= 1'b0;
	wire	[63:0]		w_dist_rddata;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_wren		<= 1'b0;
		else 
			r_dist_wren		<= i_dist_sig;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_wrdata	<= 64'd0;
		else if(i_dist_sig)
			r_dist_wrdata	<= {i_rise_data,i_fall_data,i_dist_data,i_rssi_data};
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_wraddr	<= 8'd0;
		else if(i_opto_fall || i_zero_sign)
			r_dist_wraddr	<= 8'd0;
		else 
			r_dist_wraddr	<= r_dist_wraddr + i_dist_sig;
						
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_point_num		<= 8'd0;
		else if(i_opto_fall || i_zero_sign)
			r_point_num		<= r_dist_wraddr;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pingorpang	<= 1'b0;
		else if(i_opto_fall || i_zero_sign)
			r_pingorpang	<= ~r_pingorpang;
			
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	reg		[15:0]		r_angle_max	= 16'd3600;
	reg		[7:0]		r_angle_reso = 8'd90;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_max		<= 16'd3600;
		else if(i_reso_mode == 4'd0)
			r_angle_max		<= 16'd3600;
		else if(i_reso_mode == 4'd1)
			r_angle_max		<= 16'd7200;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_angle_reso	<= 16'd90;
		else if(i_reso_mode == 4'd0)
			r_angle_reso	<= 16'd90;
		else if(i_reso_mode == 4'd1)
			r_angle_reso	<= 16'd180;
			
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	reg		[15:0]		r_dist_state	= 16'd0;
	reg		[7:0]		r_dist_rdaddr	= 8'd0;
	reg		[15:0]		r_code_angle	= 16'd0;
	reg		[7:0]		r_point_diff	= 8'd0;
	reg		[7:0]		r_space_num		= 8'd0;
	reg		[9:0]		r_dist_delay	= 10'd0;
	reg					r_cal_sig		= 1'b0;
	reg					r_dist_sig		= 1'b0;
	reg		[63:0]		r_edge_data		= 64'd0;
	reg		[7:0]		r_point_cnt		= 8'd0;
	reg		[7:0]		r_shift_cnt		= 8'd0;
	
	wire	[15:0]		w_quotient;
	wire				w_cal_done;
	wire	[15:0]		w_mult1_result;
	
	reg		[7:0]		r_move_cnt;
	reg		[7:0]		r_remainder_r;
	reg		[15:0]		r_remainder	 ;
	
	wire	[15:0]		w_remainder ;
	
	parameter		DIST_IDLE		= 16'b0000_0000_0000_0000,
					DIST_ANGLE		= 16'b0000_0000_0000_0010,
					DIST_ASSIGN0	= 16'b0000_0000_0000_0100,
					DIST_SHIFT0		= 16'b0000_0000_0000_1000,
					DIST_CODE0		= 16'b0000_0000_0001_0000,
					DIST_SIG0		= 16'b0000_0000_0010_0000,
					DIST_DELAY0		= 16'b0000_0000_0100_0000,
					DIST_ASSIGN1	= 16'b0000_0000_1000_0000,
					DIST_CODE1		= 16'b0000_0001_0000_0000,
					DIST_SIG1		= 16'b0000_0010_0000_0000,
					DIST_DELAY1		= 16'b0000_0100_0000_0000,
					DIST_ASSIGN2	= 16'b0000_1000_0000_0000,
					DIST_CODE2		= 16'b0001_0000_0000_0000,
					DIST_SIG2		= 16'b0010_0000_0000_0000,
					DIST_DELAY2		= 16'b0100_0000_0000_0000,
					DIST_END		= 16'b1000_0000_0000_0000;
					
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_dist_rdaddr	<= 8'd0;
			r_point_diff	<= 8'd0;
			r_space_num		<= 8'd0;
			r_code_angle	<= 16'd0;
			r_dist_delay	<= 10'd0;
			r_cal_sig		<= 1'b0;
			r_edge_data		<= 64'd0;
			r_dist_sig		<= 1'b0;
			r_point_cnt		<= 8'd0;
			r_shift_cnt		<= 8'd0;
			r_move_cnt		<= 8'd0;
			r_remainder_r	<= 8'd0;
			r_remainder		<= 8'd0;	
			r_dist_state	<= DIST_IDLE;
			end
		else begin
			case(r_dist_state)
				DIST_IDLE		:begin
					r_dist_rdaddr	<= 8'd0;
					r_point_diff	<= 8'd0;
					r_space_num		<= 8'd0;
					//r_code_angle	<= 16'd0;
					r_dist_delay	<= 10'd0;
					r_cal_sig		<= 1'b0;
					r_edge_data		<= 64'd0;
					r_dist_sig		<= 1'b0;
					r_point_cnt		<= 8'd0;
					r_shift_cnt		<= 8'd0;
					r_move_cnt		<= 8'd0;
					r_remainder_r	<= 8'd0;
					r_remainder		<= 8'd0;
					if(i_opto_fall | i_zero_sign)
						r_dist_state	<= DIST_ANGLE;
					else
						r_dist_state	<= DIST_IDLE;
					end
				DIST_ANGLE		:begin
					if(r_dist_delay >= 10'd7)begin
						r_dist_delay	<= 10'd0;
						if((w_mult1_result + i_angle_zero) >= r_angle_max)
							r_code_angle	<= w_mult1_result + i_angle_zero - r_angle_max;
						else
							r_code_angle	<= w_mult1_result + i_angle_zero;
						if(r_point_num > r_angle_reso)begin
							r_cal_sig		<= 1'b1;
							r_dist_state	<= DIST_ASSIGN1;
							r_point_diff	<= r_point_num - r_angle_reso;//r_point_diff	<= r_point_num + 1'b1 - r_angle_reso;
							end
						else if(r_point_num < r_angle_reso)begin
							r_cal_sig		<= 1'b1;
							r_dist_state	<= DIST_ASSIGN2;
							r_point_diff	<= r_angle_reso + 1'b1 - r_point_num;
							end
						else 
							r_dist_state	<= DIST_ASSIGN0;
						end
					else begin
						r_dist_delay	<= r_dist_delay + 1'b1;
						r_dist_state	<= DIST_ANGLE;
						end
					end
				DIST_ASSIGN0	:begin
					r_dist_state	<= DIST_SIG0;
					end
				DIST_CODE0		:begin
					if(r_code_angle + 1'b1 >= r_angle_max)
						r_code_angle	<= 16'd0;
					else
						r_code_angle	<= r_code_angle + 1'b1;
					r_dist_state	<= DIST_SIG0;
					end
				DIST_SIG0		:begin
					r_edge_data		<= w_dist_rddata;
					r_dist_sig		<= 1'b1;
					r_point_cnt		<= r_point_cnt + 1'b1;
					r_dist_rdaddr	<= r_dist_rdaddr + 1'b1;
					r_dist_state	<= DIST_DELAY0;
					end
				DIST_DELAY0		:begin
					r_dist_sig		<= 1'b0;
					if(r_dist_delay >= 10'd250)begin
						r_dist_delay 	<= 10'd0;
						if(r_point_cnt >= r_angle_reso)
							r_dist_state	<= DIST_END;
						else
							r_dist_state	<= DIST_CODE0;
						end
					else begin
						r_dist_delay	<= r_dist_delay + 1'b1;
						r_dist_state	<= DIST_DELAY0;
						end
					end
				DIST_ASSIGN1	:begin
					r_cal_sig		<= 1'b0;
					if(w_cal_done)begin
						r_space_num		<= w_quotient[7:0];
						r_dist_state	<= DIST_SHIFT0;
						r_remainder		<= w_remainder[7:0];
						end
					else
						r_dist_state	<= DIST_ASSIGN1;
					end
				DIST_SHIFT0:begin
							r_remainder		<= r_remainder*8'd100/r_point_diff;
							r_dist_state	<= DIST_SIG1;
							r_dist_rdaddr	<= r_dist_rdaddr + 1'b1;
						end
				DIST_CODE1		:begin
					if(r_code_angle + 1'b1 >= r_angle_max)
						r_code_angle	<= 16'd0;
					else
						r_code_angle	<= r_code_angle + 1'b1;
					r_dist_state	<= DIST_SIG1;
					end	
				DIST_SIG1		:begin
					r_edge_data		<= w_dist_rddata;
					r_dist_rdaddr	<= r_dist_rdaddr + 1'b1;
				if(r_remainder_r >= 8'd100)begin
					if(r_shift_cnt == (r_space_num + 1'd1) && r_move_cnt < (r_point_diff - 1'd1))begin//if(r_shift_cnt == r_space_num + 1'b1)begin
						r_dist_sig		<= 1'b0;
						r_shift_cnt		<= 8'd1;
						r_dist_state	<= DIST_SIG1;
						r_move_cnt		<= r_move_cnt + 1'd1;
						if(r_remainder_r + r_remainder >= 8'd100)
							r_remainder_r <= r_remainder_r + r_remainder - 8'd100;
						else
							r_remainder_r <= r_remainder_r + r_remainder;
						end
					else begin
						r_dist_sig		<= 1'b1;
						r_point_cnt		<= r_point_cnt + 1'b1;
						r_shift_cnt		<= r_shift_cnt + 1'b1;
						r_dist_state	<= DIST_DELAY1;
						end
					end
				else begin
					if(r_shift_cnt == r_space_num && r_move_cnt < (r_point_diff - 1'd1))begin//if(r_shift_cnt == r_space_num + 1'b1)begin
						r_dist_sig		<= 1'b0;
						r_shift_cnt		<= 8'd1;
						r_dist_state	<= DIST_SIG1;
						r_move_cnt		<= r_move_cnt + 1'd1;
						//if(r_remainder_r + r_remainder >= 8'd100)
						//	r_remainder_r <= r_remainder_r + r_remainder - 8'd100;
						//else
							r_remainder_r <= r_remainder_r + r_remainder;
						end
					else begin
						r_dist_sig		<= 1'b1;
						r_point_cnt		<= r_point_cnt + 1'b1;
						r_shift_cnt		<= r_shift_cnt + 1'b1;
						r_dist_state	<= DIST_DELAY1;
						end	
					end
				end
				DIST_DELAY1		:begin
					r_dist_sig		<= 1'b0;
					if(r_dist_delay >= 10'd250)begin
						r_dist_delay	<= 10'd0;
						if(r_point_cnt >= r_angle_reso)
							r_dist_state	<= DIST_END;
						else
							r_dist_state	<= DIST_CODE1;
						end
					else begin
						r_dist_delay	<= r_dist_delay + 1'b1;
						r_dist_state	<= DIST_DELAY1;
						end
					end		
				DIST_ASSIGN2	:begin
					r_cal_sig		<= 1'b0;
					if(w_cal_done)begin
						r_space_num		<= w_quotient[7:0];
						r_dist_state	<= DIST_SIG2;
						end
					else
						r_dist_state	<= DIST_ASSIGN2;
					end
				DIST_CODE2		:begin
					if(r_code_angle + 1'b1 >= r_angle_max)
						r_code_angle	<= 16'd0;
					else
						r_code_angle	<= r_code_angle + 1'b1;
					r_dist_state	<= DIST_SIG2;
					end	
				DIST_SIG2		:begin
					r_edge_data		<= w_dist_rddata;
					r_dist_sig		<= 1'b1;
					r_dist_state	<= DIST_DELAY2;
					if(r_shift_cnt + 1'b1 >= r_space_num && r_shift_cnt != 8'd0)begin//if(r_shift_cnt + 1'b1 >= r_space_num && r_shift_cnt != 8'd0)begin
						r_shift_cnt		<= 8'd0;
						r_point_cnt		<= r_point_cnt + 1'b1;
						end
					else begin
						r_point_cnt		<= r_point_cnt + 1'b1;
						r_shift_cnt		<= r_shift_cnt + 1'b1;
						r_dist_rdaddr	<= r_dist_rdaddr + 1'b1;
						end
					end
				DIST_DELAY2		:begin
					r_dist_sig		<= 1'b0;
					if(r_dist_delay >= 10'd250)begin
						r_dist_delay 	<= 10'd0;
						if(r_point_cnt >= r_angle_reso)
							r_dist_state	<= DIST_END;
						else
							r_dist_state	<= DIST_CODE2;
						end
					else begin
						r_dist_delay	<= r_dist_delay + 1'b1;
						r_dist_state	<= DIST_DELAY2;
						end
					end
				DIST_END		:
					r_dist_state	<= DIST_IDLE;
				default:
					r_dist_state	<= DIST_IDLE;
				endcase
			end

	wire	[63:0]w_dist_rddata1;

	distance_ram U1
	(
		.WrClock				(i_clk_50m), 
		.WrClockEn				(r_dist_wren & r_pingorpang),
		.WrAddress				(r_dist_wraddr - 1'b1), 
		.Data					(r_dist_wrdata), 
		.WE						(1'b1), 
		.RdClock				(i_clk_50m),  
		.RdClockEn				(1'b1),
		.RdAddress				(r_dist_rdaddr),
		.Q						(w_dist_rddata1),
		.Reset					(1'b0)
	);
	
	wire	[63:0]w_dist_rddata2;
	
	distance_ram U2
	(
		.WrClock				(i_clk_50m), 
		.WrClockEn				(r_dist_wren & ~r_pingorpang),
		.WrAddress				(r_dist_wraddr - 1'b1), 
		.Data					(r_dist_wrdata), 
		.WE						(1'b1), 
		.RdClock				(i_clk_50m),  
		.RdClockEn				(1'b1),
		.RdAddress				(r_dist_rdaddr),
		.Q						(w_dist_rddata2),
		.Reset					(1'b0)
	);
	
	assign	w_dist_rddata = (r_pingorpang) ? w_dist_rddata2 : w_dist_rddata1;
	
	division U3
	(
		.i_clk_50m			(i_clk_50m)	,
		.i_rst_n			(i_rst_n)	,
		
		.i_cal_sig			(r_cal_sig)	,
		.i_dividend			({24'd0,r_point_num}),
		.i_divisor			({8'd0,r_point_diff})	,

		.o_quotient			(w_quotient),
		.o_remainder		(w_remainder),
		.o_cal_done			(w_cal_done)
	);
	
	multiplier3 U4
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				(i_fall_cnt), 
		.DataB				(r_angle_reso), 
		.Result				(w_mult1_result)
	);
	
	assign	o_dist_sig		= r_dist_sig;
	assign	o_code_angle	= r_code_angle;
	assign	o_edge_data		= r_edge_data;

endmodule 