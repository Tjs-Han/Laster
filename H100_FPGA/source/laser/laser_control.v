module laser_control
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_angle_sync 	,//码盘信号标志，用以标志充电与出光
	input	[15:0]	i_stop_window	,//TDC窗口设置
		
	output			o_laser_str  	,//出光信号，充电后等待2us出光
	output			o_disable_tdc  	,//TDC窗口
	output			o_rstidx_tdc  	,
	output			o_thre_high		,
	output			o_thre_pulse	
);   
	reg [7:0]	r_laser_state = 8'd0;
	reg [3:0]	r_emit_cnt = 4'd0;
	reg [4:0]	r_rsti_cnt = 5'd0;
	reg [7:0]	r_window_cnt = 8'd0;
	reg 		r_disable_tdc = 1'b1;
	reg 		r_rstidx_tdc = 1'b0;
	reg        	r_laser_str = 1'b0;
	
	parameter   	LASER_IDLE   = 8'b0000_0000,
					LASER_WAIT   = 8'b0000_0010,
					LASER_RSTI   = 8'b0000_0100,
					LASER_DELAY  = 8'b0000_1000,
					LASER_EMIT   = 8'b0001_0000,
					LASER_WINDOW = 8'b0010_0000,
					LASER_END    = 8'b0100_0000;
					
	always@(posedge i_clk_50m or negedge i_rst_n)
	    if(i_rst_n == 0)
		   r_laser_state <= LASER_IDLE;
		else begin
			case(r_laser_state)
				LASER_IDLE	: 	r_laser_state <= LASER_WAIT;
				LASER_WAIT	: 	if(i_angle_sync)
									r_laser_state <= LASER_DELAY;
								else 
									r_laser_state <= LASER_WAIT;
				LASER_DELAY	:	r_laser_state <= LASER_RSTI;
				LASER_RSTI	:	if(r_rsti_cnt >= 5'd15)
									r_laser_state <= LASER_EMIT;
								else
									r_laser_state <= LASER_RSTI;
				LASER_EMIT	: 	if(r_emit_cnt >= 4'd2)
									r_laser_state <= LASER_WINDOW;
								else
									r_laser_state <= LASER_EMIT;
				LASER_WINDOW: 	if(r_window_cnt >= 8'd99)
									r_laser_state <= LASER_END;
								else
									r_laser_state <= LASER_WINDOW;
				LASER_END 	: 	r_laser_state <= LASER_IDLE;
				default    	: 	r_laser_state <= LASER_IDLE;
				endcase
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)//发光计数
		if(i_rst_n == 0)
			r_rsti_cnt 		<= 5'd0;
		else if(r_laser_state == LASER_RSTI)
			r_rsti_cnt 		<= r_rsti_cnt + 1'b1;
		else
			r_rsti_cnt 		<= 5'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//发光计数
		if(i_rst_n == 0)
			r_emit_cnt 		<= 4'd0;
		else if(r_laser_state == LASER_EMIT)
			r_emit_cnt 		<= r_emit_cnt + 1'b1;
		else
			r_emit_cnt 		<= 4'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//发光信号
		if(i_rst_n == 0)
			r_laser_str 	<= 1'b0;
		else if(r_laser_state == LASER_EMIT)
			r_laser_str 	<= 1'b1;
		else 
			r_laser_str 	<= 1'b0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//窗口周期计数
		if(i_rst_n == 0)
			r_window_cnt 	<= 8'd0;
		else if(r_laser_state == LASER_WINDOW)
			r_window_cnt 	<= r_window_cnt + 1'b1;
		else
			r_window_cnt 	<= 8'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//主波窗口
		if(i_rst_n == 0)	
			r_disable_tdc 	<= 1'b1;
		else if(r_laser_state == LASER_RSTI && r_rsti_cnt >= 5'd6)
			r_disable_tdc 	<= 1'b0;
		else if(r_laser_state == LASER_WINDOW && r_window_cnt >= i_stop_window[15:9])
			r_disable_tdc 	<= 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)//回波窗口
		if(i_rst_n == 0)	
			r_rstidx_tdc 	<= 1'b0;
		else if(r_laser_state == LASER_RSTI)
			r_rstidx_tdc 	<= 1'b1;
		else 
			r_rstidx_tdc 	<= 1'b0;
		   
	assign		o_laser_str		= r_laser_str;
	assign		o_disable_tdc	= r_disable_tdc;
	assign		o_rstidx_tdc	= 1'b0;//r_rstidx_tdc;
	assign		o_thre_high		= 1'b1;
	assign		o_thre_pulse	= 1'b0;

endmodule 