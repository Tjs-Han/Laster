module divider_34x16 (
               clk,
               rstn,
               //--------input
               dvalid_in,
               numerator,
               denominator,
               //--------output
               dvalid_out,
               quotient,
               remainder
        );

   input             clk;
   input             rstn;
   //--------input
   input             dvalid_in;
   input  [34-1:0]   numerator;
   input  [16-1:0]   denominator;
   //--------output
   output            dvalid_out;
   output [34-1:0]   quotient;
   output [16-1:0]   remainder;

endmodule
