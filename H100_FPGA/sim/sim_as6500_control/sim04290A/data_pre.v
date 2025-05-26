module data_pre
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_tdc_new_sig	,
	input	[15:0]	i_rise_data		,//ÉÏÉıÑØ
	input	[15:0]	i_fall_data		,//ÏÂ½µÑØ
	
	output	[15:0]	o_rise_data		,//ÉÏÉıÑØ
	output	[15:0]	o_pulse_data	,
	output			o_dist_cal_sig		
);

	reg		[3:0]	r_data_state 	= 4'd0;
	reg		[15:0]	r_rise_data		= 16'd0;//ÉÏÉıÑØ
	reg		[15:0]	r_pulse_data	= 16'd0;
	reg				r_dist_cal_sig	= 1'b0;
	
	reg				r_tdc_new_sig	= 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_tdc_new_sig	<= 1'b0;
		else
			r_tdc_new_sig	<= i_tdc_new_sig;
	end
	
	localparam	IDLE		=	4'b0000,
				DOT_IDLE	=	4'b0010,
				ASSIGN		=	4'b0100,
				END			=	4'b1000;
				

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_rise_data		<= 16'd0;
			r_pulse_data	<= 16'd0;
			r_dist_cal_sig	<= 1'b0;
			r_data_state	<= IDLE;
			end
		else begin
			case(r_data_state)
				IDLE		:begin
					r_rise_data		<= 16'd0;
					r_pulse_data	<= 16'd0;
					r_dist_cal_sig	<= 1'b0;
					r_data_state	<= DOT_IDLE;
				end
				DOT_IDLE	:begin
					r_dist_cal_sig		<= 1'b0;
					if(r_tdc_new_sig)
						r_data_state	<= ASSIGN;
					else
						r_data_state	<= DOT_IDLE;
				end
				ASSIGN		:begin
					if(i_fall_data >= i_rise_data)begin
						r_rise_data		<= i_rise_data;
						r_pulse_data	<= i_fall_data - i_rise_data;
					end
					else begin
						r_rise_data		<= 16'd0;
						r_pulse_data	<= 16'd0;
					end
					r_data_state	<= END;
				end
				END			:begin	
					r_dist_cal_sig	<= 1'b1;
					r_data_state	<= DOT_IDLE;
				end
				default:
					r_data_state	<= IDLE;
			endcase
		end
	end
			
	assign	o_rise_data		= r_rise_data;//ÉÏÉıÑØ
	assign	o_pulse_data	= r_pulse_data;
	assign	o_dist_cal_sig	= r_dist_cal_sig;

endmodule
