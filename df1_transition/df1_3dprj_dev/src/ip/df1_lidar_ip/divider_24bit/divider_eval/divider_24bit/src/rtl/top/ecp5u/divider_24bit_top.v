`timescale 1ns/100ps

module divider_24bit_top (
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

divider_24bit u1_divider_24bit (
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
