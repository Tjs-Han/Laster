`timescale 1ns / 1ps
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:  
  1: add IP  head to IP  packet
  2: add mac head to MAC packet;        
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
module mux_8b_2t1(
input   wire            sys_clk,
input   wire            sys_rst_n,

input   wire            in_packet_sop_0,    
input   wire            in_packet_eop_0,      
input   wire            in_packet_vld_0,      
input   wire   [7:0]    in_packet_dat_0,

input   wire            in_packet_sop_1,    
input   wire            in_packet_eop_1,      
input   wire            in_packet_vld_1,      
input   wire   [7:0]    in_packet_dat_1,  

input   wire            out_packet_sop,    
input   wire            out_packet_eop,      
input   wire            out_packet_vld,      
input   wire   [7:0]    out_packet_dat
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;

/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg                     f0_in_packet_eop_0;
reg                     f1_in_packet_eop_0;
reg                     fifo_0_wr;
reg           [9:0]     fifo_0_wdat;

wire                    fifo_0_empty;
wire                    fifo_0_rd;

wire                    fifo_0_inc;
wire                    fifo_0_dec;
wire                    fifo_0_eop;
wire          [9:0]     fifo_0_rdat;

reg                     f0_fifo_0_rd;
reg                     f1_fifo_0_rd;
reg           [5:0]     fifo_0_packet_cnt;

///
reg                     f0_in_packet_eop_1;
reg                     f1_in_packet_eop_1;
reg                     fifo_1_wr;
reg           [9:0]     fifo_1_wdat;

wire                    fifo_1_empty;
wire                    fifo_1_rd;

wire                    fifo_1_inc;
wire                    fifo_1_dec;
wire                    fifo_1_eop;
wire          [9:0]     fifo_1_rdat;

reg                     f0_fifo_1_rd;
reg                     f1_fifo_1_rd;
reg           [5:0]     fifo_1_packet_cnt;

/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/    
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    f0_in_packet_eop_0 <=#D 1'b0;
	    f1_in_packet_eop_0 <=#D 1'b0;      
    end else begin
	    f0_in_packet_eop_0 <=#D in_packet_eop_0;
	    f1_in_packet_eop_0 <=#D f0_in_packet_eop_0;  
    end
end

//////// cache icmp packet data  deep 64 ; wide_10bits
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_0_wr <=#D 1'd0;
    end else begin
	    fifo_0_wr <=#D in_packet_vld_0 || f0_in_packet_eop_0 || f1_in_packet_eop_0;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_0_wdat <=#D 10'd0;
    end else if(in_packet_vld_0)begin
	    fifo_0_wdat <=#D {in_packet_sop_0,in_packet_eop_0,in_packet_dat_0};
    end else if(f0_in_packet_eop_0 || f1_in_packet_eop_0)begin
	    fifo_0_wdat <=#D 10'd0;
    end
end

fIfo_mux_2048x10 u_fIfo_mux_2048x10
(
  .Clock  (sys_clk),
  .Reset  (~sys_rst_n),  

  .WrEn   (fifo_0_wr), 
  .Data   (fifo_0_wdat), 
  .RdEn   (fifo_0_rd),       
  .Q      (fifo_0_rdat),     
  .Empty  (fifo_0_empty),   
  .Full   (fifo_0_full)    
);

assign fifo_0_rd = ~fifo_0_empty && fifo_0_ren_flag;

assign fifo_0_inc = fifo_0_wr && fifo_0_wdat[8];
assign fifo_0_dec = f1_fifo_0_rd && fifo_0_rdat[9];
assign fifo_0_eop = f1_fifo_0_rd && fifo_0_rdat[8];
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  fifo_0_packet_cnt <=#D 6'd0;
    end else if(fifo_0_inc && fifo_0_dec)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt;     
    end else if(fifo_0_inc)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt + 6'd1;    
    end else if(fifo_0_dec)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt - 6'd1;                   
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    f0_fifo_0_rd <=#D 1'b0;
	    f1_fifo_0_rd <=#D 1'b0;      
    end else begin
	    f0_fifo_0_rd <=#D fifo_0_rd;
	    f1_fifo_0_rd <=#D f0_fifo_0_rd;      
    end
end

//////////////
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    f0_in_packet_eop_0 <=#D 1'b0;
	    f1_in_packet_eop_0 <=#D 1'b0;      
    end else begin
	    f0_in_packet_eop_0 <=#D in_packet_eop_0;
	    f1_in_packet_eop_0 <=#D f0_in_packet_eop_0;  
    end
end

//////// cache icmp packet data  deep 64 ; wide_10bits
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_1_wr <=#D 1'd0;
    end else begin
	    fifo_1_wr <=#D in_packet_vld_1 || f0_in_packet_eop_1 || f1_in_packet_eop_1;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_1_wdat <=#D 10'd0;
    end else if(in_packet_vld_1)begin
	    fifo_1_wdat <=#D {in_packet_sop_1,in_packet_eop_1,in_packet_dat_1};
    end else if(f0_in_packet_eop_1 || f1_in_packet_eop_1)begin
	    fifo_1_wdat <=#D 10'd0;
    end
end

fIfo_mux_128x10 u_fIfo_mux_128x10
(
  .Clock  (sys_clk),
  .Reset  (~sys_rst_n),  

  .WrEn   (fifo_1_wr), 
  .Data   (fifo_1_wdat), 
  .RdEn   (fifo_1_rd),       
  .Q      (fifo_1_rdat),     
  .Empty  (fifo_1_empty),   
  .Full   (fifo_1_full)    
);

assign fifo_1_rd = ~fifo_1_empty && fifo_1_ren_flag;

assign fifo_1_inc = fifo_1_wr && fifo_1_wdat[8];
assign fifo_1_dec = f1_fifo_1_rd && fifo_1_rdat[9];
assign fifo_1_eop = f1_fifo_1_rd && fifo_1_rdat[8];
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  fifo_1_packet_cnt <=#D 6'd0;
    end else if(fifo_1_inc && fifo_1_dec)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt;     
    end else if(fifo_1_inc)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt + 6'd1;    
    end else if(fifo_1_dec)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt - 6'd1;                   
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    f0_fifo_1_rd <=#D 1'b0;
	    f1_fifo_1_rd <=#D 1'b0;      
    end else begin
	    f0_fifo_1_rd <=#D fifo_1_rd;
	    f1_fifo_1_rd <=#D f0_fifo_1_rd;      
    end
end

/////////////////////////////////////
wire      [1:0]   ren_fifo_req_0;
wire      [1:0]   ren_fifo_req_1;
assign ren_fifo_req_0 = {|fifo_0_packet_cnt,|fifo_1_packet_cnt}; 
assign ren_fifo_req_1 = {ren_fifo_req_0[0],ren_fifo_req_0[1]}; 

parameter ST_IDLE    = 3'b001;
parameter ST_FIFO_0  = 3'b010;
parameter ST_FIFO_1  = 3'b100;
reg   [2:0]    curr_state;
reg   [2:0]    next_state;

reg            rd_fifo_0_vld;
reg            rd_fifo_1_vld;
reg            use_rd_fifo_0_vld;
reg            use_rd_fifo_1_vld;

always @ *
begin
    if(!sys_rst_n) begin
      next_state = ST_IDLE;
      rd_fifo_1_vld = 0;
      rd_fifo_0_vld = 0;      
    end
    else begin
        case (curr_state)
            ST_IDLE: 
              case(ren_fifo_req_0)
                2'b10,2'b11: 
                  begin
                    next_state = ST_FIFO_0;
                    rd_fifo_0_vld = 1;
                  end                              
                2'b01 : 
                  begin
                    next_state = ST_FIFO_1;
                    rd_fifo_1_vld = 1;
                  end
                2'b00 : next_state = ST_IDLE;         
              endcase
            ST_FIFO_0:
              if(f0_fifo_0_eop)begin
                case(ren_fifo_req_1)
                 2'b11,2'b10: 
                  begin
                    next_state = ST_FIFO_1;
                    rd_fifo_1_vld = 1;
                  end                               
                 2'b01 : 
                  begin
                    next_state = ST_FIFO_0;
                    rd_fifo_0_vld = 1;
                  end                 
                 2'b00 : next_state = ST_IDLE;      
                endcase            
              end
            ST_FIFO_1: 
              if(f0_fifo_1_eop)begin
                case(ren_fifo_req_0)
                  2'b10,2'b11: 
                    begin
                      next_state = ST_FIFO_0;
                      rd_fifo_0_vld = 1;
                    end                              
                  2'b01 : 
                    begin
                      next_state = ST_FIFO_1;
                      rd_fifo_1_vld = 1;
                    end
                  2'b00 : next_state = ST_IDLE;         
                endcase    
              end                        
            default: next_state = ST_IDLE;
        endcase
    end
end

// State flip-flops
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  curr_state <=#D 3'd0;  
		  use_rd_fifo_0_vld <=#D 1'b0;     
		  use_rd_fifo_1_vld <=#D 1'b0;             
    end
    else begin
      curr_state <=#D next_state;
		  use_rd_fifo_0_vld <=#D rd_fifo_0_vld;     
		  use_rd_fifo_1_vld <=#D rd_fifo_1_vld;           
    end
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  f0_fifo_0_eop <=#D 1'b0;                
    end
    else begin
		  f0_fifo_0_eop <=#D fifo_0_eop;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  f0_fifo_1_eop <=#D 1'b0;                
    end
    else begin
		  f0_fifo_1_eop <=#D fifo_1_eop;           
    end    
end

//对于ICMP;首先生成 MAC 头部 ， IP 头部 ； 其次读出ICMP 回复的数据;
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  fifo_0_ren_flag <=#D 1'b0;                
    end
    else if(~fifo_0_ren_flag && use_rd_fifo_0_vld)begin
		  fifo_0_ren_flag <=#D 1'b1;           
    end
    else if( fifo_0_ren_flag && fifo_0_eop)begin
		  fifo_0_ren_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  fifo_1_ren_flag <=#D 1'b0;                
    end
    else if(~fifo_1_ren_flag && use_rd_fifo_1_vld)begin
		  fifo_1_ren_flag <=#D 1'b1;           
    end
    else if( fifo_1_ren_flag && fifo_1_eop)begin
		  fifo_1_ren_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  out_packet_sop <=#D 1'b0;                
    end
    else begin
		  out_packet_sop <=#D f1_fifo_0_rd && fifo_0_rdat[9] || f1_fifo_1_rd && fifo_1_rdat[9];            
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  out_packet_eop <=#D 1'b0;                
    end
    else begin
		  out_packet_eop <=#D f1_fifo_0_rd && fifo_0_rdat[8] || f1_fifo_1_rd && fifo_1_rdat[8];            
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  out_packet_vld <=#D 1'b0;                
    end
    else begin
		  out_packet_vld <=#D f1_fifo_0_rd || f1_fifo_1_rd;            
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  out_packet_dat <=#D 8'b0;                
    end
    else if(f1_fifo_0_rd)begin
		  out_packet_dat <=#D fifo_0_rdat[7:0];            
    end    
    else if(f1_fifo_1_rd)begin
		  out_packet_dat <=#D fifo_1_rdat[7:0];            
    end       
end

endmodule