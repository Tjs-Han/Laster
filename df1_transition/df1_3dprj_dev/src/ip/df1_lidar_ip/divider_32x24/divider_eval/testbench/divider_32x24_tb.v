// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2012 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                      408-826-6000 (other locations)
// Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
// U.S.A                                    email: techsupport@latticesemi.com
// =============================================================================
//                FILE DETAILS
// Project          : Integer Divider
// File             : divider_tb.v
// Title            : top level testbench for integer divider
// Description      : 
// =============================================================================
//                REVISION HISTORY
// Version          : 1.0
// Author(s)        : 
// Mod. Date        : March 05, 2012
// Changes Made     : Initial Creation
// -----------------------------------------------------------------------------

//====================timescale define
`ifdef TIMING_SIM
   `timescale 1ns/1ps
`else
   `timescale 1ns/100ps
`endif

`define TDF 1

module divider_32x24_tb;
// =============================================================================
// parameters define
// =============================================================================
`include "params.v"

localparam HC           = 20; //half clock period
localparam WAITONETIME  = 50;
localparam SEED         = 0;

//localparam NUM_DATA     = 1<<(DWIDTH+SWIDTH);
localparam NUM_DATA     = 1000;
localparam TI_WIDTH     = clog2(NUM_DATA)+1;
localparam TO_WIDTH     = clog2(NUM_DATA)+1;
localparam RUNONETIME   = (HC*4*NUM_DATA);

// =============================================================================
// internal signal define
// =============================================================================
reg                     rstn;
reg                     clk;
reg                     ce;
reg                     dvalid_in;
reg      [DWIDTH-1:0]   numer;
reg      [SWIDTH-1:0]   denom;

wire     [QWIDTH-1:0]   quot;
wire     [RWIDTH-1:0]   remd;
wire                    dvalid_out;
wire     [QWIDTH-1:0]   ref_quot;
wire     [RWIDTH-1:0]   ref_remd;
wire                    ref_dvalid_out;

// =============================================================================
// Core top level instantiations
// =============================================================================
   divider_32x24_top  u1_divider_32x24_top (
                  //-----------input
                  .clk              (clk              ),
                  .rstn             (rstn             ),
                  .numerator        (numer            ),
                  .denominator      (denom            ),
                  //------------output
                  .quotient         (quot             ),
                  .remainder        (remd             )
               );

   divider_model  #( 
                  .DWIDTH           (DWIDTH           ),
                  .SWIDTH           (SWIDTH           ),
                  .QWIDTH           (QWIDTH           ),
                  .RWIDTH           (RWIDTH           ),
                  .DTYPE            (DTYPE            ),
                  .STYPE            (STYPE            ),
                  .LATENCY          (LATENCY          ),
                  .POS_RMD          (POS_RMD          ),
                  .FAMILY           (FAMILY           ))
   u_ref          (
                  //-----------input
                  .clk              (clk              ),
                  .rstn             (rstn             ),
                  .ce               (ce               ),
                  .dvalid_in        (dvalid_in        ),
                  .numerator        (numer            ),
                  .denominator      (denom            ),
                  //------------output
                  .dvalid_out       (ref_dvalid_out   ),
                  .quotient         (ref_quot         ),
                  .remainder        (ref_remd         )
               );

function [31:0] clog2;
   input [31:0] value;
   for (clog2=0; value>0; clog2=clog2+1) value = value>>1;
endfunction             

//internal signals definition
reg  [TI_WIDTH-1:0]     din_cnt;
reg  [TO_WIDTH+1:0]     dout_cnt;
reg  [31:0]             error_cnt;
reg                     run_en;
reg                     ready_en;
reg                     comp_error;
reg                     complete;
reg  [31:0]             seed;
reg                     compare_en;
reg                     checked;

wire [DWIDTH-1:0]       numer_w;
wire [SWIDTH-1:0]       denom_w;

//===input stat.
always @(posedge clk or negedge rstn)
begin
   if(!rstn) begin
      din_cnt <= {TI_WIDTH{1'b0}};
   end else if(ce) begin
      if(dvalid_in) begin
         din_cnt <= din_cnt + 1;
      end
   end
end

//-----output stat.
always @(posedge clk or negedge rstn)
begin
   if(!rstn) begin
      dout_cnt <= {TO_WIDTH{1'b0}};
   end else if(ce) begin
      if(ref_dvalid_out == 1'b1) begin
         dout_cnt <= dout_cnt + 1;
      end
   end
end
assign numer_w = ({$random(din_cnt*1)}<<32) + {$random(din_cnt*2)};
assign denom_w = ({$random(din_cnt*3)}<<32) + {$random(din_cnt*4)};
//-----input control logic
always @(posedge clk or negedge rstn)
begin
   if(!rstn) begin
      numer       <= #`TDF {DWIDTH{1'b0}};
      denom       <= #`TDF {DWIDTH{1'b1}};
      dvalid_in   <= #`TDF 1'b0;
   end else if(ce) begin
      if(ready_en && run_en) begin
         numer       <= #`TDF numer_w;
         denom       <= #`TDF (denom_w==0) ? 1 : denom_w;
         dvalid_in   <= #`TDF 1'b1;
      end else begin
         dvalid_in   <= #`TDF 1'b0;
      end
   end
end
//-----output data check logic
always @(posedge clk or negedge rstn)
begin
   if(!rstn) begin
      comp_error <= 1'b0;
      error_cnt  <= {32{1'b0}};
   end else if(ce) begin
      if(ref_dvalid_out==1'b1) begin
         if(compare_en==1'b1) begin
            if(quot !== ref_quot) begin
               $display("ERROR! Actual quot = %h   Expect quot = %h   At time %d", quot, ref_quot, $time);
            end
            if(remd!==ref_remd) begin
               $display("ERROR! Actual remd = %h   Expect remd = %h   At time %d", remd, ref_remd, $time);
            end
            if(quot!==ref_quot || remd!==ref_remd) begin
               error_cnt  <= error_cnt + 1;
               comp_error <= 1'b1;
            end else begin
               comp_error <= 1'b0;
            end
         end
      end else begin
         comp_error <= 1'b0;
      end
   end
end
//-----frame sync signal check logic
always @(posedge clk or negedge rstn)
begin
   if(!rstn) begin
      compare_en <= 1'b1;
   end else if(ce) begin
      if(complete==0) begin
         if(dout_cnt >= NUM_DATA-1) begin
            compare_en <= 1'b0;
         end
      end else begin
         compare_en <= 1'b0;
      end
   end
end

//-----clock generator
initial begin
   clk = 1'b0;
   forever #HC clk = ~clk;
end
//-----stimulus the core
initial begin
   input_init;
   async_reset(2);
   delay(10);
   delay(10);
   fork
      input_data;
   join
   delay(WAITONETIME);
   complete = 1'b1;
end
//-----final check
initial begin
   checked = 0;
   wait(complete == 1) begin
      check_result;
      checked = 1;
   end
   delay(5);
   $stop;
end

//---input valid data task
task input_data;
   begin
      while(run_en == 1'b1) begin
         if(dout_cnt >= NUM_DATA-1) begin
            run_en     = 1'b0;
            complete   = 1'b1;
         end
         delay(1);
      end
   end
endtask 
initial begin
   while(complete == 1'b0) begin
      wait(run_en == 1'b1) begin
         randdelay(6);
         ready_en = 1'b1;
         delay(1);
         ready_en = 1'b1;
      end
   end
end

//---variables initial task
task input_init;
   begin
      rstn        = 1'b0;
      ce          = 1'b1;
      dvalid_in   = 1'b0;
      complete    = 1'b0;
      error_cnt   = 0;
      run_en      = 1;
      ready_en    = 1;
      seed        = SEED;
   end
endtask


//---final check task
task check_result;
   begin
      if(dout_cnt == 0) begin
         $display("");
         $display("<><><><><><><><><><><><");
         $display("   No valid output data!");
         $display("<><><><><><><><><><><><");
         $display("");
      end else if(error_cnt == 0) begin
         $display("");
         $display("=======================");
         $display("   Simulation passed!");
         $display("=======================");
         $display("");
      end else begin
         $display("");
         $display("<><><><><><><><><><><><");
         $display("   Simulation failed!");
         $display("<><><><><><><><><><><><");
         $display("");
      end
   end
endtask

//---async reset task
task async_reset;
   input [31:0] dc;
   begin
      # 1 rstn = 1'b0;
      repeat (dc) @ (posedge clk);
      #HC rstn = 1'b1;
   end
endtask
//---delay task
task automatic delay;
   input [31:0] dc;
   begin
      repeat (dc) @ (posedge clk);
      # 1;
   end
endtask
//---random delay task
task automatic randdelay;
   input [31:0] dc;
   begin
      seed = {$random(seed)} % 1000;
      repeat({$random(seed)} % dc) @ (posedge clk);
      # 1;
   end
endtask

GSR GSR_INST(.GSR(rstn));
PUR PUR_INST(.PUR(1'b1));
endmodule

