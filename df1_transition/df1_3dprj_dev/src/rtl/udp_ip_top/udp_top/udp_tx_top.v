`timescale 1ns / 1ps
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan       56        0.0.1         2024.08.28
 Description:  
  1: add udp head to send udp packet;        

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

input   wire            load_parameter_vld,
input   wire   [31:0]   lidar_ip_address,

//
input   wire   [31:0]   lidar_connect_tar_ip,
input   wire   [47:0]   lidar_connect_tar_mac,
input   wire   [15:0]   cmd_tar_port,
input   wire   [15:0]   heart_tar_port,
input   wire   [15:0]   send_info_tar_port,
input   wire   [15:0]   Point_clound_tar_port,
input   wire   [15:0]   imu_tar_port,

input   wire            app_top_to_udp_top_request, 
input   wire   [2:0]    app_top_to_udp_top_type, 
input   wire   [26:0]   app_top_to_udp_top_check_data, 
input   wire   [15:0]   app_top_tx_length,

output  reg             udp_top_to_app_top_ack,

input   wire            app_top_to_udp_top_sop, 
input   wire            app_top_to_udp_top_eop, 
input   wire            app_top_to_udp_top_vld,  
input   wire   [7:0]    app_top_to_udp_top_dat    

output  reg    [31:0]   udp_top_tx_dst_ip,
output  reg    [47:0]   udp_top_tx_dst_mac,
output  reg    [15:0]   udp_top_tx_len,
output  reg             udp_top_tx_sop,
output  reg             udp_top_tx_eop,
output  reg             udp_top_tx_vld,
output         [7:0]    udp_top_tx_dat
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;
parameter DEVICE_SRC_PORT         = 16'd55000;
parameter CMD_SRC_PORT            = 16'd55100;
parameter INFO_SRC_PORT           = 16'd55200;
parameter POINT_CLOUND_SRC_PORT   = 16'd55300;
parameter IMU_SRC_PORT            = 16'd55400;
parameter LOG_SRC_PORT            = 16'd55500;
parameter HEART_SRC_PORT          = 16'd55600;
/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg       [15:0]         udp_tx_port;
reg       [15:0]         udp_src_port;

reg       [31:0]         udp_src_ip;
reg       [31:0]         udp_dst_ip;

reg       [47:0]         udp_dst_mac;

reg       [15:0]         udp_all_len;
reg                      gen_udp_head_flag;
reg       [3:0]          gen_udp_head_cnt;
reg       [26:0]         udp_check;
reg       [15:0]         use_udp_check;
reg       [7:0]          gen_udp_head_data;
reg                      gen_udp_head_vld;
/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
//tyoe 0  : device
//tyoe 1  : cmd
//tyoe 2  : info
//tyoe 3  : point clound
//tyoe 4  : imu
//tyoe 5  : log
//tyoe 6  : heart
always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  udp_tx_port <=#D cmd_tar_port;                
    end
    else if(app_top_to_udp_top_request)begin
      case(app_top_to_udp_top_type)
		   3'd0: udp_tx_port <=#D 16'd65000;             
		   3'd1: udp_tx_port <=#D cmd_tar_port;
		   3'd2: udp_tx_port <=#D send_info_tar_port;
		   3'd3: udp_tx_port <=#D Point_clound_tar_port;
		   3'd4: udp_tx_port <=#D imu_tar_port;
		   3'd5: udp_tx_port <=#D 16'd64000;
		   3'd6: udp_tx_port <=#D heart_tar_port;       
       default: udp_tx_port <=#D cmd_tar_port;                                 
      endcase
    end           
end

always @ (posedge clk)begin
    if(!sys_rst_n) begin
		  udp_src_port <=#D CMD_SRC_PORT;                
    end
    else if(app_top_to_udp_top_request)begin
      case(app_top_to_udp_top_type)
		   3'd0: udp_src_port <=#D DEVICE_SRC_PORT;             
		   3'd1: udp_src_port <=#D CMD_SRC_PORT;
		   3'd2: udp_src_port <=#D INFO_SRC_PORT;
		   3'd3: udp_src_port <=#D POINT_CLOUND_SRC_PORT;
		   3'd4: udp_src_port <=#D IMU_SRC_PORT;
		   3'd5: udp_src_port <=#D LOG_SRC_PORT;
		   3'd6: udp_src_port <=#D HEART_SRC_PORT;       
       default: udp_src_port <=#D CMD_SRC_PORT;                
      endcase
    end    
end

////////register ip,mac info
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_src_ip <=#D 32'd0;
    end else if(load_parameter_vld)begin
      udp_src_ip <=#D lidar_ip_address;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_dst_ip <=#D 32'd0;
    end else if(app_top_to_udp_top_request)begin
      udp_dst_ip <=#D lidar_connect_tar_ip;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_dst_mac <=#D 48'd0;
    end else if(app_top_to_udp_top_request)begin
      udp_dst_mac <=#D lidar_connect_tar_mac;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_all_len <=#D 16'd0;
    end else if(app_top_to_udp_top_request)begin
      udp_all_len <=#D app_top_tx_length + 16'd8;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    gen_udp_head_flag <=#D 1'b0;
    end else if(~gen_udp_head_flag && app_top_to_udp_top_request)begin
	    gen_udp_head_flag <=#D 1'b0;
    end else if( gen_udp_head_flag && (gen_udp_head_cnt == 4'd13))begin
	    gen_udp_head_flag <=#D 1'b0;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    gen_udp_head_cnt <=#D 4'd0;
    end else if(~gen_udp_head_flag && app_top_to_udp_top_request)begin
	    gen_udp_head_cnt <=#D 4'd0;
    end else if( gen_udp_head_flag)begin
	    gen_udp_head_cnt <=#D gen_udp_head_cnt + 4'd1;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_check <=#D 27'd0;
    end else if(app_top_to_udp_top_request)begin
	    udp_check <=#D app_top_to_udp_top_check_data;

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd0))begin
	    udp_check <=#D udp_check + udp_src_ip[31:16];  
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd1))begin
	    udp_check <=#D udp_check + udp_src_ip[15:0];  

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd2))begin
	    udp_check <=#D udp_check + udp_dst_ip[31:16];  
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd3))begin
	    udp_check <=#D udp_check + udp_dst_ip[15:0];    

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd4))begin
	    udp_check <=#D udp_check + 16'd17;     

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd5))begin
	    udp_check <=#D udp_check + udp_all_len;                                 

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd6))begin
	    udp_check <=#D udp_check + udp_src_port;                                 

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd7))begin
	    udp_check <=#D udp_check + udp_tx_port;                                 

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd8))begin
	    udp_check <=#D udp_check + udp_all_len;                                  

    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd9))begin
	    udp_check <=#D udp_check[26:16] + udp_check[15:0];                                 
    end      

end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    use_udp_check <=#D 16'd0;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd10))begin
	    use_udp_check <=#D udp_check[15:0] ^ 16'hFFFF;
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    gen_udp_head_data <=#D 8'b0;
    end else if(gen_udp_head_flag)begin
      case(gen_udp_head_cnt)
	     4'd5:  gen_udp_head_data <=#D udp_src_port[15:8];
	     4'd6:  gen_udp_head_data <=#D udp_src_port[7:0];
	     4'd7:  gen_udp_head_data <=#D udp_tx_port[15:8];
	     4'd8:  gen_udp_head_data <=#D udp_tx_port[7:0];
	     4'd9:  gen_udp_head_data <=#D udp_all_len[15:8];
	     4'd10: gen_udp_head_data <=#D udp_all_len[7:0];
	     4'd11: gen_udp_head_data <=#D use_udp_check[15:8];
	     4'd12: gen_udp_head_data <=#D use_udp_check[7:0];                                                 
      endcase 
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    gen_udp_head_vld <=#D 1'b0;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd4))begin
	    gen_udp_head_vld <=#D 1'b1;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd12))begin
	    gen_udp_head_vld <=#D 1'b0;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_to_app_top_ack <=#D 1'b0;
    end else begin
	    udp_top_to_app_top_ack <=#D gen_udp_head_flag && (gen_udp_head_cnt == 4'd12);      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_dst_ip <=#D 32'b0;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd0))begin
	    udp_top_tx_dst_ip <=#D udp_dst_ip;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_dst_mac <=#D 48'b0;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd0))begin
	    udp_top_tx_dst_mac <=#D udp_dst_mac;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_len <=#D 16'b0;
    end else if(gen_udp_head_flag && (gen_udp_head_cnt == 4'd0))begin
	    udp_top_tx_len <=#D udp_all_len;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_sop <=#D 1'b0;
    end else begin
	    udp_top_tx_sop <=#D gen_udp_head_flag && (gen_udp_head_cnt == 4'd5);      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_eop <=#D 1'b0;
    end else begin
	    udp_top_tx_eop <=#D app_top_to_udp_top_eop;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_vld <=#D 1'b0;
    end else begin
	    udp_top_tx_vld <=#D gen_udp_head_vld || app_top_to_udp_top_vld;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	    udp_top_tx_dat <=#D 1'b0;
    end else if(gen_udp_head_vld)begin
	    udp_top_tx_dat <=#D gen_udp_head_data;     
    end else if(app_top_to_udp_top_vld)begin
	    udp_top_tx_dat <=#D app_top_to_udp_top_dat;          
    end
end

endmodule