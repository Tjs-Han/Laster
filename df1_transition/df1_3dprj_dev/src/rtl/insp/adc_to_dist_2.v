module adc_to_dist_2
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_dac_set_sig		,
	input	[7:0]	i_device_temp		,
	input	[7:0]	i_temp_temp_base	,
	input	[15:0]	i_dist_diff			,
	
	input			i_dicp_switch		,
	output	[6:0]	o_dicp_ram_rdaddr	,
	input	[15:0]	i_dicp_rddata		,

	output	[15:0]	o_dist_compen		
);

	reg		[2:0]	r_table_state = 3'd0;
	reg		[7:0]	r_temp_diff	= 8'd0;
	reg		[7:0]	r_temp_value = 8'd0;
	reg				r_diff_value = 1'b0;
	reg		[6:0]	r_dicp_ram_rdaddr = 7'd0;
	reg		[15:0]	r_dicp_rdvalue1 = 16'd0;
	
	reg				r_dicp_polar_pre1 = 1'b0;
	
	reg				r_dicp_polar_pre = 1'b0;
	reg		[15:0]	r_dist_compen_pre = 16'd0;
	
	reg				r_dist_diff_polar = 1'b0;
	reg		[15:0]	r_dist_diff_dist = 16'd0;
	
	reg				r_dicp_polar = 1'b0;
	reg		[15:0]	r_dist_compen = 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)	begin
			r_temp_diff			<= 8'd0;
			r_temp_value		<= 8'd0;
			r_diff_value		<= 1'b0;
			r_dicp_ram_rdaddr	<= 7'd0;
			r_dicp_rdvalue1		<= 16'd0;
			r_dicp_polar_pre1	<= 1'b0;
			r_dist_compen_pre	<= 16'd0;
			r_dicp_polar_pre	<= 1'b0;
			r_dist_compen		<= 16'd0;
			r_dicp_polar		<= 1'b0;
			r_dist_diff_polar	<= 1'b0;
			r_dist_diff_dist	<= 16'd0;
			r_table_state 		<= 3'd0;
		end
		else begin
			case(r_table_state)
				3'd0:	begin
					r_temp_diff			<= 8'd0;
					r_temp_value		<= 8'd0;
					r_diff_value		<= 1'b0;
					r_dicp_ram_rdaddr	<= 7'd0;
					r_dicp_rdvalue1		<= 16'd0;
					if(i_dac_set_sig)begin
						r_temp_diff			<= i_device_temp + 8'd90 - i_temp_temp_base;
						r_dist_diff_polar	<= i_dist_diff[15];
						r_dist_diff_dist	<= i_dist_diff[14:0];
						r_table_state 		<= 3'd1;
					end
				end
				3'd1:	begin
					if(r_temp_diff[7] == 1'b1)begin
						r_dicp_ram_rdaddr	<= 7'd0;
						r_diff_value		<= 1'b0;
						r_table_state 		<= 3'd2;
					end
					else if(r_temp_diff >= 8'd178)begin
						r_dicp_ram_rdaddr	<= 7'd89;
						r_diff_value		<= 1'b0;
						r_table_state 		<= 3'd2;
					end
					else begin
						r_dicp_ram_rdaddr	<= r_temp_diff[7:1];
						r_diff_value		<= r_temp_diff[0];
						r_table_state 		<= 3'd2;
					end
				end
				3'd2:	begin
					r_table_state 		<= 3'd3;
				end
				3'd3:	begin
					r_dicp_ram_rdaddr	<= r_dicp_ram_rdaddr + 1'b1;
					r_table_state 		<= 3'd4;
				end
				3'd4:	begin
					r_dicp_polar_pre1	<= i_dicp_rddata[15];
					r_dicp_rdvalue1		<= i_dicp_rddata[14:0];
					r_table_state 		<= 3'd5;
				end
				3'd5:	begin
					r_table_state 		<= 3'd6;
				end
				3'd6:	begin
					if(r_diff_value)begin
						if(r_dicp_polar_pre1 == i_dicp_rddata[15])begin
							r_dist_compen_pre	<= r_dicp_rdvalue1 + i_dicp_rddata[14:0];
							r_dicp_polar_pre	<= r_dicp_polar_pre1;
						end
						else if(r_dicp_rdvalue1 >= i_dicp_rddata[14:0])begin
							r_dist_compen_pre	<= r_dicp_rdvalue1 - i_dicp_rddata[14:0];
							r_dicp_polar_pre	<= r_dicp_polar_pre1;
						end
						else begin
							r_dist_compen_pre	<= i_dicp_rddata[14:0] - r_dicp_rdvalue1;
							r_dicp_polar_pre	<= i_dicp_rddata[15];
						end
					end
					else begin
						r_dist_compen_pre	<= r_dicp_rdvalue1 + r_dicp_rdvalue1;
						r_dicp_polar_pre	<= r_dicp_polar_pre1;
					end
					r_table_state 		<= 3'd7;
				end
				3'd7:	begin
					if(i_dicp_switch)begin
						if(r_dicp_polar_pre == r_dist_diff_polar)begin
							r_dicp_polar		<= r_dicp_polar_pre;
							r_dist_compen		<= r_dist_compen_pre[15:1] + r_dist_diff_dist;
						end
						else if(r_dist_compen_pre[15:1] >= r_dist_diff_dist)begin
							r_dicp_polar		<= r_dicp_polar_pre;
							r_dist_compen		<= r_dist_compen_pre[15:1] - r_dist_diff_dist;
						end
						else begin
							r_dicp_polar		<= r_dist_diff_polar;
							r_dist_compen		<= r_dist_diff_dist - r_dist_compen_pre[15:1];
						end
					end
					else begin
						r_dicp_polar		<= r_dist_diff_polar;
						r_dist_compen		<= r_dist_diff_dist;
					end
					r_table_state 		<= 3'd0;
				end
			endcase
		end 
			
			
	assign	o_dist_compen	= {r_dicp_polar,r_dist_compen[14:0]};
	assign	o_dicp_ram_rdaddr = r_dicp_ram_rdaddr;

endmodule 