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
module ip_top(
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

output  wire            arp_tx_sop,             
output  wire            arp_tx_eop,      
output  wire            arp_tx_vld,     
output  wire   [7:0]    arp_tx_dat,

output  wire            mac_packet_tx_sop,      //多字节数据，高字节优先, 字节内低比特优先
output  wire            mac_packet_tx_eop,      
output  wire            mac_packet_tx_vld,     
output  wire   [7:0]    mac_packet_tx_dat,

//interface with icmp_top module 
output  wire   [15:0]   ip_icmp_match_len, 
output  wire   [31:0]   ip_icmp_match_ip,
output  wire   [47:0]   ip_icmp_match_mac,
output  wire            icmp_top_rx_sop,
output  wire            icmp_top_rx_eop,
output  wire            icmp_top_rx_vld,
output  wire   [7:0]    icmp_top_rx_dat,

input   wire   [31:0]   icmp_top_tx_dst_ip,  
input   wire   [47:0]   icmp_top_tx_dst_mac,   
input   wire   [15:0]   icmp_top_tx_ip_len,  
input   wire            icmp_top_tx_sop,
input   wire            icmp_top_tx_eop,
input   wire            icmp_top_tx_vld,
input   wire   [7:0]    icmp_top_tx_dat,

//interface with udp_top module 
input   wire   [31:0]   udp_top_tx_dst_ip,  
input   wire   [47:0]   udp_top_tx_dst_mac,   
input   wire   [15:0]   udp_top_tx_len, 
input   wire            udp_top_tx_sop,       
input   wire            udp_top_tx_eop,
input   wire            udp_top_tx_vld,
input   wire   [7:0]    udp_top_tx_dat,

output  reg    [31:0]   udp_top_rx_ip,    // 用于确认UDP连接指令对应的目的IP和MAC; 
output  reg    [47:0]   udp_top_rx_mac,
output  reg             udp_top_rx_sop,
output  reg             udp_top_rx_eop,
output  reg             udp_top_rx_vld,
output  reg    [7:0]    udp_top_rx_dat
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;

/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/

/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
ip_rx_top u_ip_rx_top (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    //load parameter input
    .load_parameter_vld   (load_parameter_vld),
    .lidar_mac_address    (lidar_mac_address),
    .lidar_ip_address     (lidar_ip_address),

    //mac_top module input
    .mac_packet_rx_sop    (mac_packet_rx_sop),
    .mac_packet_rx_eop    (mac_packet_rx_eop),
    .mac_packet_rx_vld    (mac_packet_rx_vld),
    .mac_packet_rx_dat    (mac_packet_rx_dat),

    //output mac_top module
    .arp_tx_sop           (arp_tx_sop),
    .arp_tx_eop           (arp_tx_eop),
    .arp_tx_vld           (arp_tx_vld),
    .arp_tx_dat           (arp_tx_dat),

    //output icmp_top module
    .icmp_top_rx_sop      (icmp_top_rx_sop),
    .icmp_top_rx_eop      (icmp_top_rx_eop),
    .icmp_top_rx_vld      (icmp_top_rx_vld),
    .icmp_top_rx_dat      (icmp_top_rx_dat), 
    .ip_icmp_match_len    (ip_icmp_match_len),
    .ip_icmp_match_ip     (ip_icmp_match_ip),
    .ip_icmp_match_mac    (ip_icmp_match_mac),

   //output udp_top module
    .udp_top_rx_ip        (udp_top_rx_ip),
    .udp_top_rx_mac       (udp_top_rx_mac),    
    .udp_top_rx_sop       (udp_top_rx_sop),
    .udp_top_rx_eop       (udp_top_rx_eop),
    .udp_top_rx_vld       (udp_top_rx_vld),
    .udp_top_rx_dat       (udp_top_rx_dat)          

);

//internal mux_3_to_1 
ip_tx_top u_ip_tx_top (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    //input
    .icmp_top_tx_dst_ip   (icmp_top_tx_dst_ip),
    .icmp_top_tx_dst_mac  (icmp_top_tx_dst_mac),
    .icmp_top_tx_ip_len   (icmp_top_tx_ip_len),
    .icmp_top_tx_sop      (icmp_top_tx_sop),
    .icmp_top_tx_eop      (icmp_top_tx_eop),
    .icmp_top_tx_vld      (icmp_top_tx_vld),
    .icmp_top_tx_dat      (icmp_top_tx_dat),

    .udp_top_tx_dst_ip    (udp_top_tx_dst_ip),
    .udp_top_tx_dst_mac   (udp_top_tx_dst_mac),  
    .udp_top_tx_len       (udp_top_tx_len), 
    .udp_top_tx_sop       (udp_top_tx_sop),
    .udp_top_tx_eop       (udp_top_tx_eop),
    .udp_top_tx_vld       (udp_top_tx_vld),
    .udp_top_tx_dat       (udp_top_tx_dat),   

    //output
    .mac_packet_tx_sop    (mac_packet_tx_sop),
    .mac_packet_tx_eop    (mac_packet_tx_eop),
    .mac_packet_tx_vld    (mac_packet_tx_vld),
    .mac_packet_tx_dat    (mac_packet_tx_dat)     

);


endmodule