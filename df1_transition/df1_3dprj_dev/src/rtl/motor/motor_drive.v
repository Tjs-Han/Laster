// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: motor_drive
// Date Created 	: 2025/4/25 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:motor_drive
//				Drive motor rotation and Monitor motor running status
//				add pi adjust
//	2024/11/5	
//		The motor refrequency is set to 25K，set "MOTOR_PRF" Value
//		one turn of the motor produces 4 FG signals
//		We can control the motor speed regulation period by the number of FG signals，parameter "SAMP_FG_NUM"

//	2025/04/25	
//		The motor refrequency is set to 25K，set "MOTOR_PRF" Value
//		one turn of the motor produces 7 FG signals
//		We can control the motor speed regulation period by the number of FG signals，parameter "SAMP_FG_NUM"

//	2025/05/13
//		Modify the motor speed regulation logic
// -------------------------------------------------------------------------------------------------
// Revision History :V1.1
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module motor_drive
#(	
	parameter HIGN_SPEED_MOTOR	= 4'h1,
	parameter LOW_SPEED_MOTOR	= 4'h2,
	parameter SEC2NS_REFVAL		= 32'd1000_000_000,
	parameter CLK_PERIOD_NS		= 20,
	parameter MOTOR_PRF			= 32'd25_000
)
(
	input			i_clk_50m,
	input			i_rst_n,
	
	input			i_motor_sw,
	input  [3:0]	i_motor_type,
	input  [15:0]	i_freq_motor,
	input			i_motor_fg,
	input  [15:0]	i_motor_pwm_setval,

	output [15:0]	o_motor_state,
	output [15:0]	o_pwm_value,
	output [31:0]	o_actual_speed,
	output			o_motor_pwm
);
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg  [3:0]		r_state					= 4'd0;
	reg  [15:0]		r_delay_ns_cnt			= 16'd0;
	reg  [15:0]		r_delay_ms_cnt			= 16'd0;
	reg				r_delay_flag			= 1'b0;
	reg				r_freq_switch			= 1'b0;
	wire [15:0]		w_switch_reg;
	reg  [15:0]		r_freq_motor			= 16'd10;
	reg         	r_motor_pwm    			= 1'b0;
	reg				r_speed_governing		= 1'b0;
	reg				r_speed_govern_done		= 1'b0;
	reg				r_speed_govern_failed	= 1'b0;
	reg  [15:0]		r_motor_state 			= 16'h0;
	reg  [15:0]		r_pwm_value   			= 16'd999;
	reg  [15:0]		r_pwm_cnt     			= 16'd999;
	reg  [15:0]		r_pwm_setval			= 16'd199;

	reg	 [31:0]		r_fg_frequency;
	reg	 [7:0]		r_fg_cnt;
	reg  [31:0]		r_fg_clkcnt_cache;
	reg  [31:0]		r_actual_speed;
	
	reg  [23:0]		r_cnt_true;
	wire [23:0]		w_muti_para;
	wire			w_done;
	wire			w_div0;
	wire [23:0]		w0_cal_result;
	wire [31:0]		w1_cal_result;
	reg  [23:0]		r3_clkcnt_hignnum;
	reg  [23:0]		r2_clkcnt_hignnum;
	reg  [23:0]		r1_clkcnt_hignnum;
	reg  [23:0]		r0_clkcnt_hignnum;
	reg  [23:0]		r_set_clknum;
	reg  [23:0]		r_cnt_state_high;
	reg  [23:0]		r0_clkcnt_lownum;
	reg  [23:0]		r1_clkcnt_lownum;
	reg	 [15:0]		r_pwm_value_0 	= 16'd0;
	
	reg				r0_motor_fg;
	reg				r1_motor_fg;
	reg	 [31:0]		r_clk_cnt;
	reg	 [3:0]		r_motor_fg_cnt;
	reg				r_speed_sample;
	reg				r0_speed_sample;
	reg				r1_speed_sample;
	wire			w_motor_fg_rise;
	wire       		w_speed_sample_rise;

	//
	reg	 [7:0] 		r_state_cnt	;
	reg  [7:0]		r_speed_reach_cnt;
	reg				r_speed_stable_flag;
	reg	 [7:0] 		r_speed_overcnt;
	reg				r_speed_oversig;
	//--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam FG_NUM				= 8'd7;
	localparam SAMP_FG_NUM			= 8'd16;
	localparam AMPLIFY				= 8'd101;
	localparam PERIOD_CALPARA0		= SEC2NS_REFVAL/FG_NUM/CLK_PERIOD_NS; //1000000000ns/FG_NUM/20ns
	localparam PERIOD_CALPARA1		= PERIOD_CALPARA0*AMPLIFY; //1000000000ns/FG_NUM/20ns
	localparam SHIFT_WIDTH 			= $clog2(SAMP_FG_NUM);
	localparam MOTOR_PRF_CLKCNT		= SEC2NS_REFVAL/MOTOR_PRF/CLK_PERIOD_NS - 1;
	localparam CLK_DLYCNT			= 16'd50_000;
	localparam SPEED_REACH_CNTNUM	= 8'd50;
	localparam SPEED_OVER_CNTNUM	= 8'd20;

	localparam ST_IDLE				= 4'd0;
	localparam ST_POWER_ON			= 4'd1;
	localparam ST_MOTOR2SET			= 4'd2;
	localparam ST_WAIT_SPEED		= 4'd3;
	localparam ST_SPEED_STABLE		= 4'd4;
	localparam ST_SPEED_FAILED		= 4'd5;
	//--------------------------------------------------------------------------------------------------
	// sequence define
	//--------------------------------------------------------------------------------------------------
	//r_freq_motor   record the last motor frequency
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_freq_motor	<= 16'd10;
		else
			r_freq_motor	<= i_freq_motor;
	end

	//r_pwm_setval PRF is 25k
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_pwm_setval	<= 16'd199;
		else if(i_freq_motor == 8'd60)
			r_pwm_setval	<= 16'd1490;
		else if(i_freq_motor == 8'd70)
			r_pwm_setval	<= 16'd1580;
		else if(i_freq_motor == 8'd71)
			r_pwm_setval	<= 16'd1600;
		else if(i_freq_motor <= 8'd15)
			r_pwm_setval	<= 16'd299;
		else if(i_freq_motor > 8'd15 && i_freq_motor <= 8'd25)
			r_pwm_setval	<= 16'd599;
		else if(i_freq_motor > 8'd25 && i_freq_motor <= 8'd35)
			r_pwm_setval	<= 16'd799;
		else if(i_freq_motor > 8'd35 && i_freq_motor <= 8'd45)
			r_pwm_setval	<= 16'd999;
		else if(i_freq_motor > 8'd45 && i_freq_motor <= 8'd55)
			r_pwm_setval	<= 16'd1249;
		else if(i_freq_motor > 8'd55 && i_freq_motor <= 8'd65)
			r_pwm_setval	<= 16'd1499;
		else if(i_freq_motor > 8'd65)
			r_pwm_setval	<= 16'd1580;
	end

	//PERIOD_CALPARA0='d7142857
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)begin     //  1000000000ns/60HZ/7/20ns
			r2_clkcnt_hignnum	<= 24'd120_832; //101.5%
			r1_clkcnt_hignnum   <= 24'd120_237; //101%
			r0_clkcnt_hignnum	<= 24'd119_642; //100.5%
			r_set_clknum 	 	<= 24'd119_047; //100%
			r0_clkcnt_lownum	<= 24'd118_451; //99.5%
            r1_clkcnt_lownum	<= 24'd117_856; //99%
		end else if(i_freq_motor == 8'd60)begin     //  PERIOD_CALPARA0/60HZ 
			r2_clkcnt_hignnum	<= 24'd120_832; //101.5%
			r1_clkcnt_hignnum   <= 24'd119_642; //100.5%
			r1_clkcnt_hignnum   <= 24'd119_523; //100.4%
			// r1_clkcnt_hignnum   <= 24'd119_404; //100.3%
			// r_set_clknum 	 	<= 24'd119_047; //100%
			r_set_clknum 	 	<= 24'd118_928; //99.9%
			// r_set_clknum 	 	<= 24'd118_809; //99.8%
			r0_clkcnt_lownum	<= 24'd118_451; //99.5%
            r1_clkcnt_lownum	<= 24'd117_856; //99%
		end else if(i_freq_motor == 8'd70)begin     //  PERIOD_CALPARA0/70HZ 
			r2_clkcnt_hignnum	<= 24'd103_570; //101.5%
			r1_clkcnt_hignnum   <= 24'd103_060; //101%
			r0_clkcnt_hignnum	<= 24'd102_550; //100.5%
			r_set_clknum 	 	<= 24'd102_040; //100%
			r0_clkcnt_lownum	<= 24'd101_530; //99.5%
            r1_clkcnt_lownum	<= 24'd101_019; //99%
		end else if(i_freq_motor == 8'd71)begin     //  PERIOD_CALPARA0/70HZ 
			r2_clkcnt_hignnum	<= 24'd102_112; //101.5%
			// r1_clkcnt_hignnum   <= 24'd101_609; //101%
			// r1_clkcnt_hignnum   <= 24'd101_408; //100.8%
			// r1_clkcnt_hignnum   <= 24'd101_307; //100.7%
			// r1_clkcnt_hignnum   <= 24'd101_206; //100.6%
			// r1_clkcnt_hignnum   <= 24'd101_106; //100.5%
			// r1_clkcnt_hignnum   <= 24'd101_006; //100.4%
			// r1_clkcnt_hignnum   <= 24'd100_955; //100.35%
			// r1_clkcnt_hignnum   <= 24'd100_905; //100.3%
			// r1_clkcnt_hignnum   <= 24'd100_855; //100.25%
			r1_clkcnt_hignnum   <= 24'd100_804; //100.2%
			// r_set_clknum 	 	<= 24'd100_603; //100%
			// r_set_clknum 	 	<= 24'd100_503; //99.9%
			// r_set_clknum 	 	<= 24'd100_402; //99.8%
			// r_set_clknum 	 	<= 24'd100_355; //99.75%
			r_set_clknum 	 	<= 24'd100_301; //99.7%
			// r_set_clknum 	 	<= 24'd100_201; //99.6%
			// r_set_clknum 	 	<= 24'd100_150; //99.55%
			// r_set_clknum 	 	<= 24'd100_100; //99.5%
			r0_clkcnt_lownum	<= 24'd100_100; //99.5%
            r1_clkcnt_lownum	<= 24'd99_597;  //99%
		end else begin
			r1_clkcnt_hignnum   <= w1_cal_result;
			r_set_clknum 	 	<= w0_cal_result[23:0];
		end
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)begin
			r0_motor_fg <= 1'd0;
			r1_motor_fg <= 1'd0;
		end else begin
			r0_motor_fg <= i_motor_fg;
			r1_motor_fg <= r0_motor_fg;
		end
	end

	assign w_motor_fg_rise = r0_motor_fg & ~r1_motor_fg;

	//r_fg_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_fg_cnt 		<= 8'd0;
			r_speed_sample	<= 1'b0;
		end else if(r_fg_cnt >= SAMP_FG_NUM) begin
			r_fg_cnt 		<= 8'd0;
			r_speed_sample	<= 1'b1;
		end else if(w_motor_fg_rise) begin
			r_fg_cnt 		<= r_fg_cnt + 1'b1;
			r_speed_sample	<= 1'b0;
		end else
			r_speed_sample	<= 1'b0;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_fg_frequency <= 32'd0;
		else if(i_motor_sw) begin
			if(r_fg_cnt == SAMP_FG_NUM)
				r_fg_frequency <= 32'd0;
			else if(r_fg_frequency >= 32'd150_000_000)
				r_fg_frequency <= 32'd150_000_000;
			else
				r_fg_frequency <= r_fg_frequency + 1'd1;
		end else
			r_fg_frequency <= 32'd0;
	end
	
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_fg_clkcnt_cache <= 32'd0;
		else if(r_fg_cnt == SAMP_FG_NUM)
			r_fg_clkcnt_cache <= r_fg_frequency >> SHIFT_WIDTH;
		else
			r_fg_clkcnt_cache <= r_fg_clkcnt_cache ;		
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_delay_ns_cnt	<= 16'd0;
			r_delay_ms_cnt	<= 16'd0;
		end else if(r_delay_flag) begin
			if(r_delay_ns_cnt >= CLK_DLYCNT-1) begin
				r_delay_ns_cnt	<= 16'd0;
				r_delay_ms_cnt 	<= r_delay_ms_cnt + 1'b1;
			end else
				r_delay_ns_cnt 	<= r_delay_ns_cnt + 1'b1;
		end else begin
			r_delay_ns_cnt	<= 16'd0;
			r_delay_ms_cnt	<= 16'd0;
		end
	end

	//r_freq_switch
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_freq_switch	<= 1'b0;
		else if(i_freq_motor != r_freq_motor)
			r_freq_switch	<= 1'b1;
		else
			r_freq_switch	<= 1'b0;
	end

	// STATE
	always @(posedge i_clk_50m or negedge i_rst_n) begin
		if (!i_rst_n) begin
			r_state					<= ST_IDLE;
			r_delay_flag			<= 1'b0;
			r_speed_govern_failed	<= 1'b0;
		end else begin
			case(r_state)
				ST_IDLE: begin
					r_delay_flag	<= 1'b0;
					if(i_motor_sw)
						r_state	<= ST_POWER_ON;
					else
						r_state	<= ST_IDLE;
				end
				ST_POWER_ON: begin
					if(r_delay_ms_cnt == 16'd999) begin
						r_delay_flag	<= 1'b0;
						r_state			<= ST_MOTOR2SET;
					end else begin
						r_delay_flag	<= 1'b1;
						r_state			<= ST_POWER_ON;
					end
				end
				ST_MOTOR2SET: begin
					r_speed_govern_failed	<= 1'b0;
					if(r_delay_ms_cnt == 16'd2999) begin
						r_delay_flag	<= 1'b0;
						r_state			<= ST_WAIT_SPEED;
					end else begin
						r_delay_flag	<= 1'b1;
						r_state			<= ST_MOTOR2SET;
					end
				end
				ST_WAIT_SPEED: begin
					r_delay_flag	<= 1'b1;
					if(r_freq_switch) begin
						r_state	<= ST_MOTOR2SET;
						r_delay_flag	<= 1'b0;
					end else if(r_speed_stable_flag) begin
						r_state			<= ST_SPEED_STABLE;
						r_delay_flag	<= 1'b0;
					end else if(r_delay_ms_cnt >= 16'd14999) begin
						r_state	<= ST_SPEED_FAILED;
						r_delay_flag	<= 1'b0;
					end else
						r_state	<= ST_WAIT_SPEED;	
				end
				ST_SPEED_STABLE: begin
					r_speed_govern_failed	<= 1'b0;
					if(r_freq_switch)
						r_state	<= ST_MOTOR2SET;
					else if(r_speed_oversig)
						r_state	<= ST_WAIT_SPEED;
					else if(~i_motor_sw)
						r_state	<= ST_IDLE;
					else
						r_state	<= ST_SPEED_STABLE;
				end
				ST_SPEED_FAILED: begin
					r_delay_flag			<= 1'b0;
					r_speed_govern_failed	<= 1'b1;
					if(r_freq_switch)
						r_state	<= ST_MOTOR2SET;
					else
						r_state	<= ST_WAIT_SPEED;
				end
				default: ;
			endcase
		end
	end

	// reach to target speed
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_pwm_value <= 16'd999;
		else if(r_state == ST_MOTOR2SET)
			r_pwm_value <= r_pwm_setval;
		else if(r_state == ST_WAIT_SPEED && r_speed_sample)begin
			if(r_fg_clkcnt_cache > r_set_clknum && r_fg_clkcnt_cache < r1_clkcnt_hignnum)
				r_pwm_value <= r_pwm_value;
			else if(r_fg_clkcnt_cache >= r1_clkcnt_hignnum && r_pwm_value <= 16'd1999)
				r_pwm_value <= r_pwm_value + 1'b1;
			else if(r_fg_clkcnt_cache <= r_set_clknum && r_pwm_value > 16'd30)
				r_pwm_value <= r_pwm_value - 1'b1;			
			else 
				r_pwm_value <= r_pwm_value;
		end
	end
			
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_pwm_cnt <= MOTOR_PRF_CLKCNT;
		else if(r_pwm_cnt >= MOTOR_PRF_CLKCNT)
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 16'd1;
	end


	//output ctrl pwm to motor
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_motor_pwm <= 1'b0;
		end else if(~i_motor_sw) begin
			r_motor_pwm <= 1'b0;
		end else begin
		 	if(r_pwm_cnt < r_pwm_value)
				r_motor_pwm <= 1'b1;
			else
				r_motor_pwm <= 1'b0;
		end
	end

	// // Temporary
	// always@(posedge i_clk_50m or negedge i_rst_n) begin
	// 	if(i_rst_n == 0)
	// 		r_motor_pwm <= 1'b0;
	// 	else if(~i_motor_sw)
	// 		r_motor_pwm <= 1'b0;
	// 	else if(r_pwm_cnt < i_motor_pwm_setval)
	// 		r_motor_pwm <= 1'b1;
	// 	else
	// 		r_motor_pwm <= 1'b0;
	// end
	//----------------------------------------------------------------------------------------------
	// motor state monit
	//----------------------------------------------------------------------------------------------
	//r_speed_reach_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_speed_reach_cnt <= 8'd0;
		else if(r_state == ST_WAIT_SPEED && r_speed_sample)begin
			if(r_fg_clkcnt_cache > r_set_clknum && r_fg_clkcnt_cache < r1_clkcnt_hignnum)
				r_speed_reach_cnt <= r_speed_reach_cnt + 1'b1;
			else 
				r_speed_reach_cnt <= 8'd0;
		end else if(r_state != ST_WAIT_SPEED)
			r_speed_reach_cnt <= 8'd0;
	end

	//r_speed_stable_flag
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_speed_stable_flag <= 1'b0;
		else if(r_speed_reach_cnt >= SPEED_REACH_CNTNUM)
			r_speed_stable_flag <= 1'b1;
		else if(r_state == ST_SPEED_STABLE) begin
			if(r_speed_oversig)
				r_speed_stable_flag <= 1'b0;
			else
				r_speed_stable_flag <= 1'b1;
		end else
			r_speed_stable_flag <= 1'b0;
	end

	//r_speed_govern_done
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_speed_govern_done <= 1'b0;
		else if(r_speed_stable_flag)
			r_speed_govern_done <= 1'b1;
	end	

	//r_speed_governing
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_speed_governing <= 1'b0;
		else if(r_state == ST_WAIT_SPEED)
			r_speed_governing <= 1'b1;
		else
			r_speed_governing <= 1'b0;
	end	

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_speed_overcnt <= 8'd0;
		else if(r_state == ST_SPEED_STABLE && r_speed_sample)begin
			if(r_fg_clkcnt_cache > r_set_clknum && r_fg_clkcnt_cache < r1_clkcnt_hignnum)
				r_speed_overcnt <= 8'd0;
			else 
				r_speed_overcnt <= r_speed_overcnt + 1'b1;
		end else if(r_state != ST_SPEED_STABLE)
			r_speed_overcnt <= 8'd0;
	end

	//r_speed_oversig
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_speed_oversig <= 1'b0;
		else if(r_speed_overcnt >= SPEED_OVER_CNTNUM)
			r_speed_oversig <= 1'b1;
		else if(r_speed_stable_flag)
			r_speed_oversig <= 1'b0;
	end	

	//r_motor_fg_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_motor_fg_cnt	<= 4'd0;
		else if(r_motor_fg_cnt == FG_NUM)
			r_motor_fg_cnt	<= 4'd0;
		else if(w_motor_fg_rise)
			r_motor_fg_cnt	<= r_motor_fg_cnt + 1'b1;
	end	

	//r_clk_cnt
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_clk_cnt	<= 32'd0;
		else if(r_motor_fg_cnt == FG_NUM)
			r_clk_cnt	<= 32'd0;
		else
			r_clk_cnt	<= r_clk_cnt + 1'b1;
	end	

	//r_actual_speed
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			r_actual_speed	<= 32'd0;
		else if(r_motor_fg_cnt == FG_NUM)
			r_actual_speed	<= r_clk_cnt;
	end	
	//----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	assign w_switch_reg = {w_switch_reg[14:0], r_freq_switch};

	divider_32_16bit u_divider1
	(
		.i_clk				( i_clk_50m				),
		.i_rst_n			( i_rst_n				),

		.i_start			( r_freq_switch			),
		.i_dividend			( PERIOD_CALPARA0		),
		.i_divisor			( i_freq_motor			),
		.o_quotient			( w0_cal_result			),
		.o_done				( w_done				),
		.o_div0				( w_div0				)
	);

    // divider_24bit u_divider_24bit
    // (
    //     .clk            ( i_clk_50m				),
    //     .rstn           ( i_rst_n               ),
    //     .denominator    ( i_freq_motor			),//input [15:0]
    //     .numerator      ( PERIOD_CALPARA0		),//input [23:0]
    //     .quotient       ( w0_cal_result			),//output [23:0]
    //     .remainder      (                       )
    // );

	// multiplier_16x8 u_multiplier_16x8
	multiplier_16x8 u_multiplier_16x8
	(
		.Clock			( i_clk_50m				), 
		.ClkEn			( 1'b1					), 
		.Aclr			( 1'b0					), 
		.DataA			( i_freq_motor			), //input [15:0]
        .DataB			( 8'd100				), 
		.Result			( w_muti_para			)//output [23:0]
    );

	divider_32_16bit u_divider2
	(
		.i_clk				( i_clk_50m				),
		.i_rst_n			( i_rst_n				),

		.i_start			( w_switch_reg[8]		),
		.i_dividend			( PERIOD_CALPARA1		),
		.i_divisor			( w_muti_para[15:0]		),
		.o_quotient			( w1_cal_result			),
		.o_done				( 						),
		.o_div0				( 						)
	);

    // divider_32x24 u_divider_32x24
    // (
    //     .clk            ( i_clk_50m				),
    //     .rstn           ( i_rst_n               ),
    //     .denominator    ( w_muti_para			),//input [23:0]
    //     .numerator      ( PERIOD_CALPARA1		),//input [31:0]
    //     .quotient       ( w1_cal_result			),//output [31:0]
    //     .remainder      (                       )
    // );
	//--------------------------------------------------------------------------------------------------
	// output assign define
	//--------------------------------------------------------------------------------------------------	
	assign o_motor_pwm		= r_motor_pwm;
	assign o_pwm_value		= r_pwm_value;
	assign o_motor_state	= i_motor_sw ? {15'h0, r_speed_govern_done} : 16'h0f;
	assign o_actual_speed	= r_actual_speed;

endmodule 