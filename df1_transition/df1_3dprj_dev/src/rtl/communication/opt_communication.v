// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: opt_communication
// Date Created 	: 2023/11/08 
// Version 			: V1.1
// -------------------------------------------------------------------------------------------------
// File description	:opt_communication
//			rx 1M rate
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module opt_communication(
	
	input				clk,
	input				rst_n,
	input				i_clk_100m,

	input				i_uart_rx,
	output				o_uart_tx,
	
	input				i_send_data_req,
	input [7:0]			i_send_data,
	input [10:0]		i_send_wraddr,	
	input				i_send_req,
	input [11:0]		i_send_num,

	input [10:0]		i_recv_rdaddr,
	output [7:0]		o_recv_data,
	output [10:0]		o_recv_num,
	output				o_recv_ack		
);
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg	 [10:0]			r_urat_rx_wraddr 	= 11'd0;
	reg	 [10:0]			r_recv_num 			= 11'd0;
	reg	 [15:0]			r_uart_delay 		= 16'd0;
	reg	 [ 7:0]			r_rx_state 			= 8'b0000_0000;
	reg					r_rx_done 			= 1'b0;
	reg					r_recv_permit;

	wire				w_uart_rx_valid;
	wire [ 7:0]			w_uart_rx_data;
	wire [ 9:0]			w_uart_para;
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam 			RX_IDLE   			= 8'b0000_0000;
	localparam 			RX_READY			= 8'b0000_0001;
	localparam 			RX_IN_DATA			= 8'b0000_0010;
	localparam 			RX_DELAY			= 8'b0000_0100;
	localparam 			RX_VALID			= 8'b0000_1000;
	localparam 			RX_DONE				= 8'b0001_0000;

	//----------------------------------------------------------------------------------------------
	// sequence define
	//----------------------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_rx_done = 1'b0;
		else if(r_rx_state == RX_DONE)
			r_rx_done = 1'b1;
		else
			r_rx_done = 1'b0;
	end
	
	//r_urat_rx_wraddr//
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_urat_rx_wraddr 	<= 11'd0;
		else if (r_rx_state == RX_IDLE)
			r_urat_rx_wraddr 	<= 11'd0;
		else if (w_uart_rx_valid)
			r_urat_rx_wraddr	<= r_urat_rx_wraddr + 1'b1;
	end
	
	//r_recv_num
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_recv_num 	<= 11'd0;
		else if (r_rx_state == RX_DONE)
			r_recv_num	<= r_urat_rx_wraddr;
	end
	
	//r_uart_delay
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_uart_delay <= 16'd0;
		else if (r_rx_state == RX_DELAY)
			r_uart_delay <= r_uart_delay + 1'b1;
		else
			r_uart_delay <= 16'd0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_rx_state <= RX_IDLE;
		else begin
			case(r_rx_state)
				RX_IDLE: r_rx_state <= RX_READY;
				RX_READY: begin
					if (w_uart_rx_valid & r_recv_permit)
						r_rx_state <= RX_IN_DATA;
					else
						r_rx_state <= RX_READY;
				end
				RX_IN_DATA: r_rx_state <= RX_DELAY;
				RX_DELAY:begin
					if (w_uart_rx_valid == 1'b1)
						r_rx_state <= RX_IN_DATA;
					// else if ((17'd80000 - r_uart_delay) == 10'd0)
					else if (r_uart_delay == 16'd2000)
						r_rx_state <= RX_VALID;
					else 
						r_rx_state <= RX_DELAY;
				end
				RX_VALID:r_rx_state <= RX_DONE;
				RX_DONE: r_rx_state <= RX_IDLE;
			endcase
		end
	end
	
	mancestcode_rx_upper u1(
	    .i_clk_100m 	( i_clk_100m				),
	    .i_rst_n   		( rst_n  					),
	    .i_rx_line		( i_uart_rx					),
		.i_recv_permit	( r_recv_permit				),

	    .o_data_valiad	( w_uart_rx_valid			),	
        .o_rx_data      ( w_uart_rx_data			)

	);
	
	opt_dataram8x2048 u2 (
        .wr_data    	( w_uart_rx_data    		),    // input [7:0]
        .wr_addr    	( r_urat_rx_wraddr	   		),    // input [10:0]
        .wr_en      	( w_uart_rx_valid      		),    // input
        .wr_clk     	( clk        				),    // input
        .wr_rst     	( 1'b0              		),    // input
        .rd_addr    	( i_recv_rdaddr     		),    // input [10:0]
        .rd_data    	( o_recv_data     			),    // output [7:0]
        .rd_clk     	( clk        				),    // input
        .rd_rst     	( 1'b0              		)     // input
    );
	
	// opt_dataram8x2048 u2(
	// 	.WrClock		( clk 						), 
	// 	.WrClockEn		( w_uart_rx_valid 			),
	// 	.WrAddress		( r_urat_rx_wraddr		 	), 
	// 	.Data			( w_uart_rx_data 			), 
	// 	.WE				( 1'b1 						), 
	// 	.RdClock		( ~clk 						),  
	// 	.RdClockEn		( 1'b1 						),//(w_data_req),
	// 	.RdAddress		( i_recv_rdaddr		 		),
	// 	.Q				( o_recv_data 				),
	// 	.Reset			( 1'b0 						)
	// );

	assign				o_recv_ack = r_rx_done;
	assign				o_recv_num = r_recv_num;
	//--------------------------------------------------------------------------------------------------
	//----------------------------------------------------------------------------------------------
	// reg and wire define
	//----------------------------------------------------------------------------------------------
	reg  [7:0]			r_tx_state 				= 8'd0;
	reg  [7:0]			r_uart_tx_data 			= 8'd0;
	reg  				r_uart_tx_sig 			= 1'b0;
	reg  [10:0]			r_uart_sram_rdaddr 		= 11'd0;
	reg  [11:0]			r_uart_send_num 		= 11'd0;
	reg  [15:0] 		r_delay_cnt				= 16'd0; //1ms
	
	wire 				w_uart_send_done;
	wire [7:0]			w_uart_sram_rddata;
	
	//----------------------------------------------------------------------------------------------
	// localparam define
	//----------------------------------------------------------------------------------------------
	localparam 			TX_IDLE   				= 8'b0000_0000;
	localparam 			TX_READY				= 8'b0000_0001;
	localparam 			TX_MAKE_DATA			= 8'b0000_0010;
	localparam 			TX_OUT_DATA				= 8'b0000_0100;
	localparam 			TX_WAIT					= 8'b0000_1000;
	localparam 			TX_DONE					= 8'b0001_0000;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_uart_send_num	<= 11'd0;
		else if (i_send_req)
			r_uart_send_num <= i_send_num;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_uart_sram_rdaddr <= 11'd0;
		else if (r_tx_state == TX_IDLE)
			r_uart_sram_rdaddr <= 11'd0;
		else if (r_tx_state == TX_OUT_DATA)
			r_uart_sram_rdaddr <= r_uart_sram_rdaddr + 1'b1;
	end
					
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_uart_tx_data <= 8'd0;
		else if (r_tx_state == TX_IDLE)
			r_uart_tx_data <= 8'd0;
		else if (r_tx_state == TX_OUT_DATA)
			r_uart_tx_data <= w_uart_sram_rddata;
	end
					
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_uart_tx_sig <= 1'b0;
		else if (r_tx_state == TX_IDLE)
			r_uart_tx_sig <= 1'b0;
		else if (r_tx_state == TX_MAKE_DATA)//else if (r_tx_state == TX_OUT_DATA)
			r_uart_tx_sig <= 1'b1;
		else
			r_uart_tx_sig <= 1'b0;
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			r_tx_state 	<= TX_IDLE;
			r_delay_cnt <= 16'd0;
		end else begin
			case(r_tx_state)
				TX_IDLE:begin
					r_tx_state 	<= TX_READY;
					r_delay_cnt <= 16'd0;
				end
				TX_READY:begin
					if (i_send_req)
						r_tx_state <= TX_MAKE_DATA;
					else
						r_tx_state <= TX_READY;
				end
				TX_MAKE_DATA:r_tx_state <= TX_OUT_DATA;
				TX_OUT_DATA:r_tx_state <= TX_WAIT;
				TX_WAIT:begin
					if (w_uart_send_done)begin
						if (r_uart_sram_rdaddr < r_uart_send_num)
							r_tx_state <= TX_MAKE_DATA;
						else
							r_tx_state <= TX_DONE;
					end
					else
						r_tx_state <= TX_WAIT;
				end
				TX_DONE:begin
					if(r_delay_cnt == 16'd200)begin
						r_delay_cnt <= 16'd0;
						r_tx_state <= TX_IDLE;
					end else begin
						r_delay_cnt <= r_delay_cnt + 1'b1;
						r_tx_state <= TX_DONE;
					end
				end
				default:r_tx_state <= TX_IDLE;
			endcase
		end
	end
	

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			r_recv_permit <= 1'd1;
		else if(r_tx_state == TX_IDLE)
			r_recv_permit <= 1'd1;
		else if(r_tx_state == TX_MAKE_DATA)
			r_recv_permit <= 1'd0;
	end
	
	
	
	uart2mancestcode_upper u3(
		.i_clk_100m 		( i_clk_100m			),
		.i_rst_n   			( rst_n  				),
	
		.i_data_wren		( i_send_req			),
		.i_data_send		( r_uart_tx_data		),
		.o_data_valiad		( w_uart_send_done		),
		.i_send_num			( {4'b0,r_uart_send_num}),
		.o_uart_send_done	( 						),
		.o_tx_line			( o_uart_tx				)
	);
	
	opt_dataram8x2048 u4 (
        .wr_data    		( i_send_data    		),    // input [7:0]
        .wr_addr    		( i_send_wraddr	   		),    // input [10:0]
        .wr_en      		( i_send_data_req      	),    // input
        .wr_clk     		( clk        			),    // input
        .wr_rst     		( 1'b0              	),    // input
        .rd_addr    		( r_uart_sram_rdaddr    ),    // input [10:0]
        .rd_data    		( w_uart_sram_rddata    ),    // output [7:0]
        .rd_clk     		( clk        			),    // input
        .rd_rst     		( 1'b0              	)     // input
    );

	// opt_dataram8x2048 u4(
	// 	.WrClock			( clk 					), 
	// 	.WrClockEn			( i_send_data_req 		),
	// 	.WrAddress			( i_send_wraddr 		), 
	// 	.Data				( i_send_data 			), 
	// 	.WE					( 1'b1 					), 
	// 	.RdClock			( ~clk 					),  
	// 	.RdClockEn			( 1'b1 					),//(w_data_req),
	// 	.RdAddress			( r_uart_sram_rdaddr 	),
	// 	.Q					( w_uart_sram_rddata 	),
	// 	.Reset				( 1'b0 					)
	// );

endmodule 