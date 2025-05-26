`timescale 1ns / 1ps
 
module tb_tdc_process();

	reg sys_clk_25M; 
	reg sys_rst_n; 

	reg		[15:0]	i_code_angle 		;
	reg				i_tdc_new_sig		;
	reg		[15:0]	i_rise_data			;
	reg		[15:0]	i_fall_data			;
	reg     [1:0]  	i_reso_mode     ;

	reg		[15:0]	i_start_index		;
	reg		[15:0]	i_stop_index		;	
	
	reg             i_tdc_switch        ;
	
	wire	[15:0]	o_code_angle 		;
	wire			o_cal_sig			;
	wire	[15:0]	o_rise_data			;
	wire	[15:0]	o_fall_data			;
	wire    [1:0]	tdc_process_error	;

	wire	[15:0]	w_code_angle 		;
	wire	[15:0]	w_dist_data			;
	wire	[15:0]	w_rssi_data			;
	wire			w_dist_sig		    ;

	wire  		    o_packet_wren		;
	wire  		    o_packet_pingpang	;
	wire  [7:0]	    o_packet_wrdata		;
	wire  [9:0]	    o_packet_wraddr		;
	wire  		    o_packet_make		;
	wire  [15:0]	o_packet_points		;

	wire  [15:0]	o_scan_counter		;
	wire  [7:0]	    o_telegram_no		;
	wire  [15:0]	o_first_angle		;
    wire  [1:0]     dist_report_error   ;    

GSR GSR_INST(.GSR(1'b1));
PUR PUR_INST(.PUR(1'b1));

initial begin
	sys_clk_25M = 1'b0; 
	sys_rst_n = 1'b0;
	#200 
	sys_rst_n = 1'b1;
end

always #20 sys_clk_25M = ~sys_clk_25M;

initial begin:TDC_MODULE
reg		[15:0]	code_angle ;
reg		[15:0]	temp ;
	i_tdc_new_sig = 1'b0; 
    i_code_angle  = 16'd0; 
    code_angle    = 16'd0;
    i_rise_data   = 0;
    i_fall_data   = 0;

    i_reso_mode   = 2'd2;

    i_tdc_switch  = 1;

    i_start_index  = 16'd165;
    i_stop_index   = 16'd915;    

    temp = 0;
    wait(sys_rst_n);
    #100;
    forever begin
        #40;
            i_tdc_new_sig = 1'b1; 

            temp = {$random} % 1053;

            
            if((code_angle >= 500) && (code_angle <= 1000))
              if(code_angle == 750)
                i_rise_data   = 9000; 
              else if(code_angle == 815)
                i_rise_data   = 8000; 	
              else if(code_angle == 816)
                i_rise_data   = 8000; 	
              else if(code_angle == 817)
                i_rise_data   = 8000; 												
              else if(code_angle == 818)
                i_rise_data   = 8000;                 
              else
                i_rise_data   = 7999 + $random % 100; 

            else 
                i_rise_data   = 10000 + $random % 10;

            i_fall_data   = i_rise_data + 99 + $random%100;     
            
            if(code_angle >= 1053)  
              code_angle = 0;
            else
              code_angle = code_angle + 1; 


            i_code_angle  = code_angle; 

        #40;
            i_tdc_new_sig = 1'b0;

        #61648;                   

    end

end

tdc_process U2
(
    .i_clk_50m    		(sys_clk_25M)			,
    .i_rst_n      		(sys_rst_n)				,
    
    .i_code_angle 		(i_code_angle)			,   //0 ~ 1053  i_reso_mode == 2'd2
    .i_tdc_new_sig		(i_tdc_new_sig)			,
    .i_rise_data		(i_rise_data)			,
    .i_fall_data		(i_fall_data)			,

    .i_start_index		(i_start_index)			,
    .i_stop_index		(i_stop_index)			,		
    
    .i_tdc_switch       (i_tdc_switch)         ,
    
    .o_code_angle 		(o_code_angle)		,
    .o_cal_sig			(o_cal_sig)				,
    .o_rise_data		(o_rise_data)			,
    .o_fall_data		(o_fall_data)			,
    .i_reso_mode		(i_reso_mode)       	,

    .tdc_process_error	(tdc_process_error)   
);

	dist_filter U4
	(
		.i_clk_50m    		(sys_clk_25M)				,
		.i_rst_n      		(sys_rst_n)				,
		
		.i_code_angle 		(o_code_angle)		,//�Ƕ�ֵ
		.i_dist_data		(o_rise_data)			,
		.i_rssi_data		(o_fall_data)			,
		.i_dist_new_sig		(o_cal_sig)			,
		
		.i_sfim_switch		(1'b1)		,
		
		.o_code_angle 		(w_code_angle)		,//�Ƕ�ֵ
		.o_dist_data		(w_dist_data)			,
		.o_rssi_data		(w_rssi_data)			,
		.o_dist_new_sig		(w_dist_sig)	

	);

	dist_packet U5
	(
		.i_clk_50m    		(sys_clk_25M)				,
		.i_rst_n      		(sys_rst_n)				,
		
		.i_measure_en		(1'b1 ),
		.i_code_angle 		(w_code_angle)		    ,
		.i_dist_data		(w_dist_data)			,
		.i_rssi_data		(w_rssi_data)			,
		.i_dist_new_sig		(w_dist_sig)			,
		
		.i_start_index		(i_start_index)			,
		.i_stop_index		(i_stop_index)			,
		.i_transmit_flag	(1'b1)	,
		
		.o_packet_pingpang	(o_packet_pingpang)		,
		.o_packet_wraddr	(o_packet_wraddr)		,
		.o_packet_wren		(o_packet_wren)			,
		.o_packet_wrdata	(o_packet_wrdata)		,
		
		.o_packet_make		(o_packet_make)			,
		.o_scan_counter		(o_scan_counter)		,
		.o_telegram_no		(o_telegram_no)			,
		.o_first_angle		(o_first_angle)			,
		.o_packet_points	(o_packet_points)	    ,
        .i_motor_state		(1'b1)	        ,
		.dist_report_error  (dist_report_error)			    
	);    


endmodule
