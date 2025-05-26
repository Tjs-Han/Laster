module flash_control_2
(
	input			i_clk_50m    		,
	input			i_rst_n      		,
	
	output			o_flash_wp			,
	output			o_flash_hold		,
	output			o_flash_cs			,
	output			o_flash_clk			,
	output			o_flash_mosi		,
	input			i_flash_miso		,
	
	output			o_sram_csen_flash	,
	output			o_sram_wren_flash	,
	output			o_sram_rden_flash	,
	output	[17:0]	o_sram_addr_flash	,
	output	[15:0]	o_sram_data_flash	,
	input	[15:0]	i_sram_data_flash	,
	
	input			i_factory_sig		,
	input			i_parameter_read	,
	input			i_parameter_sig		,
	input			i_cal_coe_sig		,
	input			i_code_data_sig		,
	input	[2:0]	i_code_packet_num	,
	
	input           save_user_sram_to_factory_flash_valid,
	input           save_factory_sram_to_user_flash_valid,

	output          o_iap_flag          ,
	
	output			o_flash_busy		,
	
	output	[15:0]	o_fisrt_rise		,
	
	output			o_read_complete_sig	
);

	reg             o_read_complete_sig;
	wire	[7:0]	w_ram_data;
	
	wire			w_flash_clk;
	
	reg				r_flash_clk_n = 1'b1;
	
	wire			w_cmd_ack;
	wire	[7:0]  w_data_out;
	wire			w_data_valid;
	wire			w_data_req;
	
	reg		[7:0]	r_flash_cmd 	= 8'd0;
	reg				r_cmd_valid 	= 1'b0;
	reg		[23:0]	r_flash_addr	= 24'h0A0000;
	reg		[23:0]	r_flash_rdaddr	= 24'h0A0000;
	reg		[10:0]	r_page_num		= 11'd1536;
	reg		[10:0]	r_page_rdnum	= 11'd1536;
	reg		[10:0]	r_page_cnt		= 11'd0;
	reg				r_erase_flag	= 1'b0;
	reg		[31:0]	r_delay_cnt		= 32'd0;
	reg				r_read_complete_sig	= 1'b0;
	reg				r_sram_csen_flash	= 1'b0;
	reg				r_sram_wren_flash	= 1'b1;
	reg				r_sram_rden_flash	= 1'b1;
	reg		[17:0]	r_sram_addr_flash	= 18'd0;
	reg		[17:0]	r_sram_rdaddr_flash	= 18'd0;
	reg		[15:0]	r_sram_data_flash	= 16'd0;
	reg		[7:0]	r_data_in			= 8'd0;
	
	reg		[15:0]	r_sram_rddata		= 16'd0;
	reg				r_sram_rd 			= 1'b0;
	
	reg				r_cmd_ack			= 1'b0;
	reg		 		r_read_num			= 1'b0;
	
	reg     [15:0]  r_byte_size         = 16'd256;
	
	reg		[19:0]	r_flash_state = 16'd0;
	
	reg     [31:0] r_mode_pro;
	reg             r_iap_flag;

	reg                     wait_para_save_finish_flag;
	reg                     save_user_sram_to_factory_1_flash_valid;	
	
	parameter		FLASH_IDLE			= 20'b0000_0000_0000_0000_0000,
					FLASH_READ			= 20'b0000_0000_0000_0000_0010,
					FLASH_READ_ACK		= 20'b0000_0000_0000_0000_0100,
					FLASH_READ_ASSIGN	= 20'b0000_0000_0000_0000_1000,
					FLASH_READ_WRITE	= 20'b0000_0000_0000_0001_0000,
					FLASH_READ_SHIFT	= 20'b0000_0000_0000_0010_0000,	
					FLASH_READ_DELAY	= 20'b0000_0000_0000_0100_0000,
					FLASH_READ_MODE	    = 20'b0000_0000_0000_1000_0000,
	                FLASH_READ_MODE_ACK	= 20'b0000_0000_0001_0000_0000,
					FLASH_READ_DELAY1   = 20'b0000_0000_0010_0000_0000,			
					FLASH_WAIT			= 20'b0000_0000_0100_0000_0000,
					FLASH_ERASE			= 20'b0000_0000_1000_0000_0000,
					FLASH_ERASE_ACK		= 20'b0000_0001_0000_0000_0000,
					FLASH_ERASE_DELAY	= 20'b0000_0010_0000_0000_0000,
					FLASH_WRITE			= 20'b0000_0100_0000_0000_0000,
					FLASH_WRITE_ACK		= 20'b0000_1000_0000_0000_0000,
					FLASH_WRITE_SHIFT	= 20'b0001_0000_0000_0000_0000,
					FLASH_WRITE_DELAY	= 20'b0010_0000_0000_0000_0000,
					FLASH_END			= 20'b0100_0000_0000_0000_0000;

					
					
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_state		<= FLASH_IDLE;
		else begin
			case(r_flash_state)
				FLASH_IDLE			:begin
					r_flash_state		<= FLASH_READ;
					end
				FLASH_READ			:begin
					r_flash_state		<= FLASH_READ_ACK;
					end
				FLASH_READ_ACK		:begin
					if(w_data_valid)
						r_flash_state		<= FLASH_READ_ASSIGN;
					else if(r_cmd_ack || w_cmd_ack)
						r_flash_state		<= FLASH_READ_SHIFT;
					else
						r_flash_state		<= FLASH_READ_ACK;
					end
				FLASH_READ_ASSIGN	:begin
					if(r_read_num >= 1'b1)
						r_flash_state		<= FLASH_READ_WRITE;
					else
						r_flash_state		<= FLASH_READ_ACK;
					end
				FLASH_READ_WRITE	:begin
					r_flash_state		<= FLASH_READ_ACK;
					end
				FLASH_READ_SHIFT	:begin
					if(r_page_cnt + 1'b1 >= r_page_num)
						r_flash_state		<= FLASH_READ_DELAY;//FLASH_WAIT;
					else
						r_flash_state		<= FLASH_READ;
					end
				FLASH_READ_DELAY	:begin
					if(r_delay_cnt >= 32'd249)
						r_flash_state		<= FLASH_READ_MODE;
					else
						r_flash_state		<= FLASH_READ_DELAY;
					end
				FLASH_READ_MODE	:begin
					r_flash_state		<= FLASH_READ_MODE_ACK;
					end	
				FLASH_READ_MODE_ACK	:begin
					if(w_cmd_ack)
						r_flash_state		<= FLASH_READ_DELAY1;				
					else
						r_flash_state		<= FLASH_READ_MODE_ACK;
					end
				FLASH_READ_DELAY1	:begin
					if(r_delay_cnt >= 32'd249)
						r_flash_state		<= FLASH_WAIT;
					else
						r_flash_state		<= FLASH_READ_DELAY1;
					end
				FLASH_WAIT			:begin
					if(i_parameter_sig || i_cal_coe_sig || i_code_data_sig || i_factory_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid || save_factory_sram_to_user_flash_valid)
						r_flash_state		<= FLASH_ERASE;
					else if(i_parameter_read)
						r_flash_state		<= FLASH_READ;
					else
						r_flash_state		<= FLASH_WAIT;
					end
				FLASH_ERASE			:begin
					r_flash_state		<= FLASH_ERASE_ACK;
					end
				FLASH_ERASE_ACK		:begin
					if(w_cmd_ack)
						r_flash_state		<= FLASH_ERASE_DELAY;
					else
						r_flash_state		<= FLASH_ERASE_ACK;
					end
				FLASH_ERASE_DELAY	:begin
					if(r_erase_flag)
						r_flash_state		<= FLASH_WRITE;
					else
						r_flash_state		<= FLASH_ERASE;
					end
				FLASH_WRITE			:begin
					r_flash_state		<= FLASH_WRITE_ACK;
					end
				FLASH_WRITE_ACK		:begin
					if(w_cmd_ack)
						r_flash_state		<= FLASH_WRITE_SHIFT;
					else
						r_flash_state		<= FLASH_WRITE_ACK;
					end
				FLASH_WRITE_SHIFT	:begin
					if(r_page_cnt + 1'b1 >= r_page_num)
						r_flash_state		<= FLASH_WRITE_DELAY;
					else if(r_page_cnt[7:0] == 8'hFF)
						r_flash_state		<= FLASH_ERASE;
					else
						r_flash_state		<= FLASH_WRITE;
					end
				FLASH_WRITE_DELAY	:begin
					if(r_delay_cnt >= 32'd12_500_000)
						r_flash_state		<= FLASH_END;
					else
						r_flash_state		<= FLASH_WRITE_DELAY;
					end
				FLASH_END			:begin
					if(r_page_rdnum > 11'd0)
						r_flash_state		<= FLASH_READ;
					else
						r_flash_state		<= FLASH_WAIT;
					end
				default:r_flash_state	<= FLASH_IDLE;
				endcase
			end
			
	//r_flash_clk_n
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_clk_n	<= 1'b1;
		else if(r_flash_state == FLASH_WAIT)
			r_flash_clk_n	<= 1'b1;
		else if(r_flash_state == FLASH_WRITE_DELAY)
			r_flash_clk_n	<= 1'b1;
		else
			r_flash_clk_n	<= 1'b0;
			
	//r_flash_cmd
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_cmd 	<= 8'h00;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_cmd 	<= 8'h00;
		else if(r_flash_state == FLASH_READ)
			r_flash_cmd 	<= 8'h03;
		else if(r_flash_state == FLASH_ERASE)
			r_flash_cmd 	<= 8'hD8;
		else if(r_flash_state == FLASH_WRITE)
			r_flash_cmd 	<= 8'h02;
		else if(r_flash_state == FLASH_READ_MODE)
			r_flash_cmd 	<= 8'h03;
			
	//r_cmd_valid
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_cmd_valid 	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_cmd_valid 	<= 1'b0;
		else if(r_flash_state == FLASH_READ)
			r_cmd_valid 	<= 1'b1;
		else if(r_flash_state == FLASH_ERASE)
			r_cmd_valid 	<=1'b1;
		else if(r_flash_state == FLASH_WRITE)
			r_cmd_valid 	<= 1'b1;
		else if(r_flash_state == FLASH_READ_MODE)
			r_cmd_valid 	<= 1'b1;
		else
			r_cmd_valid 	<= 1'b0;
			
	//r_flash_rdaddr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_rdaddr	<= 24'h0A0000;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_rdaddr	<= 24'h0A0000;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || save_factory_sram_to_user_flash_valid)
				r_flash_rdaddr	<= 24'h0A0000;
			else if(i_factory_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid)
				r_flash_rdaddr	<= 24'h0B0000;
			else if(i_cal_coe_sig)
				r_flash_rdaddr	<= 24'h0C0000;
			else
				r_flash_rdaddr	<= 24'h0A0000;
			end
			
	//r_flash_addr
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_addr	<= 24'h0A0000;
		else if(r_flash_state == FLASH_IDLE)
			r_flash_addr	<= 24'h0A0000;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || save_factory_sram_to_user_flash_valid)
				r_flash_addr	<= 24'h0A0000;
			else if(i_factory_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid)
				r_flash_addr	<= 24'h0B0000;
			else if(i_cal_coe_sig)
				r_flash_addr	<= 24'h0C0000;
			else if(i_code_data_sig)
				r_flash_addr	<= i_code_packet_num * 21'h020000;
			else if(i_parameter_read)
				r_flash_addr	<= 24'h0A0000;
			else
				r_flash_addr	<= 24'h0A0000;
			end
		else if(r_flash_state == FLASH_READ_SHIFT)
			r_flash_addr	<= r_flash_addr + 24'h000100;
		else if(r_flash_state == FLASH_WRITE_SHIFT)
			r_flash_addr	<= r_flash_addr + 24'h000100;
		else if(r_flash_state == FLASH_END)
			r_flash_addr	<= r_flash_rdaddr;
		else if(r_flash_state == FLASH_READ_MODE)
			r_flash_addr	<= 24'h130150;
			
	//r_page_rdnum
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_page_rdnum	<= 11'd1536;
		else if(r_flash_state == FLASH_IDLE)
			r_page_rdnum	<= 11'd1536;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || i_factory_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid || save_factory_sram_to_user_flash_valid)
				r_page_rdnum	<= 11'd256;
			else if(i_cal_coe_sig)
				r_page_rdnum	<= 11'd1024;
			else
				r_page_rdnum	<= 11'd0;
			end
			
	//r_page_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_page_num		<= 11'd1536;
		else if(r_flash_state == FLASH_IDLE)
			r_page_num		<= 11'd1536;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_factory_sig || i_parameter_sig || save_user_sram_to_factory_flash_valid  || save_user_sram_to_factory_1_flash_valid || save_factory_sram_to_user_flash_valid)
				r_page_num		<= 11'd256;
			else if(i_code_data_sig || i_parameter_read)
				r_page_num		<= 11'd512;
			else if(i_cal_coe_sig)
				r_page_num		<= 11'd1024;
			end
		else if(r_flash_state == FLASH_END)
			r_page_num		<= r_page_rdnum;
			
	//r_page_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_page_cnt		<= 11'd0;
		else if(r_flash_state == FLASH_READ_SHIFT)
			r_page_cnt		<= r_page_cnt + 1'b1;
		else if(r_flash_state == FLASH_WRITE_SHIFT)
			r_page_cnt		<= r_page_cnt + 1'b1;
		else if(r_flash_state == FLASH_IDLE || r_flash_state == FLASH_WAIT || r_flash_state == FLASH_END)
			r_page_cnt		<= 11'd0;
			
	//r_erase_flag
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_erase_flag	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_erase_flag	<= 1'b0;
		else if(r_flash_state == FLASH_ERASE_DELAY)
			r_erase_flag	<= ~r_erase_flag;
			
	//r_delay_cnt
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_delay_cnt		<= 32'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_delay_cnt		<= 32'd0;
		else if(r_flash_state == FLASH_WRITE_DELAY)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else if(r_flash_state == FLASH_READ_DELAY||r_flash_state == FLASH_READ_DELAY1)
			r_delay_cnt		<= r_delay_cnt + 1'b1;
		else
			r_delay_cnt		<= 32'd0;

	
	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			wait_para_save_finish_flag <= 1'b0;							
		end
		else if(~wait_para_save_finish_flag && i_parameter_sig)begin
			wait_para_save_finish_flag <= 1'b1;				
		end
		else if( wait_para_save_finish_flag && r_read_complete_sig)begin
			wait_para_save_finish_flag <= 1'b0;				
		end	
	end		

	always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			save_user_sram_to_factory_1_flash_valid <= 1'b0;							
		end
		else if( wait_para_save_finish_flag && r_read_complete_sig)begin
			save_user_sram_to_factory_1_flash_valid <= 1'b1;				
		end	
		else begin
			save_user_sram_to_factory_1_flash_valid <= 1'b0;				
		end			
	end	

	//r_read_complete_sig
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_read_complete_sig	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_read_complete_sig	<= 1'b0;
		else if(r_flash_state == FLASH_READ_DELAY1 && r_delay_cnt >= 32'd249)
			r_read_complete_sig	<= 1'b1;
		else
			r_read_complete_sig	<= 1'b0;
			
	//r_sram_csen_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_csen_flash	<= 1'b0;
		else if(r_flash_state == FLASH_IDLE)
			r_sram_csen_flash	<= 1'b0;
		else if(r_flash_state == FLASH_WAIT)
			r_sram_csen_flash	<= 1'b0;
		else
			r_sram_csen_flash	<= 1'b1;
			
	//r_sram_wren_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_wren_flash	<= 1'b1;
		else if(r_flash_state == FLASH_READ_WRITE)
			r_sram_wren_flash	<= 1'b0;
		else 
			r_sram_wren_flash	<= 1'b1;
			
	//r_sram_rden_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rden_flash	<= 1'b1;
		else if(r_flash_state == FLASH_ERASE)
			r_sram_rden_flash	<= 1'b0;
		else if(r_flash_state == FLASH_WRITE)
			r_sram_rden_flash	<= 1'b0;
		else if(w_data_req && r_flash_state == FLASH_WRITE_ACK)
			r_sram_rden_flash	<= ~r_sram_rden_flash;
		else if(r_flash_state == FLASH_WRITE_DELAY)
			r_sram_rden_flash	<= 1'b1;
			
	//r_read_num
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_read_num	<= 1'b0;
		else if(r_flash_state == FLASH_READ)
			r_read_num	<= 1'b0;
		else if(r_flash_state == FLASH_READ_ASSIGN)
			r_read_num	<= ~r_read_num;
			
	//r_sram_rdaddr_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rdaddr_flash	<= 18'h00000;
		else if(r_flash_state == FLASH_IDLE)
			r_sram_rdaddr_flash	<= 18'h00000;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || i_parameter_read || save_factory_sram_to_user_flash_valid)
				r_sram_rdaddr_flash	<= 18'h00000;
			else if(i_factory_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid)
				r_sram_rdaddr_flash	<= 18'h08000;
			else if(i_cal_coe_sig)
				r_sram_rdaddr_flash	<= 18'h10000;
			else if(i_code_data_sig)
				r_sram_rdaddr_flash	<= 18'h30000;
			else
				r_sram_rdaddr_flash	<= 18'h00000;
			end
			
	//r_sram_addr_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_addr_flash	<= 18'h00000;
		else if(r_flash_state == FLASH_IDLE)
			r_sram_addr_flash	<= 18'h00000;
		else if(r_flash_state == FLASH_WAIT)begin
			if(i_parameter_sig || save_user_sram_to_factory_flash_valid || save_user_sram_to_factory_1_flash_valid)
				r_sram_addr_flash	<= 18'h00000;
			else if(i_factory_sig || save_factory_sram_to_user_flash_valid)
				r_sram_addr_flash	<= 18'h08000;
			else if(i_cal_coe_sig)
				r_sram_addr_flash	<= 18'h10000;
			else if(i_code_data_sig)
				r_sram_addr_flash	<= 18'h30000;
			else
				r_sram_addr_flash	<= 18'h00000;
			end
		else if(r_flash_state == FLASH_READ_ASSIGN && r_read_num == 1'b1)
			r_sram_addr_flash	<= r_sram_addr_flash + 1'b1;
		else if(w_data_req && r_flash_state == FLASH_WRITE_ACK && r_sram_rden_flash)
			r_sram_addr_flash	<= r_sram_addr_flash + 1'b1;
		else if(r_flash_state == FLASH_WRITE)
			r_sram_addr_flash	<= r_sram_addr_flash + 1'b1;
		else if(r_flash_state == FLASH_END)
			r_sram_addr_flash	<= r_sram_rdaddr_flash;
			
	//r_sram_data_flash
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_data_flash	<= 16'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_sram_data_flash	<= 16'd0;
		else if(r_flash_state == FLASH_READ_ASSIGN)
			r_sram_data_flash	<= {r_sram_data_flash[7:0],w_data_out};
	
	//r_sram_rddata
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rddata		<= 16'd0;
		else if(w_data_req && ~r_sram_rden_flash)
			r_sram_rddata		<= i_sram_data_flash;
		else if(r_flash_state == FLASH_ERASE_DELAY && r_erase_flag)
			r_sram_rddata		<= i_sram_data_flash;
		else if(w_data_req && r_sram_rden_flash)
			r_sram_rddata		<= r_sram_rddata << 4'd8;
		else if(r_flash_state == FLASH_WRITE)
			r_sram_rddata		<= r_sram_rddata << 4'd8;
			
	//r_data_in
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_data_in			<= 8'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_data_in			<= 8'd0;
		else if(r_flash_state == FLASH_WRITE)
			r_data_in			<= r_sram_rddata[15:8];
		else if(w_data_req)
			r_data_in			<= r_sram_rddata[15:8];
				
	//r_sram_rd
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_sram_rd	<= 1'b0;
		else if(r_flash_state == FLASH_WAIT)
			r_sram_rd	<= 1'b0;
		else if(r_flash_state == FLASH_READ)
			r_sram_rd	<= 1'b1;
				
	//r_cmd_ack
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_READ_ACK)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_READ_MODE_ACK)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_WRITE_ACK)
			r_cmd_ack	<= 1'b0;
		else if(r_flash_state == FLASH_ERASE_ACK)
			r_cmd_ack	<= 1'b0;
		else if(w_cmd_ack)
			r_cmd_ack	<= 1'b1;
			
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
		  r_byte_size <= 16'd0;
        else if(r_flash_state == FLASH_READ_MODE||r_flash_state == FLASH_READ_MODE_ACK)
          r_byte_size <= 16'd4;	
        else
          r_byte_size <= 16'd256;

    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
		  r_mode_pro <= 32'd0;
		else if(r_flash_state == FLASH_READ_MODE_ACK)
		  begin
		  if(w_data_valid)
			r_mode_pro <= {r_mode_pro[23:0],w_data_out};
		  else
			r_mode_pro <= r_mode_pro;
		  end
		  
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
          r_iap_flag <= 1'd0;
        else if(r_mode_pro==32'hFFFFBDB3)		  
		  r_iap_flag <= 1'd1;	
		else
          r_iap_flag <= 1'd0;		
		  
	//r_flash_busy
	reg	r_flash_busy;
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_flash_busy <= 1'd0;
		else if(r_flash_state > FLASH_WAIT && r_flash_state <= FLASH_WRITE_DELAY )
			r_flash_busy <= 1'd1;
		else
			r_flash_busy <= 1'd0;
			
	assign 	o_flash_busy = r_flash_busy ;

//读取系数中第一个非0值

	reg	[31:0]r_coe_true_addr;
	reg		   r_coe_true_flag;
	reg		   r_coe_cal_flag;
	reg	[15:0]r_fisrt_rise;
	reg	[15:0]r_fisrt_addr;

    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_coe_true_addr <= 32'd0;
		end
		else if(r_flash_state == FLASH_IDLE)begin
			r_coe_true_addr <= 32'd0;			
		end			
		else if(r_flash_state == FLASH_READ_ASSIGN && r_read_num == 1'b0 && r_sram_addr_flash >= 18'h10000 && ~r_coe_true_flag)begin
			if(r_sram_data_flash[15] == 1'd0 && r_sram_data_flash > 16'd0)begin
				r_coe_true_addr <= r_sram_addr_flash - 18'h10000;
			end
		end
		
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)		
			r_coe_cal_flag 	<= 1'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_coe_cal_flag 	<= 1'd0;
		else if(r_flash_state == FLASH_READ_ASSIGN && r_read_num == 1'b0 && r_sram_addr_flash >= 18'h10000 && ~r_coe_true_flag)begin
			if(r_sram_data_flash[15] == 1'd0 && r_sram_data_flash > 16'd0)
				r_coe_cal_flag 	<= 1'd1;
			else
				r_coe_cal_flag 	<= 1'd0;
		end
		else if(r_coe_cal_flag)
			r_coe_cal_flag 	<= 1'd0;
			
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_coe_true_flag <= 1'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_coe_true_flag <= 1'd0;
		else if(r_fisrt_addr > 16'd0 && r_fisrt_addr < 8'd20)
			r_coe_true_flag <= 1'd1;
				

			
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fisrt_addr <= 16'd0;
		else if(r_flash_state == FLASH_IDLE)
			r_fisrt_addr <= 16'd0;
		else if(r_coe_cal_flag)begin
			if(r_coe_true_addr <= 16'd512)
				r_fisrt_addr <= 16'd512;
			else
				r_fisrt_addr <=r_coe_true_addr - (( r_coe_true_addr >> 5'd9 ) << 5'd9) ;
		end
			
    always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)
			r_fisrt_rise <= 16'd0;	
		else if(r_flash_state == FLASH_IDLE)
			r_fisrt_rise <= 16'd0;
		else if(r_coe_true_flag)
			r_fisrt_rise <= (r_fisrt_addr + 1'd1) << 5'd6;
		
		  

	assign	o_fisrt_rise = r_fisrt_rise;
		  
		  
	assign	o_sram_csen_flash	= r_sram_csen_flash;
	assign	o_sram_wren_flash	= r_sram_wren_flash;
	assign	o_sram_rden_flash	= r_sram_rden_flash;
	assign	o_sram_addr_flash	= (r_sram_rd) ? (r_sram_addr_flash - 1'b1) : r_sram_addr_flash;
	assign	o_sram_data_flash	= r_sram_data_flash;
	
	assign	o_flash_wp			= 1'b1;
	assign	o_flash_hold		= 1'b1;


    always@(posedge i_clk_50m or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			o_read_complete_sig <= 1'd0;
		end		
		else begin
			o_read_complete_sig <= ~wait_para_save_finish_flag &&  r_read_complete_sig;
		end
	end


	assign  o_iap_flag = r_iap_flag;
		
	USRMCLK u1 (.USRMCLKI(w_flash_clk), .USRMCLKTS(r_flash_clk_n) /* synthesis syn_noprune=1 */);
	
	spi_flash_top U2
	(
		.clk			(i_clk_50m),
		.rst_n			(i_rst_n),

		.o_spi_cs		(o_flash_cs),
		.o_spi_dclk		(w_flash_clk),//(o_flash_clk),
		.o_spi_mosi		(o_flash_mosi),
		.i_spi_miso		(i_flash_miso),

		.i_clk_div		(16'd4),
		.i_cmd			(r_flash_cmd),
		.i_cmd_valid	(r_cmd_valid),
		.o_cmd_ack		(w_cmd_ack),

		.i_addr			(r_flash_addr),
		.i_byte_size	(r_byte_size[8:0]),

		.o_data_req		(w_data_req),
		.i_data_in		(r_data_in),
		.o_data_out		(w_data_out),
		.o_data_valid	(w_data_valid)
	);




endmodule 