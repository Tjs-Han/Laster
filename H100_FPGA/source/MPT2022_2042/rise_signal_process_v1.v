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
// Last modified Date:     2025/05/16 09:54:52 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2025/05/16 09:54:52 
// Version:                V1.0 
// TEXT NAME:              rise_signal_process.v 
// PATH:                   D:\Project\H100_FPGA\source\MPT2022_2042\rise_signal_process.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module rise_signal_process(
    input                               i_clk                      ,
    input                               i_rst_n                    ,
    input  wire                         i_laser_str                ,
  

    input  wire                         i_tdc_result_edge_id       ,
    input  wire   [2:0]                 i_tdc_result_channel_id    ,
    input  wire                         i_tdc_result_valid_flag    ,
    input  wire  [18:0]                 i_tdc_result               ,

    output  wire  [15:0]                o_rise_data                 ,                       
    output  wire  [15:0]                o_fall_data                 , 
    output  wire                        o_data_valid
);
    reg  [3:0]    r_rise_cnt   ;
    reg  [3:0]    r_fall_cnt   ;
    reg  [15:0]   r_rise_data  ;
    reg  [15:0]   r_fall_data  ;

    reg            	r_laser_str_flag ;
    reg  [31:0]		r_laser_str_cnt ;
	reg  		   	r_laser_str;
	reg 			r_data_valid;
	reg  [7:0]     r_laser_str_num;
	
	reg r_rise_start;
	reg r_fall_start;
   	assign o_rise_data 		=   (r_laser_str_flag&i_laser_str&(r_laser_str==0)&(r_rise_cnt!=0)) ? r_rise_data:((r_laser_str_flag&i_laser_str&(r_laser_str==0)&(r_rise_cnt==0))? 16'h0:o_rise_data);
	assign o_fall_data 		=   (r_laser_str_flag&i_laser_str&(r_laser_str==0)&(r_fall_cnt!=0)) ? r_fall_data:((r_laser_str_flag&i_laser_str&(r_laser_str==0)&(r_fall_cnt==0))? 16'h0:o_fall_data);
    assign o_data_valid 	=   r_laser_str_flag&i_laser_str&(r_laser_str==0);
	reg erro_flag ;
 /****error ***/
	always @(posedge i_clk) begin
		//if(r_laser_str_flag&i_laser_str&(r_laser_str==0)&((r_rise_data>20000)|(r_fall_data>20000)|r_rise_cnt==0|r_fall_cnt==0)) begin
		if(r_laser_str_flag&i_laser_str&(r_laser_str==0)&r_fall_cnt==0&r_rise_cnt!=0) begin	
			erro_flag <=1'b1;
		end else begin
			erro_flag <=1'b0;
		end
	 end
/************** i_laser_str first come*************************/
	always @(posedge i_clk ) begin
		if(i_laser_str)begin
			r_laser_str<=1'b1;
		end else begin
			r_laser_str <=1'b0;	
		end
	end
	always @(posedge i_clk or negedge i_rst_n) begin                                        
          if (!i_rst_n) begin
            r_laser_str_flag <= 1'b0;
          end else begin
            if (r_laser_str_cnt>=32'd50000_0000) begin
                r_laser_str_flag <= 1'b0;
            end else begin
                if (i_laser_str) begin
                    r_laser_str_flag <= 1'b1;
                end else begin
                    r_laser_str_flag <= r_laser_str_flag;
                end 
            end
          end                          
    end
    always @(posedge i_clk or negedge i_rst_n)   begin                                        
          if (!i_rst_n) begin
            r_laser_str_cnt <= 31'h0;
          end else begin
                if (i_laser_str) begin
                    r_laser_str_cnt <= 32'b0;
                end else begin
                    r_laser_str_cnt <=(r_laser_str_cnt>=32'd5_0000_0000) ? r_laser_str_cnt:(r_laser_str_cnt+1'h1);
                end
          end                              
    end                                                                                                                                                                                
/****************************rise data**********************************/
    always @(posedge i_clk or negedge i_rst_n) begin                                        
        if(!i_rst_n) begin                              
            r_rise_cnt <= 0 ;                                 
        end else begin 
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id&(i_tdc_result<19'h4e20)) begin
                r_rise_cnt <= (r_rise_cnt==4'hF)? r_rise_cnt:r_rise_cnt+1;
            end  else begin
                if(i_laser_str) begin
                    r_rise_cnt <= 0;                        
                end                                                                     
            end                                     
        end 
    end  

    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin                              
            r_rise_data <= 16'h0 ;                                 
        end else begin 
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id) begin
                 if(((r_rise_data>i_tdc_result[15:0])&r_rise_cnt!=0)|r_rise_cnt==0) begin
					r_rise_data <= r_rise_start ? r_rise_data:i_tdc_result[15:0]; 
				 end else begin
					r_rise_data <=r_rise_data; 
				 end 
            end  else begin
                r_rise_data <= r_rise_data;        
            end                                                                                                         
        end 
    end
	    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin                              
            r_rise_start <= 1'b0 ;                                 
        end else begin 
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id) begin
                 if((r_rise_data>i_tdc_result[15:0])&r_rise_cnt!=0) begin
					r_rise_start <= 1'b1; 
				 end else begin
					r_rise_start <=r_rise_start; 
				 end 
            end  else begin
                r_rise_start <= i_laser_str ? 1'b0:r_rise_start;;        
            end                                                                                                         
        end 
    end

/****************************fall data**********************************/
    always @(posedge i_clk or negedge i_rst_n)  begin                                        
        if(!i_rst_n) begin                              
                 r_fall_data <= 0;   
        end else begin                                   
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id==0) begin 			
                 if(((r_fall_data>i_tdc_result[15:0])&r_fall_cnt!=0)|r_fall_cnt==0) begin
					r_fall_data <= r_fall_start ? r_fall_data:i_tdc_result[15:0]; 
				 end else begin
					r_fall_data <=r_fall_data; 
				 end
			end else begin
				 r_fall_data <= r_fall_data;
			end
        end
    end
    always @(posedge i_clk or negedge i_rst_n)  begin                                        
        if(!i_rst_n) begin                              
                 r_fall_start <= 0;   
        end else begin                                   
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id==0) begin 			
                 if((r_fall_data>i_tdc_result[15:0])&r_fall_cnt!=0) begin
					r_fall_start<=1'b1; 
				 end else begin
					r_fall_start <=r_fall_start; 
				 end
			end else begin
				 r_fall_start <= i_laser_str ? 1'b0:r_fall_start;
			end
        end
    end
    always @(posedge i_clk or negedge i_rst_n)  begin                                        
        if(!i_rst_n) begin                              
            r_fall_cnt <= 0 ;                                 
        end else begin 
            if(i_tdc_result_channel_id==0&i_tdc_result_valid_flag&i_tdc_result_edge_id==0)begin //
                r_fall_cnt <= (r_fall_cnt==4'hF)? r_fall_cnt:r_fall_cnt+1;
            end  else begin
                if(i_laser_str) begin
                    r_fall_cnt <= 0;                        
                end                                                                     
            end                                     
        end         
    end                                                                                                                                               
endmodule                                                          
