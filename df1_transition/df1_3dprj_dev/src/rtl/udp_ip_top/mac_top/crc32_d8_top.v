`timescale 1ns / 1ps
/*************************************************
 Copyright © Shandong Free Optics., Ltd. All rights reserved. 
 File name: ossd_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2024.07.29
 Description:   
 Others: 
 History:
 1. Date:
 Author: 			luxuan			ID:
 Modification:
 2. ...
*************************************************/
module crc32_d8_top(
input   wire            sys_clk,
input   wire            sys_rst_n,

//interface with rmii_top module
input   wire            start_vld,

input   wire            data_vld,
input   wire   [7:0]    data,

output  wire   [31:0]   next_xor_crc
);
/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
parameter D = 2;
/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg     [31:0]      temp_data;
/*---------------------------------------------------------------*\
                          Main Code
\*---------------------------------------------------------------*/
always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[0] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[0] <=#D 1'b1;               
    end else if(data_vld)begin  
		  temp_data[0] <=#D data[6] ^ data[0] ^ temp_data[24] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[1] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[1] <=#D 1'b1;
    end else if(data_vld)begin  
		  temp_data[1] <=#D data[7] ^ data[6] ^ data[1] ^ data[0] ^ temp_data[24] ^ temp_data[25] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[2] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[2] <=#D 1'b1;
    end else if(data_vld)begin  
		  temp_data[2] <=#D data[7] ^ data[6] ^ data[2] ^ data[1] ^ data[0] ^ temp_data[24] ^ temp_data[25] ^ temp_data[26] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[3] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[3] <=#D 1'b1;
    end else if(data_vld)begin  
		  temp_data[3] <=#D data[7] ^ data[3] ^ data[2] ^ data[1] ^ temp_data[25] ^ temp_data[26] ^ temp_data[27] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[4] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[4] <=#D 1'b1;
    end else if(data_vld)begin  
		  temp_data[4] <=#D data[6] ^ data[4] ^ data[3] ^ data[2] ^ data[0] ^ temp_data[24] ^ temp_data[26] ^ temp_data[27] ^ temp_data[28] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[5] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[5] <=#D 1'b1;
    end else if(data_vld)begin  
		  temp_data[5] <=#D data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[3] ^ data[1] ^ data[0] ^ temp_data[24] ^ temp_data[25] ^ temp_data[27] ^ temp_data[28] ^ temp_data[29] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[6] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[6] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[6] <=#D data[7] ^ data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ temp_data[25] ^ temp_data[26] ^ temp_data[28] ^ temp_data[29] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[7] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[7] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[7] <=#D data[7] ^ data[5] ^ data[3] ^ data[2] ^ data[0] ^ temp_data[24] ^ temp_data[26] ^ temp_data[27] ^ temp_data[29] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[8] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[8] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[8] <=#D data[4] ^ data[3] ^ data[1] ^ data[0] ^ temp_data[0] ^ temp_data[24] ^ temp_data[25] ^ temp_data[27] ^ temp_data[28];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[9] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[9] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[9] <=#D data[5] ^ data[4] ^ data[2] ^ data[1] ^ temp_data[1] ^ temp_data[25] ^ temp_data[26] ^ temp_data[28] ^ temp_data[29];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[10] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[10] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[10] <=#D data[5] ^ data[3] ^ data[2] ^ data[0] ^ temp_data[2] ^ temp_data[24] ^ temp_data[26] ^ temp_data[27] ^ temp_data[29];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[11] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[11] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[11] <=#D data[4] ^ data[3] ^ data[1] ^ data[0] ^ temp_data[3] ^ temp_data[24] ^ temp_data[25] ^ temp_data[27] ^ temp_data[28];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[12] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[12] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[12] <=#D data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ data[0] ^ temp_data[4] ^ temp_data[24] ^ temp_data[25] ^ temp_data[26] ^ temp_data[28] ^ temp_data[29] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[13] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[13] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[13] <=#D data[7] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[1] ^ temp_data[5] ^ temp_data[25] ^ temp_data[26] ^ temp_data[27] ^ temp_data[29] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[14] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[14] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[14] <=#D data[7] ^ data[6] ^ data[4] ^ data[3] ^ data[2] ^ temp_data[6] ^ temp_data[26] ^ temp_data[27] ^ temp_data[28] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[15] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[15] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[15] <=#D data[7] ^ data[5] ^ data[4] ^ data[3] ^ temp_data[7] ^ temp_data[27] ^ temp_data[28] ^ temp_data[29] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[16] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[16] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[16] <=#D data[5] ^ data[4] ^ data[0] ^ temp_data[8] ^ temp_data[24] ^ temp_data[28] ^ temp_data[29];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[17] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[17] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[17] <=#D data[6] ^ data[5] ^ data[1] ^ temp_data[9] ^ temp_data[25] ^ temp_data[29] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[18] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[18] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[18] <=#D data[7] ^ data[6] ^ data[2] ^ temp_data[10] ^ temp_data[26] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[19] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[19] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[19] <=#D data[7] ^ data[3] ^ temp_data[11] ^ temp_data[27] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[20] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[20] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[20] <=#D data[4] ^ temp_data[12] ^ temp_data[28];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[21] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[21] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[21] <=#D data[5] ^ temp_data[13] ^ temp_data[29];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[22] <=#D 1'd0;
    end else if(start_vld)begin   
		  temp_data[22] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[22] <=#D data[0] ^ temp_data[14] ^ temp_data[24];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[23] <=#D 1'd0;
     end else if(start_vld)begin   
		  temp_data[23] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[23] <=#D data[6] ^ data[1] ^ data[0] ^ temp_data[15] ^ temp_data[24] ^ temp_data[25] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[24] <=#D 1'd0;
     end else if(start_vld)begin   
		  temp_data[24] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[24] <=#D data[7] ^ data[2] ^ data[1] ^ temp_data[16] ^ temp_data[25] ^ temp_data[26] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[25] <=#D 1'd0;
     end else if(start_vld)begin   
		  temp_data[25] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[25] <=#D data[3] ^ data[2] ^ temp_data[17] ^ temp_data[26] ^ temp_data[27];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[26] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[26] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[26] <=#D data[6] ^ data[4] ^ data[3] ^ data[0] ^ temp_data[18] ^ temp_data[24] ^ temp_data[27] ^ temp_data[28] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[27] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[27] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[27] <=#D data[7] ^ data[5] ^ data[4] ^ data[1] ^ temp_data[19] ^ temp_data[25] ^ temp_data[28] ^ temp_data[29] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[28] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[28] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[28] <=#D data[6] ^ data[5] ^ data[2] ^ temp_data[20] ^ temp_data[26] ^ temp_data[29] ^ temp_data[30];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[29] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[29] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[29] <=#D data[7] ^ data[6] ^ data[3] ^ temp_data[21] ^ temp_data[27] ^ temp_data[30] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[30] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[30] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[30] <=#D data[7] ^ data[4] ^ temp_data[22] ^ temp_data[28] ^ temp_data[31];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  temp_data[31] <=#D 1'd0;
      end else if(start_vld)begin   
		  temp_data[31] <=#D 1'b1;
    end else if(data_vld)begin 
		  temp_data[31] <=#D data[5] ^ temp_data[23] ^ temp_data[29];
    end
end

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		  next_xor_crc <=#D 1'd0;
    end else begin
		  next_xor_crc <=#D temp_data ^ 0xFFFF;
    end
end

endmodule
