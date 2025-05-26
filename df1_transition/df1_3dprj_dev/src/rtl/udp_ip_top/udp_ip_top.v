// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: udp_ip_top
// Date Created 	: 2024/10/14
// Version 			: V1.1
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:   
 1: 在接入请求中指明对方端口;
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
// -------------------------------------------------------------------------------------------------
// File description	:udp_ip_top
//            receive mac packet
// -------------------------------------------------------------------------------------------------
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module udp_ip_top(
    input                   	i_clk,
    input                   	i_rst_n,

    //interface with rmii_top module
    input                   	i_rmii_rx_vld,
    input  [1:0]            	i_rmii_rx_dat,

    output                  	o_rmii_tx_vld,
    output [1:0]            	o_rmii_tx_dat,

    //interface with load_parameter_top module
    input                   	i_load_parameter_vld,
    input  [47:0]           	i_lidar_mac_address,
    input  [47:0]           	i_lidar_ip_address,

    //interface with app_top module 
    output [31:0]           	o_lidar_ip_address,  
    output [47:0]           	o_recv_cmd_packet_src_mac,
    output [15:0]           	o_recv_cmd_packet_src_port,
    output                  	o_recv_cmd_packe_sop,
    output                  	o_recv_cmd_packe_eop,
    output                  	o_recv_cmd_packe_vld,
    output [7:0]            	o_recv_cmd_packe_dat,

    output [31:0]          		o_recv_heart_packet_src_ip,  
    output [47:0]          		o_recv_heart_packet_src_mac,
    output [47:0]          		o_recv_heart_packet_src_port,
    output                 		o_recv_heart_packe_sop,
    output                 		o_recv_heart_packe_eop,
    output                 		o_recv_heart_packe_vld,
    output [7:0]           		o_recv_heart_packe_dat,

    input  [31:0]           	i_lidar_connect_tar_ip,
    input  [47:0]           	i_lidar_connect_tar_mac,
    input  [15:0]           	i_cmd_tar_port,
    input  [15:0]           	i_heart_tar_port,
    input  [15:0]           	i_send_info_tar_port,
    input  [15:0]           	i_Point_clound_tar_port,
    input  [15:0]           	i_imu_tar_port,

    input                  		i_app_top_to_udp_top_request, 
    input  [2:0]           		i_app_top_to_udp_top_type, 
    input  [26:0]          		i_app_top_to_udp_top_check_data, 
    input  [15:0]          		i_app_top_tx_length,
    
    output                  	o_udp_top_to_app_top_ack,

    input                   	i_app_top_to_udp_top_sop, 
    input                   	i_app_top_to_udp_top_eop, 
    input                   	i_app_top_to_udp_top_vld,  
    input  [7:0]            	i_app_top_to_udp_top_dat       
);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
    parameter D = 2;

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    wire                    	w_mac_packet_rx_sop;
    wire                    	w_mac_packet_rx_eop;
    wire                    	w_mac_packet_rx_vld;
    wire [7:0]              	w_mac_packet_rx_dat;

	wire            			w_arp_tx_sop;
	wire            			w_arp_tx_eop;
	wire            			w_arp_tx_vld;
	wire [7:0]    				w_arp_tx_dat;

    wire                    	w_mac_packet_tx_sop;
    wire                    	w_mac_packet_tx_eop;
    wire                    	w_mac_packet_tx_vld;
    wire [7:0]              	w_mac_packet_tx_dat;

    wire                    	udp_top_rx_sop;
    wire                    	udp_top_rx_eop;
    wire                    	udp_top_rx_vld;
    wire [7:0]              	udp_top_rx_dat;

    wire                    	icmp_top_rx_sop;
    wire                    	icmp_top_rx_eop;
    wire                    	icmp_top_rx_vld;
    wire [7:0]              	icmp_top_rx_dat;

    wire                    	udp_top_tx_sop;
    wire                    	udp_top_tx_eop;
    wire                    	udp_top_tx_vld;
    wire [7:0]              	udp_top_tx_dat;

    wire                    	icmp_top_tx_sop;
    wire                    	icmp_top_tx_eop;
    wire                    	icmp_top_tx_vld;
    wire [7:0]              	icmp_top_tx_dat;
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
    mac_top u_mac_top (
        .i_clk                  ( i_clk                  	),
        .i_rst_n                ( i_rst_n                	),
	
        //input 	
        .i_rmii_rx_vld          ( i_rmii_rx_vld          	),
        .i_rmii_rx_dat          ( i_rmii_rx_dat          	),
	
        //output 	
        .o_mac_packet_rx_sop    ( w_mac_packet_rx_sop    	),
        .o_mac_packet_rx_eop    ( w_mac_packet_rx_eop    	),
        .o_mac_packet_rx_vld    ( w_mac_packet_rx_vld    	),
        .o_mac_packet_rx_dat    ( w_mac_packet_rx_dat    	),
 
        //input 
        .i_arp_tx_sop			( w_arp_tx_sop				),
        .i_arp_tx_eop			( w_arp_tx_eop				),
        .i_arp_tx_vld			( w_arp_tx_vld				),
        .i_arp_tx_dat			( w_arp_tx_dat				),
 
	    .i_mac_packet_tx_sop	( w_mac_packet_tx_sop		),
        .i_mac_packet_tx_eop	( w_mac_packet_tx_eop		),
        .i_mac_packet_tx_vld	( w_mac_packet_tx_vld		),
        .i_mac_packet_tx_dat	( w_mac_packet_tx_dat		),
	
        //output 	
        .o_rmii_tx_vld          ( o_rmii_tx_vld				),
        .o_rmii_tx_dat          ( o_rmii_tx_dat				)
    );
/*
    ip_top u_ip_top (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),

        //interface with  load parameter 
        .i_load_parameter_vld   (i_load_parameter_vld),
        .i_lidar_mac_address    (i_lidar_mac_address),
        .i_lidar_ip_address     (i_lidar_ip_address),

        //interface with mac_top
        .w_mac_packet_rx_sop    (w_mac_packet_rx_sop),
        .w_mac_packet_rx_eop    (w_mac_packet_rx_eop),
        .w_mac_packet_rx_vld    (w_mac_packet_rx_vld),
        .w_mac_packet_rx_dat    (w_mac_packet_rx_dat),     

        .w_mac_packet_tx_sop    (w_mac_packet_tx_sop),
        .w_mac_packet_tx_eop    (w_mac_packet_tx_eop),
        .w_mac_packet_tx_vld    (w_mac_packet_tx_vld),
        .w_mac_packet_tx_dat    (w_mac_packet_tx_dat),

        .w_arp_tx_sop           (w_arp_tx_sop),
        .w_arp_tx_eop           (w_arp_tx_eop),
        .w_arp_tx_vld           (w_arp_tx_vld),
        .w_arp_tx_dat           (w_arp_tx_dat),    

        //interface with mac_top
        .ip_icmp_match_len    (ip_icmp_match_len),
        .ip_icmp_match_ip     (ip_icmp_match_ip),
        .ip_icmp_match_mac    (ip_icmp_match_mac),  
        .icmp_top_rx_sop      (icmp_top_rx_sop),
        .icmp_top_rx_eop      (icmp_top_rx_eop),
        .icmp_top_rx_vld      (icmp_top_rx_vld),
        .icmp_top_rx_dat      (icmp_top_rx_dat),
    
        .icmp_top_tx_dst_ip   (icmp_top_tx_dst_ip),
        .icmp_top_tx_dst_mac  (icmp_top_tx_dst_mac),
        .icmp_top_tx_ip_len   (icmp_top_tx_ip_len),
        .icmp_top_tx_sop      (icmp_top_tx_sop),
        .icmp_top_tx_eop      (icmp_top_tx_eop),
        .icmp_top_tx_vld      (icmp_top_tx_vld),
        .icmp_top_tx_dat      (icmp_top_tx_dat),

        //interface with udp_top
        .udp_top_rx_ip        (udp_top_rx_ip),
        .udp_top_rx_mac       (udp_top_rx_mac),      
        .udp_top_rx_sop       (udp_top_rx_sop),
        .udp_top_rx_eop       (udp_top_rx_eop),
        .udp_top_rx_vld       (udp_top_rx_vld),
        .udp_top_rx_dat       (udp_top_rx_dat), 

        .udp_top_tx_dst_ip    (udp_top_tx_dst_ip),
        .udp_top_tx_dst_mac   (udp_top_tx_dst_mac),  
        .udp_top_tx_len       (udp_top_tx_len), 
        .udp_top_tx_sop       (udp_top_tx_sop),
        .udp_top_tx_eop       (udp_top_tx_eop),
        .udp_top_tx_vld       (udp_top_tx_vld),
        .udp_top_tx_dat       (udp_top_tx_dat)

    );

    icmp_top u_icmp_top (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),

        //input
        .ip_icmp_match_len    (ip_icmp_match_len),
        .ip_icmp_match_ip     (ip_icmp_match_ip),
        .ip_icmp_match_mac    (ip_icmp_match_mac),  
        .icmp_top_rx_sop      (icmp_top_rx_sop),
        .icmp_top_rx_eop      (icmp_top_rx_eop),
        .icmp_top_rx_vld      (icmp_top_rx_vld),
        .icmp_top_rx_dat      (icmp_top_rx_dat),
    
        //output  
        .icmp_top_tx_ip_len   (icmp_top_tx_ip_len),    
        .icmp_top_tx_dst_ip   (icmp_top_tx_dst_ip),
        .icmp_top_tx_dst_mac  (icmp_top_tx_dst_mac),
        .icmp_top_tx_sop      (icmp_top_tx_sop),
        .icmp_top_tx_eop      (icmp_top_tx_eop),
        .icmp_top_tx_vld      (icmp_top_tx_vld),
        .icmp_top_tx_dat      (icmp_top_tx_dat)
    );

    udp_top u_udp_top (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),

        //udp_top output app_top
        .udp_top_rx_ip        (udp_top_rx_ip),
        .udp_top_rx_mac       (udp_top_rx_mac),    
        .udp_top_rx_sop       (udp_top_rx_sop),
        .udp_top_rx_eop       (udp_top_rx_eop),
        .udp_top_rx_vld       (udp_top_rx_vld),
        .udp_top_rx_dat       (udp_top_rx_dat),

        //udp_top output ip_top
        .udp_top_tx_dst_ip    (udp_top_tx_dst_ip),
        .udp_top_tx_dst_mac   (udp_top_tx_dst_mac),  
        .udp_top_tx_len       (udp_top_tx_len),     
        .udp_top_tx_sop       (udp_top_tx_sop),
        .udp_top_tx_eop       (udp_top_tx_eop),
        .udp_top_tx_vld       (udp_top_tx_vld),
        .udp_top_tx_dat       (udp_top_tx_dat),    

        //udp_top output app_top
        .o_lidar_ip_address   (o_lidar_ip_address), 
        .o_recv_cmd_packet_src_mac  (o_recv_cmd_packet_src_mac), 
        .o_recv_cmd_packet_src_port (o_recv_cmd_packet_src_port),
        .o_recv_cmd_packe_sop  (o_recv_cmd_packe_sop),
        .o_recv_cmd_packe_eop  (o_recv_cmd_packe_eop), 
        .o_recv_cmd_packe_vld  (o_recv_cmd_packe_vld), 
        .o_recv_cmd_packe_dat  (o_recv_cmd_packe_dat), 

        .o_recv_heart_packet_src_ip   (o_recv_heart_packet_src_ip), 
        .o_recv_heart_packet_src_mac  (o_recv_heart_packet_src_mac), 
        .o_recv_heart_packet_src_port (o_recv_heart_packet_src_port),     
        .o_recv_heart_packe_sop  (o_recv_heart_packe_sop),
        .o_recv_heart_packe_eop  (o_recv_heart_packe_eop), 
        .o_recv_heart_packe_vld  (o_recv_heart_packe_vld), 
        .o_recv_heart_packe_dat  (o_recv_heart_packe_dat),     

        //app_top output app_top
        .i_lidar_connect_tar_ip       (i_lidar_connect_tar_ip),
        .i_lidar_connect_tar_mac      (i_lidar_connect_tar_mac),
        .i_cmd_tar_port               (i_cmd_tar_port),
        .i_heart_tar_port             (i_heart_tar_port),      
        .i_send_info_tar_port         (i_send_info_tar_port),
        .i_Point_clound_tar_port      (i_Point_clound_tar_port),
        .i_imu_tar_port               (i_imu_tar_port),

        .i_app_top_to_udp_top_request (i_app_top_to_udp_top_request),
        .i_app_top_to_udp_top_type    (i_app_top_to_udp_top_type), 
        .o_udp_top_to_app_top_ack     (o_udp_top_to_app_top_ack),
        .i_app_top_to_udp_top_check_data  (i_app_top_to_udp_top_check_data), 
        .i_app_top_tx_length          (i_app_top_tx_length),

        .i_app_top_to_udp_top_sop     (i_app_top_to_udp_top_sop),
        .i_app_top_to_udp_top_eop     (i_app_top_to_udp_top_eop),
        .i_app_top_to_udp_top_vld     (i_app_top_to_udp_top_vld),
        .i_app_top_to_udp_top_dat     (i_app_top_to_udp_top_dat)


    );
*/

endmodule
