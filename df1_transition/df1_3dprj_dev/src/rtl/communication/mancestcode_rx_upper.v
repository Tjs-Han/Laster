// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: manchester_encoding_rx
// Date Created 	: 2023/09/06
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	: manchester_encoding_rx
//				Covert manchester code to uart serial data
// -------------------------------------------------------------------------------------------------
// Revision History :
//		2023.09.06   rx rate 10M
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------	
module mancestcode_rx_upper
(
	input					i_clk_100m,
	input					i_rst_n,	

	input					i_recv_permit,
	input					i_rx_line,
	output					o_data_valiad,
    output [7:0]			o_rx_data
);
	//--------------------------------------------------------------------------------------------------
    //localpara and parameter define
    //--------------------------------------------------------------------------------------------------
	localparam	HAND_NUM	= 5'd4;
	localparam	BPS_BT		= 8'd99;
	localparam	DELAY_NUM	= 8'd79;
	localparam	RX_LOW_CNT	= 10'd400;

	parameter 	RX_IDLE  	= 5'd0,
			  	RX_WAIT  	= 5'd1,
              	RX_HAND 	= 5'd2,
			  	RX_START 	= 5'd3,
			  	RX_DATA  	= 5'd4,
			  	RX_STOP  	= 5'd5,
			  	RX_END   	= 5'd6;
	//--------------------------------------------------------------------------------------------------
    //reg and wire define
    //--------------------------------------------------------------------------------------------------		   
	reg [4:0]	r_current_state;
	reg [4:0]	r_next_state;	
	reg [3:0]	r_rx_bit_cnt;	
	reg [15:0]	r_rx_bps_cnt;	
	reg			r_data_valiad;
    reg [7:0]   r_rx_data;
    reg [7:0]   r_delay_cnt;
	
	reg			r_rx_line1;
	reg			r_rx_line2;	
	reg			r_rx_line3;	
	reg			r_rx_line4;
	reg [15:0]	r_jitter_cnt;
	reg [4:0]	r_hand_cnt;
	reg			r_rx_flag;
	reg			r_rx_start;
	reg			r_rx_rise;
	reg			r_rx_fall;

	reg [9:0]	r_low_cnt;
	reg 		r_rx_front;
	reg 		r_rx_behind; 
	reg			r_rx_done;	

    wire        w_rx_rise;
    wire        w_rx_fall; 
	//--------------------------------------------------------------------------------------------------
	// RX start signal
	//--------------------------------------------------------------------------------------------------
	always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)begin
           r_rx_line1 <= 1'd0;
           r_rx_line2 <= 1'd0;
           r_rx_line3 <= 1'd0;
           r_rx_line4 <= 1'd0;
		end else begin
           r_rx_line1 <= i_rx_line;
           r_rx_line2 <= r_rx_line1;
           r_rx_line3 <= r_rx_line2;
           r_rx_line4 <= r_rx_line3;
        end
	end

	assign  w_rx_rise = r_rx_line1 & ~r_rx_line2;
    assign  w_rx_fall = ~r_rx_line1 & r_rx_line2;

    always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)begin
			r_rx_rise <= 1'b0;
			r_rx_fall <= 1'b0;
		end
		else begin
			r_rx_rise <= w_rx_rise;
			r_rx_fall <= w_rx_fall;
		end
	end

	always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n) begin
			r_jitter_cnt <= 16'd0;
			r_rx_flag <= 1'd0;
		end else if(r_jitter_cnt < 16'd250) begin
			r_rx_flag <= 1'd0;
			if(r_rx_line1)
				r_jitter_cnt <= r_jitter_cnt + 1'b1;
			else
				r_jitter_cnt <= 16'd0;
		end else begin
            r_rx_flag <= 1'd1;
			r_jitter_cnt <= 16'd0;
		end
	end

	always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)
            r_rx_start <= 1'd0;
        else if(r_rx_flag && r_current_state == RX_WAIT && i_recv_permit)
            r_rx_start <= 1'd1;
        else
            r_rx_start <= 1'd0;
	end
	//--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)
			r_current_state <= RX_IDLE;
		else 
			r_current_state <= r_next_state;
	end					
		
    always@ (*)begin
        case(r_current_state)
		RX_IDLE: r_next_state = RX_WAIT;
		RX_WAIT: begin
			if(r_rx_start)
				r_next_state = RX_HAND;
			else
				r_next_state = RX_WAIT;
		end
        RX_HAND: begin
			if(r_hand_cnt >= HAND_NUM)
				r_next_state = RX_START;
            else
                r_next_state = RX_HAND;
		end
        RX_START: begin
			if(r_rx_done)
				r_next_state = RX_IDLE;
			else if(r_rx_rise)
				r_next_state = RX_DATA;
			else
                r_next_state = RX_START;
		end
		RX_DATA: begin
            if(r_rx_bit_cnt >= 4'd8)
                r_next_state = RX_STOP;
			else
				r_next_state = RX_DATA;
		end
		RX_STOP : begin
			if(r_rx_bps_cnt > DELAY_NUM && r_rx_fall)
				r_next_state = RX_END;
			else
				r_next_state = RX_STOP;
		end			
		RX_END: r_next_state = RX_START;	
		default: r_next_state = RX_IDLE;
		endcase
	end

    always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)begin
			r_rx_front 		<= 1'b0;
			r_rx_behind 	<= 1'b0;
			r_rx_data 		<= 8'd0 ;
			r_rx_bps_cnt 	<= 16'd0;
			r_rx_bit_cnt 	<= 4'd0;
			r_data_valiad 	<= 1'd0;
            r_delay_cnt 	<= 2'd0;
			r_rx_done	 	<= 1'd0;
			r_hand_cnt      <= 5'd0;
			r_low_cnt		<= 10'd0;
		end else begin
			case(r_current_state)
			RX_IDLE: begin
				r_low_cnt 		<= 10'd0;
				r_rx_done 		<= 1'd0;
				r_rx_bps_cnt	<= 16'd0;
				r_rx_bit_cnt 	<= 4'd0;
				r_data_valiad	<= 1'd0;
                r_delay_cnt 	<= 2'd0;
				r_hand_cnt      <= 5'd0;
			end
			RX_WAIT: begin
				r_rx_bps_cnt 	<= 16'd0;
				r_rx_bit_cnt 	<= 4'd0;
				r_data_valiad 	<= 1'd0;
			end
            RX_HAND: begin
                if(r_hand_cnt >= HAND_NUM)
                    r_hand_cnt <= 5'd0;
                else begin
					if(r_rx_fall)
                    	r_hand_cnt <= r_hand_cnt + 1'b1;
				end	
            end
            RX_START: begin
				r_data_valiad <= 1'd0;
				if(~r_rx_line1)
					r_low_cnt <= r_low_cnt + 1'd1;
				else
					r_low_cnt <= 10'd0;

				if(r_low_cnt >= RX_LOW_CNT)
					r_rx_done <= 1'd1;
				else
					r_rx_done <= 1'd0;
            end				
			RX_DATA: begin
				if(r_rx_bps_cnt > DELAY_NUM) begin
					if(r_rx_rise) begin
                        r_rx_data <= {r_rx_data[6:0], 1'd0};
						r_rx_bit_cnt  <= r_rx_bit_cnt + 1'b1;
						r_rx_bps_cnt <=16'd0;
					end else if(r_rx_fall) begin
                        r_rx_data <= {r_rx_data[6:0], 1'd1};
						r_rx_bit_cnt  <= r_rx_bit_cnt + 1'b1;
						r_rx_bps_cnt <=16'd0;
					end 
				end else
						r_rx_bps_cnt <= r_rx_bps_cnt + 1'd1;
			end
			RX_STOP: begin
				if(r_rx_bps_cnt > DELAY_NUM) begin
					if(r_rx_fall) begin
						r_data_valiad <= 1'd1;
						r_rx_bps_cnt <= 16'd0;
					end
				end else begin
					r_data_valiad <= 1'd0;
					r_rx_bps_cnt <= r_rx_bps_cnt + 1'd1;						
				end
			end
			RX_END: begin
				r_rx_bps_cnt <=16'd0;
				r_rx_bit_cnt <= 4'd0;
			end
			endcase
		end
	end	
	//--------------------------------------------------------------------------------------------------
	// output assignment
	//--------------------------------------------------------------------------------------------------	
	assign  o_rx_data = r_rx_data ;
	assign  o_data_valiad = r_data_valiad ;

endmodule

