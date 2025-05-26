module divider_32x24 (
               clk,
               rstn,
               //--------input
               numerator,
               denominator,
               //--------output
               quotient,
               remainder
        );

   input             clk;
   input             rstn;
   //--------input
   input  [32-1:0]   numerator;
   input  [24-1:0]   denominator;
   //--------output
   output [32-1:0]   quotient;
   output [24-1:0]   remainder;

endmodule
