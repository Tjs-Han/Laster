// -------------------------------------------------------------------------------------------------
// File description  :AD SPI
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration:
//                1、In the idle state, o_adc_cs and o_adc_sclk is high
//                2、Rising edge sampling
//--------------------------------------------------------------------------------------------------
module AD_SPI(
   input                clk_50m,
   input                rst_n,
   input                i_adc_rx_en,
   input                i_adc_miso,
   output reg           o_adc_cs,
   output reg           o_adc_sclk,
   output reg           o_adc_rx_done,
   output reg [9:0]     o_adc_data
);
  
   reg [4:0]            clk_cnt;
   reg [2:0]            state;
   reg [2:0]            next_state;
   reg [4:0]            sclk_cnt;
   reg                  sclk_d0;
   reg                  sclk_d1;
   wire                 sclk_negedge;

   assign sclk_negedge = sclk_d1 && ~sclk_d0;  
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)begin
         sclk_d0 <= 1'd1;
         sclk_d1 <= 1'd1;
      end else begin
         sclk_d0 <= o_adc_sclk;
         sclk_d1 <= sclk_d0;
      end
   end
   //----------------------------------------------------------------------------------------------
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)
         clk_cnt <= 5'd0;
      else if(clk_cnt==5'd0 && o_adc_cs==1'd0)
         clk_cnt <= clk_cnt+1'd1;
      else if(clk_cnt==5'd12)
         clk_cnt <= 5'd0;
      else if(i_adc_rx_en==1'd0 && state==1'd0)
         clk_cnt <= 5'd0;
      else if(o_adc_cs==1'd1)
         clk_cnt <= 5'd0;
      else
         clk_cnt <= clk_cnt+1'd1;
   end
   //----------------------------------------------------------------------------------------------
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)
         o_adc_sclk <= 1'd1;
      else if(clk_cnt==5'd0 && o_adc_cs==1'd0)
         o_adc_sclk <= ~o_adc_sclk;
      else if(i_adc_rx_en==1'd0 && state==1'd0)
         o_adc_sclk <= 1'd1;
      else
         o_adc_sclk <= o_adc_sclk;
   end
   //----------------------------------------------------------------------------------------------   
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)
         sclk_cnt <= 5'd0;
      else if(sclk_negedge==1'd1 && o_adc_cs==1'd0)
         sclk_cnt <= sclk_cnt+1'd1;
      else if(sclk_cnt==5'd16)
         sclk_cnt <= 5'd0;
      else
         sclk_cnt <= sclk_cnt;
   end
   //----------------------------------------------------------------------------------------------
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)
         state <= 3'd0;
      else
         state <= next_state;
   end
   //----------------------------------------------------------------------------------------------
   always@(*) begin
      case(state)
         3'd0: begin
            if(i_adc_rx_en)
               next_state <= 3'd1;
            else
               next_state <= 3'd0;
         end
         3'd1: begin
            if(sclk_cnt==5'd4 && o_adc_cs==1'd0 && o_adc_sclk==1'd0)
               next_state <= 3'd2;
            else
               next_state <= 3'd1;
         end
         3'd2: begin
            if(sclk_cnt==5'd14 && o_adc_cs==1'd0 && o_adc_sclk==1'd0)
               next_state <= 3'd3;
            else
               next_state <= 3'd2;
         end
         3'd3: begin
            if(sclk_cnt==5'd16 && o_adc_cs==1'd0)
               next_state <= 3'd4;
            else
               next_state <= 3'd3;
         end
         3'd4: begin
            if(o_adc_cs==1'd1)
               next_state <= 3'd0;
            else
               next_state <= 3'd4;
         end
         default: begin 
            next_state <= 3'd0;
         end
      endcase
   end
   //----------------------------------------------------------------------------------------------
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n) begin
         o_adc_cs      <= 1'd1;
         o_adc_rx_done <= 1'd0;
      end else if(i_adc_rx_en==1'd1 && state==3'd0)
         o_adc_cs      <= 1'd0;
      else if(state==3'd3 && sclk_cnt==5'd16) 
         o_adc_rx_done <= 1'd1;
      else if(state==3'd4)
         o_adc_cs      <= 1'd1;
      else if(state==3'd0 || state==3'd1)
         o_adc_rx_done <= 1'd0;
   end
   //----------------------------------------------------------------------------------------------
   always@(posedge clk_50m or negedge rst_n) begin
      if(!rst_n)
         o_adc_data <= 10'd0;
      else if(state==3'd2 && o_adc_sclk==1'd1 && clk_cnt==5'd6) 
         o_adc_data[13-sclk_cnt] <= i_adc_miso;
      else
         o_adc_data <= o_adc_data;
   end
  
endmodule 
  
  
  
