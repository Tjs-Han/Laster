module division_2
(
	input			i_clk_50m		,
	input			i_rst_n			,
	
	input			i_cal_sig		,
	input	[15:0]	i_dividend		,
	input	[15:0]	i_dividend_sub	,
	input	[15:0]	i_divisor		,

	output	[15:0]	o_quotient		,
	output			o_cal_done
);

	reg		[3:0]	r_cal_state = 4'd0;
	reg		[15:0]	r_cal_cnt = 16'd0;
	reg		[15:0]	r_dividend = 16'd0;
	reg		[15:0]	r_divisor = 16'd0;
	reg				r_cal_done = 1'b0;
	reg		[15:0]	r_quotient = 16'd0;
	
	parameter	CAL_IDLE	= 4'b0000,
				CAL_ASSIGN	= 4'b0001,
				CAL_COMP	= 4'b0010,
				CAL_END		= 4'b0100,
				CAL_OVER	= 4'b1000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_dividend	<= 16'd0;
			r_divisor	<= 16'd0;
			r_cal_cnt	<= 16'd0;
			r_quotient	<= 16'd0;
			r_cal_done	<= 1'b0;
			r_cal_state	<= CAL_IDLE;
			end
		else begin
			case(r_cal_state)
				CAL_IDLE:begin
					r_dividend	<= 16'd0;
					r_divisor	<= 16'd0;
					r_cal_cnt	<= 16'd0;
					r_quotient	<= 16'd0;
					r_cal_done	<= 1'b0;
					if(i_cal_sig)
						r_cal_state	<= CAL_ASSIGN;
					end
				CAL_ASSIGN:begin
					r_divisor	<= i_divisor;
					r_dividend	<= i_dividend - i_dividend_sub;
					r_cal_cnt	<= 16'd0;
					if(i_divisor == 16'd0 || i_dividend <= i_dividend_sub)
						r_cal_state	<= CAL_END;
					else
						r_cal_state	<= CAL_COMP;
					end
				CAL_COMP:begin
					if(r_cal_cnt >= 16'd255)
						r_cal_state	<= CAL_END;
					else if(r_dividend >= r_divisor)begin
						r_dividend	<= r_dividend - r_divisor;
						r_cal_cnt	<= r_cal_cnt + 1'b1;
						end
					else 
						r_cal_state	<= CAL_END;
					end
				CAL_END:begin
					r_cal_done	<= 1'b1;
					r_quotient	<= r_cal_cnt;
					r_cal_state	<= CAL_OVER;
					end
				CAL_OVER:begin
					r_cal_done	<= 1'b0;
					r_cal_state	<= CAL_IDLE;
					end
				default:r_cal_state	<= CAL_IDLE;
				endcase
			end
						
	assign	o_quotient = r_quotient;
	assign	o_cal_done = r_cal_done;

endmodule 