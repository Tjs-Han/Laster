`timescale 1ns / 1ps
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan       56              0.0.1               2024.07.29
 Description: 
 1: mac packet      to  RMII
 2L calc mac crc32 ,to  RMII
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
module mac_tx_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

input   wire            mac_tx_sop,
input   wire            mac_tx_eop, 
input   wire            mac_tx_vld,
input   wire   [7:0]    mac_tx_dat,

output  reg             rmii_tx_vld,
output  reg    [1:0]    rmii_tx_dat
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
		  fifo_wr <=#D 8'd0;
    end else begin
		  fifo_wr <=#D mac_tx_vld || f0_mac_packet_tx_eop || f1_mac_packet_tx_eop;                   
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		fifo_wdat <=#D 10'd0;
    end else if(mac_tx_vld)begin
		fifo_wdat <=#D {mac_tx_sop,mac_tx_eop,mac_tx_dat};
    end else if(f0_mac_packet_tx_eop || f1_mac_packet_tx_eop)begin
		fifo_wdat <=#D 10'd0;        
    end
end

fIfo_mac_frame_2048x10 u_fIfo_mac_frame_2048x10
(
  .Clock  (sys_clk),
  .Reset  (~sys_rst_n),  

  .WrEn   (fifo_wr), 
  .Data   (fifo_wdat), 
  .RdEn   (fifo_rd),       
  .Q      (fifo_rdat),     
  .Empty  (fifo_empty),   
  .Full   (fifo_full)    
);

assign fifo_rd = ~fifo_empty && mac_tx_data_flag && (mac_tx_data_inter_cnt == 3'd0);

assign fifo_rd_eop = f1_fifo_rd && fifo_rdat[8];
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		fifo_packet_cnt <=#D 8'd0;
    end else if(fifo_wr && fifo_wdat[8] && f1_fifo_rd && fifo_rdat[9])begin
		fifo_packet_cnt <=#D fifo_packet_cnt;     
    end else if(fifo_wr && fifo_wdat[8])begin
	    fifo_packet_cnt <=#D fifo_packet_cnt + 8'd1;    
    end else if(f1_fifo_rd && fifo_rdat[9])begin
		fifo_packet_cnt <=#D fifo_packet_cnt - 8'd1;                   
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_tx_head_flag <=#D 1'b0;
    end else if(~mac_tx_head_flag && ~mac_tx_data_flag && |fifo_packet_cnt)begin
		  mac_tx_head_flag <=#D 1'b1;
    end else if( mac_tx_head_flag && &mac_tx_head_flag_cnt)begin
		  mac_tx_head_flag <=#D 1'b0;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_tx_head_flag_cnt <=#D 6'd0;
    end else if(mac_tx_head_flag)begin
		  mac_tx_head_flag_cnt <=#D mac_tx_head_flag_cnt + 6'd1;
    end else begin
		  mac_tx_head_flag_cnt <=#D 6'd0;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  rmii_tx_vld_0 <=#D 1'b0;
    end else begin
		  rmii_tx_vld_0 <=#D mac_tx_head_flag && mac_tx_head_flag_cnt[0];      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		rmii_tx_dat_0 <=#D 2'b0;
    end else if(mac_tx_head_flag && mac_tx_head_flag_cnt[0] && (mac_tx_head_flag_cnt == 6'd63))begin
		rmii_tx_dat_0 <=#D 2'b11;  
    end else if(mac_tx_head_flag && mac_tx_head_flag_cnt[0])begin
	  	rmii_tx_dat_0 <=#D 2'b10;          
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		mac_tx_data_flag <=#D 1'b0;
    end else if(~mac_tx_data_flag && mac_tx_head_flag && &mac_tx_head_flag_cnt)begin
		mac_tx_data_flag <=#D 1'b1;
    end else if( fifo_rd_eop)begin
		mac_tx_data_flag <=#D 1'b0;        
    end
end

//align with f1_mac_tx_data_flag ,f1_fifo_rd, fifo_rdat
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		mac_tx_data_inter_cnt <=#D 3'b0;
    end else if(fifo_rd_eop)begin
		mac_tx_data_inter_cnt <=#D 3'b0;       
    end else if(f1_mac_tx_data_flag)begin
		mac_tx_data_inter_cnt <=#D mac_tx_data_inter_cnt + 3'd1;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_vld_1 <=#D 1'b0;
    end else begin
		rmii_tx_vld_1 <=#D f1_mac_tx_data_flag && mac_tx_data_inter_cnt[1] || 
                           f0_fifo_rd_eop || f2_fifo_rd_eop || f4_fifo_rd_eop || f6_fifo_rd_eop;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	fifo_rdat_reg <=#D 8'b0;
    end else if(f1_fifo_rd)begin
	  	fifo_rdat_reg <=#D fifo_rdat[7:0];      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_dat_1 <=#D 8'b0;
    end else if( f1_mac_tx_data_flag && mac_tx_data_inter_cnt == 3'd1)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[0:1]; 
    end else if( f1_mac_tx_data_flag && mac_tx_data_inter_cnt == 3'd3)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[2:3];  
    end else if( f1_mac_tx_data_flag && mac_tx_data_inter_cnt == 3'd5)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[4:5];  
    end else if( f1_mac_tx_data_flag && mac_tx_data_inter_cnt == 3'd7)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[6:7];  

    end else if( f0_fifo_rd_eop)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[0:1]; 
    end else if( f2_fifo_rd_eop)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[2:3];  
    end else if( f4_fifo_rd_eop)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[4:5];
    end else if( f6_fifo_rd_eop)begin
		rmii_tx_dat_1 <=#D fifo_rdat_reg[6:7];                        

    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		start_vld <=#D 1'b0;
    end else if(~mac_tx_data_flag && mac_tx_head_flag && &mac_tx_head_flag_cnt)begin
		start_vld <=#D 1'b1;
    end else begin
		start_vld <=#D 1'b0;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		data_vld <=#D 1'b0;
    end else begin
		data_vld <=#D f1_fifo_rd;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		data <=#D 1'b0;
    end else begin
	    data <=#D fifo_rdat[7:0];
    end
end

crc32_d8_top u_crc32_d8_top
(
  .sys_clk    (sys_clk),
  .sys_rst_n  (sys_rst_n),  

  .start_vld  (start_vld), 

  .data_vld   (data_vld), 
  .data       (data),       

  //delay 2 clk 
  .next_xor_crc  (next_xor_crc)   
);

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		mac_crc32_reg <=#D 32'b0;
    end else if(f3_fifo_rd_eop)begin
		mac_crc32_reg <=#D next_xor_crc;
    end else if(mac_tx_crc32_flag && &mac_tx_crc32_cnt[2:0])begin
		mac_crc32_reg <=#D mac_crc32_reg << 8;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_tx_crc32_flag <=#D 1'b0;
    end else if(~mac_tx_crc32_flag && f6_fifo_rd_eop)begin
		  mac_tx_crc32_flag <=#D 1'b1;
    end else if( mac_tx_crc32_flag && &mac_tx_crc32_cnt)begin
		  mac_tx_crc32_flag <=#D 1'b0;        
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  mac_tx_crc32_cnt <=#D 5'b0;
    end else if(~mac_tx_crc32_flag && f6_fifo_rd_eop)begin
		  mac_tx_crc32_cnt <=#D 5'b0;       
    end else if( mac_tx_crc32_flag)begin
		  mac_tx_crc32_cnt <=#D mac_tx_crc32_cnt + 5'd1;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_vld_2 <=#D 1'b0;
    end else begin
		rmii_tx_vld_2 <=#D mac_tx_crc32_flag && mac_tx_crc32_cnt[1];      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_dat_2 <=#D 8'b0;
    end else if( mac_tx_crc32_flag && mac_tx_crc32_cnt[2:0] == 3'd1)begin
		rmii_tx_dat_2 <=#D mac_crc32_reg[24:25]; 
    end else if( mac_tx_crc32_flag && mac_tx_crc32_cnt[2:0] == 3'd3)begin
		rmii_tx_dat_2 <=#D mac_crc32_reg[26:27];  
    end else if( mac_tx_crc32_flag && mac_tx_crc32_cnt[2:0] == 3'd5)begin
		rmii_tx_dat_2 <=#D mac_crc32_reg[28:29];  
    end else if( mac_tx_crc32_flag && mac_tx_crc32_cnt[2:0] == 3'd7)begin
		rmii_tx_dat_2 <=#D mac_crc32_reg[30:31];                         
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_vld <=#D 1'b0;
    end else begin
		  rmii_tx_vld <=#D rmii_tx_vld_0 || rmii_tx_vld_1 || rmii_tx_vld_2;      
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
	  	rmii_tx_dat <=#D 2'b0;
    end else if(rmii_tx_vld_0)begin
		  rmii_tx_dat <=#D rmii_tx_dat_0;     
    end else if(rmii_tx_vld_1)begin
		  rmii_tx_dat <=#D rmii_tx_dat_1;  
    end else if(rmii_tx_vld_2)begin
		  rmii_tx_dat <=#D rmii_tx_dat_2;               
    end
end

endmodule

