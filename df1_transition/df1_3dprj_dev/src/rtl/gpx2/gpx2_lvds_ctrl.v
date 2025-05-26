// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_lvds_ctrl
// Date Created 	: 2024/09/06 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:gpx2_lvds_ctrl
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module gpx2_lvds_ctrl(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_lvds_clk/* synthesis syn_keep=1 */,
	input					i_lvds_frame/* synthesis syn_keep=1 */,
	input					i_lvds_sdo/* synthesis syn_keep=1 */,
    // control signal      
	input					i_gpx2_rdresult,
    output [63:0]			o_gpx2_result,
   	output      			o_gpx2_signal
);
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam ST_IDLE			= 8'b0000_0000;
	localparam ST_ASSIGN  		= 8'b0000_0010;
	localparam ST_COMPARE 		= 8'b0000_0100;
	localparam ST_SUBTRACE		= 8'b0000_1000;
	localparam ST_RESULT1		= 8'b0001_0000;
	localparam ST_RESULT2		= 8'b0010_0000;
	localparam ST_RESULT3		= 8'b0100_0000;
	localparam ST_END			= 8'b1000_0000;

	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
   	reg  [7:0] 				r_result_state = ST_IDLE;
	reg	 [31:0]				r_result_rise	= 32'h0;
	reg	 [31:0]				r_result_fall	= 32'h0;			
	reg	 [31:0]				r_result_rise1	= 32'h0;
	reg	 [31:0]				r_result_rise2	= 32'h0;
	reg	 [31:0]				r_result_fall1	= 32'h0;
	reg	 [31:0]				r_result_fall2	= 32'h0;
	reg						r_result_new	= 1'b0;

	reg  [31:0]				r_result_diff1	= 32'h0;
	reg  [31:0]				r_result_diff2	= 32'h0;

	wire [31:0]				w_result_start;
	wire [31:0]				w_result_sto11;
	wire [31:0]				w_result_sto12;
	wire [31:0]				w_result_sto21;
	wire [31:0]				w_result_sto22;

	//--------------------------------------------------------------------------------------------------
	// finite-state machin
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_state <= ST_IDLE;
		else begin
			case(r_result_state)
				ST_IDLE:begin
					if(i_gpx2_rdresult)
						r_result_state <= ST_ASSIGN;
					else
						r_result_state <= ST_IDLE;
					end
				ST_ASSIGN:
					r_result_state <= ST_COMPARE;
				ST_COMPARE:begin
					if(r_result_rise2 == 0)
						r_result_state <= ST_RESULT1;
					else if(r_result_rise2 <= r_result_fall1)
						r_result_state <= ST_RESULT2;
					else
						r_result_state <= ST_SUBTRACE;
					end
				ST_SUBTRACE:
					r_result_state <= ST_RESULT3;
				ST_RESULT1:
					r_result_state <= ST_END;
				ST_RESULT2:
					r_result_state <= ST_END;
				ST_RESULT3:
					r_result_state <= ST_END;
				ST_END:
					r_result_state <= ST_IDLE;
				default: r_result_state <= ST_IDLE;
			endcase
		end
	end
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	//r_result_rise1
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_rise1 <= 32'd0;
		else if(r_result_state == ST_IDLE)
			r_result_rise1 <= 32'd0;
	   	else if(r_result_state == ST_ASSIGN)begin
			if(w_result_sto21 == 32'hFFFFFFFF)
				r_result_rise1 <= 32'd0;
			else if(w_result_sto21 <= w_result_start)
				r_result_rise1 <= 32'd0;
			else
				r_result_rise1 <= w_result_sto21[23:16] * 16'd40000 + w_result_sto21[15:0] - w_result_start[23:16] * 16'd40000 - w_result_start[15:0];
		end
	end

	//r_result_rise2
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_rise2 <= 32'd0;
		else if(r_result_state == ST_IDLE)
			r_result_rise2 <= 32'd0;
	   	else if(r_result_state == ST_ASSIGN) begin
			if(w_result_sto22 == 32'hFFFFFFFF)
				r_result_rise2 <= 32'd0;
			else if(w_result_sto22 <= w_result_start)
				r_result_rise2 <= 32'd0;
			else
				r_result_rise2 <= w_result_sto22[23:16] * 16'd40000 + w_result_sto22[15:0] - w_result_start[23:16] * 16'd40000 - w_result_start[15:0];
		end
	end

	//r_result_new
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_new	<= 1'b0;
		else if(r_result_state == ST_IDLE || r_result_state == ST_END)
			r_result_new	<= 1'b0;
		else if(r_result_state == ST_RESULT1 || r_result_state == ST_RESULT2 || r_result_state == ST_RESULT3)
			r_result_new	<= 1'b1;
	end

	//r_result_rise
	//r_result_fall
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_result_rise 	<= 32'd0;
			r_result_fall 	<= 32'd0;
		end else if(r_result_state == ST_IDLE)begin
			r_result_rise 	<= 32'd0;
			r_result_fall 	<= 32'd0;
		end else if(r_result_state == ST_RESULT1)begin
			r_result_rise 	<= r_result_rise1;
			r_result_fall 	<= r_result_fall1;
		end else if(r_result_state == ST_RESULT2)begin
			r_result_rise 	<= r_result_rise2;
			r_result_fall 	<= r_result_fall1;
		end else if(r_result_state == ST_RESULT3)begin
			if(r_result_diff1 <= r_result_diff2)begin
				r_result_rise 	<= r_result_rise2;
				r_result_fall 	<= r_result_fall2;
			end else begin
				r_result_rise 	<= r_result_rise1;
				r_result_fall 	<= r_result_fall1;
			end
		end
	end		
			
	//r_result_diff1;
	//r_result_diff2;
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_result_diff1 	<= 32'd0;
			r_result_diff2 	<= 32'd0;
		end else if(r_result_state == ST_IDLE) begin
			r_result_diff1 <= 32'd0;
			r_result_diff2 <= 32'd0;
		end else if(r_result_state == ST_SUBTRACE) begin
			if(r_result_fall1 >= r_result_rise1)
				r_result_diff1 <= r_result_fall1 - r_result_rise1;
			else
				r_result_diff1 <= 32'd0;
			if(r_result_fall2 >= r_result_rise2)
				r_result_diff2 <= r_result_fall2 - r_result_rise2;
			else
				r_result_diff2 <= 32'd0;
		end
	end

	//r_result_fall1
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_fall1 <= 32'd0;
		else if(r_result_state == ST_IDLE)
			r_result_fall1 <= 32'd0;
	   	else if(r_result_state == ST_ASSIGN) begin
			if(w_result_sto11 == 32'hFFFFFFFF)
				r_result_fall1 <= 32'd0;
			else if(w_result_sto11 <= w_result_start)
				r_result_fall1 <= 32'd0;
			else
				r_result_fall1 <= w_result_sto11[23:16] * 16'd40000 + w_result_sto11[15:0] - w_result_start[23:16] * 16'd40000 - w_result_start[15:0];
		end
	end
	
	//r_result_fall2
	always@(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n)
			r_result_fall2 <= 32'd0;
		else if(r_result_state == ST_IDLE)
			r_result_fall2 <= 32'd0;
	   	else if(r_result_state == ST_ASSIGN)begin
			if(w_result_sto12 == 32'hFFFFFFFF)
				r_result_fall2 <= 32'd0;
			else if(w_result_sto12 <= w_result_start)
				r_result_fall2 <= 32'd0;
			else
				r_result_fall2 <= w_result_sto12[23:16] * 16'd40000 + w_result_sto12[15:0] - w_result_start[23:16] * 16'd40000 - w_result_start[15:0];
		end	
	end

    gpx2_lvds u_gpx2_lvds(
		.i_clk				( i_clk					),
	    .i_lvds_clk         ( i_lvds_clk            ),
		.i_gpx2_ressig		( r_result_new          ),
		 
		.i_lvds_sdo         ( i_lvds_sdo            ),
		.i_lvds_frame       ( i_lvds_frame          ),

		.o_result_start     ( w_result_start		),
		.o_result_sto11     ( w_result_sto11		),
		.o_result_sto12     ( w_result_sto12		),
		.o_result_sto21     ( w_result_sto21		),
		.o_result_sto22     ( w_result_sto22		)
   	);
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
   	assign o_gpx2_signal	= r_result_new;
	assign o_gpx2_result	= {r_result_rise, r_result_fall};
endmodule
