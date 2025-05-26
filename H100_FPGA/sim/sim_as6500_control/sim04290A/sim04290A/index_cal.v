module index_cal
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input	[15:0]	i_rise_data		,//…œ…˝—ÿ
	input	[15:0]	i_pulse_data	,
	
	input			i_dist_cal_sig	,
	input	[15:0]	i_rise_divid	,
	input	[15:0]	i_pulse_start	,
	input	[15:0]	i_pulse_divid	,
	
	output	[3:0]	o_index_flag	,
	output	[15:0]	o_rise_index	,
	output	[15:0]	o_rise_remain	,
	output	[15:0]	o_pulse_index	,
	output	[15:0]	o_pulse_remain	
);

	reg		[7:0]	r_index_state = 8'd0;
	
	reg		[3:0]	r_index_flag	= 4'd0;
	reg		[15:0]	r_rise_index	= 16'd0;
	reg		[15:0]	r_rise_index1	= 16'd0;
	reg		[15:0]	r_rise_index2	= 16'd0;
	reg		[15:0]	r_rise_remain	= 16'd0;
	reg		[15:0]	r_pulse_index	= 16'd0;
	reg		[15:0]	r_pulse_index1	= 16'd0;
	reg		[15:0]	r_pulse_index2	= 16'd0;
	reg		[15:0]	r_pulse_remain	= 16'd0;
	
	localparam		IDLE			= 8'b00000000,
					RISE_PRE		= 8'b00000001,
					RISE_INDEX1		= 8'b00000010,
					RISE_INDEX2		= 8'b00000100,
					PULSE_PRE		= 8'b00001000,
					PULSE_INDEX1	= 8'b00010000,
					PULSE_INDEX2	= 8'b00100000,
					PULSE_REMAIN	= 8'b01000000,
					END				= 8'b10000000;
					
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_index_flag		<= 4'b0000;
			r_rise_index		<= 16'd0;
			r_rise_index1		<= 16'd0;
			r_rise_index2		<= 16'd0;
			r_rise_remain		<= 16'd0;
			r_pulse_index		<= 16'd0;
			r_pulse_index1		<= 16'd0;
			r_pulse_index2		<= 16'd0;
			r_pulse_remain		<= 16'd0;
			r_index_state 		<= IDLE;
		end
		else begin
			case(r_index_state)
				IDLE		:begin
					r_index_flag		<= 4'b0000;
					if(i_dist_cal_sig)begin
						r_rise_index		<= 16'd0;
						r_rise_index1		<= 16'd0;
						r_rise_index2		<= 16'd0;
						r_rise_remain		<= 16'd0;
						r_pulse_index		<= 16'd0;
						r_pulse_index1		<= 16'd0;
						r_pulse_index2		<= 16'd0;
						r_pulse_remain		<= 16'd0;
						r_index_state 		<= RISE_PRE;
					end
					else
						r_index_state = IDLE;
				end
				RISE_PRE	:begin
					if(i_rise_data >= 16'd52480)begin
						r_index_flag		<= 4'b1001;
						r_index_state		<= END;
					end
					else if(i_rise_data[15:6] >= i_rise_divid[15:6])begin
						r_index_flag[2]		<= 1'b1;
						r_index_state		<= RISE_INDEX2;
					end
					else begin
						r_index_flag[2]		<= 1'b0;
						r_index_state		<= RISE_INDEX1;
					end
				end
				RISE_INDEX1	:begin
					r_rise_index1		<= i_rise_data >> 3'd6;
					r_rise_index2		<= 16'd0;
					r_index_state		<= PULSE_PRE;
				end
				RISE_INDEX2	:begin
					r_rise_index1		<= i_rise_divid >> 3'd6;
					r_rise_index2		<= (i_rise_data - i_rise_divid) >> 3'd7;
					r_index_state		<= PULSE_PRE;
				end
				PULSE_PRE	:begin
					r_rise_index		<= r_rise_index1 + r_rise_index2;
					r_rise_remain		<= i_rise_data - {r_rise_index1[9:0], 6'd0} - {r_rise_index2[8:0], 7'd0};
					if(i_pulse_data	<= i_pulse_start)begin
						r_index_flag		<= 4'b1001;
						r_index_state		<= END;
					end
					else if(i_pulse_data >= i_pulse_divid)begin
						r_index_flag[1]		<= 1'b1;
						r_index_state		<= PULSE_INDEX2;
					end
					else begin
						r_index_flag[1]		<= 1'b0;
						r_index_state		<= PULSE_INDEX1;
					end
				end
				PULSE_INDEX1:begin
					r_index_state		<= PULSE_REMAIN;
					r_pulse_index1		<= (i_pulse_data - i_pulse_start) >> 3'd5;
					r_pulse_index2		<= 16'd0;
				end
				PULSE_INDEX2:begin
					r_index_state		<= PULSE_REMAIN;
					r_pulse_index1		<= (i_pulse_divid - i_pulse_start) >> 3'd5;
					r_pulse_index2		<= (i_pulse_data - i_pulse_divid) >> 3'd7;
				end
				PULSE_REMAIN:begin
					r_pulse_index		<= r_pulse_index1 + r_pulse_index2;
					r_pulse_remain		<= i_pulse_data - {r_pulse_index1[10:0],5'd0} - {r_pulse_index2[8:0], 7'd0} - i_pulse_start;
					r_index_state		<= END;
				end
				END			:begin
					r_index_flag[3]		<= 1'b1;
					r_index_state		<= IDLE;
				end
				default:
					r_index_state		<= IDLE;
			endcase
		end
	end

	assign	o_index_flag	= r_index_flag;
	assign	o_rise_index	= r_rise_index;
	assign	o_rise_remain	= r_rise_remain;
	assign	o_pulse_index	= r_pulse_index;
	assign	o_pulse_remain	= r_pulse_remain;

endmodule 