module opto_switch_filter
(
	input       i_clk_50m    	,
	input       i_rst_n      	,

	input		i_opto_switch	,//�����ź�����

	output		o_opto_switch	 //�����ź����
);

	reg			r_opto_switch = 1'b0;
	
	reg         r_opto_switch1 	= 1'b1;
	reg         r_opto_switch2	= 1'b1;//�����ź�ͬ��
	
	reg 	[15:0]r_opto_cnt	= 16'd0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)//�������ź�������ͬ��
	   if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
			end
		else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_cnt <= 16'd0;
		else if(r_opto_switch2 != r_opto_switch1)
			r_opto_cnt <= 16'd0;
		else if(r_opto_cnt < 16'hffff)
			r_opto_cnt <= r_opto_cnt + 1'b1;
		else
			r_opto_cnt <= r_opto_cnt;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_opto_switch <= 1'b0;
		else if(r_opto_cnt >= 16'd500)
			r_opto_switch <= r_opto_switch2;
		else
			r_opto_switch <= r_opto_switch;
			
	assign o_opto_switch = r_opto_switch;
			
endmodule 