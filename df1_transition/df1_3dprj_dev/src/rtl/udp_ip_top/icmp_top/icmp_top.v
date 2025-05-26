`timescale 1ns / 1ps
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:       
    a: Identify the start and end of the mac frame;
    b: check mac frame by crc32;
    c: Output a valid mac frame; 
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
module icmp_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with load_parameter_top module
input   wire   [15:0]   ip_icmp_match_len,
input   wire   [31:0]   ip_icmp_match_ip,
input   wire   [47:0]   ip_icmp_match_mac,
input   wire            icmp_top_rx_sop,
input   wire            icmp_top_rx_eop,
input   wire            icmp_top_rx_vld,
input   wire   [7:0]    icmp_top_rx_dat,

output  reg    [15:0]   icmp_top_tx_ip_len;
output  reg    [31:0]   icmp_top_tx_dst_ip;
output  reg    [47:0]   icmp_top_tx_dst_mac;
output  reg             icmp_top_tx_sop,
output  reg             icmp_top_tx_eop,
output  reg             icmp_top_tx_vld,
output  reg    [7:0]    icmp_top_tx_dat,
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;

/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg                     f0_icmp_top_rx_sop;
reg         [7:0]       icmp_byte0;
reg         [7:0]       icmp_byte1;

/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_ip_len_reg <=#D 16'd0;
    end else if(icmp_top_rx_sop)begin
	  icmp_top_tx_ip_len_reg <=#D ip_icmp_match_len;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_dst_ip_reg <=#D 32'd0;
    end else if(icmp_top_rx_sop)begin
	  icmp_top_tx_dst_ip_reg <=#D ip_icmp_match_ip;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_dst_mac_reg <=#D 32'd0;
    end else if(icmp_top_rx_sop)begin
	  icmp_top_tx_dst_mac_reg <=#D ip_icmp_match_mac;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_data_parity_flag <=#D 1'd0;
    end else if(icmp_top_rx_sop)begin
	  icmp_data_parity_flag <=#D 1'd1;
    end else if(icmp_top_rx_vld)begin
	  icmp_data_parity_flag <=#D ~icmp_data_parity_flag;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  temp_cal_check_dat <=#D 23'd0;
    end else if(icmp_top_rx_sop || f0_icmp_top_rx_sop || f1_icmp_top_rx_sop || f3_icmp_top_rx_sop)begin // 前4个字节先当0计算;
	  temp_cal_check_dat <=#D 23'd0;
    end else if(icmp_top_rx_vld && ~icmp_data_parity_flag)begin                                         // 其它部分使用原始值计算;
      temp_cal_check_dat <=#D temp_cal_check_dat + {icmp_top_rx_dat,8'b0};   
    end else if(icmp_top_rx_vld &&  icmp_data_parity_flag)begin
      temp_cal_check_dat <=#D temp_cal_check_dat + icmp_top_rx_dat;           
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  temp_cal_check_dat_1 <=#D 16'd0;                     
    end else if(f0_icmp_top_rx_eop)begin
      temp_cal_check_dat_1 <=#D temp_cal_check_dat[15:0] + temp_cal_check_dat[22:16];                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
      f0_icmp_top_rx_sop <=#D 1'd0;                     
    end else begin
      f0_icmp_top_rx_sop <=#D icmp_top_rx_sop;                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_byte0 <=#D 8'd0;                     
    end else if(icmp_top_rx_sop && icmp_top_rx_vld)begin
      icmp_byte0 <=#D icmp_top_rx_dat;                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_request_flag <=#D 1'b0;                     
    end else if(f0_icmp_top_rx_sop && (icmp_byte0==8'h08) && (icmp_top_rx_dat==8'h00))begin
	    icmp_request_flag <=#D 1'b1;
    end else if(icmp_top_rx_eop)begin
	    icmp_request_flag <=#D 1'b0;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    ram_wen <=#D 1'b0;                     
    end else if(f0_icmp_top_rx_sop && (icmp_byte0==8'h08) && (icmp_top_rx_dat==8'h00))begin
	    ram_wen <=#D 1'b1;   
    end else if(icmp_top_rx_eop)begin
	    ram_wen <=#D 1'b0;                                
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    ram_addr <=#D 7'b0;   
    end else if(f0_icmp_top_rx_sop || f0_icmp_top_rx_eop)begin
	    ram_addr <=#D 7'b0;                          
    end else if(icmp_request_flag || ram_ren_flag)begin
	    ram_addr <=#D ram_addr + 7'd1;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    ram_wdat <=#D 8'b0;                     
    end else begin
	    ram_wdat <=#D icmp_top_rx_dat;                         
    end
end

ram_icmp_128x8  u_ram_icmp_128x8
(
  .Clock      (sys_clk), 
  .ClockEn    (1'b1),  
  .Reset      (~sys_rst_n),  
  .WE         (ram_wen), 
  .Address    (ram_addr), 
  .Data       (ram_wdat), 
  .Q          (ram_rdat)
);

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  cal_check_dat <=#D 16'd0;                     
    end else if(icmp_request_flag && f1_icmp_top_rx_eop)begin
      cal_check_dat <=#D temp_cal_check_dat_1 ^ 16'hFFFF;                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_ip_len <=#D 16'd0;
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	  icmp_top_tx_ip_len <=#D icmp_top_tx_ip_len_reg;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_dst_ip <=#D 32'd0;
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	  icmp_top_tx_dst_ip <=#D icmp_top_tx_dst_ip_reg;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_dst_mac <=#D 47'd0;
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	  icmp_top_tx_dst_mac <=#D icmp_top_tx_dst_mac_reg;     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_byte_len <=#D 7'b0;                     
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	    icmp_byte_len <=#D ram_addr;                           
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    gen_icmp_reply_flag <=#D 1'b0;                     
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	    gen_icmp_reply_flag <=#D 1'b1;  
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == (icmp_byte_len + 7'd2)))begin
	    gen_icmp_reply_flag <=#D 1'b0;                                
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  gen_icmp_reply_cnt <=#D 7'b0;                     
    end else if(icmp_request_flag && icmp_top_rx_eop)begin
	  gen_icmp_reply_cnt <=#D 7'b0;  
    end else if(gen_icmp_reply_flag)begin
	  gen_icmp_reply_cnt <=#D gen_icmp_reply_cnt + 7'd1;       
    end else begin
      gen_icmp_reply_cnt <=#D 7'b0;                                   
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_sop <=#D 1'b0;    
    end else begin
	  icmp_top_tx_sop <=#D gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd0);
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  icmp_top_tx_eop <=#D 1'b0;    
    end else begin
	  icmp_top_tx_eop <=#D gen_icmp_reply_flag && (gen_icmp_reply_cnt == (icmp_byte_len + 7'd2)));
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_top_tx_vld <=#D 1'b0;    
    end else begin
	    icmp_top_tx_vld <=#D gen_icmp_reply_flag;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    ram_ren_flag <=#D 1'b0;    
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd2))begin
	    ram_ren_flag <=#D 1'b1; 
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == (icmp_byte_len + 7'd2)))begin
	    ram_ren_flag <=#D 1'b0;       
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    icmp_top_tx_dat <=#D 8'b0;    
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd0))begin
	    icmp_top_tx_dat <=#D 8'h00;
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd1))begin
	    icmp_top_tx_dat <=#D 8'h00;   
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd2))begin
	    icmp_top_tx_dat <=#D cal_check_dat[15:8];   
    end else if(gen_icmp_reply_flag && (gen_icmp_reply_cnt == 7'd3))begin
	    icmp_top_tx_dat <=#D cal_check_dat[7:0];  
    end else if(gen_icmp_reply_flag)begin
	    icmp_top_tx_dat <=#D ram_rdat;                    
    end
end

endmodule