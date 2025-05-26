module iic_write_read
(
	input 			i_clk_50m		,
	input 			i_rst_n			,
	
	input 			i_send_en		,
	input		[3:0] i_send_length	,
	input 	[6:0] i_dev_addr		,
	input 	[31:0]i_write_dat		,
	
	output 	 		o_iic_done		,
	output 			o_iic_scl		,
	inout 			io_iic_sda
);

	parameter C_DIV_SEL = 10'd500;
	parameter C_DIV_SEL0 = (C_DIV_SEL>>2) -1,                 // 用来产生IIC总线SCL高电平最中间的标志位
             C_DIV_SEL1 = (C_DIV_SEL>>1) -1,                
             C_DIV_SEL2 = (C_DIV_SEL0 + C_DIV_SEL1) + 1,     // 用来产生IIC总线SCL低电平最中间的标志位
             C_DIV_SEL3 = (C_DIV_SEL>>1) +1;                 // 用来产生IIC总线SCL下降沿标志位
				 
				 
	/////////////////////////////////////////////////////////////////////
	wire 	w_scl_l_mid;
	wire 	w_scl_h_mid;
	wire 	w_scl_neg,w_scl_pos;

	reg 	[1:0] r_scl;
	reg	[9:0] r_scl_cnt;
	
	assign w_scl_neg = (r_scl == 2'b10) ? 1'b1 : 1'b0;
	assign w_scl_pos = (r_scl == 2'b01) ? 1'b1 : 1'b0;

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_scl <= 2'd0;
		else
			r_scl <= {r_scl[0],o_iic_scl};

	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)
			r_scl_cnt <= 10'd0;
		else if(r_scl_en)
			if(r_scl_cnt == C_DIV_SEL - 1'b1)
				r_scl_cnt <= 10'd0;
			else
				r_scl_cnt <= r_scl_cnt + 1'b1;
		else
			r_scl_cnt <= 10'd0;
		 
	assign o_iic_scl = (r_scl_cnt <= C_DIV_SEL1) ? 1'b1 : 1'b0;    
	assign w_scl_l_mid = (r_scl_cnt == C_DIV_SEL2) ? 1'b1 : 1'b0;    
	assign w_scl_h_mid = (r_scl_cnt == C_DIV_SEL0) ? 1'b1 : 1'b0;
	
	assign io_iic_sda = (r_sda_mode) ? r_iic_sda : 1'bz;
	assign o_iic_done = r_iic_done;
	
	///////////////////////////////////////////////////////////////////////////
	
	reg	[9:0]	r_iic_state;
	reg	[9:0]	r_jump_state;
	reg	[3:0]	r_send_length;
	reg  [31:0] r_send_data;
	reg	[3:0]	r_send_cnt;
	reg	[7:0]	r_load_data;
	
	reg		  	r_iic_scl;
	reg		  	r_iic_sda;
	
	reg			r_scl_en;
	reg			r_sda_mode;
	reg			r_ack_flag;
	reg			r_iic_done;
	reg	[3:0]	r_bit_cnt;
	
	parameter	IIC_IDLE			= 10'b00_0000_0000,
					IIC_DEVADDR_W	= 10'b00_0000_0010,
					IIC_LOAD_DATA  = 10'b00_0000_0100,
					IIC_START_SIG  = 10'b00_0000_1000,
					IIC_SEND_BYTE  = 10'b00_0001_0000,
					IIC_WAIT_ACK   = 10'b00_0010_0000,
					IIC_CHECK_ACK  = 10'b00_0100_0000,
					IIC_STOP_SIG   = 10'b00_1000_0000,
					IIC_DONE			= 10'b01_0000_0000;
	
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 1'b0)begin
			r_iic_state 	<= IIC_IDLE;
			r_jump_state   <= IIC_IDLE;
			r_scl_en 		<= 1'b0;
			r_sda_mode     <= 1'b1;
			r_iic_sda		<= 1'b1;
			r_load_data    <= 8'd0;
			r_bit_cnt      <= 4'd0;
			r_ack_flag     <= 1'b0;
			r_iic_done     <= 1'b0;
			r_send_length 	<= 4'd0;
			r_send_cnt	 	<= 4'd0;
			end
		else begin
			case(r_iic_state)
				IIC_IDLE			:begin
					if(i_send_en)begin
						r_iic_state 	<= IIC_DEVADDR_W;
						r_send_length 	<= i_send_length;
						r_send_data    <= i_write_dat;
						end
					else begin
						r_iic_state 	<= IIC_IDLE;
						r_send_length 	<= 4'd0;
						r_send_cnt	 	<= 4'd0;
						r_iic_done		<= 1'b0;
						end
					end
				IIC_DEVADDR_W	:begin
					r_jump_state	<= IIC_LOAD_DATA;
					r_iic_state 	<= IIC_START_SIG;
					r_load_data  	<= {i_dev_addr,1'b0};
					end
				IIC_LOAD_DATA  :begin
					r_iic_state 	<= IIC_SEND_BYTE;
					r_load_data  	<= r_send_data >> 5'd24;
					r_send_cnt 		<= r_send_cnt + 1'b1;
					if(r_send_cnt + 1'b1 >= r_send_length)begin
						r_send_data		<= 32'd0;
						r_jump_state	<= IIC_STOP_SIG;
						end
					else begin
						r_send_data		<= r_send_data << 4'd8;
						r_jump_state	<= IIC_LOAD_DATA;
						end
					end
				IIC_START_SIG	:begin
					r_scl_en 		<= 1'b1;
					r_sda_mode     <= 1'b1;
					if(w_scl_h_mid)begin
						r_iic_state 	<= IIC_SEND_BYTE;
						r_iic_sda 		<= 1'b0;
						end
					else begin
						r_iic_state 	<= IIC_START_SIG;
						r_iic_sda 		<= r_iic_sda;
						end
					end
				IIC_SEND_BYTE	:begin
					r_scl_en 		<= 1'b1;
					r_sda_mode     <= 1'b1;
					if(w_scl_l_mid)begin
						if(r_bit_cnt == 4'd8)begin
							r_bit_cnt 		<= 4'd0;
							r_iic_state 	<= IIC_WAIT_ACK;
							r_iic_sda 		<= r_iic_sda;
							end
						else begin
							r_iic_state 	<= IIC_SEND_BYTE;
							r_iic_sda 		<= r_load_data[4'd7-r_bit_cnt] ;
							r_bit_cnt 		<= r_bit_cnt + 1'b1;
							end
						end
					else
						r_iic_state 	<= IIC_SEND_BYTE;//其他信号保持
					end
				IIC_WAIT_ACK	:begin
					r_scl_en 		<= 1'b1;
					r_sda_mode     <= 1'b0;
					if(w_scl_h_mid)begin
						r_ack_flag 		<= io_iic_sda;
						r_iic_state 	<= IIC_CHECK_ACK;
						end
					else begin
						r_ack_flag 		<= r_ack_flag;
						r_iic_state 	<= IIC_WAIT_ACK;
						end
					end
				IIC_CHECK_ACK	:begin
					r_scl_en 		<= 1'b1;
					if(!r_ack_flag)begin//ACK有效
						if(w_scl_neg)begin
							r_iic_state 		<= r_jump_state;
							r_sda_mode 			<= 1'b1;
							if(r_send_cnt >= r_send_length)begin
								r_send_cnt        <= 4'd0;
								r_iic_sda 			<= 1'b0;//读取完应答信号以后要把SDA信号设置成输出并拉低，因为如果这个状态后面是停止状态的话，需要SDA信号的上升沿，所以这里提前拉低它
								end
							else 
								r_iic_sda 			<= 1'b0;
							end
						else
							r_iic_state 	<= IIC_CHECK_ACK;
						end
					else
						r_iic_state 	<= IIC_DONE;//IIC_IDLE;//出错？
					end
				IIC_STOP_SIG	:begin
					r_scl_en 		<= 1'b1;
					r_sda_mode     <= 1'b1;
					if(w_scl_h_mid)begin
						r_iic_state 	<= IIC_DONE;
						r_iic_sda		<= 1'b1;        
						end
					else
						r_iic_state <= IIC_STOP_SIG;
					end
				IIC_DONE			:begin
					r_iic_state 	<= IIC_IDLE;
					r_jump_state   <= IIC_IDLE;
					r_scl_en 		<= 1'b0;
					r_sda_mode     <= 1'b1;
					r_iic_sda		<= 1'b1;
					r_load_data    <= 8'd0;
					r_bit_cnt      <= 4'd0;
					r_ack_flag     <= 1'b0;
					r_iic_done     <= 1'b1;
					end
				default:r_iic_state 	<= IIC_IDLE;
				endcase
			end

endmodule 