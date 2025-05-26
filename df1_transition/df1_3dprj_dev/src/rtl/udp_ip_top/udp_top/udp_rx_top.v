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
module udp_rx_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with ip_top module        
input   wire   [31:0]   udp_top_rx_ip,
input   wire   [47:0]   udp_top_rx_mac,
input   wire            udp_top_rx_sop,
input   wire            udp_top_rx_eop,
input   wire            udp_top_rx_vld,
input   wire   [7:0]    udp_top_rx_dat,

//interface with app_top module 
output  reg    [31:0]   recv_cmd_packet_src_ip,  
output  reg    [47:0]   recv_cmd_packet_src_mac,
output  reg    [15:0]   recv_cmd_packet_src_port,
output  reg             recv_cmd_packe_sop,
output  reg             recv_cmd_packe_eop,
output  reg             recv_cmd_packe_vld,
output  reg    [7:0]    recv_cmd_packe_dat,

output  reg    [31:0]   recv_heart_packet_src_ip,  
output  reg    [47:0]   recv_heart_packet_src_mac,
output  reg    [15:0]   recv_heart_packet_src_port,
output  reg             recv_heart_packe_sop,
output  reg             recv_heart_packe_eop,
output  reg             recv_heart_packe_vld,
output  reg    [7:0]    recv_heart_packe_dat
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
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_rx_ip_reg <=#D 32'd0;
    end else if(udp_top_rx_sop)begin
      udp_top_rx_ip_reg <=#D udp_top_rx_ip;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_rx_mac_reg <=#D 48'd0;
    end else if(udp_top_rx_sop)begin
      udp_top_rx_mac_reg <=#D udp_top_rx_mac;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  f0_udp_top_rx_sop <=#D 1'd0; 
		  f1_udp_top_rx_sop <=#D 1'd0; 
		  f2_udp_top_rx_sop <=#D 1'd0; 
		  f3_udp_top_rx_sop <=#D 1'd0;  
		  f4_udp_top_rx_sop <=#D 1'd0; 
		  f5_udp_top_rx_sop <=#D 1'd0;                                                    
    end else begin
		  f0_udp_top_rx_sop <=#D udp_top_rx_sop;
		  f1_udp_top_rx_sop <=#D f0_udp_top_rx_sop;
		  f2_udp_top_rx_sop <=#D f1_udp_top_rx_sop;
		  f3_udp_top_rx_sop <=#D f2_udp_top_rx_sop;   
		  f3_udp_top_rx_sop <=#D f3_udp_top_rx_sop; 
		  f4_udp_top_rx_sop <=#D f4_udp_top_rx_sop;                            
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_src_port <=#D 16'b0;                       
    end else if(udp_top_rx_sop)begin
		  udp_src_port[15:8] <=#D udp_top_rx_dat;
    end else if(f0_udp_top_rx_sop)begin
		  udp_src_port[7:0] <=#D udp_top_rx_dat;    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  udp_dst_port <=#D 16'b0;                       
    end else if(f1_udp_top_rx_sop)begin
		  udp_dst_port[15:8] <=#D udp_top_rx_dat;
    end else if(f2_udp_top_rx_sop)begin
		  udp_dst_port[7:0] <=#D udp_top_rx_dat;    
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  cmd_packet_flag <=#D 1'b0;                       
    end else if(~cmd_packet_flag && f6_udp_top_rx_sop && (udp_dst_port == 16'd55100))begin
		  cmd_packet_flag <=#D 1'b1;
    end else if( cmd_packet_flag && udp_top_rx_eop)begin
		  cmd_packet_flag <=#D 1'b0;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  heart_packet_flag <=#D 1'b0;                       
    end else if(~heart_packet_flag && f6_udp_top_rx_sop && (udp_dst_port == 8'd55600))begin
		  heart_packet_flag <=#D 1'b1;
    end else if( heart_packet_flag && udp_top_rx_eop)begin
		  heart_packet_flag <=#D 1'b0;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packet_src_ip <=#D 32'd0;
    end else if(cmd_packet_flag && f7_udp_top_rx_sop)begin
      recv_cmd_packet_src_ip <=#D udp_top_rx_ip_reg;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packet_src_mac <=#D 48'd0;
    end else if(cmd_packet_flag && f7_udp_top_rx_sop)begin
      recv_cmd_packet_src_mac <=#D udp_top_rx_mac_reg;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packet_src_port <=#D 16'd0;
    end else if(cmd_packet_flag && f7_udp_top_rx_sop)begin
      recv_cmd_packet_src_port <=#D udp_src_port;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packe_sop <=#D 1'd0;
    end else begin
      recv_cmd_packe_sop <=#D cmd_packet_flag && f7_udp_top_rx_sop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packe_eop <=#D 1'd0;
    end else begin
      recv_cmd_packe_eop <=#D cmd_packet_flag && udp_top_rx_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packe_vld <=#D 1'd0;
    end else begin
      recv_cmd_packe_vld <=#D cmd_packet_flag && udp_top_rx_vld;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_cmd_packe_dat <=#D 8'd0;
    end else begin
      recv_cmd_packe_dat <=#D  udp_top_rx_dat;
    end
end

///////////////////////////////////////////////////////////////////////
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packet_src_ip <=#D 32'd0;
    end else if(heart_packet_flag && f7_udp_top_rx_sop)begin
      recv_heart_packet_src_ip <=#D udp_top_rx_ip_reg;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packet_src_mac <=#D 48'd0;
    end else if(heart_packet_flag && f7_udp_top_rx_sop)begin
      recv_heart_packet_src_mac <=#D udp_top_rx_mac_reg;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packet_src_port <=#D 16'd0;
    end else if(heart_packet_flag && f7_udp_top_rx_sop)begin
      recv_heart_packet_src_port <=#D udp_src_port;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packe_sop <=#D 1'd0;
    end else begin
      recv_heart_packe_sop <=#D heart_packet_flag && f7_udp_top_rx_sop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packe_eop <=#D 1'd0;
    end else begin
      recv_heart_packe_eop <=#D heart_packet_flag && udp_top_rx_eop;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packe_vld <=#D 1'd0;
    end else begin
      recv_heart_packe_vld <=#D heart_packet_flag && udp_top_rx_vld;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    recv_heart_packe_dat <=#D 8'd0;
    end else begin
      recv_heart_packe_dat <=#D  udp_top_rx_dat;
    end
end

endmodule