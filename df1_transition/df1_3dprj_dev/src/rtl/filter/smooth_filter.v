module smooth_filter
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[3:0]	i_reso_mode			,
	input	[15:0]	i_code_angle 		,//�Ƕ�ֵ
	input	[15:0]	i_dist_data			,
	input	[15:0]	i_rssi_data			,
	input	[15:0]	i_rssi_tail			,
	input	[15:0]	i_pulse_data		,
	input			i_dist_new_sig		,
	
	input			i_sfim_switch		,
	
	output	[15:0]	o_code_angle 		,//�Ƕ�ֵ
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output	[15:0]	o_rssi_tail			,
	output	[15:0]	o_pulse_data		,
	output			o_dist_new_sig		
);
    reg    	[15:0]	r_start_screen_angle = 16'd0;
	reg    	[15:0]	r_stop_screen_angle = 16'd0;
	reg    	[15:0] 	r_dist_data_reg    = 16'd0;
	reg    	[15:0] 	r_rssi_data_reg    = 16'd0;
	reg    	[15:0] 	r_pulse_data_reg    = 16'd0;
	reg    	[15:0] 	r_rssi_tail_reg   = 16'd0;
	reg    			r_dist_new_reg    = 1'b0;
	reg    			r_dist_new_reg1   = 1'b0;
	wire   	[15:0]	w_dist_data;
	wire   	[15:0]	w_rssi_data;
	wire   	[15:0]	w_pulse_data;
	wire	[15:0]	w_rssi_tail;
	wire   			w_dist_new_sig;
	
	reg		[15:0]	r_code_angle = 16'd0;//�Ƕ�ֵ
	reg		[19:0]	r_dist_data = 20'd0;
	reg		[15:0]	r_rssi_data = 16'd0;
	reg		[15:0]	r_pulse_data = 16'd0;
	reg		[15:0]	r_rssi_tail = 16'd0;
	reg				r_dist_new_sig = 1'b0;
	
	reg		[15:0]	r_filter_state = 16'd0;
	
	reg		[15:0]	r_dist_data1 = 16'd0;
	reg		[15:0]	r_dist_data2 = 16'd0;
	reg		[15:0]	r_dist_data3 = 16'd0;
	reg		[15:0]	r_dist_data4 = 16'd0;
	reg		[15:0]	r_dist_data5 = 16'd0;
	
	reg		[15:0]	r_rssi_data1 = 16'd0;
	reg		[15:0]	r_rssi_data2 = 16'd0;
	reg		[15:0]	r_rssi_data3 = 16'd0;
	reg		[15:0]	r_rssi_data4 = 16'd0;
	reg		[15:0]	r_rssi_data5 = 16'd0;
	
	reg		[15:0]	r_pulse_data1 = 16'd0;
	reg		[15:0]	r_pulse_data2 = 16'd0;
	reg		[15:0]	r_pulse_data3 = 16'd0;
	reg		[15:0]	r_pulse_data4 = 16'd0;
	reg		[15:0]	r_pulse_data5 = 16'd0;
	
	reg		[15:0]	r_rssi_tail1 = 16'd0;
	reg		[15:0]	r_rssi_tail2 = 16'd0;
	reg		[15:0]	r_rssi_tail3 = 16'd0;
	reg		[15:0]	r_rssi_tail4 = 16'd0;
	reg		[15:0]	r_rssi_tail5 = 16'd0;
	
	reg		[15:0]	r_dist_diff1 = 16'd0;
	reg		[15:0]	r_dist_diff2 = 16'd0;
	reg		[15:0]	r_dist_diff3 = 16'd0;
	reg		[15:0]	r_dist_diff4 = 16'd0;
	
	parameter		FILTER_IDLE		= 16'b0000_0000_0000_0000,
					FILTER_WAIT		= 16'b0000_0000_0000_0010,
					FILTER_ASSIGN	= 16'b0000_0000_0000_0100,
					FILTER_SHIFT	= 16'b0000_0000_0000_1000,
					FILTER_SUB		= 16'b0000_0000_0001_0000,
					FILTER_COMP		= 16'b0000_0000_0010_0000,
					FILTER_CAL1		= 16'b0000_0000_0100_0000,
					FILTER_CAL2		= 16'b0000_0000_1000_0000,
					FILTER_CAL3		= 16'b0000_0001_0000_0000,
					FILTER_CAL4		= 16'b0000_0010_0000_0000,
					FILTER_END		= 16'b0000_0100_0000_0000,
					FILTER_OVER		= 16'b0000_1000_0000_0000; 
					
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			r_dist_data5 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_dist_data1 <= r_dist_data2;
			r_dist_data2 <= r_dist_data3;
			r_dist_data3 <= r_dist_data4;
			r_dist_data4 <= r_dist_data5;
			r_dist_data5 <= i_dist_data;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			r_rssi_data5 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_rssi_data1 <= r_rssi_data2;
			r_rssi_data2 <= r_rssi_data3;
			r_rssi_data3 <= r_rssi_data4;
			r_rssi_data4 <= r_rssi_data5;
			r_rssi_data5 <= i_rssi_data;
		end
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)begin
			r_pulse_data1 <= 16'd0;
			r_pulse_data2 <= 16'd0;
			r_pulse_data3 <= 16'd0;
			r_pulse_data4 <= 16'd0;
			r_pulse_data5 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_pulse_data1 <= r_pulse_data2;
			r_pulse_data2 <= r_pulse_data3;
			r_pulse_data3 <= r_pulse_data4;
			r_pulse_data4 <= r_pulse_data5;
			r_pulse_data5 <= i_pulse_data;
		end
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)begin
			r_rssi_tail1 <= 16'd0;
			r_rssi_tail2 <= 16'd0;
			r_rssi_tail3 <= 16'd0;
			r_rssi_tail4 <= 16'd0;
			r_rssi_tail5 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_ASSIGN)begin
			r_rssi_tail1 <= r_rssi_tail2;
			r_rssi_tail2 <= r_rssi_tail3;
			r_rssi_tail3 <= r_rssi_tail4;
			r_rssi_tail4 <= r_rssi_tail5;
			r_rssi_tail5 <= i_rssi_tail;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			r_dist_diff4 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_IDLE)begin
			r_dist_diff1 <= 16'd0;
			r_dist_diff2 <= 16'd0;
			r_dist_diff3 <= 16'd0;
			r_dist_diff4 <= 16'd0;
		end
		else if(r_filter_state	== FILTER_SUB)begin
			if(r_dist_data3 >= r_dist_data1)
				r_dist_diff1 <= r_dist_data3 - r_dist_data1;
			else
				r_dist_diff1 <= r_dist_data1 - r_dist_data3;
			if(r_dist_data3 >= r_dist_data2)
				r_dist_diff2 <= r_dist_data3 - r_dist_data2;
			else
				r_dist_diff2 <= r_dist_data2 - r_dist_data3;
			if(r_dist_data3 >= r_dist_data4)
				r_dist_diff3 <= r_dist_data3 - r_dist_data4;
			else
				r_dist_diff3 <= r_dist_data4 - r_dist_data3;
			if(r_dist_data3 >= r_dist_data5)
				r_dist_diff4 <= r_dist_data3 - r_dist_data5;
			else
				r_dist_diff4 <= r_dist_data5 - r_dist_data3;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_dist_data	<= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_dist_data	<= 16'd0;
		else if(r_filter_state == FILTER_CAL1)
			r_dist_data <= (r_dist_data1 + r_dist_data2 + r_dist_data3 + r_dist_data3 + r_dist_data3 + r_dist_data3 +r_dist_data4 + r_dist_data5) >> 2'd3;
		else if(r_filter_state == FILTER_CAL2)
			r_dist_data <= (r_dist_data2 + r_dist_data3 + r_dist_data3 + r_dist_data4) >> 2'd2;
		else if(r_filter_state == FILTER_CAL3)
			r_dist_data <= (r_dist_data2 + r_dist_data3 + r_dist_data3 + r_dist_data4) >> 2'd2;
		else if(r_filter_state == FILTER_CAL4)
			r_dist_data <= r_dist_data3;
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state == FILTER_IDLE)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state == FILTER_CAL1 || r_filter_state == FILTER_CAL2 || r_filter_state == FILTER_CAL3 ||r_filter_state == FILTER_CAL4)
			r_rssi_data <= r_rssi_data3;
	end	
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_pulse_data	<= 16'd0;
		else if(r_filter_state == FILTER_IDLE)
			r_pulse_data	<= 16'd0;
		else if(r_filter_state == FILTER_CAL1 || r_filter_state == FILTER_CAL2 || r_filter_state == FILTER_CAL3 ||r_filter_state == FILTER_CAL4)
			r_pulse_data <= r_pulse_data3;
	end	
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_rssi_tail	<= 16'd0;
		else if(r_filter_state == FILTER_IDLE)
			r_rssi_tail	<= 16'd0;
		else if(r_filter_state == FILTER_CAL1 || r_filter_state == FILTER_CAL2 || r_filter_state == FILTER_CAL3 ||r_filter_state == FILTER_CAL4)
			r_rssi_tail <= r_rssi_tail3;
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)		
			r_code_angle <= 16'd0;
		else if(r_filter_state == FILTER_ASSIGN)begin
			if(i_reso_mode == 4'd0)begin
				if(i_code_angle >= 16'd2)
					r_code_angle <= i_code_angle - 16'd2;
				else
					r_code_angle <= i_code_angle + 16'd3598;
			end
			else if(i_reso_mode == 4'd1)begin
				if(i_code_angle >= 16'd2)
					r_code_angle <= i_code_angle - 16'd2;
				else
					r_code_angle <= i_code_angle + 16'd7198;
			end
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_dist_new_sig <= 1'b0;
		else if(r_filter_state == FILTER_END)
			r_dist_new_sig <= 1'b1;
		else
			r_dist_new_sig <= 1'b0;
	end
		  
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 1'b0)
			r_filter_state	<= FILTER_IDLE;
		else begin
			case(r_filter_state)
				FILTER_IDLE	:begin
				    if(i_sfim_switch)
						r_filter_state	<= FILTER_WAIT;
					else
						r_filter_state	<= FILTER_IDLE;
				end
				FILTER_WAIT	:begin
					if(i_dist_new_sig)
						r_filter_state	<= FILTER_ASSIGN;
					else
						r_filter_state	<= FILTER_WAIT;
				end
				FILTER_ASSIGN:
					r_filter_state	<= FILTER_SHIFT;
				FILTER_SHIFT:begin
					if(r_dist_data3 >= 16'd2500 || r_dist_data3 == 16'd0)
						r_filter_state	<= FILTER_CAL4;
					else
						r_filter_state	<= FILTER_SUB;
				end
				FILTER_SUB	:
					r_filter_state	<= FILTER_COMP;
				FILTER_COMP	:begin
					if(r_dist_data3<=16'd500)begin
						if(r_dist_diff1 <= 16'd25 && r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
							r_filter_state	<= FILTER_CAL1;
						else if(r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
							r_filter_state	<= FILTER_CAL2;
						else
							r_filter_state	<= FILTER_CAL4;
					end
					else if(r_dist_data3>16'd500&&r_dist_data3<16'd2500)begin
						if(r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
							r_filter_state	<= FILTER_CAL3; 
						else
							r_filter_state	<= FILTER_CAL4;	
                    end		
                end					
				FILTER_CAL1,FILTER_CAL2,FILTER_CAL3,FILTER_CAL4:
					r_filter_state	<= FILTER_END;
				FILTER_END:
					r_filter_state	<= FILTER_OVER;
				FILTER_OVER:
					r_filter_state	<= FILTER_IDLE;
				default:r_filter_state	<= FILTER_IDLE;
			endcase
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)			
			r_dist_data_reg <= 16'd0;
		else if(w_dist_new_sig)		
			r_dist_data_reg <= w_dist_data;		
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_rssi_data_reg	<= 16'd0;
		else if(w_dist_new_sig)
			r_rssi_data_reg	<= w_rssi_data;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_pulse_data_reg	<= 16'd0;
		else if(w_dist_new_sig)
			r_pulse_data_reg	<= w_pulse_data;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_rssi_tail_reg	<= 16'd0;
		else if(w_dist_new_sig)
			r_rssi_tail_reg	<= w_rssi_tail;
	end

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_dist_new_reg	<= 1'b0;
			r_dist_new_reg1	<= 1'b0;
		end
		else begin
			r_dist_new_reg	<= w_dist_new_sig;
			r_dist_new_reg1	<= r_dist_new_reg;
		end
	end
			
	assign	w_dist_data 	= (i_sfim_switch)?r_dist_data[15:0]:i_dist_data;
	assign	w_rssi_data 	= (i_sfim_switch)?r_rssi_data:i_rssi_data;
	assign	w_pulse_data 	= (i_sfim_switch)?r_pulse_data:i_pulse_data;
	assign	w_rssi_tail 	= (i_sfim_switch)?r_rssi_tail:i_rssi_tail;
	assign	w_dist_new_sig 	= (i_sfim_switch)?r_dist_new_sig:i_dist_new_sig;
	
	assign	o_code_angle 	= (i_sfim_switch)?r_code_angle:i_code_angle;//�Ƕ�ֵ
	assign	o_dist_data 	= r_dist_data_reg;
	assign	o_rssi_data		= r_rssi_data_reg;
	assign	o_pulse_data	= r_pulse_data_reg;
	assign	o_rssi_tail		= r_rssi_tail_reg;
	assign	o_dist_new_sig	= r_dist_new_reg1;
				

endmodule 