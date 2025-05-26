module tdc_process
(
	input				i_clk_50m    		,
	input				i_rst_n      		,
	
	input		[15:0]	i_code_angle 		,//�Ƕ�ֵ
	input				i_tdc_new_sig		,
	input		[15:0]	i_rise_data			,//������
	input		[15:0]	i_fall_data			,//�½���
	input       [1:0]  	i_reso_mode         ,

	input		[15:0]	i_start_index		,
	input		[15:0]	i_stop_index		,	
	
	input               i_tdc_switch        ,//����
	
	output		[15:0]	o_code_angle 		,//�Ƕ�ֵ
	output				o_cal_sig			,
	output		[15:0]	o_rise_data			,//������
	output		[15:0]	o_fall_data			,//�½���
	output reg  [1:0]	tdc_process_error	,

	output reg  [15:0]	tdc_process_error_last_code,
	output reg  [15:0]	tdc_process_error_current_code
);

	reg			[15:0]	r_rise_data_1 = 16'd0;
	reg			[15:0]	r_rise_data_2 = 16'd0;
	reg			[15:0]	r_rise_data_3 = 16'd0;
	
	reg			[15:0]	r_rise_diff_1 = 16'd0;
	reg			[15:0]	r_rise_diff_2 = 16'd0;
	
	reg			[15:0]	r_fall_data_1 = 16'd0;
	reg			[15:0]	r_fall_data_2 = 16'd0;
	reg			[15:0]	r_fall_data_3 = 16'd0;
	
	reg					r_tdc_new_sig_1 = 1'b0;
	reg					r_tdc_new_sig_2 = 1'b0;
	
	reg			[10:0]	r_tdc_wr_addr	= 11'd0;
	reg			[15:0]	r_tdc_wr_rise	= 16'd0;
	reg			[15:0]	r_tdc_wr_fall	= 16'd0;
	reg					r_tdc_wren		= 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_rise_data_1	<= 16'd0;
			r_rise_data_2	<= 16'd0;
			r_rise_data_3	<= 16'd0;
			end
		else if(i_tdc_new_sig)begin
			r_rise_data_1	<= i_rise_data;
			r_rise_data_2	<= r_rise_data_1;
			r_rise_data_3	<= r_rise_data_2;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_fall_data_1	<= 16'd0;
			r_fall_data_2	<= 16'd0;
			r_fall_data_3	<= 16'd0;
			end
		else if(i_tdc_new_sig)begin
			r_fall_data_1	<= i_fall_data;
			r_fall_data_2	<= r_fall_data_1;
			r_fall_data_3	<= r_fall_data_2;
			end

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_tdc_new_sig_1	<= 1'b0;
			r_tdc_new_sig_2	<= 1'b0;
			end
		else begin
			r_tdc_new_sig_1	<= i_tdc_new_sig;
			r_tdc_new_sig_2	<= r_tdc_new_sig_1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_diff_1	<= 16'd0;
		else if(r_tdc_new_sig_1)begin
			if(r_rise_data_1 >= r_rise_data_3)
				r_rise_diff_1	<= r_rise_data_1 - r_rise_data_3;
			else
				r_rise_diff_1	<= r_rise_data_3 - r_rise_data_1;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_diff_2	<= 16'd0;
		else if(r_tdc_new_sig_1)begin
			if(r_rise_data_2 >= r_rise_data_1)
				r_rise_diff_2	<= r_rise_data_2 - r_rise_data_1;
			else
				r_rise_diff_2	<= r_rise_data_1 - r_rise_data_2;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wr_addr	<= 11'd0;
		else if(i_tdc_new_sig)
			r_tdc_wr_addr	<= i_code_angle[10:0] - 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wr_rise	<= 16'd0;
		else if(r_tdc_new_sig_2)begin
			if(r_rise_diff_1 <= 16'd5 && r_rise_diff_2 <= 16'd5)
				r_tdc_wr_rise	<= r_rise_data_3;
			else 
				r_tdc_wr_rise	<= r_rise_data_2;
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wr_fall	<= 16'd0;
		else if(r_tdc_new_sig_2)
			r_tdc_wr_fall	<= r_fall_data_2;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_tdc_wren		<= 1'b0;
		else
			r_tdc_wren		<= r_tdc_new_sig_2;
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	reg			[15:0]	r_code_angle	= 16'd0;
	reg			[15:0]	r_rise_data		= 16'd0;
	reg			[15:0]	r_fall_data		= 16'd0;
	reg					r_cal_sig		= 1'b0;
	
	reg					r_first_sig		= 1'b0;
	reg			[10:0]	r_tdc_rd_addr	= 11'd0;
	reg			[10:0]	r_addr_start	= 11'd0;
	reg			[15:0]	r_rise_post		= 16'd0;
	reg			[15:0]	r_fall_post		= 16'd0;
	reg			[15:0]	r_rise_last		= 16'd0;
	reg			[15:0]	r_fall_last		= 16'd0;
	reg			[15:0]	r_diff_post		= 16'd0;
	reg					r_post_sign		= 1'b0;
	reg			[15:0]	r_diff_now		= 16'd0;
	reg					r_now_sign		= 1'b0;
	reg			[15:0]	r_data_length	= 16'd0;
	reg			[15:0]	r_delay_cnt		= 16'd0;
	wire		[15:0]	w_tdc_rd_rise;
	wire		[15:0]	w_tdc_rd_fall;
	
	reg					r_para_en		= 1'b0;
	wire		[15:0]	w_tdc_para_1;
	wire		[15:0]	w_tdc_para_2;
	wire		[10:0]	w_addr_mid;
	wire				w_para_done;
	
	reg					r_process_en	= 1'b0;
	wire		[15:0]	w_process_data;
	wire				w_process_done;
	
	reg			[10:0]	r_loop_cnt		= 11'd0;
	
	reg			[15:0]	r_data_state	= 16'd0;
	
	parameter		DATA_IDLE		= 16'b0000_0000_0000_0000,
					DATA_READ		= 16'b0000_0000_0000_0010,
					DATA_DIFF		= 16'b0000_0000_0000_0100,
					DATA_JUDGE		= 16'b0000_0000_0000_1000,
					DATA_PARA		= 16'b0000_0000_0001_0000,
					DATA_LOOP		= 16'b0000_0000_0010_0000,
					DATA_ASSIGN1	= 16'b0000_0000_0100_0000,
					DATA_SIG1		= 16'b0000_0000_1000_0000,
					DATA_DELAY1		= 16'b0000_0001_0000_0000,
					DATA_ASSIGN		= 16'b0000_0010_0000_0000,
					DATA_SIG		= 16'b0000_0100_0000_0000,
					DATA_DELAY		= 16'b0000_1000_0000_0000,
					DATA_END		= 16'b0001_0000_0000_0000;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_tdc_rd_addr		<= 11'd0;
			r_rise_post			<= 16'd0;
			r_fall_post			<= 16'd0;
			r_diff_post			<= 16'd0;
			r_post_sign			<= 1'b0;
			r_diff_now			<= 16'd0;
			r_now_sign			<= 1'b0;
			r_data_length		<= 16'd0;
			r_para_en			<= 1'b0;
			r_process_en		<= 1'b0;
			r_loop_cnt			<= 11'd0;
			r_first_sig			<= 1'b0;
			r_data_state		<= DATA_IDLE;
			end
		else begin
			case(r_data_state)
				DATA_IDLE	:begin
					if((i_code_angle >= 16'd1053&&i_reso_mode==2'd2)||(i_code_angle >= 16'd1755&&i_reso_mode==2'd0)||(i_code_angle >= 16'd1404&&i_reso_mode==2'd1)||(i_code_angle >= 16'd702&&i_reso_mode==2'd3))begin
						r_data_state		<= DATA_READ;						
					end
					else begin
						r_data_state		<= DATA_IDLE;
					end

					r_tdc_rd_addr		<= 11'd0;
					r_rise_post			<= 16'd0;
					r_fall_post			<= 16'd0;
					r_diff_post			<= 16'd0;
					r_post_sign			<= 1'b0;
					r_diff_now			<= 16'd0;
					r_now_sign			<= 1'b0;
					r_data_length		<= 16'd0;					
					r_para_en			<= 1'b0;
					r_process_en		<= 1'b0;
					r_loop_cnt			<= 11'd0;
					r_first_sig			<= 1'b0;

				end
				DATA_READ	:begin
					if(w_tdc_rd_rise >= 16'd8000 || w_tdc_rd_rise == 16'd0 || w_tdc_rd_rise == 16'hFFFF)begin
						r_rise_post			<= w_tdc_rd_rise;
						r_fall_post			<= w_tdc_rd_fall;

						if(r_data_length != 16'd0)begin
							r_tdc_rd_addr		<= r_addr_start + 16'd1;

							r_diff_post			<= 16'd0;
							r_post_sign			<= 1'b0;
							r_diff_now			<= 16'd0;
							r_now_sign			<= 1'b0;
							r_data_length		<= 16'd0;
							r_para_en			<= 1'b0;
							r_process_en		<= 1'b0;
							r_loop_cnt			<= 11'd0;
							r_first_sig			<= 1'b1;
						end

						r_data_state		<= DATA_ASSIGN;
					end
					else
						r_data_state		<= DATA_DIFF;
					end
				DATA_DIFF	:begin
					if(r_diff_now > 16'd2)begin
						r_diff_post			<= r_diff_now;
						r_post_sign			<= r_now_sign;
					end

					if(w_tdc_rd_rise >= r_rise_post + 16'd12)begin
						r_diff_now			<= 16'd12;
						r_now_sign			<= 1'b1;
						end
					else if(w_tdc_rd_rise >= r_rise_post)begin
						r_diff_now			<= w_tdc_rd_rise - r_rise_post;
						r_now_sign			<= 1'b1;
						end
					else if(r_rise_post >= w_tdc_rd_rise + 16'd12)begin
						r_diff_now			<= 16'd12;
						r_now_sign			<= 1'b0;
						end
					else begin
						r_diff_now			<= r_rise_post - w_tdc_rd_rise;
						r_now_sign			<= 1'b0;
						end
					r_data_state		<= DATA_JUDGE;
					r_rise_post			<= w_tdc_rd_rise;
					r_fall_post			<= w_tdc_rd_fall;
					end
				DATA_JUDGE	:begin
					if(r_diff_now <= 16'd2)begin
						if(r_data_length == 16'd0)begin
							r_addr_start		<= r_tdc_rd_addr - 1'b1;
						end
						r_data_length		<= r_data_length + 1'b1;
						r_tdc_rd_addr		<= r_tdc_rd_addr + 1'b1;

						if(r_data_length < 16'd256)
						  r_data_state		<= DATA_READ;
						else
						  r_data_state		<= DATA_PARA;
					end
					else if(r_data_length > 16'd0)
						r_data_state		<= DATA_PARA;
					else
						r_data_state		<= DATA_ASSIGN;
					end
				DATA_PARA	:begin
					r_para_en			<= 1'b1;
					if(w_para_done)begin
						r_tdc_rd_addr		<= r_addr_start;
						r_para_en			<= 1'b0;
						r_data_state		<= DATA_LOOP;
						end
					else
						r_data_state		<= DATA_PARA;
					end
				DATA_LOOP	:begin
					r_process_en		<= 1'b1;
					if(w_process_done)begin
						r_process_en		<= 1'b0;
						r_data_state		<= DATA_ASSIGN1;
						end
					end
				DATA_ASSIGN1:
					r_data_state		<= DATA_SIG1;
				DATA_SIG1	:begin
					if((r_tdc_rd_addr >= 16'd1053&&i_reso_mode==2'd2)||(r_tdc_rd_addr >= 16'd1755&&i_reso_mode==2'd0)||(r_tdc_rd_addr >= 16'd1404&&i_reso_mode==2'd1)||(r_tdc_rd_addr >= 16'd702&&i_reso_mode==2'd3))
						r_data_state		<= DATA_IDLE;
					else begin
						r_tdc_rd_addr		<= r_tdc_rd_addr + 1'b1;
						r_data_state		<= DATA_DELAY1;
						end
					end
				DATA_DELAY1	:begin
					if(r_delay_cnt >= 16'd400)begin//if(r_delay_cnt >= 8'd63)begin
						if(r_loop_cnt >= r_data_length)begin
							r_data_length		<= 16'd0;
							r_loop_cnt			<= 11'd0;
							r_tdc_rd_addr		<= r_tdc_rd_addr + 1'b1;
							r_data_state		<= DATA_END;
							end
						else begin
							r_loop_cnt			<= r_loop_cnt + 1'b1;
							r_data_state		<= DATA_LOOP;
							end
						end
					else
						r_data_state		<= DATA_DELAY1;
					end
				DATA_ASSIGN	:
					r_data_state		<= DATA_SIG;
				DATA_SIG	:begin
					r_first_sig			<= 1'b1;
					if((r_tdc_rd_addr >= 16'd1053&&i_reso_mode==2'd2)||(r_tdc_rd_addr >= 16'd1755&&i_reso_mode==2'd0)||(r_tdc_rd_addr >= 16'd1404&&i_reso_mode==2'd1)||(r_tdc_rd_addr >= 16'd702&&i_reso_mode==2'd3))
						r_data_state		<= DATA_IDLE;
					else begin
						r_tdc_rd_addr		<= r_tdc_rd_addr + 1'b1;
						r_data_state		<= DATA_DELAY;
						end
					end
				DATA_DELAY	:begin
					if(r_delay_cnt >= 16'd400)
						r_data_state		<= DATA_END;
					else
						r_data_state		<= DATA_DELAY;
					end
				DATA_END	:
					r_data_state		<= DATA_READ;
				default		:
					r_data_state		<= DATA_IDLE;
				endcase
			end
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_last		<= 16'd0;
		else if(r_data_state == DATA_IDLE)
			r_rise_last		<= 16'd0;
		else if(r_data_state == DATA_READ)
			r_rise_last		<= r_rise_post;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fall_last		<= 16'd0;
		else if(r_data_state == DATA_IDLE)
			r_fall_last		<= 16'd0;
		else if(r_data_state == DATA_READ)
			r_fall_last		<= r_fall_post;
					
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_angle	<= 16'd0;
		else if(r_data_state == DATA_ASSIGN)
			r_code_angle	<= r_tdc_rd_addr - 1'b1;
		else if(r_data_state == DATA_ASSIGN1)
			r_code_angle	<= r_tdc_rd_addr;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_rise_data		<= 16'd0;
		else if(r_data_state == DATA_ASSIGN)
			r_rise_data		<= r_rise_last;
		else if(r_data_state == DATA_ASSIGN1)
			r_rise_data		<= w_process_data;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fall_data		<= 16'd0;
		else if(r_data_state == DATA_ASSIGN)
			r_fall_data		<= r_fall_last;
		else if(r_data_state == DATA_ASSIGN1)
			r_fall_data		<= w_tdc_rd_fall;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_delay_cnt		<= 16'd0;
		else if(r_data_state == DATA_DELAY || r_data_state == DATA_DELAY1)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt		<= 16'd0;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_cal_sig		<= 1'b0;
		else if(r_data_state == DATA_SIG)
			r_cal_sig		<= r_first_sig;
		else if(r_data_state == DATA_SIG1)
			r_cal_sig		<= 1'b1;
		else
			r_cal_sig		<= 1'b0;
			
	reg		[15:0]	rr_code_angle = 16'd0;
	reg				r_code_error = 1'b0;
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			rr_code_angle	<= 16'd0;
		else if(r_data_state == DATA_ASSIGN)
			rr_code_angle	<= r_code_angle;
		else if(r_data_state == DATA_ASSIGN1)
			rr_code_angle	<= r_code_angle;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_code_error	<= 1'b0;
		else if(r_code_angle == 16'd0 || r_code_angle == 16'hFFFF)
			r_code_error	<= 1'b0;
		else if(rr_code_angle + 1'b1 == r_code_angle)
			r_code_error	<= 1'b0;
		else
			r_code_error	<= 1'b1;
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign		o_code_angle 	= (i_tdc_switch)?r_code_angle:i_code_angle;//�Ƕ�ֵ
	assign		o_cal_sig		= (i_tdc_switch)?r_cal_sig:i_tdc_new_sig;
	assign		o_rise_data		= (i_tdc_switch)? r_rise_data:i_rise_data;//������
	assign		o_fall_data		= (i_tdc_switch)? (r_fall_data + r_code_error):i_fall_data;//�½���

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	tdc_data_ram U1
	(
		.WrClock				(i_clk_50m), 
		.WrClockEn				(r_tdc_wren),
		.WrAddress				(r_tdc_wr_addr), 
		.Data					(r_tdc_wr_rise), 
		.WE						(1'b1), 
		.RdClock				(i_clk_50m),  
		.RdClockEn				(1'b1),
		.RdAddress				(r_tdc_rd_addr),
		.Q						(w_tdc_rd_rise),
		.Reset					(1'b0)
	);
	
	tdc_data_ram U2
	(
		.WrClock				(i_clk_50m), 
		.WrClockEn				(r_tdc_wren),
		.WrAddress				(r_tdc_wr_addr), 
		.Data					(r_tdc_wr_fall), 
		.WE						(1'b1), 
		.RdClock				(i_clk_50m),  
		.RdClockEn				(1'b1),
		.RdAddress				(r_tdc_rd_addr),
		.Q						(w_tdc_rd_fall),
		.Reset					(1'b0)
	);
	
	tdc_para U3
	(
		.i_clk_50m    			(i_clk_50m)				,
		.i_rst_n      			(i_rst_n)				,
		
		.i_para_en				(r_para_en)				,
		.i_diff_now				(r_diff_now)			,
		.i_diff_post			(r_diff_post)			,
		.i_data_length			(r_data_length)			,
		.i_addr_start			(r_addr_start)			,
		
		.o_tdc_para_1			(w_tdc_para_1)			,
		.o_tdc_para_2			(w_tdc_para_2)			,
		.o_addr_mid				(w_addr_mid)			,
		.o_para_done			(w_para_done)	
	);

	cal_process U4
	(
		.i_clk_50m    			(i_clk_50m)				,
		.i_rst_n      			(i_rst_n)				,
		
		.i_process_en			(r_process_en)			,
		.i_post_sign			(r_post_sign)			,
		.i_now_sign				(r_now_sign)			,
		.i_tdc_para_1			(w_tdc_para_1)			,
		.i_tdc_para_2			(w_tdc_para_2)			,
		.i_addr_mid				(w_addr_mid)			,
		.i_rise_data			(w_tdc_rd_rise)			,
		.i_tdc_rd_addr			(r_tdc_rd_addr)			,
		
		.o_process_done			(w_process_done)		,
		.o_process_data			(w_process_data)       
	);

/////////debug add
    reg 	[15:0]	code_angle_i;
    reg 			code_angle_vld_i;	
    reg 			code_angle_vld_1_i;	
    reg 	[15:0]	last_code_angle_i;	
	reg             first_flag;	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_i	<= 16'b0;
		else 
			code_angle_i	<= i_code_angle;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_i	<= 1'b0;
		else
			code_angle_vld_i	<= i_tdc_new_sig;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_1_i	<= 1'b0;
		else
			code_angle_vld_1_i	<= (i_code_angle >= i_start_index) && (i_code_angle <= i_stop_index) ;			
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			last_code_angle_i	<= 16'b0;
		else if(code_angle_vld_i)
			last_code_angle_i	<= code_angle_i;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			first_flag	<= 1'b1;
		else if(code_angle_vld_i && code_angle_vld_1_i)
			first_flag	<= 1'b0;		

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			tdc_process_error[0] <= 1'b0;		
		else if(~first_flag && code_angle_vld_i && code_angle_vld_1_i && (code_angle_i != (last_code_angle_i + 16'd1)))
			tdc_process_error[0] <= 1'b1;	

//////////						
    reg 	[15:0]	code_angle_o;
    reg 			code_angle_vld_o;	
    reg 			code_angle_vld_1_o;	
    reg 	[15:0]	last_code_angle_o;		
	reg             first_flag_1;		
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_o	<= 16'b0;
		else 
			code_angle_o	<= o_code_angle;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_o	<= 1'b0;
		else
			code_angle_vld_o	<= o_cal_sig;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			code_angle_vld_1_o	<= 1'b0;
		else
			code_angle_vld_1_o	<= (o_code_angle >= i_start_index) && (o_code_angle <= i_stop_index) ;			
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			last_code_angle_o	<= 16'b0;
		else if(code_angle_vld_o)
			last_code_angle_o	<= code_angle_o;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			first_flag_1	<= 1'b1;
		else if(code_angle_vld_o && code_angle_vld_1_o)
			first_flag_1	<= 1'b0;				

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			tdc_process_error[1] <= 1'b0;		
		else if(~first_flag_1 && code_angle_vld_o && code_angle_vld_1_o && (code_angle_o != (last_code_angle_o + 16'd1)))
			tdc_process_error[1] <= 1'b1;	

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			tdc_process_error_last_code <= 16'b0;		
		else if(~first_flag_1 && code_angle_vld_o && code_angle_vld_1_o && (code_angle_o != (last_code_angle_o + 16'd1)))
			tdc_process_error_last_code <= last_code_angle_o;		

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			tdc_process_error_current_code <= 16'b0;		
		else if(~first_flag_1 && code_angle_vld_o && code_angle_vld_1_o && (code_angle_o != (last_code_angle_o + 16'd1)))
			tdc_process_error_current_code <= code_angle_o;						

/////////////////////////////////////////
			
endmodule 