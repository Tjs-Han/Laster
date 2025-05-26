module dist_cal
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	

	input	[15:0]	i_rise_data		    ,

	input	[3:0]	i_index_flag		,
	input	[15:0]	i_rise_index		,
	input	[15:0]	i_rise_remain		,
	input	[15:0]	i_pulse_index		,
	input	[15:0]	i_pulse_remain		,
	
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	input	[15:0]	i_dist_compen		,
	output	[17:0]	o_coe_sram_addr		,
	input	[15:0]	i_coe_sram_data		,
	
	output	reg		    o_dist_flag			,
	output	reg [15:0]	o_dist_data			
);

	reg		[11:0]	r_dist_state 	= 12'd0;
	
	reg		[17:0]	r_coe_sram_addr	= 18'd0;
	reg				r_dist_flag		= 1'b0;
	reg		[31:0]	r_dist_data		= 32'd0;
	
	reg		[15:0]	r_dist_coe_ll 	= 16'd0;
	reg		[15:0]	r_dist_coe_lh 	= 16'd0;
	reg		[15:0]	r_dist_coe_hl 	= 16'd0;
	reg		[15:0]	r_dist_coe_hh 	= 16'd0;
	reg		[31:0]	r_dist_data_l 	= 32'd0;
	reg		[31:0]	r_dist_data_h 	= 32'd0;
	
	reg				r_sign_coe_ll 	= 1'b0;
	reg				r_sign_coe_lh 	= 1'b0;
	reg				r_sign_coe_hl 	= 1'b0;
	reg				r_sign_coe_hh 	= 1'b0;
	reg				r_sign_data_l 	= 1'b0;
	reg				r_sign_data_h 	= 1'b0;
	reg				r_sign_data	  	= 1'b0;
	
	reg				r_incr_polar  = 1'b0;
	reg 	[15:0]	r_mult1_dataA = 16'd0;
    reg 	[15:0]	r_mult1_dataB = 16'd0;
	reg				r_mult1_en	  = 1'b0;
    wire	[31:0]	w_mult1_result;
	
	reg 	[15:0]	r_mult2_dataA = 16'd0;
    reg 	[15:0]	r_mult2_dataB = 16'd0;
	reg				r_mult2_en	  = 1'b0;
    wire	[31:0]	w_mult2_result;
	
	reg		[3:0]	r_index_flag	= 4'd0;
	reg		[15:0]	r_delay_cnt		= 16'd0;
	
	localparam		SRAM_COE_BASE = 18'h10000;
	
	localparam		IDLE			= 12'b0000_0000_0000,
					PRE				= 12'b0000_0000_0010,
					READ_DIST1		= 12'b0000_0000_0100,
					READ_DIST2		= 12'b0000_0000_1000,
					READ_DIST3		= 12'b0000_0001_0000,
					READ_DIST4		= 12'b0000_0010_0000,
					DIST_CAL1		= 12'b0000_0100_0000,
					CAL_DELAY		= 12'b0000_1000_0000,
					DIST_CAL2		= 12'b0001_0000_0000,
					CAL_DELAY2		= 12'b0010_0000_0000,
					END				= 12'b0100_0000_0000,
					OVER			= 12'b1000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_dist_coe_ll 		<= 16'd0;
			r_dist_coe_lh 		<= 16'd0;
			r_dist_coe_ll 		<= 16'd0;
			r_dist_coe_hh 		<= 16'd0;
			r_dist_data_l 		<= 32'd0;
			r_dist_data_h 		<= 32'd0;
			r_dist_data			<= 32'd0;
			r_dist_flag			<= 1'b0;
			r_sign_coe_ll 		<= 1'b0;
			r_sign_coe_lh 		<= 1'b0;
			r_sign_coe_hl 		<= 1'b0;
			r_sign_coe_hh 		<= 1'b0;
			r_sign_data_l 		<= 1'b0;
			r_sign_data_h 		<= 1'b0;
			r_sign_data			<= 1'b0;
			r_incr_polar		<= 1'b0;
			r_index_flag		<= 4'd0;
			r_delay_cnt			<= 16'd0;
			r_dist_state		<= IDLE;
		end
		else begin
			case(r_dist_state)
				IDLE		:begin
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_lh 		<= 16'd0;
					r_dist_coe_ll 		<= 16'd0;
					r_dist_coe_hh 		<= 16'd0;
					r_dist_data_l 		<= 32'd0;
					r_dist_data_h 		<= 32'd0;
					r_dist_flag			<= 1'b0;
					r_sign_coe_ll 		<= 1'b0;
					r_sign_coe_lh 		<= 1'b0;
					r_sign_coe_hl 		<= 1'b0;
					r_sign_coe_hh 		<= 1'b0;
					r_sign_data_l 		<= 1'b0;
					r_sign_data_h 		<= 1'b0;
					r_sign_data			<= 1'b0;
					r_incr_polar		<= 1'b0;
					r_delay_cnt			<= 16'd0;
					if(i_index_flag[3])begin
						r_dist_state		<= PRE;
						r_dist_data			<= 32'd0;
						r_index_flag		<= i_index_flag;
					end
					else
						r_dist_state		<= IDLE;
				end
				PRE			:begin
					if(r_index_flag[0])begin
						r_dist_data			<= 32'd0;
						r_dist_state		<= OVER;
					end
					else begin
						r_coe_sram_addr 	<= SRAM_COE_BASE + (i_pulse_index << 4'd9) + i_rise_index;
						r_dist_state		<= READ_DIST1;
					end
				end
				READ_DIST1	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_ll		<= i_coe_sram_data[11:0];
						r_sign_coe_ll		<= 1'b1;
					end
					else begin
						r_dist_coe_ll		<= i_coe_sram_data;
						r_sign_coe_ll		<= 1'b0;
					end
					r_coe_sram_addr 	<= SRAM_COE_BASE + (i_pulse_index << 4'd9) + i_rise_index + 1'b1;
					r_dist_state		<= READ_DIST2;
				end
				READ_DIST2	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_lh		<= i_coe_sram_data[11:0];
						r_sign_coe_lh		<= 1'b1;
					end
					else begin
						r_dist_coe_lh		<= i_coe_sram_data;
						r_sign_coe_lh		<= 1'b0;
					end
					r_coe_sram_addr 	<= SRAM_COE_BASE + ((i_pulse_index + 1'b1)<< 4'd9) + i_rise_index;
					r_dist_state		<= READ_DIST3;
				end
				READ_DIST3	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_hl		<= i_coe_sram_data[11:0];
						r_sign_coe_hl		<= 1'b1;
					end
					else begin
						r_dist_coe_hl		<= i_coe_sram_data;
						r_sign_coe_hl		<= 1'b0;
					end
					r_coe_sram_addr 	<= SRAM_COE_BASE + ((i_pulse_index + 1'b1)<< 4'd9) + i_rise_index + 1'b1;
					r_dist_state		<= READ_DIST4;
				end
				READ_DIST4	:begin
					if(i_coe_sram_data[15:12] == 4'hF)begin
						r_dist_coe_hh		<= i_coe_sram_data[11:0];
						r_sign_coe_hh		<= 1'b1;
					end
					else begin
						r_dist_coe_hh		<= i_coe_sram_data;
						r_sign_coe_hh		<= 1'b0;
					end
					r_coe_sram_addr		<= 18'd0;
					r_dist_state		<= DIST_CAL1;
				end
				DIST_CAL1	:begin
					if(r_dist_coe_ll == 0 || r_dist_coe_lh == 0 || r_dist_coe_hl == 0 || r_dist_coe_hh == 0)begin
						r_dist_data			<= 32'd0;
						r_dist_state		<= OVER;
					end
					else begin
						r_mult1_en			<= 1'b1;
						r_mult2_en			<= 1'b1;
						r_mult1_dataA		<= i_rise_remain;
						if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b0)begin
							if(r_dist_coe_lh < r_dist_coe_ll)
								r_mult1_dataB		<= 16'd0;
							else
								r_mult1_dataB		<= r_dist_coe_lh - r_dist_coe_ll;
						end
						else if(r_sign_coe_lh == 1'b0 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_lh + r_dist_coe_ll;
						else if(r_sign_coe_lh == 1'b1 && r_sign_coe_ll == 1'b1)
							r_mult1_dataB		<= r_dist_coe_ll - r_dist_coe_lh;
						else
							r_mult1_dataB		<= 16'd0;
						r_mult2_dataA		<= i_rise_remain;
						if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b0)begin
							if(r_dist_coe_hh < r_dist_coe_hl)
								r_mult2_dataB		<= 16'd0;
							else
								r_mult2_dataB		<= r_dist_coe_hh - r_dist_coe_hl;
						end
						else if(r_sign_coe_hh == 1'b0 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hh + r_dist_coe_hl;
						else if(r_sign_coe_hh == 1'b1 && r_sign_coe_hl == 1'b1)
							r_mult2_dataB		<= r_dist_coe_hl - r_dist_coe_hh;
						else
							r_mult2_dataB		<= 16'd0;
						r_dist_state		<= CAL_DELAY;
					end
				end
				CAL_DELAY	:begin
					if(r_delay_cnt >= 16'd14)begin
						r_dist_state		<= DIST_CAL2;
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
						if(r_index_flag[2])begin
							r_dist_data_l		<= w_mult1_result >> 3'd7;
							r_dist_data_h		<= w_mult2_result >> 3'd7;
						end
						else begin
							r_dist_data_l		<= w_mult1_result >> 3'd6;
							r_dist_data_h		<= w_mult2_result >> 3'd6;
						end
						r_mult1_en			<= 1'b0;
						r_mult2_en			<= 1'b0;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
				end
				DIST_CAL2	:begin
					r_dist_state		<= CAL_DELAY2;
					r_mult1_en			<= 1'b1;
					r_mult1_dataA		<= i_pulse_remain;
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
				CAL_DELAY2	:begin
					if(r_delay_cnt >= 16'd14)begin
						r_dist_state		<= END;
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
						if(r_index_flag[1])
							r_dist_data			<= w_mult1_result >> 4'd7;
						else
							r_dist_data			<= w_mult1_result >> 4'd5;
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end
					else 
						r_delay_cnt			<= r_delay_cnt + 1'b1;
				end	
				END			:begin
					r_dist_state		<= OVER;
					if(r_dist_data[15:0] == 16'd0)
						r_dist_data[15:0]	<= 16'd0;
					else if(i_dist_compen[15] == 1'b1)
						r_dist_data[15:0]	<= r_dist_data[15:0] + i_dist_compen[14:0];
					else if(i_dist_compen[15] == 1'b0)begin
						if(r_dist_data[15:0] >= i_dist_compen[14:0])
							r_dist_data[15:0]	<= r_dist_data[15:0] - i_dist_compen[14:0];
						else
							r_dist_data[15:0]	<= 16'd0;
						end
					end
				OVER		:begin
					r_dist_state		<= IDLE;
					r_dist_flag			<= 1'b1;
					if(r_dist_data[15:0] <= i_distance_min || r_dist_data[15:0] >= i_distance_max)
						r_dist_data			<= 32'd0;
				end
				default:
					r_dist_state		<= IDLE;
			endcase
		end
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
	

	assign	o_coe_sram_addr 	= r_coe_sram_addr;


	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			o_dist_flag	<= 1'b0;
		else
			o_dist_flag	<= r_dist_flag;
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			o_dist_data	<= 16'b0;

		else if(i_rise_data == 16'hFFFF)
			o_dist_data	<= 16'd65535;

		else if((i_rise_data > 16'd1500) && (r_dist_data == 16'd0))
			o_dist_data	<= 16'd65535;						

		else if((i_rise_data <= 16'd1500) && (r_dist_data == 16'd0))
			o_dist_data	<= 16'b0;		

		else 
			o_dist_data	<= r_dist_data[15:0];
						
	end

endmodule 