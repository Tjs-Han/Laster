//------------------------------------------------
// USERNAME module instantiation template
//------------------------------------------------
               .clk              (clk              ),
               .rstn             (rstn             ),
               //--------input
               .dvalid_in        (dvalid_in        ),
               .numerator        (numerator        ),
               .denominator      (denominator      ),
               //--------output
               .dvalid_out       (dvalid_out       ),
               .quotient         (quotient         ),
               .remainder        (remainder        )
    );
