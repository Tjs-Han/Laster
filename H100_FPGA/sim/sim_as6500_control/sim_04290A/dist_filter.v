module dist_filter
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input	[15:0]	i_code_angle 		,//角度值
	input	[15:0]	i_dist_data			,
	input	[15:0]	i_rssi_data			,
	input			i_dist_new_sig		,
	
	input			i_sfim_switch		,
	
	output	[15:0]	o_code_angle 		,//角度值
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		
);

	
	reg		[15:0]	r_code_angle = 16'd0;//角度值
	reg		[19:0]	r_dist_data = 20'd0;
	reg		[15:0]	r_rssi_data = 16'd0;
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
					FILTER_END1		= 16'b0000_1000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_dist_data1 <= 16'd0;
			r_dist_data2 <= 16'd0;
			r_dist_data3 <= 16'd0;
			r_dist_data4 <= 16'd0;
			r_dist_data5 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_rssi_data1 <= 16'd0;
			r_rssi_data2 <= 16'd0;
			r_rssi_data3 <= 16'd0;
			r_rssi_data4 <= 16'd0;
			r_rssi_data5 <= 16'd0;
			end
		else if(r_filter_state	== FILTER_IDLE)begin
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)
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
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_rssi_data	<= 16'd0;
		else if(r_filter_state == FILTER_END)
			r_rssi_data <= r_rssi_data3;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)		
			r_code_angle <= 16'd0;
		else if(r_filter_state	== FILTER_IDLE)
			r_code_angle <= 16'd0;
		else if(r_filter_state == FILTER_END)begin
			if(i_code_angle >= 16'd2)
				r_code_angle <= i_code_angle - 2'd2;
			else
				r_code_angle <= i_code_angle;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_dist_new_sig <= 1'b0;
		else if(r_filter_state == FILTER_END1)
			r_dist_new_sig <= 1'b1;
		else
			r_dist_new_sig <= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_filter_state	<= FILTER_IDLE;
		else begin
			case(r_filter_state)
				FILTER_IDLE	:
					r_filter_state	<= FILTER_WAIT;
				FILTER_WAIT	:begin
					if(i_dist_new_sig)
						r_filter_state	<= FILTER_ASSIGN;
					else
						r_filter_state	<= FILTER_WAIT;
					end
				FILTER_ASSIGN:
					r_filter_state	<= FILTER_SHIFT;
				FILTER_SHIFT:begin
					if(r_dist_data3 >= 16'd2500 || r_dist_data3 == 16'd0 || ~i_sfim_switch)
						r_filter_state	<= FILTER_CAL4;
					else
						r_filter_state	<= FILTER_SUB;
					end
				FILTER_SUB	:
					r_filter_state	<= FILTER_COMP;
				FILTER_COMP	:begin
					if(r_dist_data3<=16'd500)
					begin
					  if(r_dist_diff1 <= 16'd25 && r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
						r_filter_state	<= FILTER_CAL1;
					  else if(r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
						r_filter_state	<= FILTER_CAL2;
					  else
						r_filter_state	<= FILTER_CAL4;
					end
					else if(r_dist_data3>16'd500&&r_dist_data3<16'd2500)
				    begin
					  if(r_dist_diff2 <= 16'd25 && r_dist_diff3 <= 16'd25 && r_dist_diff4 <= 16'd25)
						r_filter_state	<= FILTER_CAL3; 
                      else
						r_filter_state	<= FILTER_CAL4;	
                    end		
                 end					
				FILTER_CAL1,FILTER_CAL2,FILTER_CAL3,FILTER_CAL4:
					r_filter_state	<= FILTER_END;
				FILTER_END:
					r_filter_state	<= FILTER_END1;
				FILTER_END1:
					r_filter_state	<= FILTER_WAIT;
				default:r_filter_state	<= FILTER_IDLE;
				endcase
			end
			
	assign	o_code_angle 	= r_code_angle;//角度值
	assign	o_dist_data 	= r_dist_data[15:0];
	assign	o_rssi_data 	= r_rssi_data;
	assign	o_dist_new_sig 	= r_dist_new_sig;
				

endmodule 