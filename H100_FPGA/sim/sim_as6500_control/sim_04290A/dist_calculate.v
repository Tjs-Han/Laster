module dist_calculate
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	input			i_rssi_switch		,
	input			i_tdc_new_sig		,
	input	[15:0]	i_rise_data			,//������
	input	[15:0]	i_fall_data			,//�½��ء�
	
	input	[15:0]	i_rise_divid		,
	input	[15:0]	i_pulse_start		,
	input	[15:0]	i_pulse_divid		,
	input	[15:0]	i_distance_min		,
	input	[15:0]	i_distance_max		,
	input	[15:0]	i_dist_compen		,
	output	[17:0]	o_coe_sram_addr		,
	input	[15:0]	i_coe_sram_data		,
	
	output	[15:0]	o_dist_data			,
	output	[15:0]	o_rssi_data			,
	output			o_dist_new_sig		
);

	wire		[3:0]	w_index_flag;//3�����״̬��2��ǰ�طֽ�״̬��1�������ֽ�״̬��0������״̬
	wire		[15:0]	w_rise_index;
	wire		[15:0]	w_rise_remain;
	wire		[15:0]	w_pulse_index;
	wire		[15:0]	w_pulse_remain;
	
	wire		[15:0]	w_rise_data;
	wire		[15:0]	w_pulse_data;
	wire				w_dist_cal_sig;
	
	data_pre U1(
	
		.i_clk_50m    		(i_clk_50m)			,
		.i_rst_n      		(i_rst_n)			,
		
		.i_tdc_new_sig		(i_tdc_new_sig)		,
		.i_rise_data		(i_rise_data)		,//������
		.i_fall_data		(i_fall_data)		,//�½���
		
		.o_rise_data		(w_rise_data)		,//������
		.o_pulse_data		(w_pulse_data)		,
		.o_dist_cal_sig		(w_dist_cal_sig)
	);

	index_cal U2(
	
		.i_clk_50m    		(i_clk_50m)			,
		.i_rst_n      		(i_rst_n)			,
		
		.i_rise_data		(w_rise_data)		,//������
		.i_pulse_data		(w_pulse_data)		,
		
		.i_dist_cal_sig		(w_dist_cal_sig)	,
		.i_rise_divid		(i_rise_divid)		,
		.i_pulse_start		(i_pulse_start)		,
		.i_pulse_divid		(i_pulse_divid)		,
		
		.o_index_flag		(w_index_flag)		,
		.o_rise_index		(w_rise_index)		,
		.o_rise_remain		(w_rise_remain)		,
		.o_pulse_index		(w_pulse_index)		,
		.o_pulse_remain		(w_pulse_remain)
	
	);
	
	wire	[17:0]	w_coe_sram_addrd;
	wire			w_dist_flag		;
	
	dist_cal U3(
	
		.i_clk_50m    		(i_clk_50m)			,
		.i_rst_n      		(i_rst_n)			,
		
		.i_rise_data		(w_rise_data)		,

		.i_index_flag		(w_index_flag)		,
		.i_rise_index		(w_rise_index)		,
		.i_rise_remain		(w_rise_remain)		,
		.i_pulse_index		(w_pulse_index)		,
		.i_pulse_remain		(w_pulse_remain)	,
		
		.i_distance_min		(i_distance_min)	,
		.i_distance_max		(i_distance_max)	,
		.i_dist_compen		(i_dist_compen)		,
		.o_coe_sram_addr	(w_coe_sram_addrd)	,
		.i_coe_sram_data	(i_coe_sram_data)	,
		
		.o_dist_flag		(w_dist_flag)		,
		.o_dist_data		(o_dist_data)		
	
	);
	
	wire	[17:0]	w_coe_sram_addrr;
	wire			w_rssi_sram_en;
	
	assign			o_coe_sram_addr = (w_rssi_sram_en)?w_coe_sram_addrr:w_coe_sram_addrd;
	
	rssi_cal U4(
	
		.i_clk_50m    		(i_clk_50m)			,
		.i_rst_n      		(i_rst_n)			,
		
		.i_rssi_switch		(i_rssi_switch)		,
		.i_dist_flag		(w_dist_flag)		,
		.i_pulse_data		(w_pulse_data)		,
		.i_dist_data		(o_dist_data)		,
		
		.o_coe_sram_addr	(w_coe_sram_addrr)	,
		.o_rssi_sram_en		(w_rssi_sram_en)	,
		.i_coe_sram_data	(i_coe_sram_data)	,
		
		.o_rssi_data		(o_rssi_data)		,
		.o_dist_new_sig		(o_dist_new_sig)	
	);

endmodule 