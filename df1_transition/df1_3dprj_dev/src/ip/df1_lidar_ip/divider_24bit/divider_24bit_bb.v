module divider_24bit (
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
   input  [24-1:0]   numerator;
   input  [16-1:0]   denominator;
   //--------output
   output [24-1:0]   quotient;
   output [16-1:0]   remainder;

endmodule
