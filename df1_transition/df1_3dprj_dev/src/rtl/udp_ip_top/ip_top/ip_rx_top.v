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
module ip_rx_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with load_parameter_top module
input   wire            load_parameter_vld,
input   wire   [47:0]   lidar_mac_address,
input   wire   [47:0]   lidar_ip_address,

//interface with rmii_top module        
input   wire            mac_packet_rx_sop,      //多字节数据，高字节优先, 字节内低比特优先
input   wire            mac_packet_rx_eop,      
input   wire            mac_packet_rx_vld,      //连续输入
input   wire   [7:0]    mac_packet_rx_dat,

output  reg             arp_tx_sop,
output  reg             arp_tx_eop,
output  reg             arp_tx_vld,
output  reg    [7:0]    arp_tx_dat,

output  reg    [15:0]   ip_icmp_match_len, 
output  reg    [31:0]   ip_icmp_match_ip,
output  reg    [47:0]   ip_icmp_match_mac,

output  reg             icmp_top_rx_sop,
output  reg             icmp_top_rx_eop,
output  reg             icmp_top_rx_vld,
output  reg    [7:0]    icmp_top_rx_dat,

output  reg    [31:0]   udp_top_rx_ip,    // 用于确认UDP连接指令对应的目的IP和MAC; 
output  reg    [47:0]   udp_top_rx_mac,
output  reg             udp_top_rx_sop,
output  reg             udp_top_rx_eop,
output  reg             udp_top_rx_vld,
output  reg    [7:0]    udp_top_rx_dat,
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;

/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg         [47:0]      lidar_mac_address_reg;
reg         [31:0]      lidar_ip_address_reg;
reg         [3:0]       mac_head_cnt;

reg         [47:0]      mac_dst_mac_addr;
reg         [47:0]      mac_src_mac_addr;
reg         [15:0]      mac_type;

reg                     mac_arp_flag;
reg                     arp_packet_flag;
reg         [4:0]       arp_packet_cnt;
reg         [15:0]      arp_packet_hardware_type;
reg         [15:0]      arp_packet_protocol_type;
reg         [15:0]      arp_packet_operation_code;
reg         [47:0]      arp_packet_send_mac_addr;
reg         [31:0]      arp_packet_send_ip_addr;
reg         [31:0]      arp_packet_recv_ip_addr;
reg                     arp_packet_eop;
reg                     arp_match_lidar_vld;
reg         [47:0]      arp_match_mac_dst_mac_addr;
reg         [31:0]      arp_match_dst_ip_addr;

reg         [5:0]       arp_reply_packet_cnt;

reg                     pre_arp_tx_sop;
reg                     pre_arp_tx_eop;
reg                     pre_arp_tx_vld;
reg         [7:0]       pre_arp_tx_dat;

reg                     mac_ip_flag;
reg                     ip_packet_head_flag;
reg         [4:0]       ip_packet_head_cnt;
reg         [7:0]       ip_packet_head_data0;
reg         [7:0]       ip_packet_head_data1;
reg         [15:0]      ip_packet_head_data2;
reg         [15:0]      ip_packet_head_data3;
reg         [15:0]      ip_packet_head_data4;
reg         [7:0]       ip_packet_head_data5;
reg         [7:0]       ip_packet_head_data6;
reg         [31:0]      ip_packet_head_data8;
reg         [31:0]      ip_packet_head_data9;

reg         [11:0]      ip_data_cnt;
reg                     ip_data_flag;
reg                     ip_data_sop;
reg                     ip_data_eop;
reg                     ip_data_vld;
reg         [7:0]       ip_data_dat;
reg                     ip_data_first_byte_pulse;

reg                     ip_icmp_flag_0;
reg                     ip_icmp_flag_1;
reg                     ip_icmp_flag;
reg                     ip_icmp_match_pulse;

reg                     ip_udp_flag_0;
reg                     ip_udp_flag_1;
reg                     ip_udp_flag;
/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    lidar_mac_address_reg <=#D 48'd0;                     
    end else if(load_parameter_vld)begin
      lidar_mac_address_reg <=#D lidar_mac_address;                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    lidar_ip_address_reg <=#D 32'hc0_A8_01_F0;                     
    end else if(load_parameter_vld)begin
      lidar_ip_address_reg <=#D lidar_ip_address;                    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    mac_head_cnt <=#D 4'd0;                     
    end else if(mac_packet_rx_sop)begin
	    mac_head_cnt <=#D 4'd1;  
    end else if(mac_packet_rx_eop)begin
	    mac_head_cnt <=#D 4'd0;        
    end else if(mac_packet_rx_vld  && &mac_head_cnt)begin
	    mac_head_cnt <=#D mac_head_cnt;           
    end else if(mac_packet_rx_vld)begin
	    mac_head_cnt <=#D mac_head_cnt + 4'd1;                        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    mac_dst_mac_addr <=#D 48'd0;                     
    end else if(mac_packet_rx_sop)begin
      mac_dst_mac_addr[47:40] <=#D mac_packet_rx_dat;      
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd1))begin
      mac_dst_mac_addr[39:32] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd2))begin
      mac_dst_mac_addr[31:24] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd3))begin
      mac_dst_mac_addr[23:16] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd4))begin
      mac_dst_mac_addr[15:8] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd5))begin
      mac_dst_mac_addr[7:0] <=#D mac_packet_rx_dat;  
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    mac_src_mac_addr <=#D 48'd0;                     
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd6))begin
      mac_src_mac_addr[47:40] <=#D mac_packet_rx_dat;      
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd7))begin
      mac_src_mac_addr[39:32] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd8))begin
      mac_src_mac_addr[31:24] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd9))begin
      mac_src_mac_addr[23:16] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd10))begin
      mac_src_mac_addr[15:8] <=#D mac_packet_rx_dat;   
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd11))begin
      mac_src_mac_addr[7:0] <=#D mac_packet_rx_dat;  
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    mac_type <=#D 16'd0;                     
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd12))begin
      mac_type[15:8] <=#D mac_packet_rx_dat;      
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd13))begin
      mac_type[7:0] <=#D mac_packet_rx_dat;
    end
end

//arp part  start
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_arp_flag <=#D 1'd0;                       
    end else begin
		  mac_arp_flag <=#D mac_dst_mac_addr == 48'hff_ff_ff_ff_ff_ff;                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_flag <=#D 1'b0;         
    end else if(mac_packet_rx_eop)begin
		  arp_packet_flag <=#D 1'd0;                         
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd14) && mac_arp_flag && (mac_type == 16'h0806))begin
		  arp_packet_flag <=#D 1'b1;    
    end else if(arp_packet_flag  && (arp_packet_cnt==5'd27))begin
		  arp_packet_flag <=#D 1'b0;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_cnt <=#D 5'd0;
    end else if(mac_packet_rx_eop)begin
		  arp_packet_cnt <=#D 5'd0;        
    end else if(arp_packet_flag  && (arp_packet_cnt==5'd27))begin
		  arp_packet_cnt <=#D 5'd0;                                 
    end else if(arp_packet_flag)begin
		  arp_packet_cnt <=#D arp_packet_cnt + 5'd1;                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_hardware_type <=#D 16'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd0))begin
		  arp_packet_hardware_type[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd1))begin
		  arp_packet_hardware_type[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_protocol_type <=#D 16'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd2))begin
		  arp_packet_protocol_type[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd3))begin
		  arp_packet_protocol_type[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_operation_code <=#D 16'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd6))begin
		  arp_packet_operation_code[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd7))begin
		  arp_packet_operation_code[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_send_mac_addr <=#D 48'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd8))begin
		  arp_packet_send_mac_addr[47:40] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd9))begin
		  arp_packet_send_mac_addr[39:32] <=#D mac_packet_rx_dat;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd10))begin
		  arp_packet_send_mac_addr[31:24] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd11))begin
		  arp_packet_send_mac_addr[23:16] <=#D mac_packet_rx_dat;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd12))begin
		  arp_packet_send_mac_addr[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd13))begin
		  arp_packet_send_mac_addr[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_send_ip_addr <=#D 32'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd14))begin
		  arp_packet_send_ip_addr[31:24] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd15))begin
		  arp_packet_send_ip_addr[23:16] <=#D mac_packet_rx_dat;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd16))begin
		  arp_packet_send_ip_addr[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd17))begin
		  arp_packet_send_ip_addr[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_recv_ip_addr <=#D 32'd0;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd24))begin
		  arp_packet_recv_ip_addr[31:24] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd25))begin
		  arp_packet_recv_ip_addr[23:16] <=#D mac_packet_rx_dat;
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd26))begin
		  arp_packet_recv_ip_addr[15:8] <=#D mac_packet_rx_dat;   
    end else if(arp_packet_flag && (arp_packet_cnt == 5'd27))begin
		  arp_packet_recv_ip_addr[7:0] <=#D mac_packet_rx_dat;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_packet_eop <=#D 1'd0;
    end else begin
	  	arp_packet_eop <=#D arp_packet_flag && (arp_packet_cnt == 5'd27);
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_match_lidar_vld <=#D 1'b0;
    end else if(arp_packet_eop && (arp_packet_operation_code == 16'h0001) && (arp_packet_recv_ip_addr == lidar_ip_address_reg))begin
		  arp_match_lidar_vld <=#D 1'b1;
    end else begin
		  arp_match_lidar_vld <=#D 1'b0;       
    end
end


always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  arp_match_mac_dst_mac_addr <=#D 48'd0;
    end else if(arp_match_lidar_vld)begin
		  arp_match_mac_dst_mac_addr <=#D mac_src_mac_addr;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_match_dst_ip_addr <=#D 32'd0;
    end else if(arp_match_lidar_vld)begin
		 arp_match_dst_ip_addr <=#D arp_packet_send_ip_addr;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_reply_packet_flag <=#D 1'b0;
    end else if(~arp_reply_packet_flag && arp_match_lidar_vld)begin
		 arp_reply_packet_flag <=#D 1'b1;
    end else if( arp_reply_packet_flag && (arp_reply_packet_cnt == 6'd59))begin
		 arp_reply_packet_flag <=#D 1'b0;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_reply_packet_cnt <=#D 6'd0;
    end else if(~arp_reply_packet_flag && arp_match_lidar_vld)begin
		 arp_reply_packet_cnt <=#D 6'd0;
    end else if( arp_reply_packet_flag)begin
		 arp_reply_packet_cnt <=#D arp_reply_packet_cnt + 6'b1;    
    end else begin
		 arp_reply_packet_cnt <=#D 6'd0;             
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 pre_arp_tx_sop <=#D 1'b0;
    end else begin
		 pre_arp_tx_sop <=#D arp_reply_packet_flag && (arp_reply_packet_cnt == 6'd0);        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 pre_arp_tx_eop <=#D 1'b0;
    end else begin
		 pre_arp_tx_eop <=#D arp_reply_packet_flag && (arp_reply_packet_cnt == 6'd59);        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 pre_arp_tx_vld <=#D 1'b0;
    end else begin
		 pre_arp_tx_vld <=#D arp_reply_packet_flag;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 pre_arp_tx_dat <=#D 8'b0;
    end else if(arp_reply_packet_flag)begin
        case(arp_reply_packet_cnt)
	  	 6'd0: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[47:40]; 
	  	 6'd1: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[39:32]; 
	  	 6'd2: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[31:24]; 
	  	 6'd3: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[23:16]; 
	  	 6'd4: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[15:8]; 
	  	 6'd5: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[7:0]; 
	  	 6'd6: pre_arp_tx_dat <=#D  lidar_mac_address_reg[47:40]; 
	  	 6'd7: pre_arp_tx_dat <=#D  lidar_mac_address_reg[39:32]; 
	  	 6'd8: pre_arp_tx_dat <=#D  lidar_mac_address_reg[31:24]; 
	  	 6'd9: pre_arp_tx_dat <=#D  lidar_mac_address_reg[23:16];   
	  	 6'd10: pre_arp_tx_dat <=#D lidar_mac_address_reg[15:8]; 
	  	 6'd11: pre_arp_tx_dat <=#D lidar_mac_address_reg[7:0]; 

	  	 6'd12: pre_arp_tx_dat <=#D 8'h08; 
	  	 6'd13: pre_arp_tx_dat <=#D 8'h06;
	  	 6'd14: pre_arp_tx_dat <=#D 8'h00;
	  	 6'd15: pre_arp_tx_dat <=#D 8'h01;
	  	 6'd16: pre_arp_tx_dat <=#D 8'h08; 
	  	 6'd17: pre_arp_tx_dat <=#D 8'h00;  
	  	 6'd18: pre_arp_tx_dat <=#D 8'h06; 
	  	 6'd19: pre_arp_tx_dat <=#D 8'h04; 
	  	 6'd20: pre_arp_tx_dat <=#D 8'h00; 
	  	 6'd21: pre_arp_tx_dat <=#D 8'h02; 

	  	 6'd22: pre_arp_tx_dat <=#D lidar_mac_address_reg[47:40];
	  	 6'd23: pre_arp_tx_dat <=#D lidar_mac_address_reg[39:32];
	  	 6'd24: pre_arp_tx_dat <=#D lidar_mac_address_reg[31:24];
	  	 6'd25: pre_arp_tx_dat <=#D lidar_mac_address_reg[23:16];
	  	 6'd26: pre_arp_tx_dat <=#D lidar_mac_address_reg[15:8]; 
	  	 6'd27: pre_arp_tx_dat <=#D lidar_mac_address_reg[7:0]; 

	  	 6'd28: pre_arp_tx_dat <=#D lidar_mac_ip_reg[31:24];
	  	 6'd29: pre_arp_tx_dat <=#D lidar_mac_ip_reg[23:16];
	  	 6'd30: pre_arp_tx_dat <=#D lidar_mac_ip_reg[15:8]; 
	  	 6'd31: pre_arp_tx_dat <=#D lidar_mac_ip_reg[7:0];                            

	  	 6'd32: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[47:40];
	  	 6'd33: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[39:32];
	  	 6'd34: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[31:24];
	  	 6'd35: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[23:16];
	  	 6'd36: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[15:8]; 
	  	 6'd37: pre_arp_tx_dat <=#D arp_match_mac_dst_mac_addr[7:0]; 

	  	 6'd38: pre_arp_tx_dat <=#D arp_match_dst_ip_addr[31:24];
	  	 6'd39: pre_arp_tx_dat <=#D arp_match_dst_ip_addr[23:16];
	  	 6'd40: pre_arp_tx_dat <=#D arp_match_dst_ip_addr[15:8]; 
	  	 6'd41: pre_arp_tx_dat <=#D arp_match_dst_ip_addr[7:0];

	  	 default: pre_arp_tx_dat <=#D 8'h00;                                                                                                                                                                                                                                                                    
        endcase
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_tx_sop <=#D 1'b0;
    end else begin
		 arp_tx_sop <=#D pre_arp_tx_sop;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_tx_eop <=#D 1'b0;
    end else begin
		 arp_tx_eop <=#D pre_arp_tx_eop;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_tx_vld <=#D 1'b0;
    end else begin
		 arp_tx_vld <=#D pre_arp_tx_vld;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 arp_tx_dat <=#D 8'b0;
    end else begin
		 arp_tx_dat <=#D pre_arp_tx_dat;        
    end
end

//arp part  end
/////ip part start
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_ip_flag <=#D 1'd0;                       
    end else begin
		  mac_ip_flag <=#D mac_dst_mac_addr == lidar_mac_address_reg;                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_packet_head_flag <=#D 1'b0;         
    end else if(mac_packet_rx_eop)begin
		  ip_packet_head_flag <=#D 1'd0;                         
    end else if(mac_packet_rx_vld  && (mac_head_cnt==4'd14) && mac_ip_flag && (mac_type == 16'h0800))begin
		  ip_packet_head_flag <=#D 1'b1;    
    end else if(ip_packet_head_flag && mac_packet_rx_vld  && (ip_packet_head_cnt == 5'd19))begin
		  ip_packet_head_flag <=#D 1'b0;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_packet_head_cnt <=#D 5'b0;         
    end else if(mac_packet_rx_eop)begin
		  ip_packet_head_cnt <=#D 5'd0;                         
    end else if(ip_packet_head_flag && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd19))begin
		  ip_packet_head_cnt <=#D 5'b0;    
    end else if(ip_packet_head_flag && mac_packet_rx_vld)begin
		  ip_packet_head_cnt <=#D ip_packet_head_cnt + 5'd1;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_packet_head_data0 <=#D 8'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd0))begin
		  ip_packet_head_data0 <=#D 8'b0;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data1 <=#D 8'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd1))begin
		 ip_packet_head_data1 <=#D 8'b0;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data2 <=#D 16'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd2))begin
		 ip_packet_head_data2[15:8] <=#D mac_packet_rx_dat;      
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd3))begin
		 ip_packet_head_data2[7:0] <=#D mac_packet_rx_dat;                                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data3 <=#D 16'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd4))begin
		 ip_packet_head_data3[15:8] <=#D mac_packet_rx_dat;      
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd5))begin
		 ip_packet_head_data3[7:0] <=#D mac_packet_rx_dat;                                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data4 <=#D 16'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd6))begin
		 ip_packet_head_data4[15:8] <=#D mac_packet_rx_dat;      
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd7))begin
		 ip_packet_head_data4[7:0] <=#D mac_packet_rx_dat;                                      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data5 <=#D 8'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd8))begin
		 ip_packet_head_data5 <=#D mac_packet_rx_dat;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data6 <=#D 8'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd9))begin
		 ip_packet_head_data6 <=#D mac_packet_rx_dat;                               
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data8 <=#D 32'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd12))begin
		 ip_packet_head_data8[31:24] <=#D mac_packet_rx_dat;  
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd13))begin
		 ip_packet_head_data8[23:16] <=#D mac_packet_rx_dat;
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd14))begin
		 ip_packet_head_data8[15:8] <=#D mac_packet_rx_dat;
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd15))begin
		 ip_packet_head_data8[7:0] <=#D mac_packet_rx_dat;                                                     
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		 ip_packet_head_data9 <=#D 32'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd16))begin
		 ip_packet_head_data9[31:24] <=#D mac_packet_rx_dat;  
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd17))begin
		 ip_packet_head_data9[23:16] <=#D mac_packet_rx_dat;
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd18))begin
		 ip_packet_head_data9[15:8] <=#D mac_packet_rx_dat;
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd19))begin
		 ip_packet_head_data9[7:0] <=#D mac_packet_rx_dat;                                                     
    end
end

////ip_data part start
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_cnt <=#D 12'd0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd19))begin
		  ip_data_cnt <=#D 12'd0; 
    end else if(mac_packet_rx_vld && (ip_data_cnt == (ip_packet_head_data2-16'd21)))begin
		  ip_data_cnt <=#D 12'd0;             
    end else if(mac_packet_rx_vld)begin
		  ip_data_cnt <=#D ip_data_cnt + 12'd1;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_flag <=#D 1'd0;                       
    end else if(mac_packet_rx_eop)begin
		  ip_data_flag <=#D 1'd0;        
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd19))begin
		  ip_data_flag <=#D 1'd1;                         
    end else if(mac_packet_rx_vld && (ip_data_cnt == (ip_packet_head_data2-16'd21)))begin
		  ip_data_flag <=#D 1'd0;          
    end
end

// align with f0_mac_packet_rx_vld
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_sop <=#D 1'd0;                       
    end else if(ip_data_flag && mac_packet_rx_vld && (ip_data_cnt == 12'd0))begin
		  ip_data_sop <=#D 1'd1;     
    end else begin
		  ip_data_sop <=#D 1'd0;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_eop <=#D 1'd0;                       
    end else if(ip_data_flag && mac_packet_rx_vld && (ip_data_cnt == (ip_packet_head_data2-16'd21)))begin
		  ip_data_eop <=#D 1'd1;     
    end else begin
		  ip_data_eop <=#D 1'd0;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_vld <=#D 1'd0;                       
    end else begin
		  ip_data_vld <=#D ip_data_flag && mac_packet_rx_vld;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_dat <=#D 8'd0;                       
    end else begin
		  ip_data_dat <=#D mac_packet_rx_dat;                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_data_first_byte_pulse <=#D 1'b0;                       
    end else if(ip_packet_head_flag  && mac_packet_rx_vld && (ip_packet_head_cnt == 5'd19))begin
		  ip_data_first_byte_pulse <=#D 1'b1;    
    end else begin
		  ip_data_first_byte_pulse <=#D 1'b0;                             
    end
end
////ip data part end

/////////////////////////////        icmp part start
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_flag_0 <=#D 1'd0;                       
    end else begin
		  ip_icmp_flag_0 <=#D ip_packet_head_data0==8'h0405;                          
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_flag_1 <=#D 1'd0;                       
    end else begin
		  ip_icmp_flag_1 <=#D ip_packet_head_data6==8'h01;                          
    end
end

// align with f0_mac_packet_rx_vld
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_flag <=#D 1'b0;                       
    end else if(ip_data_first_byte_pulse && ip_icmp_flag_0 && ip_icmp_flag_1 && (ip_packet_head_data9 == lidar_ip_address_reg))begin
		  ip_icmp_flag <=#D 1'b1;    
    end else if(ip_data_eop)begin
		  ip_icmp_flag <=#D 1'b0;                             
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_match_pulse <=#D 1'b0;                       
    end else if(ip_data_first_byte_pulse && ip_icmp_flag_0 && ip_icmp_flag_1 && (ip_packet_head_data9 == lidar_ip_address_reg))begin
		  ip_icmp_match_pulse <=#D 1'b1;    
    end else begin
		  ip_icmp_match_pulse <=#D 1'b0;                             
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_match_len <=#D 16'b0;                       
    end else if(ip_icmp_match_pulse)begin
		  ip_icmp_match_len <=#D ip_packet_head_data2;                                
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_match_mac <=#D 48'b0;                       
    end else if(ip_icmp_match_pulse)begin
		  ip_icmp_match_mac <=#D mac_src_mac_addr;                                
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_icmp_match_ip <=#D 32'b0;                       
    end else if(ip_icmp_match_pulse)begin
		  ip_icmp_match_ip <=#D ip_packet_head_data8;                                
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  icmp_top_rx_sop <=#D 1'd0;                       
    end else begin
		  icmp_top_rx_sop <=#D ip_icmp_flag && ip_data_sop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  icmp_top_rx_eop <=#D 1'd0;                       
    end else begin
		  icmp_top_rx_eop <=#D ip_icmp_flag && ip_data_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  icmp_top_rx_vld <=#D 1'd0;                       
    end else begin
		  icmp_top_rx_vld <=#D ip_icmp_flag && ip_data_vd;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  icmp_top_rx_dat <=#D 16'd0;                       
    end else begin
		  icmp_top_rx_dat <=#D ip_data_dat;
    end
end

//////////                           icmp part end

/////////////////////////////        udp part start
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_udp_flag_0 <=#D 1'd0;                       
    end else begin
		  ip_udp_flag_0 <=#D ip_packet_head_data0==8'h0405;                          
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_udp_flag_1 <=#D 1'd0;                       
    end else begin
		  ip_udp_flag_1 <=#D ip_packet_head_data6==8'd17;                          
    end
end

// align with f0_mac_packet_rx_vld
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  ip_udp_flag <=#D 1'b0;                       
    end else if(ip_data_first_byte_pulse && ip_udp_flag_0 && ip_udp_flag_1 && (ip_packet_head_data9 == lidar_ip_address_reg))begin
		  ip_udp_flag <=#D 1'b1;    
    end else if(ip_data_eop)begin
		  ip_udp_flag <=#D 1'b0;                             
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_mac <=#D 48'd0;                       
    end else if(ip_udp_flag && ip_data_sop)begin
		  udp_top_rx_mac <=#D mac_src_mac_addr;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_ip <=#D 32'd0;                       
    end else if(ip_udp_flag && ip_data_sop)begin
		  udp_top_rx_ip <=#D ip_packet_head_data8;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_sop <=#D 1'd0;                       
    end else begin
		  udp_top_rx_sop <=#D ip_udp_flag && ip_data_sop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_eop <=#D 1'd0;                       
    end else begin
		  udp_top_rx_eop <=#D ip_udp_flag && ip_data_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_vld <=#D 1'd0;                       
    end else begin
		  udp_top_rx_vld <=#D ip_udp_flag && ip_data_vd;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_top_rx_dat <=#D 16'd0;                       
    end else begin
		  udp_top_rx_dat <=#D ip_data_dat;
    end
end

//////////                           udp part end

endmodule