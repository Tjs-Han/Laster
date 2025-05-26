module dist_calculate
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[15:0]	i_start_index		,
	input	[15:0]	i_stop_index		,
	input			i_tdc_new_sig		,
	input	[15:0]	i_code_angle		,
	input	[15:0]	i_rise_data			,//ÉÏÉıÑØ
	input	[15:0]	i_fall_data			,//ÏÂ½µÑØ
	
	input	[15:0]	i_rise_start		,
	input	[15:0]	i_pulse_start		,
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	output	[17:0]	o_coe_sram_addr		,
	input	[15:0]	i_coe_sram_data		,
	
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		
);
	
	reg		[15:0]	r_pulse_value = 16'd0;
	reg		[15:0]	r_rise_data	= 16'd0;//ÉÏÉıÑØ
	reg		[15:0]	r_rise_start = 16'd0;
	reg		[15:0]	r_rise_step = 16'd0;
	reg		[15:0]	r_rise_index = 16'd0;
	reg		[15:0]	r_rise_remain = 16'd0;
	reg		[15:0]	r_pulse_start = 16'd0;
	reg		[15:0]	r_pulse_step = 16'd0;
	reg		[15:0]	r_distance_min = 16'd50;
	reg		[15:0]	r_distance_max = 16'd25000;	
	reg		[15:0]	r_pulse_index = 16'd0;
	reg		[15:0]	r_pulse_remain = 16'd0;
	reg		[31:0]	r_dist_data	= 32'd0;
	reg		[15:0]	r_rssi_data	= 16'd0;
	reg				r_dist_new_sig = 1'b0;
	reg		[17:0]	r_coe_sram_addr = 18'd0;
	reg		[15:0]	r_dist_coe_ll = 16'd0;
	reg		[15:0]	r_dist_coe_lh = 16'd0;
	reg		[15:0]	r_dist_coe_hl = 16'd0;
	reg		[15:0]	r_dist_coe_hh = 16'd0;
	reg		[31:0]	r_dist_data_l = 32'd0;
	reg		[31:0]	r_dist_data_h = 32'd0;
	reg		[15:0]	r_delay_cnt	= 16'd0;
	
	reg		[15:0]	r_cal_state = 16'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_distance_min 	<= 16'd50;
			r_distance_max 	<= 16'd25000;
			end			
		else begin
			r_distance_min 	<= i_distance_min;
			r_distance_max 	<= i_distance_max;	
			end
			
	parameter		CAL_IDLE		=	16'b0000_0000_0000_0000,
					CAL_DOT_IDLE	=	16'b0000_0000_0000_0010,
					CAL_PULSE_INDEX	=	16'b0000_0000_0000_0100,
					CAL_RISE_INDEX	=	16'b0000_0000_0000_1000,
					CAL_READ_DIST1	=	16'b0000_0000_0001_0000,
					CAL_READ_DIST2	=	16'b0000_0000_0010_0000,
					CAL_READ_DIST3	=	16'b0000_0000_0100_0000,
					CAL_READ_DIST4	=	16'b0000_0000_1000_0000,
					CAL_DIST_CAL1	=	16'b0000_0001_0000_0000,
					CAL_DELAY		=	16'b0000_0010_0000_0000,
					CAL_DIST_CAL2	=	16'b0000_0100_0000_0000,
					CAL_DELAY2		=	16'b0000_1000_0000_0000,
					CAL_END			=	16'b0001_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_cal_state		<= CAL_IDLE;
		else begin
			case(r_cal_state)
				CAL_IDLE		:begin
					r_pulse_value 		<= 16'd0;
					r_rise_data			<= 16'd0;//ÉÏÉıÑØ
					r_rise_start 		<= 16'd0;
					r_rise_step			<= 16'd0;
					r_rise_index 		<= 16'd0;
					r_rise_remain 		<= 16'd0;
					r_pulse_start 		<= 16'd0;
					r_pulse_step		<= 16'd0;
					r_pulse_index 		<= 16'd0;
					r_pulse_remain 		<= 16'd0;
					r_dist_data			<= 32'd0;
					r_rssi_data			<= 16'd0;
					r_dist_new_sig 		<= 1'b0;
					r_coe_sram_addr 	<= 18'd0;
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_lh 		<= 16'd0;
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_hh 		<= 16'd0;
					r_dist_data_l 		<= 32'd0;
					r_dist_data_h 		<= 32'd0;
					r_delay_cnt			<= 16'd0;
					if(i_code_angle + 16'd10 >= i_start_index)
						r_cal_state			<= CAL_DOT_IDLE;
					end
				CAL_DOT_IDLE	:begin
					r_dist_new_sig		<= 1'b0;
					if(i_tdc_new_sig)begin
						if(i_fall_data <= i_rise_data)begin
							r_dist_data			<= 16'd0;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end
						else if(i_rise_data < i_rise_start)begin
							r_dist_data			<= 16'd0;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end
						else if((i_fall_data - i_rise_data) < i_pulse_start)begin
							r_dist_data			<= 16'd0;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end
						else begin
							r_rssi_data			<= i_fall_data - i_rise_data;
							r_rise_data			<= i_rise_data;
							r_pulse_start		<= i_pulse_start;
							r_pulse_step		<= 16'd128;
							r_pulse_index		<= 16'd0;
							r_rise_start		<= i_rise_start;
							r_rise_step			<= 16'd64;
							r_rise_index		<= 16'd0;
							r_cal_state			<= CAL_PULSE_INDEX;
							end
						end
					end
				CAL_PULSE_INDEX	:begin
					if(r_rssi_data <= r_pulse_start)begin
						r_cal_state			<= CAL_RISE_INDEX;
						r_pulse_remain		<= r_rssi_data + r_pulse_step - r_pulse_start;
						end
					else if(r_pulse_index >= 16'd128)begin
						r_dist_data			<= 16'd0;
						r_rssi_data			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else begin
						r_pulse_start		<= r_pulse_start + r_pulse_step;
						r_pulse_index		<= r_pulse_index + 1'b1;
						end
					end
				CAL_RISE_INDEX	:begin
					if(r_rise_data <= r_rise_start)begin
						r_cal_state			<= CAL_READ_DIST1;
						r_rise_remain		<= r_rise_data + r_rise_step - r_rise_start;
						r_coe_sram_addr 	<= ((r_pulse_index - 1'b1) << 4'd9) + r_rise_index - 1'b1;//((r_rise_index - 1'b1) << 3'd7) + r_pulse_index - 1'b1;
						end
					else if(r_rise_index >= 16'd512)begin
						r_dist_data			<= 16'd0;
						r_rssi_data			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else begin
						r_rise_start		<= r_rise_start + r_rise_step;
						r_rise_index		<= r_rise_index + 1'b1;
						end
					end
				CAL_READ_DIST1	:begin
					r_dist_coe_ll		<= i_coe_sram_data;
					r_coe_sram_addr		<= ((r_pulse_index - 1'b1) << 4'd9) + r_rise_index;//((r_rise_index - 1'b1) << 3'd7) + r_pulse_index;
					r_cal_state			<= CAL_READ_DIST2;
					end
				CAL_READ_DIST2	:begin
					r_dist_coe_lh		<= i_coe_sram_data;
					r_coe_sram_addr		<= (r_pulse_index << 4'd9) + r_rise_index - 1'b1;//(r_rise_index << 3'd7) + r_pulse_index - 1'b1;
					r_cal_state			<= CAL_READ_DIST3;
					end
				CAL_READ_DIST3	:begin
					r_dist_coe_hl		<= i_coe_sram_data;
					r_coe_sram_addr		<= (r_pulse_index << 4'd9) + r_rise_index;//(r_rise_index << 3'd7) + r_pulse_index;
					r_cal_state			<= CAL_READ_DIST4;
					end
				CAL_READ_DIST4	:begin
					r_dist_coe_hh		<= i_coe_sram_data;
					r_coe_sram_addr		<= 18'd0;
					r_cal_state			<= CAL_DIST_CAL1;
					end
				CAL_DIST_CAL1	:begin
					if(r_dist_coe_ll == 0 || r_dist_coe_lh == 0 || r_dist_coe_hl == 0 || r_dist_coe_hh == 0)begin
						r_dist_data			<= 16'd0;
						r_rssi_data			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else begin
						r_dist_data_l		<= r_rise_remain * (r_dist_coe_lh - r_dist_coe_ll);
						r_dist_data_h		<= r_rise_remain * (r_dist_coe_hh - r_dist_coe_hl);
						//r_dist_data_l		<= r_rise_remain * (r_dist_coe_hl - r_dist_coe_ll)/r_rise_step + r_dist_coe_ll;
						//r_dist_data_h		<= r_rise_remain * (r_dist_coe_hh - r_dist_coe_lh)/r_rise_step + r_dist_coe_lh;
						r_cal_state			<= CAL_DELAY;
						end
					end
				CAL_DELAY		:begin
					if(r_delay_cnt >= 16'd19)begin
						r_dist_data_l		<= r_dist_data_l + r_dist_coe_ll;
						r_dist_data_h		<= r_dist_data_h + r_dist_coe_hl;
						r_cal_state			<= CAL_DIST_CAL2;
						r_delay_cnt			<= 16'd0;
						end
					else if(r_delay_cnt == 16'd9)begin
						r_dist_data_l		<= r_dist_data_l >> 4'd6;
						r_dist_data_h		<= r_dist_data_h >> 4'd6;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end
				CAL_DIST_CAL2	:begin
					r_dist_data			<= r_pulse_remain * (r_dist_data_h - r_dist_data_l);
					//r_dist_data			<= r_pulse_remain * (r_dist_data_h - r_dist_data_l)/r_pulse_step + r_dist_data_l;
					r_cal_state			<= CAL_DELAY2;
					end
				CAL_DELAY2		:begin
					if(r_delay_cnt >= 16'd19)begin
						r_cal_state			<= CAL_END;
						r_dist_data			<= r_dist_data + r_dist_data_l;
						r_delay_cnt			<= 16'd0;
						end
					else if(r_delay_cnt == 16'd9)begin
						r_dist_data			<= r_dist_data >> 4'd7;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end		
				CAL_END			:begin
					if(r_rssi_data <= 16'd400)
						r_dist_data			<= 32'd0;
					else if(r_dist_data[15:0] <= r_distance_min || r_dist_data[15:0] >= r_distance_max)
						r_dist_data			<= 32'd0;
					r_dist_new_sig		<= 1'b1;
					if(i_code_angle >= i_stop_index + 4'd10)
						r_cal_state			<= CAL_IDLE;
					else
						r_cal_state			<= CAL_DOT_IDLE;
					end
				default:r_cal_state			<= CAL_IDLE;
				endcase
			end
						
						
	assign	o_coe_sram_addr		= r_coe_sram_addr | 18'h10000;
	
	assign	o_dist_data			= r_dist_data[15:0];
	assign	o_rssi_data			= r_rssi_data;
	assign	o_dist_new_sig		= r_dist_new_sig;

endmodule 