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
module ip_tx_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with rmii_top module    
input   wire            load_parameter_vld,
input   wire   [47:0]   lidar_mac_address,
input   wire   [31:0]   lidar_ip_address,

input   wire   [31:0]   icmp_top_tx_dst_ip,  
input   wire   [47:0]   icmp_top_tx_dst_mac,   
input   wire   [15:0]   icmp_top_tx_ip_len,  
input   wire            icmp_top_tx_sop,      //多字节数据，高字节优先, 字节内低比特优先
input   wire            icmp_top_tx_eop,      
input   wire            icmp_top_tx_vld,      //连续输入
input   wire   [7:0]    icmp_top_tx_dat,

input   wire   [31:0]   udp_top_tx_dst_ip,  
input   wire   [47:0]   udp_top_tx_dst_mac,   
input   wire   [15:0]   udp_top_tx_len, 
input   wire            udp_top_tx_sop,       //多字节数据，高字节优先, 字节内低比特优先
input   wire            udp_top_tx_eop,      
input   wire            udp_top_tx_vld,       //连续输入
input   wire   [7:0]    udp_top_tx_dat,      

output  reg             mac_packet_tx_sop,
output  reg             mac_packet_tx_eop,
output  reg             mac_packet_tx_vld,
output  reg    [7:0]    mac_packet_tx_dat
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;

parameter ST_IDLE = 3'b001;
parameter ST_UDP  = 3'b010;
parameter ST_ICMP = 3'b100;
/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg         [47:0]      lidar_mac_address_reg;
reg         [31:0]      lidar_ip_address_reg;

reg         [47:0]      icmp_top_tx_dst_mac_reg;
reg         [31:0]      icmp_top_tx_dst_ip_reg;

reg         [47:0]      udp_top_tx_dst_mac_reg;
reg         [31:0]      udp_top_tx_dst_ip_reg;

reg         [15:0]      ip_tx_sequence;
reg         [15:0]      icmp_top_tx_ip_len_reg;
reg         [15:0]      udp_top_tx_ip_len_reg;


reg                     fifo_0_wr;
reg         [9:0]       fifo_0_wdat;
wire                    fifo_0_rd;
wire        [9:0]       fifo_0_rdat;
wire                    fifo_0_empty;
wire                    fifo_0_full;
wire                    fifo_0_inc;
wire                    fifo_0_dec;
wire                    fifo_0_eop;
reg         [3:0]       fifo_0_packet_cnt;

reg                     fifo_1_wr;
reg         [9:0]       fifo_1_wdat;
wire                    fifo_1_rd;
wire        [9:0]       fifo_1_rdat;
wire                    fifo_1_empty;
wire                    fifo_1_full;
wire                    fifo_1_inc;
wire                    fifo_1_dec;
wire                    fifo_1_eop;
reg         [3:0]       fifo_1_packet_cnt;

wire        [1:0]       ren_fifo_req_0;
wire        [1:0]       ren_fifo_req_1;
reg         [2:0]       curr_state;
reg         [2:0]       next_state;
reg                     rd_fifo_0_vld;
reg                     rd_fifo_1_vld;
reg                     use_rd_fifo_0_vld;
reg                     use_rd_fifo_1_vld;

reg                     gen_icmp_tx_mac_ip_head_flag;
reg         [5:0]       gen_icmp_tx_mac_ip_head_cnt;
reg         [19:0]      temp_ip_head_check_0;
reg         [7:0]       gen_icmp_tx_mac_ip_head_data;
reg                     icmp_frame_ren_flag;
reg                     mac_packet_tx_0_sop;
reg                     mac_packet_tx_0_eop;
reg                     mac_packet_tx_0_vld;
reg         [7:0]       mac_packet_tx_0_dat;

reg                     gen_udp_tx_mac_ip_head_flag;
reg         [5:0]       gen_udp_tx_mac_ip_head_cnt;
reg         [19:0]      temp_ip_head_check_1;
reg         [7:0]       gen_udp_tx_mac_ip_head_data;
reg                     udp_frame_ren_flag;
reg                     mac_packet_tx_1_sop;
reg                     mac_packet_tx_1_eop;
reg                     mac_packet_tx_1_vld;
reg         [7:0]       mac_packet_tx_1_dat;
/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  ip_tx_sequence <=#D 16'b0;                
    end
    else if(mac_packet_tx_eop)begin
		  ip_tx_sequence <=#D ip_tx_sequence + 16'd1;             
    end    
end

////////register ip,mac info
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    lidar_mac_address_reg <=#D 48'd0;
    end else if(load_parameter_vld)begin
      lidar_mac_address_reg <=#D lidar_mac_address;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    lidar_ip_address_reg <=#D 32'd0;
    end else if(load_parameter_vld)begin
      lidar_ip_address_reg <=#D lidar_ip_address;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_top_tx_dst_mac_reg <=#D 48'd0;
    end else if(icmp_top_tx_sop)begin
      icmp_top_tx_dst_mac_reg <=#D icmp_top_tx_dst_mac;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_top_tx_dst_ip_reg <=#D 32'd0;
    end else if(icmp_top_tx_sop)begin
      icmp_top_tx_dst_ip_reg <=#D icmp_top_tx_dst_ip;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_top_tx_ip_len_reg <=#D 16'd0;
    end else if(icmp_top_tx_sop)begin
      icmp_top_tx_ip_len_reg <=#D icmp_top_tx_ip_len;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_dst_mac_reg <=#D 48'd0;
    end else if(udp_top_tx_sop)begin
      udp_top_tx_dst_mac_reg <=#D udp_top_tx_dst_mac;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_dst_ip_reg <=#D 32'd0;
    end else if(udp_top_tx_sop)begin
      udp_top_tx_dst_ip_reg <=#D udp_top_tx_dst_ip;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_ip_len_reg <=#D 16'd0;
    end else if(udp_top_tx_sop)begin
      udp_top_tx_ip_len_reg <=#D udp_top_tx_len + 16'd20;
    end
end
//////////end                 

//////// cache icmp packet data  deep 64 ; wide_10bits
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_0_wr <=#D 1'd0;
    end else begin
	    fifo_0_wr <=#D icmp_top_tx_vld || f0_udp_top_tx_eop || f1_udp_top_tx_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_0_wdat <=#D 10'd0;
    end else if(icmp_top_tx_vld)begin
	    fifo_0_wdat <=#D {icmp_top_tx_sop,icmp_top_tx_eop,icmp_top_tx_dat};
    end else if(f0_udp_top_tx_eop || f1_udp_top_tx_eop)begin
	    fifo_0_wdat <=#D 10'd0;
    end
end

//with output register fifo_0_rdat delay 2 clk from fifo_0_rd
fIfo_icmp_frame_64x10 u_fIfo_icmp_frame_64x10
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

assign fifo_0_rd = ~fifo_0_empty && icmp_frame_ren_flag;

assign fifo_0_inc = fifo_0_wr && fifo_0_wdat[8];
assign fifo_0_dec = f1_fifo_0_rd && fifo_0_rdat[9];
assign fifo_0_eop = f1_fifo_0_rd && fifo_0_rdat[8];
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  fifo_0_packet_cnt <=#D 4'd0;
    end else if(fifo_0_inc && fifo_0_dec)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt;     
    end else if(fifo_0_inc)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt + 4'd1;    
    end else if(fifo_0_dec)begin
		  fifo_0_packet_cnt <=#D fifo_0_packet_cnt - 4'd1;                   
    end
end

//////// cache udp packet data  deep 2048 ; wide_10bits
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_1_wr <=#D 1'd0;
    end else begin
	    fifo_1_wr <=#D udp_top_tx_vld || f0_udp_top_tx_eop || f1_udp_top_tx_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    fifo_1_wdat <=#D 10'd0;
    end else if(udp_top_tx_vld)begin
	    fifo_1_wdat <=#D {udp_top_tx_sop,udp_top_tx_eop,udp_top_tx_dat};
    end else if(f0_udp_top_tx_eop || f1_udp_top_tx_eop)begin
	    fifo_1_wdat <=#D 10'd0;    
    end
end

fIfo_udp_frame_2048x10 u_fIfo_udp_frame_2048x10
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

assign fifo_1_rd = ~fifo_1_empty && udp_frame_ren_flag;

assign fifo_1_inc = fifo_1_wr && fifo_1_wdat[8];
assign fifo_1_dec = f1_fifo_1_rd && fifo_1_rdat[9];
assign fifo_1_eop = f1_fifo_1_rd && fifo_1_rdat[8];
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  fifo_1_packet_cnt <=#D 4'd0;
    end else if(fifo_1_inc && fifo_1_dec)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt;     
    end else if(fifo_1_inc)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt + 4'd1;    
    end else if(fifo_1_dec)begin
		  fifo_1_packet_cnt <=#D fifo_1_packet_cnt - 4'd1;                   
    end
end

assign ren_fifo_req_0 = {|fifo_1_packet_cnt,|fifo_0_packet_cnt}; 
assign ren_fifo_req_1 = {ren_fifo_req_0[0],ren_fifo_req_0[1]}; 

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
                    next_state = ST_UDP;
                    rd_fifo_1_vld = 1;
                  end                              
                2'b01 : 
                  begin
                    next_state = ST_ICMP;
                    rd_fifo_0_vld = 1;
                  end
                2'b00 : next_state = ST_IDLE;         
              endcase
            ST_UDP:
              if(f0_fifo_1_eop)begin
                case(ren_fifo_req_1)
                 2'b11,2'b10: 
                  begin
                    next_state = ST_ICMP;
                    rd_fifo_0_vld = 1;
                  end                               
                 2'b01 : 
                  begin
                    next_state = ST_UDP;
                    rd_fifo_1_vld = 1;
                  end                 
                 2'b00 : next_state = ST_IDLE;      
                endcase            
              end
            ST_ICMP: 
              if(f0_fifo_0_eop)begin
                case(ren_fifo_req_0)
                  2'b10,2'b11: 
                    begin
                      next_state = ST_UDP;
                      rd_fifo_1_vld = 1;
                    end                              
                  2'b01 : 
                    begin
                      next_state = ST_ICMP;
                      rd_fifo_0_vld = 1;
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

//对于ICMP;首先生成 MAC 头部 ， IP 头部 ； 其次读出ICMP 回复的数据;
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  gen_icmp_tx_mac_ip_head_flag <=#D 1'b0;                
    end
    else if(~gen_icmp_tx_mac_ip_head_flag && use_rd_fifo_0_vld)begin
		  gen_icmp_tx_mac_ip_head_flag <=#D 1'b1;           
    end
    else if( gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd33))begin
		  gen_icmp_tx_mac_ip_head_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  gen_icmp_tx_mac_ip_head_cnt <=#D 6'b0;                
    end
    else if(~gen_icmp_tx_mac_ip_head_flag && use_rd_fifo_0_vld)begin
		  gen_icmp_tx_mac_ip_head_cnt <=#D 6'b0;           
    end
    else if( gen_icmp_tx_mac_ip_head_flag)begin
		  gen_icmp_tx_mac_ip_head_cnt <=#D gen_icmp_tx_mac_ip_head_cnt + 6'b1;
    end
end

//IP head
  // 16'h4500
  // icmp_top_tx_ip_len_reg
  // ip_tx_sequence
  // 16'h4000
  // 16'h8001
  // lidar_ip_address_reg[31:16]
  // lidar_ip_address_reg[15:0]
  // icmp_top_tx_dst_ip_reg[31:16]
  // icmp_top_tx_dst_ip_reg[15:0]

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  temp_ip_head_check_0 <=#D 20'b0;                
    end
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd1))begin
		  temp_ip_head_check_0 <=#D 20'h10501 + icmp_top_tx_ip_len_reg;           
    end    
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd2))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 + ip_tx_sequence;           
    end    
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd3))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 + lidar_ip_address_reg[31:16];            
    end    
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd4))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 + lidar_ip_address_reg[15:0];            
    end  
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd5))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 + icmp_top_tx_dst_ip_reg[31:16];            
    end  
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd6))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 + icmp_top_tx_dst_ip_reg[15:0];            
    end   
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd7))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0[19:16] + temp_ip_head_check_0[15:0];            
    end  
    else if(gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd8))begin
		  temp_ip_head_check_0 <=#D temp_ip_head_check_0 ^ 20'hFFFFF;              
    end                             
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 gen_icmp_tx_mac_ip_head_data <=#D 8'b0;
    end else if(gen_icmp_tx_mac_ip_head_flag)begin
        case(gen_icmp_tx_mac_ip_head_cnt)
        //mac head
        6'd0: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[47:40]; 
        6'd1: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[39:32]; 
        6'd2: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[31:24]; 
        6'd3: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[23:16]; 
        6'd4: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[15:8]; 
        6'd5: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_mac_reg[7:0]; 
        6'd6: gen_icmp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[47:40]; 
        6'd7: gen_icmp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[39:32]; 
        6'd8: gen_icmp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[31:24]; 
        6'd9: gen_icmp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[23:16];   
        6'd10: gen_icmp_tx_mac_ip_head_data <=#D lidar_mac_address_reg[15:8]; 
        6'd11: gen_icmp_tx_mac_ip_head_data <=#D lidar_mac_address_reg[7:0]; 
        6'd12: gen_icmp_tx_mac_ip_head_data <=#D 8'h08; 
        6'd13: gen_icmp_tx_mac_ip_head_data <=#D 8'h00;
      
       //IP head
	  	 6'd14: gen_icmp_tx_mac_ip_head_data <=#D 8'h45;

	  	 6'd15: gen_icmp_tx_mac_ip_head_data <=#D 8'h00;

	  	 6'd16: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_ip_len_reg[15:8];  
	  	 6'd17: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_ip_len_reg[7:0];

	  	 6'd18: gen_icmp_tx_mac_ip_head_data <=#D ip_tx_sequence[15:8]; 
	  	 6'd19: gen_icmp_tx_mac_ip_head_data <=#D ip_tx_sequence[7:0]; 

	  	 6'd20: gen_icmp_tx_mac_ip_head_data <=#D 8'h40; 
	  	 6'd21: gen_icmp_tx_mac_ip_head_data <=#D 8'h00; 

	  	 6'd22: gen_icmp_tx_mac_ip_head_data <=#D 8'h80;

	  	 6'd23: gen_icmp_tx_mac_ip_head_data <=#D 8'h01;          

 	     6'd24: gen_icmp_tx_mac_ip_head_data <=#D temp_ip_head_check_0[15:8];
 	     6'd25: gen_icmp_tx_mac_ip_head_data <=#D temp_ip_head_check_0[7:0];                    

	  	 6'd26: gen_icmp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[31:24];
	  	 6'd27: gen_icmp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[23:16];
	  	 6'd28: gen_icmp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[15:8]; 
	  	 6'd29: gen_icmp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[7:0];                            

	  	 6'd30: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_ip_reg[31:24];
	  	 6'd31: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_ip_reg[23:16];
	  	 6'd32: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_ip_reg[15:8]; 
	  	 6'd33: gen_icmp_tx_mac_ip_head_data <=#D icmp_top_tx_dst_ip_reg[7:0];

	  	 default: gen_icmp_tx_mac_ip_head_data <=#D 8'h00;                                                                                                                                                                                                                                                                    
        endcase
    end
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  icmp_frame_ren_flag <=#D 1'b0;                
    end
    else if( gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd31))begin
		  icmp_frame_ren_flag <=#D 1'b1;           
    end
    else if( fifo_0_eop)begin
		  icmp_frame_ren_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_0_sop <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_0_sop <=#D gen_icmp_tx_mac_ip_head_flag && (gen_icmp_tx_mac_ip_head_cnt == 6'd0);           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_0_eop <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_0_eop <=#D fifo_0_eop;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_0_vld <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_0_vld <=#D gen_icmp_tx_mac_ip_head_flag || f1_fifo_0_rd;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_0_dat <=#D 8'b0;                
    end
    else if(gen_icmp_tx_mac_ip_head_flag)begin
		  mac_packet_tx_0_dat <=#D  gen_icmp_tx_mac_ip_head_data;           
    end    
    else if(f1_fifo_0_rd)begin
		  mac_packet_tx_0_dat <=#D  fifo_0_rdat[7:0];           
    end       
end

///////////////////
//对于UDP;首先生成 MAC 头部 ， IP 头部；其次读出UDP 上报或者回复的数据;
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  gen_udp_tx_mac_ip_head_flag <=#D 1'b0;                
    end
    else if(~gen_udp_tx_mac_ip_head_flag && use_rd_fifo_1_vld)begin
		  gen_udp_tx_mac_ip_head_flag <=#D 1'b1;           
    end
    else if( gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd33))begin
		  gen_udp_tx_mac_ip_head_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  gen_udp_tx_mac_ip_head_cnt <=#D 6'b0;                
    end
    else if(~gen_udp_tx_mac_ip_head_flag && use_rd_fifo_1_vld)begin
		  gen_udp_tx_mac_ip_head_cnt <=#D 6'b0;           
    end
    else if( gen_udp_tx_mac_ip_head_flag)begin
		  gen_udp_tx_mac_ip_head_cnt <=#D gen_udp_tx_mac_ip_head_cnt + 6'b1;
    end
end

//IP head
  // 16'h4500
  // udp_top_tx_ip_len_reg : udp_top_len +  20;
  // ip_tx_sequence
  // 16'h0000
  // 16'hFF11
  // check
  // lidar_ip_address_reg[31:16]
  // lidar_ip_address_reg[15:0]
  // udp_top_tx_dst_ip_reg[31:16]
  // udp_top_tx_dst_ip_reg[15:0]

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  temp_ip_head_check_1 <=#D 20'b0;                
    end
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd1))begin
		  temp_ip_head_check_1 <=#D 20'h14411 + udp_top_tx_ip_len_reg;           
    end    
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd2))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 + ip_tx_sequence;           
    end    
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd3))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 + lidar_ip_address_reg[31:16];            
    end    
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd4))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 + lidar_ip_address_reg[15:0];            
    end  
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd5))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 + udp_top_tx_dst_ip_reg[31:16];            
    end  
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd6))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 + udp_top_tx_dst_ip_reg[15:0];            
    end   
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd7))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1[19:16] + temp_ip_head_check_1[15:0];            
    end    
    else if(gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd8))begin
		  temp_ip_head_check_1 <=#D temp_ip_head_check_1 ^ 20'hFFFFF;            
    end                            
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 gen_udp_tx_mac_ip_head_data <=#D 8'b0;
    end else if(gen_udp_tx_mac_ip_head_flag)begin
        case(gen_udp_tx_mac_ip_head_cnt)
        //mac head
        6'd0: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[47:40]; 
        6'd1: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[39:32]; 
        6'd2: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[31:24]; 
        6'd3: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[23:16]; 
        6'd4: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[15:8]; 
        6'd5: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_mac_reg[7:0]; 
        6'd6: gen_udp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[47:40]; 
        6'd7: gen_udp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[39:32]; 
        6'd8: gen_udp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[31:24]; 
        6'd9: gen_udp_tx_mac_ip_head_data <=#D  lidar_mac_address_reg[23:16];   
        6'd10: gen_udp_tx_mac_ip_head_data <=#D lidar_mac_address_reg[15:8]; 
        6'd11: gen_udp_tx_mac_ip_head_data <=#D lidar_mac_address_reg[7:0]; 
        6'd12: gen_udp_tx_mac_ip_head_data <=#D 8'h08; 
        6'd13: gen_udp_tx_mac_ip_head_data <=#D 8'h00;
      
       //IP head
	  	 6'd14: gen_udp_tx_mac_ip_head_data <=#D 8'h45;

	  	 6'd15: gen_udp_tx_mac_ip_head_data <=#D 8'h00;

	  	 6'd16: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_ip_len_reg[15:8];  
	  	 6'd17: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_ip_len_reg[7:0];

	  	 6'd18: gen_udp_tx_mac_ip_head_data <=#D ip_tx_sequence[15:8]; 
	  	 6'd19: gen_udp_tx_mac_ip_head_data <=#D ip_tx_sequence[7:0]; 

	  	 6'd20: gen_udp_tx_mac_ip_head_data <=#D 8'h00; 
	  	 6'd21: gen_udp_tx_mac_ip_head_data <=#D 8'h00; 

	  	 6'd22: gen_udp_tx_mac_ip_head_data <=#D 8'hFF;

	  	 6'd23: gen_udp_tx_mac_ip_head_data <=#D 8'h11;          

 	     6'd24: gen_udp_tx_mac_ip_head_data <=#D temp_ip_head_check_1[15:8];
 	     6'd25: gen_udp_tx_mac_ip_head_data <=#D temp_ip_head_check_1[7:0];                    

	  	 6'd26: gen_udp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[31:24];
	  	 6'd27: gen_udp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[23:16];
	  	 6'd28: gen_udp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[15:8]; 
	  	 6'd29: gen_udp_tx_mac_ip_head_data <=#D lidar_ip_address_reg[7:0];                            

	  	 6'd30: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_ip_reg[31:24];
	  	 6'd31: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_ip_reg[23:16];
	  	 6'd32: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_ip_reg[15:8]; 
	  	 6'd33: gen_udp_tx_mac_ip_head_data <=#D udp_top_tx_dst_ip_reg[7:0];

	  	 default: gen_udp_tx_mac_ip_head_data <=#D 8'h00;                                                                                                                                                                                                                                                                    
        endcase
    end
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  udp_frame_ren_flag <=#D 1'b0;                
    end
    else if( gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd31))begin
		  udp_frame_ren_flag <=#D 1'b1;           
    end
    else if( fifo_1_eop)begin
		  udp_frame_ren_flag <=#D 1'b0;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_1_sop <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_1_sop <=#D gen_udp_tx_mac_ip_head_flag && (gen_udp_tx_mac_ip_head_cnt == 6'd0);           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_1_eop <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_1_eop <=#D fifo_1_eop;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_1_vld <=#D 1'b0;                
    end
    else begin
		  mac_packet_tx_1_vld <=#D gen_udp_tx_mac_ip_head_flag || f1_fifo_1_rd;           
    end    
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_1_dat <=#D 8'b0;                
    end
    else if(gen_udp_tx_mac_ip_head_flag)begin
		  mac_packet_tx_1_dat <=#D  gen_udp_tx_mac_ip_head_data;           
    end    
    else if(f1_fifo_1_rd)begin
		  mac_packet_tx_1_dat <=#D  fifo_1_rdat[7:0];           
    end       
end

///////////////////////////
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_sop <=#D 1'b0;                
    end 
    else begin
		  mac_packet_tx_sop <=#D  mac_packet_tx_0_sop || mac_packet_tx_1_sop;           
    end       
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_eop <=#D 1'b0;                
    end 
    else begin
		  mac_packet_tx_eop <=#D  mac_packet_tx_0_eop || mac_packet_tx_1_eop;           
    end       
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_vld <=#D 1'b0;                
    end 
    else begin
		  mac_packet_tx_vld <=#D  mac_packet_tx_0_vld || mac_packet_tx_1_vld;           
    end       
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  mac_packet_tx_dat <=#D 8'b0;                
    end 
    else if(mac_packet_tx_0_vld)begin
		  mac_packet_tx_dat <=#D  mac_packet_tx_0_dat;           
    end    
    else if(mac_packet_tx_1_vld)begin
		  mac_packet_tx_dat <=#D  mac_packet_tx_1_dat;           
    end          
end

endmodule