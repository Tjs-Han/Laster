module tdc_para
(
	input			i_clk_50m    	,
	input			i_rst_n      	,
	
	input			i_para_en		,
	input	[15:0]	i_diff_now		,
	input	[15:0]	i_diff_post		,
	input	[15:0]	i_data_length	,
	input	[10:0]	i_addr_start	,
	
	output	[15:0]	o_tdc_para_1	,
	output	[15:0]	o_tdc_para_2	,
	output	[10:0]	o_addr_mid		,
	output			o_para_done			
);

	reg		[15:0]	r_tdc_para_1	= 16'd0;
	reg		[15:0]	r_tdc_para_2	= 16'd0;
	reg		[10:0]	r_addr_mid		= 11'd0;
	reg				r_para_done		= 1'b0;	
	
	reg		[15:0]	r_diff_now		= 16'd0;
	reg		[15:0]	r_diff_post		= 16'd0;
	reg		[15:0]	r_data_length	= 16'd0;
	reg		[7:0]	r_para_state	= 8'd0;
	
	reg     [15:0] div_beichushu_1 = 16'd0;
	reg     [15:0] div_beichushu_2 = 16'd0;
	reg     [15:0] div_chushu      = 16'd0;
	reg             div_en_1       = 1'd0;
	reg             div_en_2       = 1'd0;
	wire            done_1     ;
	wire            done_2   ;   
	wire    [15:0] yshang_1  ;
	wire    [15:0] yshang_2;
	
	reg     done_1_reg;
	reg     done_2_reg;
	
	
	
	
	
	parameter		PARA_IDLE		= 8'b0000_0000,
					PARA_WAIT		= 8'b0000_0010,
					PARA_PARA		= 8'b0000_0100,
					PARA_JUDGE		= 8'b0000_1000,
					PARA_MID		= 8'b0001_0000,
					PARA_DONE		= 8'b0010_0000;
	
	
	always@(posedge i_clk_50m or negedge i_rst_n)
		if(i_rst_n == 0)begin
			r_diff_now		<= 16'd0;
			r_diff_post		<= 16'd0;
			r_data_length	<= 16'd0;
			r_tdc_para_1	<= 16'd0;
			r_tdc_para_2	<= 16'd0;
			r_addr_mid		<= 11'd0;
			r_para_done		<= 1'b0;
			r_para_state	<= PARA_IDLE;
			end
		else begin
			case(r_para_state)
				PARA_IDLE	:begin
					r_para_done		<= 1'b0;
					r_para_state	<= PARA_WAIT;
					end
				PARA_WAIT	:begin
					if(i_para_en)begin
						r_diff_now		<= i_diff_now;
						r_diff_post		<= i_diff_post;
						r_data_length	<= i_data_length+1'b1 ;
						r_tdc_para_1	<= 16'd0;
						r_tdc_para_2	<= 16'd0;
						r_addr_mid		<= 11'd0;
						r_para_state	<= PARA_PARA;
						end
					else
						r_para_state	<= PARA_WAIT;
					end
				PARA_PARA	:begin
					div_en_1 <= 1'd1;
					div_en_2 <= 1'd1;
					div_beichushu_1 <= r_diff_post<<'d10;
					div_beichushu_2 <= r_diff_now <<'d10;
					div_chushu <= r_data_length;
					r_para_state	<= PARA_JUDGE;
					end					
				PARA_JUDGE	:
				      begin
				      div_en_1 <= 1'd0;
					  div_en_2 <= 1'd0;
					if(done_1_reg==1'd1&&done_2_reg==1'd1)
					  begin
					  r_tdc_para_1 <= yshang_1;	
					  r_tdc_para_2 <= yshang_2;
					  r_para_state	<= PARA_MID;
                      end
		            else
					  r_para_state	<= PARA_JUDGE;
					  end
				PARA_MID	:begin
					r_addr_mid		<= i_addr_start + r_data_length[7:1];
					r_para_state	<= PARA_DONE;
					end
				PARA_DONE	:begin
					r_para_done		<= 1'b1;
					r_para_state	<= PARA_IDLE;
					end
				default		:
					r_para_state	<= PARA_IDLE;
				endcase
			end
			
			
   always@(posedge i_clk_50m or negedge i_rst_n)
	  if(i_rst_n == 0)
		done_1_reg <= 1'd0;
	  else if(done_1==1'd1)
		done_1_reg <= 1'd1;
	  else if(r_para_state==PARA_MID)
		done_1_reg <= 1'd0;
	  else
		done_1_reg <= done_1_reg;
		
   always@(posedge i_clk_50m or negedge i_rst_n)
	  if(i_rst_n == 0)
		done_2_reg <= 1'd0;
	  else if(done_2==1'd1)
		done_2_reg <= 1'd1;
	  else if(r_para_state==PARA_MID)
		done_2_reg <= 1'd0;
	  else
		done_2_reg <= done_2_reg;


	assign		o_tdc_para_1 	= r_tdc_para_1;
	assign		o_tdc_para_2 	= r_tdc_para_2;
	assign		o_addr_mid		= r_addr_mid;
	assign		o_para_done		= r_para_done;	
	
	
div_rill   div_rill_1
  (
  .clk  (i_clk_50m),
  .rst  (i_rst_n),
  .enable (div_en_1),
  .a    (div_beichushu_1),
  .b    (div_chushu),
  .done (done_1),
  .yshang(yshang_1),
  .yyushu()
  );
  
 div_rill   div_rill_2 
  (
  .clk  (i_clk_50m),
  .rst  (i_rst_n),
  .enable (div_en_2),
  .a    (div_beichushu_2),
  .b    (div_chushu),
  .done (done_2),
  .yshang(yshang_2),
  .yyushu()
 
  );	
	
endmodule 