// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: uart2mancestcode_upper
// Date Created 	: 2023/06/26 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:uart2mancestcode_upper
//				Convert serial data to Manchester code for sending
//				2023.06.26---A single byte send need 1000ns
// -------------------------------------------------------------------------------------------------
// Revision History :V1.1
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module uart2mancestcode_upper
(
	input			i_clk_100m,
	input			i_rst_n,	

	input			i_data_wren,
	input [7:0]		i_data_send,
	input [15:0] 	i_send_num,
	output			o_data_valiad,
	output			o_uart_send_done,
	output			o_tx_line
		
);
	//--------------------------------------------------------------------------------------------------
	// reg define
	//--------------------------------------------------------------------------------------------------
	reg [3:0]	r_current_state;
	reg [3:0]	r_next_state;	
	reg [15:0]	r_tx_byte_cnt ;
	reg [7:0]	r_tx_bit_cnt ;	
	reg [15:0]	r_tx_bps_cnt ;	
	reg 		r_data_valiad;
	reg 		r_tx_line;
	reg 		r_data_send_done;
	
	reg [15:0]	r_delay_cnt;

	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------
	localparam START 		= 8'd99;
	localparam BYTE_START	= 5'd19;
	localparam BPS_BT    	= 4'd9;
	localparam SAMPLE_BT 	= 4'd5;

	parameter TX_IDLE  		= 4'd0,
			  TX_WAIT  		= 4'd1,
			  TX_HAND 		= 4'd2,
			  TX_START 		= 4'd3,
			  TX_DATA  		= 4'd4,
			  TX_STOP  		= 4'd5,
			  TX_END   		= 4'd6;			   			   
	
	//--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    always@ (posedge i_clk_100m or negedge i_rst_n)begin
		if(~i_rst_n)
			r_current_state <= TX_IDLE;
		else 
			r_current_state <= r_next_state;
	end					
		
    always@ (*)begin
        case(r_current_state)
			TX_IDLE: r_next_state = TX_WAIT;
			TX_WAIT:begin
				if(i_data_wren)
					r_next_state = TX_HAND;
				else
					r_next_state = TX_WAIT;
			end
			TX_HAND: begin
				if(r_delay_cnt >= START)
					r_next_state = TX_START;
				else
					r_next_state = TX_HAND;
			end
			TX_START: begin
				if(r_tx_bps_cnt >= BYTE_START)
					r_next_state = TX_DATA;
				else
					r_next_state = TX_START;
			end
			TX_DATA: begin
                if(r_tx_bit_cnt >= 4'd7 && r_tx_bps_cnt >= BPS_BT)
                    r_next_state = TX_STOP;
				else
					r_next_state = TX_DATA;
			end
			TX_STOP: begin
				if(r_tx_bps_cnt >= BPS_BT) begin
					if(r_tx_byte_cnt < i_send_num)
						r_next_state = TX_START;
					else
						r_next_state = TX_END;
				end else
					r_next_state = TX_STOP;
				
			end
			TX_END: r_next_state = TX_WAIT;
			default: r_next_state = TX_IDLE;
		endcase
	end
	
    always@ (posedge i_clk_100m or negedge i_rst_n) begin
		if(~i_rst_n)begin
			r_tx_bps_cnt <=16'd0;
			r_tx_bit_cnt <= 4'd0;
			r_tx_byte_cnt <= 8'd0;
			r_data_valiad <= 1'd0;
			r_delay_cnt	  <= 16'd0;
			r_tx_line     <= 1'b0; 
			r_data_send_done <= 1'd0;
		end else begin
			case(r_current_state)
				TX_IDLE: begin
					r_tx_bps_cnt 		<= 16'd0;
					r_tx_bit_cnt 		<= 4'd0;
					r_tx_byte_cnt 		<= 8'd0;
					r_tx_line     		<= 1'b0; 
					r_data_valiad 		<= 1'd0;
					r_delay_cnt	  		<= 16'd0;
					r_data_send_done	<= 1'd0;
				end
				TX_WAIT: begin
					r_data_send_done 	<= 1'd0;
					r_tx_bps_cnt 		<= 16'd0;
					r_tx_bit_cnt 		<= 4'd0;
					r_tx_byte_cnt 		<= 8'd0;
					r_data_valiad 		<= 1'd0;
					r_tx_line 			<= 1'd0; //r_tx_line;
				end
				TX_HAND: begin
					if(r_delay_cnt <= 8'd30)						
						r_tx_line <= 1'd1;
					else if(r_delay_cnt > 8'd30 && r_delay_cnt <= 8'd40)
						r_tx_line <= 1'd0;
					else if(r_delay_cnt > 8'd40 && r_delay_cnt <= 8'd50)
						r_tx_line <= 1'd1;
					else if(r_delay_cnt > 8'd50 && r_delay_cnt <= 8'd60)
						r_tx_line <= 1'd0;
					else if(r_delay_cnt > 8'd60 && r_delay_cnt <= 8'd70)
						r_tx_line <= 1'd1;
					else if(r_delay_cnt > 8'd70 && r_delay_cnt <= 8'd80)
						r_tx_line <= 1'd0;
					else if(r_delay_cnt > 8'd80 && r_delay_cnt <= 8'd90)
						r_tx_line <= 1'd1;
					else if(r_delay_cnt > 8'd90 && r_delay_cnt <= 8'd99)
						r_tx_line <= 1'd0;		
					if(r_delay_cnt >= START)
						r_delay_cnt <= 8'd0;
					else
						r_delay_cnt <= r_delay_cnt + 1'd1;
				end
				TX_START: begin
					r_data_valiad <= 1'd0;
                    if(r_tx_bps_cnt >= BYTE_START)
						r_tx_bit_cnt  <= 4'd0;
					if(r_tx_bps_cnt >= (BPS_BT + SAMPLE_BT))
						r_tx_line      <= 1'b1;
					else
						r_tx_line      <= 1'b0;
					if(r_tx_bps_cnt >= BYTE_START)
						r_tx_bps_cnt  <= 16'd0;
					else
						r_tx_bps_cnt <= r_tx_bps_cnt + 1'd1;
				end
				TX_DATA: begin
					if(r_tx_bps_cnt >= BPS_BT)
						r_tx_bps_cnt <= 16'd0;
					else
						r_tx_bps_cnt <= r_tx_bps_cnt + 1'd1;
                    if(r_tx_bit_cnt >= 4'd7 && r_tx_bps_cnt >= BPS_BT)begin
						r_tx_byte_cnt <= r_tx_byte_cnt + 1'd1;
						r_tx_bit_cnt  <= 4'd0;
					end else if(r_tx_bps_cnt >= BPS_BT)
						r_tx_bit_cnt  <= r_tx_bit_cnt + 1'b1;
					if(r_tx_bps_cnt >= SAMPLE_BT)
						r_tx_line	<= ~i_data_send[4'd7 - r_tx_bit_cnt];
					else
						r_tx_line	<= i_data_send[4'd7 - r_tx_bit_cnt];
				end
				TX_STOP: begin
					if(r_tx_bps_cnt >= SAMPLE_BT)
						r_tx_line <= 1'd0;
					else
						r_tx_line <= 1'd1;
					if(r_tx_bps_cnt >= BPS_BT)begin
						// r_tx_byte_cnt <= r_tx_byte_cnt + 1'd1;
						r_data_valiad <= 1'd1;   
						r_tx_bps_cnt <= 16'd0;
					end else begin
						r_data_valiad <= 1'd0;
						r_tx_bps_cnt <= r_tx_bps_cnt + 1'd1;						
					end
				end
				TX_END: begin
					r_data_valiad 	 	<= 1'd0;
					r_tx_byte_cnt 	 	<= 16'd0;
					r_tx_bps_cnt  	 	<=16'd0;
					r_tx_bit_cnt  	 	<= 4'd0;
					r_tx_byte_cnt 	 	<= 8'd0;
					r_tx_line     	 	<= 1'b0;
					if(r_tx_byte_cnt >= i_send_num)
						r_data_send_done <= 1'd1;
					else
						r_data_send_done <= 1'd0;
				end
			endcase
		end
	end	

	assign	o_data_valiad 	 = r_data_valiad;
	assign	o_tx_line		 = r_tx_line;
	assign	o_uart_send_done = r_data_send_done ;

	
	endmodule

						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						