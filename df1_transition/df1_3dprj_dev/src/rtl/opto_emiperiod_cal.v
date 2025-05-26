// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: opto_emiperiod_cal
// Date Created 	: 2024/08/31 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:opto_emiperiod_cal module
//				The light time interval is calculated according to the light frequency
//				Based on Clock counting 
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module opto_emiperiod_cal
#(
	parameter OPTO_FREQ		= 32'd300_000
)
(
	input       i_clk,
	input       i_rst_n,

	output		o_angle_sync,
	output		o_gpx2_init
);
	//----------------------------------------------------------------------------------------------
	/* 	localparam and localparam define

	*/
	//----------------------------------------------------------------------------------------------
	localparam SEC_REFVAL		= 32'd1000_000_000;
	localparam CLK_PERIOD_NS	= 10;
	localparam LASER_CLK_CNT	= SEC_REFVAL/OPTO_FREQ/CLK_PERIOD_NS;
	//----------------------------------------------------------------------------------------------
	//	reg define
	//----------------------------------------------------------------------------------------------
	reg			r_angle_sync		= 1'b0;
	reg			r_gpx2_init			= 1'b0;
	reg	[15:0]	r_clk_cnt 			= 16'd0;
	reg	[15:0]	r_initclk_cnt		= 16'd0;

	reg			r_module_en			= 1'b0;
	reg  [31:0]	r_moden_delaycnt	= 32'd0;
	//----------------------------------------------------------------------------------------------
	/* 	localparam and localparam define
		calculate laser time
	*/
	//----------------------------------------------------------------------------------------------

	always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_module_en 		<= 1'b0;
			r_moden_delaycnt	<= 32'd0;
        end else if(r_moden_delaycnt >= 32'd400_000_000)begin
            r_module_en 		<= 1'b1;
			r_moden_delaycnt	<= r_moden_delaycnt;
		end else begin
			r_module_en 		<= 1'b0;
			r_moden_delaycnt	<= r_moden_delaycnt + 32'd1;
		end
    end
	
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_angle_sync	<= 1'b0;
			r_clk_cnt		<= 16'd0;
		end else if(r_module_en) begin
			if(r_clk_cnt <= LASER_CLK_CNT-1)begin
				r_angle_sync	<= 1'b0;
				r_clk_cnt		<= r_clk_cnt + 1'b1;
			end else begin
				r_angle_sync	<= 1'b1;
				r_clk_cnt		<= 16'd0;
			end
		end else begin
			r_angle_sync	<= 1'b0;
			r_clk_cnt		<= 16'd0;
		end
	end	

	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_gpx2_init		<= 1'b0;
		else if(r_clk_cnt == LASER_CLK_CNT-700) 
			r_gpx2_init		<= 1'b1;
		else
			r_gpx2_init		<= 1'b0;
	end		

	//----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------		
	assign o_angle_sync = r_angle_sync;
	assign o_gpx2_init	= r_gpx2_init;		
endmodule 