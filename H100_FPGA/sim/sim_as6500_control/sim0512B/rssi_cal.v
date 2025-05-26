module rssi_cal
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_rssi_switch		,
	input			i_dist_flag			,
	input	[15:0]	i_pulse_data		,
	input	[15:0]	i_dist_data			,
	
	output	[17:0]	o_coe_sram_addr		,
	output			o_rssi_sram_en		,
	input	[15:0]	i_coe_sram_data		,
	
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		
);

	reg		[11:0]	r_rssi_state = 12'd0;
	reg				r_dist_new_sig = 1'b0;
	reg				r_rssi_sram_en = 1'b0;
	
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
	reg		[15:0]	r_dividend	  = 16'd0;
	reg		[15:0]	r_divisor	  = 16'd0;
	wire	[15:0]	w_divide_result;
	wire			w_divide_done;
	
	reg		[15:0]	r_dist_data = 16'd0;
	reg		[15:0]	r_rssi_data = 16'd0;
	reg		[15:0]	r_dist_index = 16'd0;
	reg		[15:0]	r_dist_value = 16'd0;
	reg		[15:0]	r_dist_remain = 16'd0;
	reg		[15:0]	r_rssi_para	 = 16'd0;
	reg		[15:0]	r_rssi_para1 = 16'd0;
	reg		[15:0]	r_rssi_para2 = 16'd0;
	reg		[15:0]	r_pulse_para  = 16'd0;
	reg		[15:0]	r_pulse_para1 = 16'd0;
	reg		[15:0]	r_pulse_para2 = 16'd0;
	
	reg		[15:0]	r_delay_cnt	= 16'd0;
	
	reg		[17:0]	r_coe_sram_addr = 18'd0;
	
	localparam	SRAM_RSSI_BASE	= 18'h04000;
	
	localparam	IDLE		= 12'b0000_0000_0000,
				DIST_INDEX	= 12'b0000_0000_0010,
				RSSI_PRE	= 12'b0000_0000_0100,
				RSSI_READ1	= 12'b0000_0000_1000,
				RSSI_READ2	= 12'b0000_0001_0000,
				RSSI_READ3	= 12'b0000_0010_0000,
				RSSI_READ4	= 12'b0000_0100_0000,
				RSSI_CAL	= 12'b0000_1000_0000,
				RSSI_DELAY	= 12'b0001_0000_0000,
				RSSI_DIVID	= 12'b0010_0000_0000,
				RSSI_WAIT	= 12'b0100_0000_0000,
				END			= 12'b1000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_dist_data			<= 16'd0;
			r_rssi_data			<= 16'd0;
			r_dist_index 		<= 16'd0;
			r_dist_value 		<= 16'd0;
			r_dist_remain		<= 16'd0;
			r_rssi_para			<= 16'd0;
			r_rssi_para1		<= 16'd0;
			r_rssi_para2		<= 16'd0;
			r_pulse_para		<= 16'd0;
			r_pulse_para1		<= 16'd0;
			r_pulse_para2		<= 16'd0;
			r_delay_cnt			<= 16'd0;
			r_coe_sram_addr		<= 18'd0;
			r_dist_new_sig		<= 1'b0;
			r_rssi_sram_en		<= 1'b0;
			r_rssi_state		<= IDLE;
		end
		else begin
			case(r_rssi_state)
				IDLE		:begin
					r_dist_new_sig		<= 1'b0;
					if(i_dist_flag)begin
						if(i_dist_data == 16'd0)begin
							r_rssi_data			<= 16'd0;
							r_rssi_state		<= END;
						end
						else if(i_rssi_switch == 1'b0)begin
							r_rssi_data			<= i_pulse_data >> 2'd3;
							r_rssi_state		<= END;
						end
						else begin
							r_rssi_data			<= 16'd0;
							r_dist_index 		<= 16'd0;
							r_dist_value 		<= 16'd0;
							r_dist_remain		<= 16'd0;
							r_rssi_para			<= 16'd0;
							r_rssi_para1		<= 16'd0;
							r_rssi_para2		<= 16'd0;
							r_pulse_para		<= 16'd0;
							r_pulse_para1		<= 16'd0;
							r_pulse_para2		<= 16'd0;
							r_delay_cnt			<= 16'd0;
							r_coe_sram_addr		<= 18'd0;
							r_rssi_sram_en		<= 1'b1;
							r_dist_data			<= i_dist_data;
							r_rssi_state		<= DIST_INDEX;
						end
					end
					else
						r_rssi_state		<= IDLE;
				end
				DIST_INDEX	:begin
					r_dist_index 		<= r_dist_data[15:6];
					r_dist_value		<= {r_dist_data[15:6],6'd0};
					r_rssi_state		<= RSSI_PRE;
					end
				RSSI_PRE	:begin
					r_dist_remain		<= r_dist_data[15:0] - r_dist_value;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index;
					r_rssi_state		<= RSSI_READ1;
					end
				RSSI_READ1	:begin
					r_rssi_para1		<= i_coe_sram_data;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 1'b1;
					r_rssi_state		<= RSSI_READ2;
					end
				RSSI_READ2	:begin
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 16'd1024;
					r_rssi_para2		<= i_coe_sram_data;
					r_rssi_state		<= RSSI_READ3;
					end
				RSSI_READ3	:begin
					r_pulse_para1		<= i_coe_sram_data;
					r_coe_sram_addr 	<= SRAM_RSSI_BASE + r_dist_index + 16'd1025;
					r_rssi_state		<= RSSI_READ4;
					end
				RSSI_READ4	:begin
					r_pulse_para2		<= i_coe_sram_data;
					r_rssi_state		<= RSSI_CAL;
					end
				RSSI_CAL	:begin
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
					r_rssi_state			<= RSSI_DELAY;
					end
				RSSI_DELAY	:begin
					if(r_delay_cnt == 16'd9)begin
						r_mult1_en			<= 1'b0;
						r_mult2_en			<= 1'b0;
						r_delay_cnt			<= 16'd0;
						if(r_rssi_para2 >= r_rssi_para1)
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para1;
						else
							r_rssi_para			<= w_mult1_result[21:6] + r_rssi_para2;
						if(r_pulse_para2 >= r_pulse_para1)
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para1;
						else
							r_pulse_para		<= w_mult2_result[21:6] + r_pulse_para2;
						r_rssi_state			<= RSSI_DIVID;
						end
					else
						r_delay_cnt			<= r_delay_cnt + 1'b1;
					end	
				RSSI_DIVID	:begin
					if(i_pulse_data > r_pulse_para)begin
						r_divide_en			<= 1'b1;
						r_dividend			<= i_pulse_data - r_pulse_para;
						r_divisor			<= r_rssi_para;
						r_rssi_state		<= RSSI_WAIT;
						end
					else begin
						r_divide_en			<= 1'b0;
						r_rssi_data			<= 16'd1;
						r_rssi_state		<= END;
						end
					end
				RSSI_WAIT	:begin
					r_divide_en			<= 1'b0;
					if(w_divide_done)begin
						r_rssi_state		<= END;
						if(w_divide_result >= 16'd255)
							r_rssi_data			<= 16'd4095;
						else if(w_divide_result == 16'd0)
							r_rssi_data			<= 16'd1;
						else
							r_rssi_data			<= {w_divide_result[11:0],4'd0};
						end
					end
				END		:begin	
					r_rssi_sram_en		<= 1'b0;
					r_dist_new_sig		<= 1'b1;
					r_rssi_state		<= IDLE;
				end
				default:
					r_rssi_state		<= IDLE;
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
	
	div_rill U3
	(
		.clk  				(i_clk_50m),
		.rst  				(i_rst_n),
		.enable 			(r_divide_en),
		.a    				(r_dividend),
		.b    				(r_divisor),
		.done 				(w_divide_done),
		.yshang				(w_divide_result),
		.yyushu				()
	);
						
						
	assign	o_coe_sram_addr		= r_coe_sram_addr;
	assign	o_rssi_sram_en 		= r_rssi_sram_en;
	assign	o_rssi_data			= r_rssi_data;
	assign	o_dist_new_sig		= r_dist_new_sig;

endmodule 