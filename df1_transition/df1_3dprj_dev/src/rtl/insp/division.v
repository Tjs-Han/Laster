// -------------------------------------------------------------------------------------------------
// File description  :division
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module division
(
	input			i_clk,
	input			i_rst_n,
	
	input			i_cal_sig,
	input  [31:0]	i_dividend,
	input  [15:0]	i_divisor,

	output [15:0]	o_quotient,
	output			o_cal_done
);
	//----------------------------------------------------------------------------------------------
	// reg and wire signal define
	//----------------------------------------------------------------------------------------------
	reg [3:0]		r_cal_state = 4'd0;
	reg [15:0]		r_cal_cnt 	= 16'd0;
	reg [31:0]		r_dividend 	= 32'd0;
	reg [15:0]		r_divisor 	= 16'd0;
	reg				r_cal_done 	= 1'b0;
	reg [15:0]		r_quotient 	= 16'd0;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------	
	localparam CAL_IDLE		= 4'b0000;
	localparam CAL_ASSIGN	= 4'b0001;
	localparam CAL_COMP		= 4'b0010;
	localparam CAL_END		= 4'b0100;
	localparam CAL_OVER		= 4'b1000;
	
	always@(posedge i_clk or negedge i_rst_n) begin
		if(i_rst_n == 0)begin
			r_dividend	<= 32'd0;
			r_divisor	<= 16'd0;
			r_cal_cnt	<= 16'd0;
			r_quotient	<= 16'd0;
			r_cal_done	<= 1'b0;
			r_cal_state	<= CAL_IDLE;
		end else begin
			case(r_cal_state)
				CAL_IDLE:begin
					r_dividend	<= 32'd0;
					r_divisor	<= 16'd0;
					r_cal_cnt	<= 16'd0;
					r_quotient	<= 16'd0;
					r_cal_done	<= 1'b0;
					if(i_cal_sig)
						r_cal_state	<= CAL_ASSIGN;
					end
				CAL_ASSIGN:begin
					r_dividend	<= i_dividend;
					r_divisor	<= i_divisor;
					r_cal_cnt	<= 16'd0;
					r_cal_state	<= CAL_COMP;
					end
				CAL_COMP:begin
					if(r_dividend >= r_divisor)begin
						r_dividend	<= r_dividend - r_divisor;
						r_cal_cnt	<= r_cal_cnt + 1'b1;
						end
					else 
						r_cal_state	<= CAL_END;
					end
				CAL_END:begin
					r_cal_done	<= 1'b1;
					r_quotient	<= r_cal_cnt;
					r_cal_state	<= CAL_OVER;
					end
				CAL_OVER:begin
					r_cal_done	<= 1'b0;
					r_cal_state	<= CAL_IDLE;
					end
				default:r_cal_state	<= CAL_IDLE;
			endcase
		end
	end		
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------			
	assign	o_quotient = r_quotient;
	assign	o_cal_done = r_cal_done;

endmodule 