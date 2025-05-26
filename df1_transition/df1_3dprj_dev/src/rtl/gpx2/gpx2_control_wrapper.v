// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_control_wrapper
// Date Created 	: 2024/09/05 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:gpx2_control_wrapper
//				Frame3 sdo3 is stop3 channel matched start, main wave
//				Frame2 sdo2 is stop2 channel cmatched final edge , echo wave
//				Frame1 sdo1 is stop1 channel cmatched front edge , echo wave
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module gpx2_control_wrapper
#(	
	parameter GPX2_SPICPOL			= 1'b0,
	parameter GPX2_SPICPHA			= 1'b1,
	parameter CLK_DIV_NUM			= 8'd8,
	parameter SPICOM_INRV_CLKCNT	= 8'd4
)
(
	input					i_clk_100m,
	input					i_rst_n,

	//lvds signal
	input      				i_gpx2_lvds_lclkout,
	input [2:0]				i_gpx2_lvds_frame,
	input [2:0]				i_gpx2_lvds_sdo,
	
	// control signal           
	input					i_tdc_interrupt,    
    input                   i_gpx2_measure_en,
    input                   i_gpx2_measure_sign,
    input                   i_gpx2_init,
	input  [15:0]			i_code_angle1,
	input  [15:0]			i_code_angle2,
	
	input					i_tdc_spi_miso,
	output					o_tdc_spi_mosi,
	output					o_tdc_spi_ssn,
	output					o_tdc_spi_clk,

	output					o_tdcmodule_en,
	output					o_tdc_ready,
	output      			o_gpx2_signal,
	output [31:0]			o_gpx2_risedata,
   	output [31:0]			o_gpx2_falldata,
	output [15:0]			o_gpx2_code_angle1,
	output [15:0]			o_gpx2_code_angle2
);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg  [7:0]   			r_curr_state		= 8'h0;
    reg  [7:0]   			r_next_state		= 8'h0;
	reg						r_tdcmodule_en		= 1'b0;
	reg  [31:0]				r_tdcen_delaycnt	= 32'd0;
	reg 					r1_tdc_interrupt	= 1'b1;
	reg 					r2_tdc_interrupt	= 1'b1;
	// inst gpx2
	wire   					w_spicom_req;
	wire [7:0]  			w_spi_wdata;
	wire   					w_spicom_ready;
	wire  					w_spi_rdvalid;
	wire [7:0]  			w_spi_rdbyte;

	reg  [31:0]         	r_valid_data1		= 32'h0;
	reg  [31:0]         	r_valid_data2		= 32'h0;
	reg  [31:0]         	r_valid_data3		= 32'h0;

	reg  [31:0]         	r_result_stop1		= 32'h0;
	reg  [31:0]         	r_result_stop2		= 32'h0;
	reg  [31:0]         	r_result_stop3		= 32'h0;

	reg						r_angle_sync		= 1'b0;
	reg  [15:0]				r_code_angle1		= 16'd0;
	reg  [15:0]				r_code_angle2		= 16'd0;
	reg						r_tdcsync_ready		= 1'b1;
	wire					w_filldata_sig;
	reg  [2:0]				r_ecocnt			= 3'd0;
	reg  [5:0]				r_cal_dlycnt		= 6'd0;
	reg						r_cal_flag			= 1'b0;
	reg						r_tdc_sig			= 1'b0;
	reg						r_gpx2_signal		= 1'b0;
	reg  [31:0]         	r_tdc_risedata		= 32'h0;
	reg  [31:0]         	r_tdc_falldata		= 32'h0;
	reg  [15:0]				r_gpx2_code_angle	= 16'h0;
	wire [31:0]         	w_result_rise;
	wire [31:0]         	w_result_fall;

	reg  [31:0]         	r_start_data		= 32'h0;
	reg  [31:0]         	r_data_stop1		= 32'h0;
	reg  [31:0]         	r_data_stop2		= 32'h0;
	
	reg  [2:0]          	r1_lvds_sdo			= 3'h0;
	reg  [2:0]          	r2_lvds_sdo			= 3'h0;

	reg  [2:0]          	r1_lvds_frame		= 3'h0;
	reg  [2:0]          	r2_lvds_frame		= 3'h0;

	reg  [5:0]          	r_result_cnt1		= 6'd0;
	reg  [5:0]          	r_result_cnt2		= 6'd0;
	reg  [5:0]          	r_result_cnt3		= 6'd0;
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
	localparam ST_IDLE							= 8'd0;
    localparam ST_READY							= 8'd1;
    localparam ST_WAIT_MFRAME					= 8'd2;
	localparam ST_WAIT_ECORISE					= 8'd3;
    localparam ST_WAIT_ECOFALL					= 8'd4;
	localparam ST_WAIT_ECOEND					= 8'd5;
	localparam ST_ECOEND						= 8'd6;
	localparam ST_JUDGE							= 8'd7;
    localparam ST_WAIT_CAL						= 8'd8;
	localparam ST_START_CAL						= 8'd9;
    localparam ST_OUT_RESULT					= 8'd10;
    localparam ST_DONE							= 8'd11;
	//--------------------------------------------------------------------------------------------------
	// sequence define
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tdcmodule_en 		<= 1'b0;
			r_tdcen_delaycnt	<= 32'd0;
        end else if(r_tdcen_delaycnt >= 32'd400_000)begin
            r_tdcmodule_en 		<= 1'b1;
			r_tdcen_delaycnt	<= r_tdcen_delaycnt;
		end else begin
			r_tdcmodule_en 		<= 1'b0;
			r_tdcen_delaycnt	<= r_tdcen_delaycnt + 32'd1;
		end
    end
	//--------------------------------------------------------------------------------------------------
	// flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk_100m) begin
		r1_tdc_interrupt   <= i_tdc_interrupt;
		r2_tdc_interrupt   <= r1_tdc_interrupt;
	end

	always@(posedge i_gpx2_lvds_lclkout) begin
		r1_lvds_frame   <= i_gpx2_lvds_frame;
		r2_lvds_frame   <= r1_lvds_frame;
		r1_lvds_sdo     <= i_gpx2_lvds_sdo;
		r2_lvds_sdo     <= r1_lvds_sdo;
	end

	//r_result_cnt1
	always@(posedge i_gpx2_lvds_lclkout) begin
	    if(r_result_cnt1 > 6'd0) begin
		    r_result_stop1	<= {r_result_stop1[30:0],r2_lvds_sdo[0]};
			r_result_cnt1	<= r_result_cnt1 - 1'b1;
		end else if(r2_lvds_frame[0]) begin
		    r_result_cnt1	<= 6'd31;
			r_result_stop1	<= {r_result_stop1[30:0],r2_lvds_sdo[0]};
		end
    end

	always@(posedge i_gpx2_lvds_lclkout) begin
	    if(r_result_cnt2 > 6'd0) begin
		    r_result_stop2	<= {r_result_stop2[30:0],r2_lvds_sdo[1]};
			r_result_cnt2	<= r_result_cnt2 - 1'b1;
		end else if(r2_lvds_frame[1]) begin
		    r_result_cnt2	<= 6'd31;
			r_result_stop2	<= {r_result_stop2[30:0],r2_lvds_sdo[1]};
		end
    end

	always@(posedge i_gpx2_lvds_lclkout) begin
	    if(r_result_cnt3 > 6'd0) begin
		    r_result_stop3	<= {r_result_stop3[30:0],r2_lvds_sdo[2]};
			r_result_cnt3	<= r_result_cnt3 - 1'b1;
		end else if(r2_lvds_frame[2]) begin
		    r_result_cnt3	<= 6'd31;
			r_result_stop3	<= {r_result_stop3[30:0],r2_lvds_sdo[2]};
		end
    end

	always@(posedge i_gpx2_lvds_lclkout) begin
		if(r_result_cnt1 == 6'd0)
			r_valid_data1	<= r_result_stop1;
		else
			r_valid_data1	<= r_valid_data1;
	end

	always@(posedge i_gpx2_lvds_lclkout) begin
		if(r_result_cnt2 == 6'd0)
			r_valid_data2	<= r_result_stop2;
		else
			r_valid_data2	<= r_valid_data2;
	end

	always@(posedge i_gpx2_lvds_lclkout) begin
		if(r_result_cnt3 == 6'd0)
			r_valid_data3	<= r_result_stop3;
		else
			r_valid_data3	<= r_valid_data3;
	end
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_angle_sync 	<= 1'b0;
			r_code_angle1	<= 16'd0;
			r_code_angle2	<= 16'd0;
        end else begin
            r_angle_sync 	<= i_gpx2_measure_sign;
			r_code_angle1	<= i_code_angle1;
			r_code_angle2	<= i_code_angle2;
        end
    end
	//--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
	//r_curr_state
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_curr_state <= ST_IDLE;
        end else begin
            r_curr_state <= r_next_state;
        end
    end

    //r_next_state trans comb logic
    always @(*) begin
		if(r_angle_sync)
			r_next_state = ST_IDLE;
		else begin
        	case(r_curr_state)
        	    ST_IDLE: begin
        	        if(r_tdcmodule_en)    
        	            r_next_state = ST_WAIT_MFRAME;
        	        else
        	            r_next_state = ST_IDLE;
        	    end
				ST_WAIT_MFRAME: begin
					if(r2_lvds_frame[2])
        	            r_next_state = ST_WAIT_ECORISE;
        	        else
        	            r_next_state = ST_WAIT_MFRAME;
				end
				ST_WAIT_ECORISE: begin
					if(r2_lvds_frame[0])
        	            r_next_state = ST_WAIT_ECOFALL;
        	        else
        	            r_next_state = ST_WAIT_ECORISE;
				end
				ST_WAIT_ECOFALL: begin
					if(r2_lvds_frame[1])
        	            r_next_state = ST_WAIT_ECOEND;
        	        else
        	            r_next_state = ST_WAIT_ECOFALL;
				end
				ST_WAIT_ECOEND: begin
					if(r2_lvds_frame[1])
						r_next_state = ST_WAIT_ECOEND;
					else
						r_next_state = ST_ECOEND;
				end
				ST_ECOEND: r_next_state = ST_JUDGE;
				ST_JUDGE: begin
					if(r_ecocnt == 3'd1)
						r_next_state = ST_WAIT_ECORISE;
					else if(r_ecocnt == 3'd2)
						r_next_state = ST_WAIT_CAL;
					else
						r_next_state = ST_JUDGE;
				end
				ST_WAIT_CAL: begin
					if(r_cal_flag)
						r_next_state = ST_START_CAL;
					else
						r_next_state = ST_WAIT_CAL;
				end
				ST_START_CAL: begin
					if(r_cal_dlycnt >= 6'd10)
						r_next_state = ST_OUT_RESULT;
					else
						r_next_state = ST_START_CAL;
				end
				ST_OUT_RESULT: r_next_state = ST_DONE;
				ST_DONE: r_next_state = ST_WAIT_MFRAME;
        	    default : begin
        	        r_next_state = ST_IDLE;
        	    end
			endcase
		end
	end

	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
			r_ecocnt		<= 3'd0;
			r_cal_flag		<= 1'b0;
            r_tdc_sig    	<= 1'b0;
			r_start_data	<= 32'h0;
			r_data_stop1	<= 32'h0;
			r_data_stop2	<= 32'h0;
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
					r_ecocnt		<= 3'd0;
					r_cal_flag		<= 1'b0;
                    r_tdc_sig    	<= 1'b0;
					r_start_data	<= 32'h0;
					r_data_stop1	<= 32'h0;
					r_data_stop2	<= 32'h0;
                end 
				ST_ECOEND: begin
					r_ecocnt	<= r_ecocnt + 1'b1;
				end
				ST_WAIT_CAL: begin
					r_cal_dlycnt	<= 6'd0;
					if(r_result_cnt3 == 6'd0)
						r_start_data	<= r_result_stop3;
					else
						r_start_data	<= r_start_data;

					if(r_result_cnt1 == 6'd0)
						r_data_stop1	<= r_result_stop1;
					else
						r_data_stop1	<= r_data_stop1;
					
					if(r_result_cnt2 == 6'd0) begin
						r_cal_flag		<= 1'b1;
						r_data_stop2	<= r_result_stop2;
					end else begin
						r_cal_flag		<= 1'b0;
						r_data_stop2	<= r_data_stop2;
					end
				end
				ST_START_CAL: begin
					if(r_cal_dlycnt >= 6'd10)
						r_cal_dlycnt	<= 6'd0;
					else
						r_cal_dlycnt	<= r_cal_dlycnt + 1'b1;
				end
				ST_OUT_RESULT: begin
					r_tdc_sig    	<= 1'b1;
					r_cal_dlycnt	<= 6'd0;
				end
				ST_DONE: r_tdc_sig    	<= 1'b0;
				default: begin
                    r_tdc_sig    	<= 1'b0;          
                end
            endcase
		end
	end

	//r_gpx2_signal
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
			r_gpx2_signal		<= 1'b0;
			r_tdc_risedata		<= 32'h0;
			r_tdc_falldata		<= 32'h0;
		end else if(r_tdc_sig) begin
			r_gpx2_signal		<= 1'b1;
			r_tdc_risedata		<= w_result_rise;
			r_tdc_falldata		<= w_result_fall;
		end else begin
			r_gpx2_signal		<= 1'b0;
			r_tdc_risedata		<= r_tdc_risedata;
			r_tdc_falldata		<= r_tdc_falldata;
		end
	end

	//r_tdcsync_ready
	always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
			r_tdcsync_ready	<= 1'b1;
		else if(r_curr_state == ST_WAIT_MFRAME)
			r_tdcsync_ready	<= 1'b1;
		else
			r_tdcsync_ready	<= 1'b0;
	end
	//--------------------------------------------------------------------------------------------------
	// instance domain
	//--------------------------------------------------------------------------------------------------
	sub_ip u1_sub_ip
	(
		.DataA						( r_data_stop1				),
		.DataB						( r_start_data				),
		.Result						( w_result_rise				)
	);

	sub_ip u2_sub_ip
	(
		.DataA						( r_data_stop2				),
		.DataB						( r_start_data				),
		.Result						( w_result_fall				)
	);

	gpx2_cfg  u_gpx2_cfg 
	(
		.i_clk                		( i_clk_100m               	),
		.i_rst_n              		( i_rst_n				 	),
		.i_gpx2_module_en			( r_tdcmodule_en			),

		.i_gpx2_measure_en      	( i_gpx2_measure_en			),
		.i_gpx2_measure_sign    	( r_angle_sync				),
		.i_gpx2_init       			( i_gpx2_init				),

		.o_spi_ssn					( o_tdc_spi_ssn				),
		.o_spicom_req      			( w_spicom_req				),
		.o_spi_wdata            	( w_spi_wdata              	),
		.i_spicom_ready           	( w_spicom_ready           	),
		.i_spi_rdvalid      		( w_spi_rdvalid          	),
		.i_spi_rdbyte            	( w_spi_rdbyte				)
	);
	

	gpx2_spi_master #(
		.GPX2_SPICPOL				( GPX2_SPICPOL				),
		.GPX2_SPICPHA				( GPX2_SPICPHA				),
        .CLK_DIV_NUM                ( CLK_DIV_NUM           	),
        .SPICOM_INRV_CLKCNT         ( SPICOM_INRV_CLKCNT    	)
    )	
	u_gpx2_spi_master(	
		.i_clk 						( i_clk_100m				),
		.i_rst_n					( i_rst_n					),

		.o_spi_dclk					( o_tdc_spi_clk 			),
		.o_spi_mosi					( o_tdc_spi_mosi 			),
		.i_spi_miso					( i_tdc_spi_miso 			),

		.i_spicom_req				( w_spicom_req 				),
		.i_spi_wdata				( w_spi_wdata				),
		.o_spicom_ready				( w_spicom_ready			),
		.o_spi_rdvalid				( w_spi_rdvalid				),
		.o_spi_rdbyte				( w_spi_rdbyte 				)
	);

	data_fill u_data_fill
	(
		.i_clk						( i_clk_100m				),
		.i_rst_n					( i_rst_n					),

		.i_tdcmodule_en				( r_tdcmodule_en			),
		.i_angle_sync				( r_angle_sync				),
		.i_tdcsync_ready			( r_tdcsync_ready			),
		.i_code_angle1				( r_code_angle1				),
		.i_code_angle2				( r_code_angle2				),
		.i_tdc_newsig				( r_gpx2_signal				),
		.i_rise_data				( r_tdc_risedata			),
		.i_fall_data				( r_tdc_falldata			),

		.o_filldata_sig				( w_filldata_sig			),
		.o_code_angle1				( o_gpx2_code_angle1		),
		.o_code_angle2				( o_gpx2_code_angle2		),
		.o_tdc_newsig				( o_gpx2_signal				),
		.o_rise_data				( o_gpx2_risedata			),
		.o_fall_data				( o_gpx2_falldata			)
	);
	//----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign o_tdcmodule_en 		= r_tdcmodule_en;
endmodule 