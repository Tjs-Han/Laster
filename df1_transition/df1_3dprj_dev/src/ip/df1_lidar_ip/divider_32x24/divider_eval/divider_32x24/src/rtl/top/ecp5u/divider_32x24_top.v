`timescale 1ns/100ps

module divider_32x24_top (
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

divider_32x24 u1_divider_32x24 (
               .clk              (clk              ),
               .rstn             (rstn             ),
               //--------input
               .numerator        (numerator        ),
               .denominator      (denominator      ),
               //--------output
               .quotient         (quotient         ),
               .remainder        (remainder        )
    );

endmodule
