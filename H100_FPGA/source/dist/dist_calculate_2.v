module dist_calculate_2
(
	input			i_clk_50m    		,
	input			i_rst_n      		,

	input			i_tdc_new_sig		,
	input	[15:0]	i_rise_data			,//ÉÏÉıÑØ
	input	[15:0]	i_fall_data			,//ÏÂ½µÑØ¡¢
	
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

	parameter		SRAM_COE_BASE = 18'h10000;
					
	reg		[15:0]	r_rise_data	= 16'd0;//ÉÏÉıÑØ
	reg		[15:0]	r_fall_data	= 16'd0;//ÏÂ½µÑØ
	reg		[15:0]	r_pulse_data = 16'd0;
	reg		[15:0]	r_pulse_start = 16'd0;
	reg		[15:0]	r_pulse_divid = 16'd0;
	reg		[15:0]	r_distance_min = 16'd50;
	reg		[15:0]	r_distance_max = 16'd25000;	
	
	reg		[15:0]	r_pulse_value = 16'd0;
	reg		[15:0]	r_rise_index = 16'd0;
	reg		[15:0]	r_rise_remain = 16'd0;
	reg		[15:0]	r_pulse_index1 = 16'd0;
	reg		[15:0]	r_pulse_index2 = 16'd0;
	reg		[15:0]	r_pulse_remain = 16'd0;
	
	reg		[31:0]	r_dist_midd	= 32'd0;
	reg		[15:0]	r_rssi_midd = 16'd0;
	
	reg				r_pingorpang = 1'b0;
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
	
	reg		[15:0]	r_cal_state = 16'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_max		<= 16'd0;
		else 
			r_pulse_max		<= 16'd25000;
			
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
			
				
	parameter		CAL_IDLE			=	16'b0000_0000_0000_0000,
					CAL_DOT_IDLE		=	16'b0000_0000_0000_0010,
					CAL_DOT_ASSIGN		=	16'b0000_0000_0000_0100,
					CAL_PULSE_PRE		=	16'b0000_0000_0000_1000,
					CAL_RISE_INDEX		=	16'b0000_0000_0001_0000,
					CAL_READ_PRE		=	16'b0000_0000_0010_0000,
					CAL_READ_DIST1		=	16'b0000_0000_0100_0000,
					CAL_READ_DIST2		=	16'b0000_0000_1000_0000,
					CAL_READ_DIST3		=	16'b0000_0001_0000_0000,
					CAL_READ_DIST4		=	16'b0000_0010_0000_0000,
					CAL_DIST_CAL1		=	16'b0000_0100_0000_0000,
					CAL_DELAY			=	16'b0000_1000_0000_0000,
					CAL_DIST_CAL2		=	16'b0001_0000_0000_0000,
					CAL_DELAY2			=	16'b0010_0000_0000_0000,
					CAL_END				=	16'b0100_0000_0000_0000,
					CAL_OVER			=	16'b1000_0000_0000_0000;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_pulse_start 		<= 16'd0;
			r_pulse_divid		<= 16'd0;
			end
		else if(r_cal_state == CAL_DOT_ASSIGN)begin
			r_pulse_start		<= i_pulse_start;
			r_pulse_divid		<= i_rise_start;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_data 	<= 16'd0;
		else if(r_cal_state == CAL_DOT_ASSIGN)
			r_rise_data 	<= i_rise_data;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fall_data 	<= 16'd0;
		else if(r_cal_state == CAL_DOT_ASSIGN)
			r_fall_data		<= i_fall_data;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_pulse_data	<= 16'd0;
		else if(r_cal_state == CAL_DOT_ASSIGN)
			r_pulse_data	<= i_fall_data - i_rise_data;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_pulse_value 		<= 16'd0;
			r_rise_index 		<= 16'd0;
			r_rise_remain 		<= 16'd0;
			r_pulse_index1 		<= 16'd0;
			r_pulse_index2 		<= 16'd0;
			r_pulse_remain 		<= 16'd0;
			r_dist_midd			<= 32'd0;
			r_rssi_midd			<= 16'd0;
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
			r_delay_cnt			<= 16'd0;
			r_incr_polar		<= 1'b0;
			r_cal_state			<= CAL_IDLE;
			end
		else begin
			case(r_cal_state)
				CAL_IDLE		:begin
					r_pulse_value 		<= 16'd0;
					r_rise_index 		<= 16'd0;
					r_rise_remain 		<= 16'd0;
					r_pulse_index1 		<= 16'd0;
					r_pulse_index2 		<= 16'd0;
					r_pulse_remain 		<= 16'd0;
					r_dist_midd			<= 32'd0;
					r_rssi_midd			<= 16'd0;
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
					r_delay_cnt			<= 16'd0;
					r_incr_polar		<= 1'b0;
					r_cal_state			<= CAL_DOT_IDLE;
					end
				CAL_DOT_IDLE	:begin
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
					if(i_tdc_new_sig)
						r_cal_state			<= CAL_DOT_ASSIGN;
					else
						r_cal_state			<= CAL_DOT_IDLE;
					end
				CAL_DOT_ASSIGN	:begin
					r_cal_state			<= CAL_PULSE_PRE;
					end	
				CAL_PULSE_PRE	:begin
					if(r_fall_data <= r_rise_data)begin
						r_dist_midd			<= 32'd0;
						r_rssi_midd			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else if((r_fall_data - r_rise_data) < r_pulse_start)begin
						r_dist_midd			<= 32'd0;
						r_rssi_midd			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else if((r_fall_data - r_rise_data) >= r_pulse_max)begin
						r_dist_midd			<= 32'd0;
						r_rssi_midd			<= 16'd0;
						r_cal_state			<= CAL_END;
						end
					else if((r_fall_data - r_rise_data) <= r_pulse_divid)begin
						r_cal_state			<= CAL_RISE_INDEX;
						r_pulse_index1		<= (r_pulse_data - r_pulse_start) >> 3'd5;
						r_pulse_index2		<= 16'd0;
						end
					else begin
						r_cal_state			<= CAL_RISE_INDEX;
						r_pulse_index1		<= (r_pulse_divid - r_pulse_start) >> 3'd5;
						r_pulse_index2		<= (r_pulse_data - r_pulse_divid) >> 3'd7;
						end
					end
				CAL_RISE_INDEX	:begin
					if(r_rise_data >= r_rise_max)begin
						r_dist_midd			<= 32'd0;
						r_rssi_midd			<= 16'd0;
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
						r_dist_midd			<= 32'd0;
						r_rssi_midd			<= 16'd0;
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
						r_cal_state			<= CAL_END;
						r_rssi_midd			<= r_pulse_data;
						r_delay_cnt			<= 16'd0;
						if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b0)
							r_dist_midd			<= r_dist_data_l + r_dist_midd;
						else if(r_incr_polar == 1'b0 && r_sign_data_l == 1'b1)begin
							if(r_dist_midd >= r_dist_data_l)
								r_dist_midd			<= r_dist_midd - r_dist_data_l;
							else
								r_dist_midd			<= 32'd0;
							end
						else if(r_incr_polar == 1'b1 && r_sign_data_l == 1'b0)begin
							if(r_dist_midd >= r_dist_data_l)
								r_dist_midd			<= 32'd0;
							else
								r_dist_midd			<= r_dist_data_l - r_dist_midd;
							end
						else 
							r_dist_midd			<= 32'd0;
						end
					else if(r_delay_cnt == 16'd9)begin
						r_mult1_en			<= 1'b0;
						if(r_pulse_data >= r_pulse_divid)
							r_dist_midd			<= w_mult1_result >> 4'd7;
						else
							r_dist_midd			<= w_mult1_result >> 4'd5;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
						end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end	
				CAL_END			:begin
					if(r_pulse_data <= 16'd400 || r_dist_midd[15:0] <= r_distance_min || r_dist_midd[15:0] >= r_distance_max)begin
						r_rssi_midd			<= 16'd0;
						r_dist_midd			<= 32'd0;
						end
					r_cal_state			<= CAL_OVER;
					end
				CAL_OVER		:begin
					r_cal_state			<= CAL_DOT_IDLE;
					end
				default:r_cal_state			<= CAL_IDLE;
				endcase
			end
			
	reg		[15:0]	r_dist_data	= 16'd0;
	reg		[15:0]	r_rssi_data	= 16'd0;
	reg				r_dist_new_sig = 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_data			<= 16'd0;
		else if(r_cal_state == CAL_OVER)
			r_dist_data			<= r_dist_midd[15:0];
		else
			r_dist_data			<= r_dist_midd[15:0];
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rssi_data			<= 16'd0;
		else if(r_cal_state == CAL_OVER)
			r_rssi_data			<= r_rssi_midd;
		else
			r_rssi_data			<= r_rssi_midd;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_dist_new_sig		<= 1'b0;
		else if(r_cal_state == CAL_OVER)
			r_dist_new_sig		<= 1'b1;
		else
			r_dist_new_sig		<= 1'b0;

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
						
						
	assign	o_coe_sram_addr		= r_coe_sram_addr;
	
	assign	o_dist_data			= r_dist_data;
	assign	o_rssi_data			= r_rssi_data;
	assign	o_dist_new_sig		= r_dist_new_sig;

endmodule 