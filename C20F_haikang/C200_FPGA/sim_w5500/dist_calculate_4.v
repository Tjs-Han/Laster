module dist_calculate_4
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[15:0]	i_stop_index		,
	input			i_tdc_new_sig		,
	input	[15:0]	i_code_angle		,
	input	[15:0]	i_rise_data			,//ÉÏÉıÑØ
	input	[15:0]	i_fall_data			,//ÏÂ½µÑØ¡¢
	
	input			i_dirt_warn			,//ÔàÎÛ±¨¾¯
	
	input	[15:0]	i_rise_start		,
	input	[15:0]	i_pulse_start		,
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	output	[17:0]	o_coe_sram_addr		,
	input	[15:0]	i_coe_sram_data		,
	
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		,
	
	input          i_add_sub_flag       ,
	input  [15:0]  i_dist_temp_value   ,
	
	input  [15:0]  i_fixed_value       ,
	input           i_fixed_value_flag  ,

	input			i_dirt_mode			,
	input  [7:0]	i_dirt_points		,
	input  [15:0]  i_dirt_rise			,
	output			o_dirt_warn
);

	parameter		SRAM_COE_BASE = 18'h10000,
					SRAM_RSSI_BASE	= 18'h04000;
	
	reg		[15:0]	r_pulse_value = 16'd0;
	reg		[15:0]	r_rise_data	= 16'd0;//ÉÏÉıÑØ
	reg		[15:0]	r_rise_index = 16'd0;
	reg		[15:0]	r_rise_remain = 16'd0;
	reg		[15:0]	r_pulse_start = 16'd0;
	reg		[15:0]	r_pulse_divid = 16'd0;
	reg		[15:0]	r_distance_min = 16'd50;
	reg		[15:0]	r_distance_max = 16'd25000;	
	reg		[15:0]	r_pulse_index1 = 16'd0;
	reg		[15:0]	r_pulse_index2 = 16'd0;
	reg		[15:0]	r_pulse_remain = 16'd0;
	reg		[31:0]	r_dist_data	= 32'd0;
	reg		[15:0]	r_pulse_data = 16'd0;
	reg		[15:0]	r_rssi_data	= 16'd0;
	reg				r_dist_new_sig = 1'b0;
	
	reg		[17:0]	r_coe_sram_addr = 18'd0;
	reg		[15:0]	r_dist_coe_ll = 16'd0;
	reg		[15:0]	r_dist_coe_lh = 16'd0;
	reg		[15:0]	r_dist_coe_hl = 16'd0;
	reg		[15:0]	r_dist_coe_hh = 16'd0;
	reg		[31:0]	r_dist_data_l = 32'd0;
	reg		[31:0]	r_dist_data_h = 32'd0;
	
	reg				r_sign_coe_ll = 1'b0;
	reg				r_sign_coe_lh = 1'b0;
	reg				r_sign_coe_hl = 1'b0;
	reg				r_sign_coe_hh = 1'b0;
	reg				r_sign_data_l = 1'b0;
	reg				r_sign_data_h = 1'b0;
	reg				r_sign_data	  = 1'b0;
	
	reg		[15:0]	r_dist_index = 16'd0;
	reg		[15:0]	r_dist_remain = 16'd0;
	reg		[15:0]	r_dist_value = 16'd0;
	reg		[15:0]	r_rssi_para	 = 16'd0;
	reg		[15:0]	r_rssi_para1 = 16'd0;
	reg		[15:0]	r_rssi_para2 = 16'd0;
	reg		[15:0]	r_pulse_para  = 16'd0;
	reg		[15:0]	r_pulse_para1 = 16'd0;
	reg		[15:0]	r_pulse_para2 = 16'd0;
	reg     [15:0] r_rise_post = 16'd0;
	reg     [15:0] r_pulse_post = 16'd0;
	
	reg		[15:0]	r_delay_cnt	= 16'd0;
	
	reg		[15:0]	r_pulse_max = 16'd0;
	reg		[15:0]	r_rise_max = 16'd0;
	
	reg				r_incr_polar  = 1'b0;
	reg 	[15:0]	r_mult1_dataA = 16'd0;
    reg 	[15:0]	r_mult1_dataB = 16'd0;
	reg				r_mult1_en	  = 1'b0;
    wire	[31:0]	w_mult1_result;
	
	reg 	[15:0]	r_mult2_dataA = 16'd0;
    reg 	[15:0]	r_mult2_dataB = 16'd0;
	reg				r_mult2_en	  = 1'b0;
    wire	[31:0]	w_mult2_result;
	
	reg				r_divide_en	  = 1'b0;
	wire	[15:0]	w_divide_result;
	wire			w_divide_done;
	
	reg		[27:0]	r_cal_state = 28'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_max		<= 16'd0;
		else
			r_pulse_max		<= i_pulse_start + 16'd32768;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_max		<= 16'd0;
		else
			r_rise_max		<= 16'd32768;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_distance_min 	<= 16'd50;
			r_distance_max 	<= 16'd25000;
			end			
		else begin
			r_distance_min 	<= i_distance_min;
			r_distance_max 	<= i_distance_max;	
			end
			
	reg		[7:0]	r_rise_min_cnt = 8'd0;
	reg		[7:0]	r_rise_min_cnt_r = 8'd0;	
	reg			    r_dirt_warn = 1'b0;
	reg		[15:0] 	r_code_angle_0 = 16'd0;
	reg		[15:0] 	r_code_angle_1 = 16'd0;	
	reg				r_dirt_mode = 1'b0;
			
	parameter		CAL_IDLE			=	28'b0000_0000_0000_0000_0000_0000_0000,
					CAL_DOT_IDLE		=	28'b0000_0000_0000_0000_0000_0000_0010,
					CAL_PULSE_PRE		=	28'b0000_0000_0000_0000_0000_0000_0100,
					CAL_PULSE_INDEX1	=	28'b0000_0000_0000_0000_0000_0000_1000,
					CAL_PULSE_INDEX2	=	28'b0000_0000_0000_0000_0000_0001_0000,
					CAL_RISE_INDEX		=	28'b0000_0000_0000_0000_0000_0010_0000,
					CAL_READ_PRE		=	28'b0000_0000_0000_0000_0000_0100_0000,
					CAL_READ_DIST1		=	28'b0000_0000_0000_0000_0000_1000_0000,
					CAL_READ_DIST2		=	28'b0000_0000_0000_0000_0001_0000_0000,
					CAL_READ_DIST3		=	28'b0000_0000_0000_0000_0010_0000_0000,
					CAL_READ_DIST4		=	28'b0000_0000_0000_0000_0100_0000_0000,
					CAL_DIST_CAL1		=	28'b0000_0000_0000_0000_1000_0000_0000,
					CAL_DELAY			=	28'b0000_0000_0000_0001_0000_0000_0000,
					CAL_DIST_CAL2		=	28'b0000_0000_0000_0010_0000_0000_0000,
					CAL_DELAY2			=	28'b0000_0000_0000_0100_0000_0000_0000,
					CAL_DIST_END		=	28'b0000_0000_0000_1000_0000_0000_0000,
					CAL_DIST_INDEX		=	28'b0000_0000_0001_0000_0000_0000_0000,
					CAL_RSSI_PRE		=	28'b0000_0000_0010_0000_0000_0000_0000,
					CAL_RSSI_READ1		=	28'b0000_0000_0100_0000_0000_0000_0000,
					CAL_RSSI_READ2		=	28'b0000_0000_1000_0000_0000_0000_0000,
					CAL_RSSI_READ3		=	28'b0000_0001_0000_0000_0000_0000_0000,
					CAL_RSSI_READ4		=	28'b0000_0010_0000_0000_0000_0000_0000,
					CAL_RSSI_CAL		=	28'b0000_0100_0000_0000_0000_0000_0000,
					CAL_RSSI_DELAY		=	28'b0000_1000_0000_0000_0000_0000_0000,
					CAL_RSSI_WAIT		=	28'b0001_0000_0000_0000_0000_0000_0000,
					CAL_END				=	28'b0010_0000_0000_0000_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_dist_index 		<= 16'd0;
			r_dist_remain 		<= 16'd0;
			r_dist_value 		<= 16'd0;
			r_rssi_para			<= 16'd0;
			r_rssi_para1		<= 16'd0;
			r_rssi_para2		<= 16'd0;
			r_pulse_para		<= 16'd0;
			r_pulse_para1		<= 16'd0;
			r_pulse_para2		<= 16'd0;
			r_divide_en			<= 1'b0;
			r_pulse_value 		<= 16'd0;
			r_rise_data			<= 16'd0;//ÉÏÉıÑØ
			r_rise_index 		<= 16'd0;
			r_rise_remain 		<= 16'd0;
			r_pulse_start 		<= 16'd0;
			r_pulse_divid		<= 16'd0;
			r_pulse_index1 		<= 16'd0;
			r_pulse_index2 		<= 16'd0;
			r_pulse_remain 		<= 16'd0;
			r_dist_data			<= 32'd0;
			r_rssi_data			<= 16'd0;
			r_pulse_data		<= 16'd0;
			r_dist_new_sig 		<= 1'b0;
			r_coe_sram_addr 	<= 18'd0;
			r_dist_coe_ll 		<= 16'd0;
			r_dist_coe_lh 		<= 16'd0;
			r_dist_coe_ll 		<= 16'd0;
			r_dist_coe_hh 		<= 16'd0;
			r_dist_data_l 		<= 32'd0;
			r_dist_data_h 		<= 32'd0;
			r_sign_coe_ll 		<= 1'b0;
			r_sign_coe_lh 		<= 1'b0;
			r_sign_coe_hl 		<= 1'b0;
			r_sign_coe_hh 		<= 1'b0;
			r_sign_data_l 		<= 1'b0;
			r_sign_data_h 		<= 1'b0;
			r_sign_data			<= 1'b0;
			r_delay_cnt			<= 16'd0;
			r_incr_polar		<= 1'b0;
			r_cal_state			<= CAL_IDLE;
			end
		else begin
			case(r_cal_state)
				CAL_IDLE		:begin
					r_dist_index 		<= 16'd0;
					r_dist_remain 		<= 16'd0;
					r_dist_value 		<= 16'd0;
					r_rssi_para			<= 16'd0;
					r_rssi_para1		<= 16'd0;
					r_rssi_para2		<= 16'd0;
					r_pulse_para		<= 16'd0;
					r_pulse_para1		<= 16'd0;
					r_pulse_para2		<= 16'd0;
					r_divide_en			<= 1'b0;
					r_pulse_value 		<= 16'd0;
					r_rise_data			<= 16'd0;//ÉÏÉıÑØ
					r_rise_index 		<= 16'd0;
					r_rise_remain 		<= 16'd0;
					r_pulse_start 		<= 16'd0;
					r_pulse_divid		<= 16'd0;
					r_pulse_index1 		<= 16'd0;
					r_pulse_index2 		<= 16'd0;
					r_pulse_remain 		<= 16'd0;
					r_dist_data			<= 32'd0;
					r_rssi_data			<= 16'd0;
					r_pulse_data		<= 16'd0;
					r_dist_new_sig 		<= 1'b0;
					r_coe_sram_addr 	<= 18'd0;
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_lh 		<= 16'd0;
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_hh 		<= 16'd0;
					r_dist_data_l 		<= 32'd0;
					r_dist_data_h 		<= 32'd0;
					r_sign_coe_ll 		<= 1'b0;
					r_sign_coe_lh 		<= 1'b0;
					r_sign_coe_hl 		<= 1'b0;
					r_sign_coe_hh 		<= 1'b0;
					r_sign_data_l 		<= 1'b0;
					r_sign_data_h 		<= 1'b0;
					r_sign_data			<= 1'b0;
					r_delay_cnt			<= 16'd0;
					r_incr_polar		<= 1'b0;
					if(i_code_angle == 16'd0)
						r_cal_state			<= CAL_DOT_IDLE;
					end
				CAL_DOT_IDLE	:begin
					r_dist_new_sig		<= 1'b0;
					r_rise_post         <= r_rise_data;
					r_pulse_post        <= r_pulse_data >> 1'd1;

					if(i_tdc_new_sig)begin
						if(i_fall_data <= i_rise_data)begin
							r_dist_data			<= 32'd65534;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end
						else if((i_fall_data - i_rise_data) < i_pulse_start)begin
							r_dist_data			<= 32'd65533;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end
						else if((i_fall_data - i_rise_data) >= r_pulse_max)begin
							r_dist_data			<= 32'd65535;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
							end					
						else begin
							r_pulse_data		<= i_fall_data - i_rise_data;
							r_rise_data			<= i_rise_data;
							r_pulse_start		<= i_pulse_start;
							r_pulse_divid		<= i_rise_start;
							r_pulse_index1 		<= 16'd0;
							r_pulse_index2 		<= 16'd0;
							r_rise_index		<= 16'd0;
							r_incr_polar		<= 1'b0;
							r_sign_coe_ll 		<= 1'b0;
							r_sign_coe_lh 		<= 1'b0;
							r_sign_coe_hl 		<= 1'b0;
							r_sign_coe_hh 		<= 1'b0;
							r_sign_data_l 		<= 1'b0;
							r_sign_data_h 		<= 1'b0;
							r_sign_data			<= 1'b0;
							r_dist_index 		<= 16'd0;
							r_dist_remain 		<= 16'd0;
							r_dist_value 		<= 16'd0;
							r_rssi_para			<= 16'd0;
							r_rssi_para1		<= 16'd0;
							r_rssi_para2		<= 16'd0;
							r_pulse_para1		<= 16'd0;
							r_pulse_para2		<= 16'd0;
							r_divide_en			<= 1'b0;
							r_cal_state			<= CAL_PULSE_PRE;
							end
						end
					end
				CAL_PULSE_PRE	:begin
					if(r_rise_post == i_rise_data&&(i_fall_data-i_rise_data) <= r_pulse_post)
					  begin
                      r_dist_data <= 32'd0;
                      r_rssi_data <= 16'd0;
                      r_cal_state <= CAL_END;
                    end
					else if((i_fall_data - i_rise_data) <= r_pulse_divid)
						r_cal_state			<= CAL_PULSE_INDEX1;
					else
						r_cal_state			<= CAL_PULSE_INDEX2;
					end
				CAL_PULSE_INDEX1:begin
					r_cal_state			<= CAL_RISE_INDEX;
					r_pulse_index1		<= (r_pulse_data - r_pulse_start) >> 3'd5;
					r_pulse_index2		<= 16'd0;
					end
				CAL_PULSE_INDEX2:begin
					r_cal_state			<= CAL_RISE_INDEX;
					r_pulse_index1		<= (r_pulse_divid - r_pulse_start) >> 3'd5;
					r_pulse_index2		<= (r_pulse_data - r_pulse_divid) >> 3'd7;
					end
				CAL_RISE_INDEX	:begin
					if(r_rise_data >= r_rise_max)begin
						r_dist_data			<= 32'd0;
						r_rssi_data			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else begin
						r_rise_index		<= r_rise_data >> 3'd6;
						r_pulse_value		<= {r_pulse_index1[10:0],5'd0} + {r_pulse_index2[8:0], 7'd0};
						r_cal_state			<= CAL_READ_PRE;
						end
					end
				CAL_READ_PRE	:begin
					r_pulse_remain		<= r_pulse_data - r_pulse_start - r_pulse_value;
					r_rise_remain		<= r_rise_data - {r_rise_index[9:0], 6'd0};
					r_coe_sram_addr 	<= SRAM_COE_BASE + ((r_pulse_index1 + r_pulse_index2) << 4'd9) + r_rise_index;
					r_cal_state			<= CAL_READ_DIST1;
					end
				CAL_READ_DIST1	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_ll		<= i_coe_sram_data[11:0];
						r_sign_coe_ll		<= 1'b1;
						end
					else begin
						r_dist_coe_ll		<= i_coe_sram_data;
						r_sign_coe_ll		<= 1'b0;
						end
					r_coe_sram_addr		<= SRAM_COE_BASE + ((r_pulse_index1 + r_pulse_index2) << 4'd9) + r_rise_index + 1'b1;
					r_cal_state			<= CAL_READ_DIST2;
					end
				CAL_READ_DIST2	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_lh		<= i_coe_sram_data[11:0];
						r_sign_coe_lh		<= 1'b1;
						end
					else begin
						r_dist_coe_lh		<= i_coe_sram_data;
						r_sign_coe_lh		<= 1'b0;
						end
					r_coe_sram_addr		<= SRAM_COE_BASE + ((r_pulse_index1 + r_pulse_index2 + 1'b1) << 4'd9) + r_rise_index;
					r_cal_state			<= CAL_READ_DIST3;
					end
				CAL_READ_DIST3	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_hl		<= i_coe_sram_data[11:0];
						r_sign_coe_hl		<= 1'b1;
						end
					else begin
						r_dist_coe_hl		<= i_coe_sram_data;
						r_sign_coe_hl		<= 1'b0;
						end
					r_coe_sram_addr		<= SRAM_COE_BASE + ((r_pulse_index1 + r_pulse_index2 + 1'b1) << 4'd9) + r_rise_index + 1'b1;
					r_cal_state			<= CAL_READ_DIST4;
					end
				CAL_READ_DIST4	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_hh		<= i_coe_sram_data[11:0];
						r_sign_coe_hh		<= 1'b1;
						end
					else begin
						r_dist_coe_hh		<= i_coe_sram_data;
						r_sign_coe_hh		<= 1'b0;
						end
					r_coe_sram_addr		<= 18'd0;
					r_cal_state			<= CAL_DIST_CAL1;
					end
				CAL_DIST_CAL1	:begin
					if(r_dist_coe_ll == 0 || r_dist_coe_lh == 0 || r_dist_coe_hl == 0 || r_dist_coe_hh == 0)begin
						r_dist_data			<= 32'd65533;
						r_rssi_data			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else begin
						r_mult1_en			<= 1'b1;
						r_mult2_en			<= 1'b1;
						r_mult1_dataA		<= r_rise_remain;
						if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b0)
							r_mult1_dataB		<= r_dist_coe_lh - r_dist_coe_ll;
						else if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_lh + r_dist_coe_ll;
						else if(r_sign_coe_lh == 1'b1 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_ll - r_dist_coe_lh;
						else
							r_mult1_dataB		<= 16'd0;
						r_mult2_dataA		<= r_rise_remain;
						if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b0)
							r_mult2_dataB		<= r_dist_coe_hh - r_dist_coe_hl;
						else if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hh + r_dist_coe_hl;
						else if(r_sign_coe_hh == 1'b1 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hl - r_dist_coe_hh;
						else
							r_mult2_dataB		<= 16'd0;
						r_cal_state			<= CAL_DELAY;
						end
					end
				CAL_DELAY		:begin
					if(r_delay_cnt >= 16'd14)begin
						r_cal_state			<= CAL_DIST_CAL2;
						r_delay_cnt			<= 16'd0;
						if(r_sign_coe_ll == 1'b1)begin
							if(r_dist_data_l >= r_dist_coe_ll)begin
								r_dist_data_l		<= r_dist_data_l - r_dist_coe_ll;
								r_sign_data_l		<= 1'b0;
								end
							else begin
								r_dist_data_l		<= r_dist_coe_ll - r_dist_data_l;
								r_sign_data_l		<= 1'b1;
								end
							end
						else begin
							r_dist_data_l		<= r_dist_data_l + r_dist_coe_ll;
							r_sign_data_l		<= 1'b0;
							end
						if(r_sign_coe_hl == 1'b1)begin
							if(r_dist_data_h >= r_dist_coe_hl)begin
								r_dist_data_h		<= r_dist_data_h - r_dist_coe_hl;
								r_sign_data_h		<= 1'b0;
								end
							else begin
								r_dist_data_h		<= r_dist_coe_hl - r_dist_data_h;
								r_sign_data_h		<= 1'b1;
								end
							end
						else begin
							r_dist_data_h		<= r_dist_data_h + r_dist_coe_hl;
							r_sign_data_h		<= 1'b0;
							end
						end
					else if(r_delay_cnt == 16'd9)begin
						r_dist_data_l		<= w_mult1_result >> 4'd6;
						r_dist_data_h		<= w_mult2_result >> 4'd6;
						r_mult1_en			<= 1'b0;
						r_mult2_en			<= 1'b0;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end
				CAL_DIST_CAL2	:begin
					r_cal_state			<= CAL_DELAY2;
					r_mult1_en			<= 1'b1;
					r_mult1_dataA		<= r_pulse_remain;
					if(r_sign_data_h == 1'b0 && r_sign_data_l == 1'b0)begin
						if(r_dist_data_h >= r_dist_data_l)begin
							r_incr_polar		<= 1'b0;
							r_mult1_dataB		<= r_dist_data_h - r_dist_data_l;
							end
						else begin
							r_incr_polar		<= 1'b1;
							r_mult1_dataB		<= r_dist_data_l - r_dist_data_h;
							end
						end
					else if(r_sign_data_h == 1'b1 && r_sign_data_l == 1'b0)begin
						r_incr_polar		<= 1'b1;
						r_mult1_dataB		<= r_dist_data_l + r_dist_data_h;
						end
					else if(r_sign_data_h == 1'b0 && r_sign_data_l == 1'b1)begin
						r_incr_polar		<= 1'b0;
						r_mult1_dataB		<= r_dist_data_h + r_dist_data_l;
						end
					else begin
						if(r_dist_data_h >= r_dist_data_l)begin
							r_incr_polar		<= 1'b1;
							r_mult1_dataB		<= r_dist_data_h - r_dist_data_l;
							end
						else begin
							r_incr_polar		<= 1'b0;
							r_mult1_dataB		<= r_dist_data_l - r_dist_data_h;
							end
						end
					end
				CAL_DELAY2		:begin
					if(r_delay_cnt >= 16'd14)begin
						r_cal_state			<= CAL_DIST_END;
						r_delay_cnt			<= 16'd0;
						if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b0)
							r_dist_data			<= r_dist_data_l + r_dist_data;
						else if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b1)begin
							if(r_dist_data >= r_dist_data_l)
								r_dist_data			<= r_dist_data - r_dist_data_l;
							else
								r_dist_data			<= 32'd0;
							end
						else if(r_incr_polar == 1'b1 && r_sign_data_l == 1'b0)begin
							if(r_dist_data >= r_dist_data_l)
								r_dist_data			<= 32'd0;
							else
								r_dist_data			<= r_dist_data_l - r_dist_data;
							end
						else 
							r_dist_data			<= 32'd0;
						end
					else if(r_delay_cnt == 16'd9)begin
						r_mult1_en			<= 1'b0;
						if(r_pulse_data >= r_pulse_divid)
							r_dist_data			<= w_mult1_result >> 4'd7;
						else
							r_dist_data			<= w_mult1_result >> 4'd5;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end	
				CAL_DIST_END	:begin
					if(r_dist_data[15:0] <= r_distance_min && r_dist_data[15:0] != 16'd0)begin // || r_dist_data[15:0] >= r_distance_max)begin
							r_dist_data			<= 32'd65533;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
						end	
					else if(r_dist_data[15:0] >= r_distance_max)begin
							r_dist_data			<= 32'd65535;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
						end	
					else if(r_dist_data[15:0] == 16'd0)begin
							r_dist_data			<= 32'd65534;
							r_rssi_data			<= 16'd0;
							r_cal_state			<= CAL_END;
						end	
					else 
						r_cal_state			<= CAL_DIST_INDEX;
					end
				CAL_DIST_INDEX	:begin
					r_dist_index 		<= r_dist_data[15:6];
					r_dist_value		<= {r_dist_data[15:6],6'd0};
					r_cal_state			<= CAL_RSSI_PRE;
					end
				CAL_RSSI_PRE	:begin
					r_dist_remain		<= r_dist_data[15:0] - r_dist_value;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index;
					r_cal_state			<= CAL_RSSI_READ1;
					end
				CAL_RSSI_READ1	:begin
					r_rssi_para1		<= i_coe_sram_data;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 1'b1;
					r_cal_state			<= CAL_RSSI_READ2;
					end
				CAL_RSSI_READ2	:begin
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 16'd512;
					r_rssi_para2		<= i_coe_sram_data;
					r_cal_state			<= CAL_RSSI_READ3;
					end
				CAL_RSSI_READ3	:begin
					r_pulse_para1		<= i_coe_sram_data;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 16'd513;
					r_cal_state			<= CAL_RSSI_READ4;
					end
				CAL_RSSI_READ4	:begin
					r_pulse_para2		<= i_coe_sram_data;
					r_cal_state			<= CAL_RSSI_CAL;
					end
				CAL_RSSI_CAL	:begin
					r_mult1_en			<= 1'b1;
					r_mult1_dataA		<= r_dist_remain;
					r_mult2_en			<= 1'b1;
					r_mult2_dataA		<= r_dist_remain;
					if(r_rssi_para2 >= r_rssi_para1)
						r_mult1_dataB		<= r_rssi_para2 - r_rssi_para1;
					else 
						r_mult1_dataB		<= r_rssi_para1 - r_rssi_para2;
					if(r_pulse_para2 >= r_pulse_para1)
						r_mult2_dataB		<= r_pulse_para2 - r_pulse_para1;
					else 
						r_mult2_dataB		<= r_pulse_para1 - r_pulse_para2;
					r_cal_state			<= CAL_RSSI_DELAY;
					end
				CAL_RSSI_DELAY	:begin
					if(r_delay_cnt == 16'd9)begin
						r_mult1_en			<= 1'b0;
						r_mult2_en			<= 1'b0;
						r_divide_en			<= 1'b1;
						r_delay_cnt			<= 16'd0;
						if(r_rssi_para2 >= r_rssi_para1)
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para1;
						else
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para2;
						if(r_pulse_para2 >= r_pulse_para1)
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para1;
						else
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para2;
						r_cal_state			<= CAL_RSSI_WAIT;
						end
					else
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end	
				CAL_RSSI_WAIT	:begin
					r_divide_en			<= 1'b0;
					if(w_divide_done)begin
						r_cal_state			<= CAL_END;
						if(w_divide_result >= 16'd255)
							r_rssi_data			<= 16'd255;
						else if(w_divide_result == 16'd0)
							r_rssi_data			<= 16'd1;
						else
							r_rssi_data			<= w_divide_result;
						end
					end
				CAL_END		:begin	
					r_dist_new_sig		<= 1'b1;
					if(i_code_angle >= i_stop_index + 4'd10)
						r_cal_state			<= CAL_IDLE;
					else
						r_cal_state			<= CAL_DOT_IDLE;
					end
				default:r_cal_state			<= CAL_IDLE;
				endcase
			end
			
   reg   [15:0] r_dist_data_temp;   always@(posedge i_clk_50m or negedge i_rst_n)
	 if(i_rst_n == 0)
       r_dist_data_temp <= 16'd0;  
	 else if(r_dist_data==16'd0 || r_dist_data >= 16'd65533)
	   r_dist_data_temp <= r_dist_data;
	 else if(i_fixed_value_flag==1'd1)
	 begin
	   if(r_dist_data!=16'd0&&i_add_sub_flag==1'd1)
	     r_dist_data_temp <= r_dist_data - i_dist_temp_value+i_fixed_value;
	   else if(r_dist_data!=16'd0&&i_add_sub_flag==1'd0)
	     r_dist_data_temp <= r_dist_data + i_dist_temp_value+i_fixed_value;
	 end
	 else if(i_fixed_value_flag==1'd0)
	 begin
	   if(r_dist_data!=16'd0&&i_add_sub_flag==1'd1)
	     r_dist_data_temp <= r_dist_data - i_dist_temp_value-i_fixed_value;
	   else if(r_dist_data!=16'd0&&i_add_sub_flag==1'd0)
	     r_dist_data_temp <= r_dist_data + i_dist_temp_value-i_fixed_value;
	 end
	
  reg  r_dist_new_sig_reg ;
  always@(posedge i_clk_50m or negedge i_rst_n)
	 if(i_rst_n == 0)	
       r_dist_new_sig_reg <= 1'd0;
	 else
	   r_dist_new_sig_reg <= r_dist_new_sig; 
	   
	   
			
	//ÔàÎÛ±¨¾¯
	
	reg		[7:0] r_dirt_points;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)	
			r_dirt_points <= 8'd30;
		else
			r_dirt_points <= i_dirt_points;
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_rise_min_cnt <= 8'd0;
		else if(i_code_angle == i_stop_index)
			r_rise_min_cnt <= 8'd0;
		else if(r_rise_min_cnt >= 8'd108)
			r_rise_min_cnt <= 8'd108;
		else if(r_cal_state == CAL_END)begin
			if( i_rise_data <= i_dirt_rise && i_rise_data > 16'd0 && i_fall_data > 16'd0 && r_dist_data >= 16'd65533 && r_code_angle_1 >= 16'd270 && r_code_angle_1 <= 16'd810)
				r_rise_min_cnt <= r_rise_min_cnt + 1'd1;
			else
				r_rise_min_cnt <= r_rise_min_cnt;
		end
		else
			r_rise_min_cnt <= r_rise_min_cnt;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_code_angle_0 <= 16'd0;
			r_code_angle_1 <= 16'd0;
		end
		else begin
			r_code_angle_0 <= i_code_angle;
			r_code_angle_1 <= r_code_angle_0;
		end
	end
		
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_rise_min_cnt_r <= 8'd0;
		else if(r_code_angle_0 == 16'd811 && r_code_angle_1 == 16'd810)
			r_rise_min_cnt_r <= r_rise_min_cnt;
		else
			r_rise_min_cnt_r <= r_rise_min_cnt_r;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_dirt_mode <= 1'd0;
		else
			r_dirt_mode <= i_dirt_mode;
	end	
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)	
			r_dirt_warn <= 1'd0;
		else if(r_rise_min_cnt_r >= r_dirt_points)
			r_dirt_warn <= i_dirt_mode;
		else
			r_dirt_warn <= 1'd0;
	end

	multiplier U1
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult1_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult1_dataA), 
		.DataB				(r_mult1_dataB), 
		.Result				(w_mult1_result)
	);
	
	multiplier U2
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(r_mult2_en), 
		
		.Aclr				(1'b0), 
		.DataA				(r_mult2_dataA), 
		.DataB				(r_mult2_dataB), 
		.Result				(w_mult2_result)
	);
	
	division_2 U3
	(
		.i_clk_50m			(i_clk_50m)			,
		.i_rst_n			(i_rst_n)			,
		
		.i_cal_sig			(r_divide_en)		,
		.i_dividend			(r_pulse_data)		,
		.i_dividend_sub		(r_pulse_para)		,
		.i_divisor			(r_rssi_para)		,

		.o_quotient			(w_divide_result)	,
		.o_cal_done			(w_divide_done)
	);
						
						
						
						
						
	assign	o_coe_sram_addr		= r_coe_sram_addr;
	assign	o_dirt_warn    		= r_dirt_warn;
	assign	o_dist_data			= r_dist_data_temp;
	assign	o_rssi_data			= r_rssi_data;
	assign	o_dist_new_sig		= r_dist_new_sig_reg;

endmodule 