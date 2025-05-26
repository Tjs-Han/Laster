   module AD_SPI(
  input clk,
  input rst,
  input rx_en,
  input SDATA,
  output reg CS,
  output reg SCLK,
  output reg rx_done,
  output reg [9:0]data_out
  );
  
  reg    [4:0]clk_cnt;
  reg    [2:0]state;
  reg    [2:0]next_state;
  reg    [4:0]sclk_cnt;
  reg    SCLK_d0;
  reg    SCLK_d1;
  wire    SCLK_negedge;

  
  always@(posedge clk or negedge rst) //定义SCLK下降沿
  if(!rst)
  begin
  SCLK_d0 <= 1'd1;
  SCLK_d1 <= 1'd1;
  end
  else
  begin
  SCLK_d0 <= SCLK;
  SCLK_d1 <= SCLK_d0;
  end
  
  assign SCLK_negedge = SCLK_d1 && ~SCLK_d0;
  
  
  always@(posedge clk or negedge rst )  //定义SCLK时钟
  if(!rst)
  
  clk_cnt <= 5'd0;
  
  else if(clk_cnt==5'd0 && CS==1'd0)
  clk_cnt <= clk_cnt+1'd1;
  else if(clk_cnt==5'd12)
  clk_cnt <= 5'd0;
  else if(rx_en==1'd0 && state==1'd0)
  clk_cnt <= 5'd0;
  else if(CS==1'd1)
  clk_cnt <= 5'd0;
  else
  clk_cnt <= clk_cnt+1'd1;
  
  always@(posedge clk or negedge rst )  //定义SCLK时钟
  if(!rst)
  SCLK <= 1'd1;
  else if(clk_cnt==5'd0 && CS==1'd0)
  SCLK <= ~SCLK;
  else if(rx_en==1'd0 && state==1'd0)
  SCLK <= 1'd1;
  else
  SCLK <= SCLK;
  
  
  
  always@(posedge clk or negedge rst)//定义SCLK时钟计数，按时钟下降沿计数
  if(!rst)
  sclk_cnt <= 5'd0;
  else if(SCLK_negedge==1'd1&&CS==1'd0)
  sclk_cnt <= sclk_cnt+1'd1;
  else if(sclk_cnt==5'd16)
  sclk_cnt <= 5'd0;
  else
  sclk_cnt <= sclk_cnt;
   
  always@(posedge clk or negedge rst)//状态转换
  begin
  if(!rst)
  state <= 3'd0;
  else
  state <= next_state;
  end
  
  always@(*)
  begin
  case(state)
  3'd0:
  if(rx_en)
  begin
  next_state <= 3'd1;
  end
  else
  next_state <= 3'd0;
  3'd1:
  if(sclk_cnt==5'd4 && CS==1'd0 && SCLK==1'd0)
  next_state <= 3'd2;
  else
  next_state <= 3'd1;
  3'd2:
  if(sclk_cnt==5'd14 && CS==1'd0 && SCLK==1'd0)
  next_state <= 3'd3;
  else
  next_state <= 3'd2;
  3'd3:
  if(sclk_cnt==5'd16&& CS==1'd0 )
  begin
  next_state <= 3'd4;
  end
  else
  next_state <= 3'd3;
  3'd4:
  if(CS==1'd1)
  begin
  next_state <= 3'd0;
  end
  else
  next_state <= 3'd4;
  default 
  next_state <= 3'd0;
  endcase
  end
  
  always@(posedge clk or negedge rst)//片选信号CS以及数据有效信号rx_done定义
  begin
  if(!rst)
  begin
  CS <= 1'd1;
  rx_done <= 1'd0;
  end
  else if(rx_en==1'd1 && state==3'd0)
  CS <= 1'd0;
  else if(state==3'd3 && sclk_cnt==5'd16 ) 
  rx_done <= 1'd1;
  else if(state==3'd4)
  CS <= 1'd1;
  else if(state==3'd0||state==3'd1 )
  rx_done <= 1'd0;
  end
  
  always@(posedge clk or negedge rst)//数据输出信号data_out信号定义
  begin
  if(!rst)
  data_out <= 10'd0;
  else if(state==3'd2 && SCLK==1'd1 && clk_cnt==5'd6) 
  data_out[13-sclk_cnt] <= SDATA;
  else
  data_out <= data_out;
  
  end
  
  endmodule 
  
  
  
