`timescale 1ns / 1ps
/*************************************************
 Copyright æ¼Shandong Free Optics., Ltd. All rights reserved. 
 File name: cfg_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2023.02.16
 Description:   
 Others: 
 History:
 1. Date:
 Author: 							ID:
 Modification:
 2. ...
*************************************************/
module mpt2042_spi_top(
//interface with tdc_control
input   wire        sys_clk,
input   wire        sys_rst_n,


input   wire        spi_tx_valid,
input   wire        spi_tx_rw,
input   wire        spi_cmd_type,
input   wire [7:0]  spi_tx_data,

input   wire        spi_so,   
output  reg         spi_clk,
output  reg         spi_ssn,
output  reg         spi_si, 

output  reg         next_byte_vld,
output  reg         spi_finish_pulse,
output  reg         spi_rd_vld,
output  reg [7:0]   spi_rdat
);

/*-------------------------------------------------------------------*\
                          Parameter Description
\*-------------------------------------------------------------------*/
localparam D = 2;
localparam SPI_CLK_LEN = 12'd3072;
/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
reg         [11:0]      spi_clk_cnt;
reg                     spi_clk_cnt_flag;

reg         [7:0]       tx_data;

reg                     f0_spi_tx_valid;
reg                     f1_spi_tx_valid;
reg                     f2_spi_tx_valid;

reg                     spi_tx_rw_reg;
reg                     spi_cmd_type_reg;

reg                     f0_next_byte_vld;
reg                     f1_next_byte_vld;
/*-------------------------------------------------------------------*\
                          Main Code
\*-------------------------------------------------------------------*/
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_tx_rw_reg <=#D 1'b0;
    end else if(spi_tx_valid)begin
        spi_tx_rw_reg <=#D spi_tx_rw;
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_cmd_type_reg <=#D 1'b0;
    end else if(spi_tx_valid)begin
        spi_cmd_type_reg <=#D spi_cmd_type;
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_spi_tx_valid <=#D 1'b0;
        f1_spi_tx_valid <=#D 1'b0;  
        f2_spi_tx_valid <=#D 1'b0;                       
    end else begin
        f0_spi_tx_valid <=#D spi_tx_valid;
        f1_spi_tx_valid <=#D f0_spi_tx_valid;   
        f2_spi_tx_valid <=#D f1_spi_tx_valid;         
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_clk_cnt_flag <=#D 1'b0;      
    end else if( spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd58) && ~spi_cmd_type_reg)begin//write spi_cmd_type_reg==0 write 1byte cnt=19
        spi_clk_cnt_flag <=#D 1'b0;    
    end else if( spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd3)   &&  spi_cmd_type_reg)begin //read spi_cmd_type_reg==1
        spi_clk_cnt_flag <=#D 1'b0;                  
    end else if(~spi_clk_cnt_flag && f1_spi_tx_valid)begin
        spi_clk_cnt_flag <=#D 1'b1;   
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_clk_cnt[11:5] <=#D 7'b0; 
    end else if( spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd58) && ~spi_cmd_type_reg)begin
        spi_clk_cnt[11:5] <=#D 7'b0;    
    end else if( spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd3)   &&  spi_cmd_type_reg)begin
        spi_clk_cnt[11:5] <=#D 7'b0;                    
    end else if( spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 8'd19))begin
        spi_clk_cnt[11:5] <=#D spi_clk_cnt[11:5] + 7'd1;    
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_clk_cnt[4:0] <=#D 5'b0; 
    end else if(f1_spi_tx_valid)begin
        spi_clk_cnt[4:0] <=#D 5'b0;           
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19))begin
        spi_clk_cnt[4:0] <=#D 5'b0;                 
    end else if(spi_clk_cnt_flag)begin
        spi_clk_cnt[4:0] <=#D spi_clk_cnt[4:0] + 5'b1;    
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_ssn <=#D 1'b1;      
    end else begin
        spi_ssn <=#D ~(spi_tx_valid ||f0_spi_tx_valid || f1_spi_tx_valid || spi_clk_cnt_flag);    
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_clk <=#D 1'b1;
    end else if(f2_spi_tx_valid)begin
        spi_clk <=#D 1'b0;         
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] <= 8'd14))begin
        spi_clk <=#D ~spi_clk;
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 8'd15) && ~spi_clk)begin
        spi_clk <=#D ~spi_clk;        
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tx_data <=#D 8'b0;
    end else if(spi_tx_valid)begin
        tx_data <=#D spi_tx_data;      
    end else if(f1_next_byte_vld && spi_tx_rw_reg)begin
        tx_data <=#D 8'b0; 
    end else if(f1_next_byte_vld)begin
        tx_data <=#D spi_tx_data;                       
    end else if(spi_clk_cnt_flag && spi_clk_cnt[0])begin
        tx_data <=#D tx_data << 1;
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_si <=#D 1'b0;
    end else begin
        spi_si <=#D tx_data[7];    
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        next_byte_vld <=#D 1'b0;
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd16) && (spi_clk_cnt[11:5] < 7'd58)  && ~spi_cmd_type_reg)begin
        next_byte_vld <=#D 1'b1; 
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd16) && (spi_clk_cnt[11:5] < 7'd2)    &&  spi_cmd_type_reg)begin
        next_byte_vld <=#D 1'b1;         
    end else begin
        next_byte_vld <=#D 1'b0;        
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_next_byte_vld <=#D 1'b0;
        f1_next_byte_vld <=#D 1'b0;        
    end else begin
        f0_next_byte_vld <=#D next_byte_vld;
        f1_next_byte_vld <=#D f0_next_byte_vld;     
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_rdat <=#D 8'b0;  
    end else if(spi_clk_cnt_flag && spi_clk_cnt[0])begin
        spi_rdat <=#D {spi_rdat[6:0],spi_so} ;
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_finish_pulse <=#D 1'b0;
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd58)  && ~spi_cmd_type_reg)begin
        spi_finish_pulse <=#D 1'b1; 
    end else if(spi_clk_cnt_flag && (spi_clk_cnt[4:0] == 5'd19) && (spi_clk_cnt[11:5] == 7'd3)   &&  spi_cmd_type_reg)begin
        spi_finish_pulse <=#D 1'b1;   
    end else begin
        spi_finish_pulse <=#D 1'b0;          
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_rd_vld <=#D 1'b0;
    end else begin
        spi_rd_vld <=#D spi_clk_cnt_flag && spi_clk_cnt[0] && (spi_clk_cnt[4:0] == 5'd15) && (spi_clk_cnt[11:5] >= 7'd1) && spi_tx_rw_reg;
    end
end

endmodule