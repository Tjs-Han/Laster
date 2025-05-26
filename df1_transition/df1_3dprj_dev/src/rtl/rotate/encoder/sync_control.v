// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: sync_control
// Date Created 	: 2024/09/07 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// File description	:sync_control
//                  generate laering signal
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module sync_control
#(
	parameter SEC2NS_REFVAL	= 1000_000_000,
	parameter CLK_PERIOD_NS	= 10,
	parameter MOTOR_FREQ	= 100,
	parameter OPTO_FREQ		= 300_000,
	parameter TOOTH_NUM		= 100
)
(
	input				i_clk,
	input				i_rst_n,

	input				i_motor_state,
	input  [3:0]		i_reso_mode,

	input				i_zero_sign,
	input				i_opto_rise,
	input  [23:0]		i_cyc_result,

	output        		o_angle_sync,
	output				o_tdc_strdy,
    output          	o_zero_sign        
);
	//----------------------------------------------------------------------------------------------
	/* 	parameter and localparam define
		two code per tooth
		CLK_PERIOD_NS: i_clk period,the units are ns,use to calculate clk cnt
		TOTAL_CODE_NUM: df1 the code disk is designed for 100 teeth, 98 normal tooth and 1 zero tooth
						which is 196 normal code and 2 zero code.
	*/ 
	//----------------------------------------------------------------------------------------------
	parameter LASER_CLK_CNT				= SEC2NS_REFVAL/OPTO_FREQ/CLK_PERIOD_NS;
	parameter NORMAL_TOOTH_LASERNUM     = OPTO_FREQ/MOTOR_FREQ/TOOTH_NUM;
    parameter ZER0_TOOTH_LASERNUM       = NORMAL_TOOTH_LASERNUM << 1;
	parameter FS_IDLE  					= 8'b0000_0000,
			  FS_WAIT  					= 8'b0000_0010,
			  FS_JUDGE 					= 8'b0000_0100,
			  FS_BEGIN 					= 8'b0000_1000,		
			  FS_DELAY 					= 8'b0001_0000,					
			  FS_CYC   					= 8'b0010_0000,
			  FS_INRV  					= 8'b0100_0000;
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg  [7:0]		fs_state        	= 8'd0;
	reg        		r_angle_sync    	= 1'd0; 
	reg	 [7:0]		r_pss_cnt       	= 8'd0; 
	reg	 [7:0]		r_angle_cnt     	= 8'd0;
	reg	 [23:0]		r_inrv_cnt      	= 24'd0;
	reg	 [23:0]		r_cyc_result    	= 24'd0;
	reg				r_opto_rise     	= 1'd0;
	reg				r_zero_sign     	= 1'd0;
	reg				r_zero_sign_r   	= 1'd0;
	reg             r_tdc_strdy			= 1'b0;
	reg  [15:0]		r_tdc_strdy_cnt		= 16'd100;
	reg  [17:0]		r_dly1ms_clkcnt		= 18'd0;
	reg  [15:0]		r_dly1s_1mscnt		= 16'd0;
	reg	 [23:0]		r_temp_dlysnt		= 24'd0;
	reg				r_err_flag			= 1'b0;
	reg  [7:0]		r_rise_cnt			= 8'd0;
	//----------------------------------------------------------------------------------------------
	// flip-flop interface domain
	//----------------------------------------------------------------------------------------------
    //r_opto_rise
    always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_opto_rise <= 1'b0;
		else if(fs_state == FS_BEGIN || fs_state == FS_WAIT || fs_state == FS_JUDGE)
			r_opto_rise <= 1'b0;
		else if(i_opto_rise)
			r_opto_rise <= 1'b1;
    end

	//r_temp_dlysnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_temp_dlysnt	<= 24'd0;
		else if(r_opto_rise)
			r_temp_dlysnt	<= r_temp_dlysnt + 1'b1;
		else
			r_temp_dlysnt	<= 24'd0;
	end

    //r_zero_sign
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_zero_sign <= 1'd0;
		else if(fs_state == FS_JUDGE || fs_state == FS_WAIT)
			r_zero_sign <= 1'd0;
		else if(i_zero_sign)
			r_zero_sign <= 1'd1;
    end

	//r_cyc_result
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			// r_cyc_result    <= 24'd277;
			r_cyc_result    <= LASER_CLK_CNT;
		else 
			r_cyc_result    <= i_cyc_result;
	end
	//r_dly1ms_clkcnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_dly1ms_clkcnt	<= 18'd0;
		else if(fs_state == FS_DELAY) begin
			if(r_dly1ms_clkcnt >= 18'd100_000)
				r_dly1ms_clkcnt	<= 18'd0;
			else
				r_dly1ms_clkcnt	<= r_dly1ms_clkcnt + 1'b1;
		end else
			r_dly1ms_clkcnt	<= 18'd0;
	end
	//r_dly1s_1mscnt
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_dly1s_1mscnt	<= 16'd0;
		else if(fs_state == FS_DELAY) begin
			if(r_dly1ms_clkcnt >= 18'd100_000)
				r_dly1s_1mscnt	<= r_dly1s_1mscnt + 1'b1;
			else
				r_dly1s_1mscnt	<= r_dly1s_1mscnt;
		end else
			r_dly1s_1mscnt	<= 10'd0;
	end	

	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			// r_tdc_strdy_cnt	<= LASER_CLK_CNT - 16'd700;
			r_tdc_strdy_cnt	<= LASER_CLK_CNT - 16'd10;
		else 
			// r_tdc_strdy_cnt	<= i_cyc_result - 16'd700;
			r_tdc_strdy_cnt	<= i_cyc_result - 16'd10;
	end
	//r_rise_cnt		
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_rise_cnt	<= 8'd0;
		else if(i_zero_sign)
			r_rise_cnt	<= 8'd0;
		else if(i_opto_rise)
			r_rise_cnt	<= r_rise_cnt + 1'd1;
    end

	//r_err_flag
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)
			r_err_flag	<= 1'b0;
		else if(fs_state == FS_BEGIN && r_opto_rise) begin
			if(r_pss_cnt + 1'b1 == r_rise_cnt)
				r_err_flag	<= 1'b0;
			else
				r_err_flag	<= 1'b1;
		end else if(fs_state == FS_JUDGE)
			r_err_flag	<= 1'b0;
	end

    always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0)begin
			r_tdc_strdy		<= 1'b0;
			r_zero_sign_r 	<= 1'b0;
			r_pss_cnt       <= 8'd0;
			r_angle_sync    <= 1'b0;
			r_angle_cnt     <= 8'd0;
			r_inrv_cnt      <= 24'd0;
            fs_state        <= FS_IDLE;
		end else begin
			case(fs_state)
				FS_IDLE  :begin
					r_tdc_strdy		<= 1'b0;
					r_zero_sign_r 	<= 1'b0;
                    r_pss_cnt       <= 8'd0;
                    r_angle_sync    <= 1'b0;
                    r_angle_cnt     <= 8'd0;
                    r_inrv_cnt      <= 24'd0;
					fs_state        <= FS_WAIT;
				end
				FS_WAIT	:begin
					if(i_motor_state)
						fs_state	<= FS_DELAY;
					else
						fs_state	<= FS_WAIT;
				end
				FS_DELAY: begin
					if(r_dly1s_1mscnt >= 16'd6000)
						fs_state	<= FS_JUDGE;
					else
						fs_state	<= FS_DELAY;
				end
				FS_JUDGE :begin
					r_zero_sign_r 	<= 1'b0;
					if(i_zero_sign || r_zero_sign)begin
						r_tdc_strdy		<= 1'b0;
						r_zero_sign_r 	<= 1'b1;
						r_pss_cnt	    <= 8'd0;
						r_angle_cnt		<= 8'd0;
						r_inrv_cnt		<= 24'd0;
						fs_state	    <= FS_CYC;
					end else begin
						fs_state	    <= FS_JUDGE;
					end
				end				
				FS_BEGIN :begin
					r_angle_sync	<= 1'b0;
					if(i_zero_sign)
						fs_state		<= FS_JUDGE;
					else if(i_opto_rise || r_opto_rise)begin
						r_pss_cnt		<= r_pss_cnt + 1'b1;
                        r_angle_cnt		<= 8'd0;
						r_inrv_cnt		<= 24'd0;
						fs_state		<= FS_CYC;
					end
				end
				FS_CYC  :begin
					r_zero_sign_r 	<= 1'b0;
					r_angle_sync    <= 1'b1;
					r_angle_cnt     <= r_angle_cnt + 1'b1;
					fs_state        <= FS_INRV;
				end
				FS_INRV :begin
					r_angle_sync    <= 1'b0;
					if(r_inrv_cnt + 2'd2 < r_cyc_result)begin
						r_inrv_cnt	    <= r_inrv_cnt + 1'b1;
						fs_state	    <= FS_INRV;
						if(r_inrv_cnt == r_tdc_strdy_cnt)
							r_tdc_strdy		<= 1'b1;
						else
							r_tdc_strdy		<= 1'b0;
					end else begin
						r_inrv_cnt		<= 24'd0;
						if(r_pss_cnt + 2'd2 >= TOOTH_NUM)begin
							if(r_angle_cnt < ZER0_TOOTH_LASERNUM)
								fs_state		<= FS_CYC;
							else
								fs_state		<= FS_JUDGE;
						end else begin
							if(r_angle_cnt < NORMAL_TOOTH_LASERNUM)
								fs_state		<= FS_CYC;
							else
								fs_state		<= FS_BEGIN;
						end
					end
				end
				default:fs_state     <= FS_IDLE;
			endcase
		end
    end
	//test temp
	reg  [15:0]		r_tset_cnt;
	reg  [15:0]		r_store;
	always@(posedge i_clk or negedge i_rst_n)begin
		if(i_rst_n == 0) begin
			r_tset_cnt	<= 16'd0;
			r_store		<= 16'd0;
		end else if(r_angle_sync) begin
			r_tset_cnt	<= 16'd0;
			r_store		<= r_tset_cnt;
		end else begin
			r_tset_cnt	<= r_tset_cnt + 1'b1;
			r_store		<= r_store;
		end
	end
	//----------------------------------------------------------------------------------------------
	// output assign
	//----------------------------------------------------------------------------------------------    
    assign o_angle_sync = r_angle_sync;
    assign o_zero_sign  = r_zero_sign_r;
	assign o_tdc_strdy	= r_tdc_strdy;
endmodule