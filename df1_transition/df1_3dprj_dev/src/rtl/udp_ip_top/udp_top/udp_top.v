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
module udp_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with  module   

///////////////////////////////////////////////////////receive
//interface with ip_top module        
input   wire   [31:0]   udp_top_rx_ip,    
input   wire   [47:0]   udp_top_rx_mac,
input   wire            udp_top_rx_sop,
input   wire            udp_top_rx_eop,
input   wire            udp_top_rx_vld,
input   wire   [7:0]    udp_top_rx_dat,

//interface with app_top module 
output  wire   [31:0]   recv_cmd_packet_src_ip,  
output  wire   [47:0]   recv_cmd_packet_src_mac,
output  wire   [15:0]   recv_cmd_packet_src_port,
output  wire            recv_cmd_packe_sop,
output  wire            recv_cmd_packe_eop,
output  wire            recv_cmd_packe_vld,
output  wire   [7:0]    recv_cmd_packe_dat,

output  wire   [31:0]   recv_heart_packet_src_ip,  

output  wire   [47:0]   recv_heart_packet_src_mac,
output  wire   [15:0]   recv_heart_packet_src_port,
output  wire            recv_heart_packe_sop,
output  wire            recv_heart_packe_eop,
output  wire            recv_heart_packe_vld,
output  wire   [7:0]    recv_heart_packe_dat,

//////
input   wire   [31:0]   lidar_connect_tar_ip,
input   wire   [47:0]   lidar_connect_tar_mac,
input   wire   [15:0]   cmd_tar_port,
input   wire   [15:0]   heart_tar_port,
input   wire   [15:0]   send_info_tar_port,
input   wire   [15:0]   Point_clound_tar_port,
input   wire   [15:0]   imu_tar_port,

///////////////////////////////////////////////////////transfer
input   wire            app_top_to_udp_top_request, 
input   wire   [2:0]    app_top_to_udp_top_type, 
input   wire   [26:0]   app_top_to_udp_top_check_data, 
input   wire   [15:0]   app_top_tx_length,

output  wire            udp_top_to_app_top_ack,

input   wire            app_top_to_udp_top_sop, 
input   wire            app_top_to_udp_top_eop, 
input   wire            app_top_to_udp_top_vld,  
input   wire   [7:0]    app_top_to_udp_top_dat    

output  wire   [31:0]   udp_top_tx_dst_ip,
output  wire   [47:0]   udp_top_tx_dst_mac,
output  wire   [15:0]   udp_top_tx_len,
output  wire            udp_top_tx_sop,
output  wire            udp_top_tx_eop,
output  wire            udp_top_tx_vld,
output  wire   [7:0]    udp_top_tx_dat

);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D          = 2;
/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg         [47:0]      lidar_mac_address_reg;
/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
udp_rx_top u_udp_rx_top (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    .udp_top_rx_ip        (udp_top_rx_ip),
    .udp_top_rx_mac       (udp_top_rx_mac),    
    .udp_top_rx_sop       (udp_top_rx_sop),
    .udp_top_rx_eop       (udp_top_rx_eop),
    .udp_top_rx_vld       (udp_top_rx_vld),
    .udp_top_rx_dat       (udp_top_rx_dat),    

    .recv_cmd_packet_src_ip   (recv_cmd_packet_src_ip), 
    .recv_cmd_packet_src_mac  (recv_cmd_packet_src_mac), 
    .recv_cmd_packet_src_port (recv_cmd_packet_src_port),
    .recv_cmd_packe_sop  (recv_cmd_packe_sop),
    .recv_cmd_packe_eop  (recv_cmd_packe_eop), 
    .recv_cmd_packe_vld  (recv_cmd_packe_vld), 
    .recv_cmd_packe_dat  (recv_cmd_packe_dat), 

    .recv_heart_packet_src_ip   (recv_heart_packet_src_ip), 
    .recv_heart_packet_src_mac  (recv_heart_packet_src_mac), 
    .recv_heart_packet_src_port (recv_heart_packet_src_port),     
    .recv_heart_packe_sop  (recv_heart_packe_sop),
    .recv_heart_packe_eop  (recv_heart_packe_eop), 
    .recv_heart_packe_vld  (recv_heart_packe_vld), 
    .recv_heart_packe_dat  (recv_heart_packe_dat)       

);

udp_tx_top u_udp_tx_top (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),

    .load_parameter_vld     (load_parameter_vld)
    .lidar_ip_address       (lidar_ip_address)
    
    //input
    .lidar_connect_tar_ip       (lidar_connect_tar_ip),
    .lidar_connect_tar_mac      (lidar_connect_tar_mac),
    .cmd_tar_port               (cmd_tar_port),
    .heart_tar_port             (heart_tar_port),        
    .send_info_tar_port         (send_info_tar_port),
    .Point_clound_tar_port      (Point_clound_tar_port),
    .imu_tar_port               (imu_tar_port),

    .app_top_to_udp_top_request (app_top_to_udp_top_request),
    .app_top_to_udp_top_type    (app_top_to_udp_top_type), 
    .udp_top_to_app_top_ack     (udp_top_to_app_top_ack),
    .app_top_to_udp_top_check_data  (app_top_to_udp_top_check_data), 
    .app_top_tx_length          (app_top_tx_length),

    .udp_top_tx_dst_ip  (udp_top_tx_dst_ip),
    .udp_top_tx_dst_mac (udp_top_tx_dst_mac),
    .udp_top_tx_len     (udp_top_tx_len),
    .udp_top_tx_sop     (udp_top_tx_sop),
    .udp_top_tx_eop     (udp_top_tx_eop),
    .udp_top_tx_vld     (udp_top_tx_vld),
    .udp_top_tx_dat     (udp_top_tx_dat)   

);


endmodule