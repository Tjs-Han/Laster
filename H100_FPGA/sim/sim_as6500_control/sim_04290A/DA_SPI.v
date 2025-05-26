 module DA_SPI(
   input clk,
	input rst,
	input tx_en,
	input [15:0] data_in,
	output reg SCLK,
	output reg SYNC,
	output reg DIN,
	output reg tx_done );
	
	
	reg [2:0]  clk_cnt;
	wire         SCLK_negedge;
	wire         SCLK_posedge;
	reg [4:0]  SCLK_cnt;
	reg        SCLK_d0;
	reg        SCLK_d1;
	wire          SYNC_posedge;
	reg        SYNC_d0;
	reg        SYNC_d1;
	reg [1:0]    state;
	reg [1:0]    next_state;
	reg [1:0]  SCLK_posedge_cnt; 
	
	always@(posedge clk or negedge rst)//定义分频时钟SCLK的上升下降沿
	if(!rst)
		begin
		SCLK_d0 <= 1'd0;
		SCLK_d1 <= 1'd0;
		end
	else if(SYNC==1'd1)
		begin
		SCLK_d0 <= 1'd0;
		SCLK_d1 <= 1'd0;
		end
	else
		begin
		SCLK_d0 <= SCLK;
		SCLK_d1 <= SCLK_d0;
		end
	
	assign SCLK_negedge=SCLK_d1 && ~SCLK_d0;
	assign SCLK_posedge=SCLK_d0 && ~SCLK_d1;
	
	always@(posedge clk or negedge rst)//定义片选信号SYNC下降沿
	if(!rst)
		begin
		SYNC_d0 <= 1'd0;
		SYNC_d1 <= 1'd0;
		end
	else
		begin
		SYNC_d0 <= SYNC;
		SYNC_d1 <= SYNC_d0;
		end

	assign SYNC_posedge=SYNC_d0 && ~SYNC_d1;
	
	always@(posedge clk or negedge rst)//定义SCLK下降沿计数
	begin
	if(!rst)
	  SCLK_posedge_cnt <= 2'd0;
	else if(SCLK_posedge==1'd1)
     SCLK_posedge_cnt <= SCLK_posedge_cnt+1'd1;
	else if(SYNC==1'd0)
     SCLK_posedge_cnt <= 2'd0;
	else 
	  SCLK_posedge_cnt <= SCLK_posedge_cnt;
	end
		
	always@(posedge clk or negedge rst)//定义SCLK计数
	begin
	if(!rst)
	   SCLK_cnt <= 1'd0;
	else if(SCLK_cnt==5'd16)
	   SCLK_cnt <= 1'd0;
	else if(state==2'd2&&SCLK_negedge==1'd1&&SYNC==1'd0)
	   SCLK_cnt <= SCLK_cnt+1'd1;
	else
	   SCLK_cnt <= SCLK_cnt;
	end
		
	always@(posedge clk or negedge rst)//定义系统时钟clk计数
	begin
	if(!rst)
	   clk_cnt <= 3'd0;
   else if(clk_cnt==3'd4)
	   clk_cnt <= 3'd0;
	else if(state==2'd1||state==2'd2)
	   clk_cnt <= clk_cnt+1'd1;
	else 
	   clk_cnt <= 3'd0;
	end
	
	always@(posedge clk or negedge rst)//分频SCLK
	begin
	if(!rst)
	   SCLK <= 1'd0;
	else if(SYNC_posedge==1'd1||clk_cnt==3'd4)
	   SCLK <= ~SCLK;
	else if(state==2'd3)
	   SCLK <= 1'd0;
	else
	   SCLK <= SCLK;
	end
		
	always@(posedge clk or negedge rst)//片选信号SYNC定义
	begin
	if(!rst)
	   SYNC <= 1'd0;
	else if(state==2'd1)
	   SYNC <= 1'd1;
	else if(state==2'd2)
		SYNC <= 1'd0;
	else
	   SYNC <= SYNC;
	end
		
	always@(posedge clk or negedge rst)//状态转换
	if(!rst)
		state <= 2'd0;
	else 
	   state <= next_state;
      		
	always@(*)
	begin
	   case(state)
   	2'd0:
		if(tx_en==1'd1)
	      next_state <= 2'd1;
		else
		   next_state <= 2'd0;
		2'd1:
		if(clk_cnt==3'd4)
		   next_state <= 2'd2;
		else
		   next_state <= 2'd1;
		2'd2:
		if(SCLK_cnt==5'd16)
		   next_state <= 2'd3;
		else
		   next_state <= 2'd2;
		2'd3:
		if(SYNC==1'd0&&DIN==1'd0)
	      next_state <= 2'd0;
		else
	      next_state <= 2'd3;
		default
		   next_state <= 2'd0;
		endcase
	end
	
	always@(posedge clk or negedge rst)//数据发送完成定义
	begin
	if(!rst)
	   tx_done <= 1'd0;
	else if(state==2'd3)
	   tx_done <= 1'd1;
	else if(state==2'd0||state==2'd1)
	   tx_done <= 1'd0;
	else
	   tx_done <= 1'd0;
	end
	
	always@(posedge clk or negedge rst)//输出输出DIN定义
	
	begin
	if(!rst)
	   DIN <= 1'd0;
	else if(state==2'd2&&SCLK==1'd1)
	   DIN <= data_in[15-SCLK_cnt];
	else if(SCLK==1'd0&&state==2'd3)
	   DIN <= 1'd0;
	else
	   DIN <= DIN;
	end
	
	endmodule
