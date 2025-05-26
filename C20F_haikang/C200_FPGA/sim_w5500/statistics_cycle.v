`timescale 1ns / 1ps 
//****************************************VSCODE PLUG-IN**********************************// 
//---------------------------------------------------------------------------------------- 
// IDE :                   VSCODE      
// VSCODE plug-in version: Verilog-Hdl-Format-2.4.20240526
// VSCODE plug-in author : Jiang Percy 
//---------------------------------------------------------------------------------------- 
//****************************************Copyright (c)***********************************// 
// Copyright(C)            COMPANY_NAME
// All rights reserved      
// File name:               
// Last modified Date:     2025/04/25 09:42:10 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             tianjunsheng
// Created date:           2025/04/25 09:42:10 
// Version:                V1.0 
// TEXT NAME:              Statistics_cycle.v 
// PATH:                   D:\Project\C20F_haikang\C200_FPGA\rtl_tjs\Statistics_cycle.v 
// Descriptions:            
//        Statistics zero to w_opto_switch cycle ,Statistics w_opto_switch to w_opto_switch cycle                 
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module statistics_cycle (
    input			i_clk_50m    		,
	input			i_rst_n      		,

/*Statistics signal*/
    input			i_opto_switch		,//码盘信号输入
    input           i_zero_sign         ,//零点信号
    input           i_motor_state       ,//调速完�
/*ram read*/
    input   [5:0]   i_ram_raddr         ,// ram read data addr
    input           i_ram_ren           ,// ram read enable
    output  [31:0]  o_ram_rdata         // ram read data                                                           
);
reg [31:0]  r_opto_opto_cnt ; // opto signal to opto clk cnt;
reg [7:0]   r_opto_num      ; // the opto number between zero signal and zero signal ;

wire        w_opto_rise     ;
wire        w_zero_rise     ;
reg         r_opto_switch1  ;
reg         r_opto_switch2  ; 
reg         r_zero_sign     ; 
reg			r_zero_sign1    ;

/*******************ram write signal*********************************************/
reg [5:0]   r_ram_waddr     ;
reg         r_we            ;
reg [31:0]  r_ram_wdata     ;

/****************** opto rise ***************************************************/
    always@(posedge i_clk_50m or negedge i_rst_n) begin//对码盘信号做两次同步
	    if(i_rst_n == 0)begin
			r_opto_switch1 <= 1'b1;
			r_opto_switch2 <= 1'b1;
		end else begin
			r_opto_switch1 <= i_opto_switch;
			r_opto_switch2 <= r_opto_switch1;
		end	
    end
	assign w_opto_rise = ~r_opto_switch2 & r_opto_switch1;//判断码盘信号上升
        
/************************r_zero_opto_cnt*******************************************/
    always @(posedge i_clk_50m or negedge i_rst_n)  begin                                        
        if(!i_rst_n) begin                               
            r_zero_sign <=1'b0;
            r_zero_sign1<=1'b0;  
        end else begin
            r_zero_sign <= i_zero_sign; 
            r_zero_sign1 <= r_zero_sign ;
        end                                                                 
     end 
    assign  w_zero_rise = ~r_zero_sign1&r_zero_sign ;

/*************************r_opto_opto_cnt*****************************************/   
    always @(posedge i_clk_50m or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_opto_opto_cnt <= 32'b0 ;
        end else begin
            if (w_zero_rise) begin
                r_opto_opto_cnt <=0;
            end else begin
                if (w_opto_rise&(r_opto_num<=58)) begin
                    r_opto_opto_cnt <=0;
                end else begin
                    r_opto_opto_cnt <=r_opto_opto_cnt+1'b1;
                end
            end
        end
    end 
/**************************r_opto_num ******************************************/  
    always @(posedge i_clk_50m or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_opto_num <= 8'b0;
        end else begin
            if (w_zero_rise) begin
                r_opto_num <= 8'b0;
            end else begin
                r_opto_num <= w_opto_rise ? (r_opto_num+1'b1):r_opto_num;
            end
        end
    end 
/**************************ram write data***********************************/   
    always @(posedge i_clk_50m or negedge i_rst_n ) begin
        if (!i_rst_n) begin
            r_ram_waddr <= 6'b0;
            r_we        <= 1'b0;
            r_ram_wdata <= 32'b0;
        end else begin
            if (w_zero_rise) begin
                r_ram_waddr <= 6'b0;
                r_we        <= w_zero_rise;
                r_ram_wdata <= r_opto_num;
            end else begin
                r_ram_wdata <=  r_opto_opto_cnt; 
                r_ram_waddr <=  ((w_opto_rise&r_opto_num<=58)|(~r_zero_sign&i_zero_sign)) ? r_ram_waddr +1'b1:r_ram_waddr;
                r_we        <=  (w_opto_rise&r_opto_num<=58)|(~r_zero_sign&i_zero_sign); 
            end
        end
    end  
/**************************ram width 32bit depth 64***************************/

ramw32_dp64 ramw32_dp64 (
    .WrAddress  (r_ram_waddr    ), 
    .RdAddress  (i_ram_raddr    ), 
    .Data       (r_ram_wdata    ), 
    .WE         (r_we           ), 
    .RdClock    (i_clk_50m      ), 
    .RdClockEn  (i_ram_ren      ), 
    .Reset      ( ~i_rst_n      ), 
    .WrClock    (i_clk_50m      ), 
    .WrClockEn  ( 1'b1          ), 
    .Q          (o_ram_rdata    )
);                            
endmodule                                                          
