///////////////////////////////////////////////////////////////////////
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// ====================================================================
// Copyright 2012 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
//
// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from Lattice Semiconductor 
// Corporation.
// The entire notice above must be reproduced on all authorized
// copies and copies may only be made to the extent permitted
// by a licensing agreement from Lattice Semiconductor Corporation.

// ====================================================================
// File Details         
// ====================================================================
// Project     : Divider
// File        : divider_model.v
// Title       : divider model
// 
// Description : integer divider model module
//                    
// Additional info. :
// ====================================================================
module divider_model(
                  clk,
                  rstn,
                  ce, 
                  dvalid_in,
                  numerator, 
                  denominator, 
                  dvalid_out,
                  quotient,
                  remainder);

parameter   DWIDTH         = 40;          // numerator/dividend width
parameter   SWIDTH         = 20;          // denominator/divisor width
parameter   QWIDTH         = 40;          // quotient width
parameter   RWIDTH         = 20;          // remainder width
parameter   LATENCY        = 20;
parameter   DTYPE          = "UNSIGNED";  // numerator/dividend sign
parameter   STYPE          = "UNSIGNED";  // denominator/divisor width
parameter   POS_RMD        = "FALSE";
parameter   FAMILY         = "ECP3";

input                      clk;
input                      rstn;
input                      ce;
input       [DWIDTH-1:0]   numerator;
input       [SWIDTH-1:0]   denominator;
input                      dvalid_in;
output      [QWIDTH-1:0]   quotient;
output      [RWIDTH-1:0]   remainder;
output                     dvalid_out;

reg            [QWIDTH-1:0]   numer_un;
reg            [RWIDTH-1:0]   denom_un;
reg  signed    [QWIDTH-1:0]   numer_sn;
reg  signed    [RWIDTH-1:0]   denom_sn;
reg            [QWIDTH-1:0]   quot_un;
reg            [RWIDTH-1:0]   rmd_un;
reg  signed    [QWIDTH-1:0]   quot_sn;
reg  signed    [RWIDTH-1:0]   rmd_sn;
reg            [QWIDTH-1:0]   quot;
reg            [RWIDTH-1:0]   rmd;
reg            [QWIDTH-1:0]   quot_r[LATENCY-1:0];
reg            [RWIDTH-1:0]   rmd_r[LATENCY-1:0];
reg                           dvalid_r[LATENCY-1:0];

genvar ii;
generate
if(DTYPE=="UNSIGNED" && STYPE=="UNSIGNED") begin
   always @(*)
   begin
      numer_un = numerator;
      denom_un = denominator;
      quot     = numer_un/denom_un;
      rmd      = numer_un%denom_un;
   end
end else begin
   always @(*)
   begin
      numer_sn = numerator;
      denom_sn = denominator;
      quot_sn  = numer_sn/denom_sn;
      rmd_sn   = numer_sn%denom_sn;
   end
   always @(*)
   begin
      if(POS_RMD=="TRUE") begin
         if(rmd_sn[RWIDTH-1]) begin
            quot  = (denom_sn[RWIDTH-1]) ? (quot_sn+1) : (quot_sn-1);
            rmd   = (denom_sn[RWIDTH-1]) ? (rmd_sn-denom_sn) : (rmd_sn+denom_sn);
         end else begin
            quot  = quot_sn;
            rmd   = rmd_sn;
         end
      end else begin
         quot  = quot_sn;
         rmd   = rmd_sn;
      end
   end
end
for(ii=0;ii<LATENCY;ii=ii+1) begin
   always @(posedge clk or negedge rstn)
   begin
      if(!rstn) begin
         quot_r[ii]   <= {QWIDTH{1'b0}};
         rmd_r[ii]    <= {RWIDTH{1'b0}};
         dvalid_r[ii] <= 1'b0;
      end else if(ce) begin
         if(ii==0) begin
            quot_r[ii]   <= quot;
            rmd_r[ii]    <= rmd;
            dvalid_r[ii] <= dvalid_in;
         end else begin
            quot_r[ii]   <= quot_r[ii-1];
            rmd_r[ii]    <= rmd_r[ii-1];
            dvalid_r[ii] <= dvalid_r[ii-1];
         end
      end
   end
end
assign quotient = quot_r[LATENCY-1];
assign remainder = rmd_r[LATENCY-1];
assign dvalid_out= dvalid_r[LATENCY-1];
endgenerate

endmodule
