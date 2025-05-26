/*
//@Function		: AS6500_ctrl module

//@Author		: WangQiang
 
//@Version		: v1
 
//@Date			: 2021-9-1

//@Company		: Free Optics

//@Note			: R200 Prj

*/
`timescale 1ns/1ps
module as6500_ctrl(

    input                           sys_clk,
    input                           sys_rst_n,

    // control signal
    input                           en_as6500_measure,
    input                           sign_as6500_measure,
    input                           as6500_interrupt,
    output           reg            spi_cs_n = 1'b1,

    // flag
    output                          as6500_config_done,
    output          reg             as6500_init_done = 1'b1,

    // result data
    output          reg [31:0]      measure_data = 32'd0,
    output          reg             measure_data_valide = 1'b0,

    //spi master side
    output          reg [7:0]       spi_tx_byte = 8'd0,
    output          reg				 spi_tx_byte_valid = 1'b0,
    input                            spi_tx_ready,
    input                            spi_rx_byte_valid,
    input           [7:0]            spi_rx_byte 
);

// one pat for spi_tx_ready
reg spi_tx_ready_reg = 1'b0;
always@(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        spi_tx_ready_reg <= 1'b0;
    end
    else begin
        spi_tx_ready_reg <= spi_tx_ready;
    end
end


// define localparam
localparam NUM_CONFIG_REGISTER                          =       8'd17;
localparam NUM_RESULT_REGISTER_PER_CHANNEL              =       8'd4;
localparam NUM_CLEAR_REGISTER_PER_CHANNEL               =       8'd1;
localparam NUM_WAIT_INTN_PERIOD                         =       8'd23;

// as6500 opcode
localparam OP_CODE_NOP                                  =       8'h0;
localparam OP_CODE_POWER_ON_RESET                       =       8'h30;
localparam OP_CODE_INIT                                 =       8'h18;
localparam OP_CODE_WRITE_CONFIG                         =       8'h80;
localparam OP_CODE_READ_CONFIG                          =       8'h40;
localparam OP_CODE_READ_CH1_RESULT                      =       8'h6A;
localparam OP_CODE_READ_CH2_RESULT                      =       8'h70;
localparam OP_CODE_READ_CH3_RESULT                      =       8'h76;
localparam OP_CODE_READ_CH4_RESULT                      =       8'h7C;
localparam OP_CODE_CLEAR_CH1_RESULT                     =       8'h6D;
localparam OP_CODE_CLEAR_CH2_RESULT                     =       8'h73;
localparam OP_CODE_CLEAR_CH3_RESULT                     =       8'h79;
localparam OP_CODE_CLEAR_CH4_RESULT                     =       8'h7F;

// internal signal
	reg		[7:0] 	cnt_byte 			= 8'd0;
	reg		[2:0] 	cnt1				= 2'd0/* synthesis syn_keep=1 */;
	reg		[5:0]	cnt_delay_h			= 6'd0;
	reg		[7:0]	cnt_delay_l			= 8'd0;
	reg		[7:0]	cnt_wait			= 8'd0;
	reg		[3:0]	cnt_clear			= 4'd0;
	reg 			verify_success		= 1'b0;
	reg		[143:0]read_config_value	= 144'd0;
	reg		[31:0]	middle_result		= 32'd0;
	reg		[31:0] start_result		= 32'd0;
	reg		[31:0] rise_result			= 32'd0;
	reg		[31:0] fall_result			= 32'd0;
	reg		[31:0] rise				= 32'd0;
	reg		[31:0] fall				= 32'd0;
	reg		[31:0] rise_1				= 32'd0;
	reg		[31:0] fall_1				= 32'd0;
	reg		[31:0] rise_2				= 32'd0;
	reg		[31:0] fall_2				= 32'd0;	
	reg		[135:0] CONFIG_VALUE_REG	= 	{
												8'h04,
												8'h7D, 
												8'hF1,
												8'h05, 
												8'hCC,
												8'h0A,
												8'h00,
												8'h13,
												8'hA1,
												8'hA3,  // quarz enable
												8'hC0,
												8'h01,    
												8'h00,   
												8'h00,    
												8'h00,
												8'h87,    
												8'hC7
											};// as6500 config register
	
	wire	[19:0] REFCLK_DIVISION;
	assign 	REFCLK_DIVISION = CONFIG_VALUE_REG[43:24];

//*****************************************
// control state machine
//*****************************************
// define state
localparam ST_IDLE                                  = 6'd0;

localparam ST_POWER_ON_RESET_PRE                    = 6'd1;
localparam ST_POWER_ON_RESET                        = 6'd2;
localparam ST_POWER_ON_RESET_POST                   = 6'd3;

localparam ST_CONFIG_PRE                            = 6'd4;
localparam ST_CONFIG                                = 6'd5;
localparam ST_CONFIG_POST                           = 6'd6;

localparam ST_READ_CONFIG_PRE                       = 6'd7;
localparam ST_READ_CONFIG                           = 6'd8;
localparam ST_READ_CONFIG_POST                      = 6'd9;

localparam ST_INIT_PRE                              = 6'd10;
localparam ST_INIT                                  = 6'd11;
localparam ST_INIT_POST                             = 6'd12;

localparam ST_WAIT_SIGN                             = 6'd13;
localparam ST_WAIT_INTN                             = 6'd14;

localparam ST_CLEAR_FALL_BEGIN_PRE                  = 6'd15;
localparam ST_CLEAR_FALL_BEGIN                      = 6'd16;
localparam ST_CLEAR_FALL_BEGIN_POST                 = 6'd17;

localparam ST_READ_START_RESULT_PRE                 = 6'd18;
localparam ST_READ_START_RESULT                     = 6'd19;
localparam ST_READ_START_RESULT_POST                = 6'd20;

localparam ST_READ_RISE_RESULT_PRE                  = 6'd21;
localparam ST_READ_RISE_RESULT                      = 6'd22;
localparam ST_READ_RISE_RESULT_POST                 = 6'd23;

localparam ST_READ_FALL_RESULT_PRE                  = 6'd24;
localparam ST_READ_FALL_RESULT                      = 6'd25;
localparam ST_READ_FALL_RESULT_POST                 = 6'd26;

localparam ST_CAL_RESULT                            = 6'd27;
localparam ST_WAIT_CAL_RESULT                       = 6'd28;

localparam ST_MEASURE_DONE                          = 6'd29;

localparam ST_CLEAR_START_BEHIND_PRE                = 6'd30;
localparam ST_CLEAR_START_BEHIND                    = 6'd31;
localparam ST_CLEAR_START_BEHIND_POST               = 6'd32;

localparam ST_CLEAR_RISE_BEHIND_PRE                 = 6'd33;
localparam ST_CLEAR_RISE_BEHIND                     = 6'd34;
localparam ST_CLEAR_RISE_BEHIND_POST                = 6'd35;

localparam ST_CLEAR_FALL_BEHIND_PRE                 = 6'd36;
localparam ST_CLEAR_FALL_BEHIND                     = 6'd37;
localparam ST_CLEAR_FALL_BEHIND_POST                = 6'd38;

localparam ST_CLEAR_DONE                            = 6'd39;


// register state
reg[5:0] current_state = 6'd0;
reg[5:0] next_state = 6'd0;  
always@(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        current_state <= ST_IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// next_state trans comb logic
always @(posedge sys_clk, negedge sys_rst_n) begin
    next_state <= ST_IDLE;
    case(current_state)
        ST_IDLE: begin
            if(!sys_rst_n)    
                next_state <= ST_IDLE;
            else
                next_state <= ST_POWER_ON_RESET_PRE;
        end
    
        ST_POWER_ON_RESET_PRE: begin
            if( 2'd2 == cnt1)
                next_state <= ST_POWER_ON_RESET;
            else 
                next_state <= ST_POWER_ON_RESET_PRE;
        end

        ST_POWER_ON_RESET : begin
            if(spi_rx_byte_valid)
                next_state <= ST_POWER_ON_RESET_POST;
            else
                next_state <= ST_POWER_ON_RESET;
        end

        ST_POWER_ON_RESET_POST : begin
            if(cnt_delay_h >= 6'h30)
                next_state <= ST_CONFIG_PRE;
            else 
                next_state <= ST_POWER_ON_RESET_POST;
        end
    
        ST_CONFIG_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CONFIG;
            else 
                next_state <= ST_CONFIG_PRE;
        end

        ST_CONFIG : begin
            if(NUM_CONFIG_REGISTER + 8'd1 == cnt_byte)
                next_state <= ST_CONFIG_POST;
            else
                next_state <= ST_CONFIG;
        end

        ST_CONFIG_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_CONFIG_PRE;
            else 
                next_state <= ST_CONFIG_POST;
        end

        ST_READ_CONFIG_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_CONFIG;
            else 
                next_state <= ST_READ_CONFIG_PRE;            
        end

        ST_READ_CONFIG : begin
            if(NUM_CONFIG_REGISTER + 8'd1 == cnt_byte)
                next_state <= ST_READ_CONFIG_POST;
            else
                next_state <= ST_READ_CONFIG;                    
        end

        ST_READ_CONFIG_POST : begin
            if( 2'd2 == cnt1) begin
                if(verify_success)
                    next_state <= ST_INIT_PRE;
                else
                    next_state <= ST_IDLE;
            end
            else
                next_state <= ST_READ_CONFIG_POST;
        end
		
		ST_INIT_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_INIT;
            else 
                next_state <= ST_INIT_PRE;              
        end

        ST_INIT : begin
            if(spi_rx_byte_valid)
                next_state <= ST_INIT_POST;
            else
                next_state <= ST_INIT;        
        end

        ST_INIT_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_WAIT_SIGN;
            else 
                next_state <= ST_INIT_POST;            
        end
		
		ST_WAIT_SIGN : begin
			if(en_as6500_measure)begin
				if(sign_as6500_measure)
					next_state <= ST_WAIT_INTN;
				else
					next_state <= ST_WAIT_SIGN;
				end
			else
				next_state <= ST_WAIT_SIGN;
		end

        ST_WAIT_INTN : begin
            if(1'b0 == as6500_interrupt)
                next_state <= ST_CLEAR_FALL_BEGIN_PRE;
			else if(NUM_WAIT_INTN_PERIOD <= cnt_wait)
				next_state <= ST_CLEAR_FALL_BEGIN_PRE;
            else
                next_state <= ST_WAIT_INTN;
        end
		
		ST_CLEAR_FALL_BEGIN_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_FALL_BEGIN;
            else 
                next_state <= ST_CLEAR_FALL_BEGIN_PRE;               
        end

        ST_CLEAR_FALL_BEGIN : begin
            if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_CLEAR_FALL_BEGIN_POST;
            else
                next_state <= ST_CLEAR_FALL_BEGIN;            
        end

        ST_CLEAR_FALL_BEGIN_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_START_RESULT_PRE;
            else 
                next_state <= ST_CLEAR_FALL_BEGIN_POST;             
        end

        ST_READ_START_RESULT_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_START_RESULT;
            else 
                next_state <= ST_READ_START_RESULT_PRE;               
        end

        ST_READ_START_RESULT : begin
            if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_READ_START_RESULT_POST;
            else
                next_state <= ST_READ_START_RESULT;            
        end

        ST_READ_START_RESULT_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_RISE_RESULT_PRE;
            else 
                next_state <= ST_READ_START_RESULT_POST;             
        end

        ST_READ_RISE_RESULT_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_RISE_RESULT;
            else 
                next_state <= ST_READ_RISE_RESULT_PRE;             
        end

        ST_READ_RISE_RESULT : begin
            if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_READ_RISE_RESULT_POST;
            else
                next_state <= ST_READ_RISE_RESULT;                
        end

        ST_READ_RISE_RESULT_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_FALL_RESULT_PRE;
            else 
                next_state <= ST_READ_RISE_RESULT_POST;             
        end

        ST_READ_FALL_RESULT_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_READ_FALL_RESULT;
            else 
                next_state <= ST_READ_FALL_RESULT_PRE;          
        end

        ST_READ_FALL_RESULT : begin
            if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_READ_FALL_RESULT_POST;
            else
                next_state <= ST_READ_FALL_RESULT;               
        end

        ST_READ_FALL_RESULT_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CAL_RESULT;
            else 
                next_state <= ST_READ_FALL_RESULT_POST;             
        end

        ST_CAL_RESULT : begin
            if( 2'd2 == cnt1)
                next_state <= ST_WAIT_CAL_RESULT;
            else 
                next_state <= ST_CAL_RESULT;               
        end

        ST_WAIT_CAL_RESULT : begin
            if( 2'd2 == cnt1)
				next_state <= ST_MEASURE_DONE;
            else 
                next_state <= ST_WAIT_CAL_RESULT;              
        end

        ST_MEASURE_DONE : begin
            if( 2'd2 == cnt1)begin
				if(1'b1 == as6500_interrupt)
					next_state <= ST_WAIT_SIGN;
				else 
					next_state <= ST_CLEAR_START_BEHIND_PRE;
				end
            else 
                next_state <= ST_MEASURE_DONE;               
        end
		
		ST_CLEAR_START_BEHIND_PRE : begin
			if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_START_BEHIND;
            else 
                next_state <= ST_CLEAR_START_BEHIND_PRE;               
        end

        ST_CLEAR_START_BEHIND : begin
            if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_CLEAR_START_BEHIND_POST;
            else
                next_state <= ST_CLEAR_START_BEHIND;            
        end

        ST_CLEAR_START_BEHIND_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_RISE_BEHIND_PRE;
            else 
                next_state <= ST_CLEAR_START_BEHIND_POST;             
        end
		
        ST_CLEAR_RISE_BEHIND_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_RISE_BEHIND;
            else 
                next_state <= ST_CLEAR_RISE_BEHIND_PRE;               
        end

        ST_CLEAR_RISE_BEHIND : begin
            if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_CLEAR_RISE_BEHIND_POST;
            else
                next_state <= ST_CLEAR_RISE_BEHIND;            
        end

        ST_CLEAR_RISE_BEHIND_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_FALL_BEHIND_PRE;
            else 
                next_state <= ST_CLEAR_RISE_BEHIND_POST;             
        end
		
		ST_CLEAR_FALL_BEHIND_PRE : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_FALL_BEHIND;
            else 
                next_state <= ST_CLEAR_FALL_BEHIND_PRE;               
        end

        ST_CLEAR_FALL_BEHIND : begin
            if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                next_state <= ST_CLEAR_FALL_BEHIND_POST;
            else
                next_state <= ST_CLEAR_FALL_BEHIND;            
        end

        ST_CLEAR_FALL_BEHIND_POST : begin
            if( 2'd2 == cnt1)
                next_state <= ST_CLEAR_DONE;
            else 
                next_state <= ST_CLEAR_FALL_BEHIND_POST;             
        end
		
		ST_CLEAR_DONE : begin
			if( 2'd2 == cnt1)begin
				//if(1'b1 == as6500_interrupt) 
				if(1'b0 == as6500_interrupt)// tjs
					next_state <= ST_WAIT_SIGN;
				else if(cnt_clear >= 4'd3)
					next_state <= ST_CLEAR_START_BEHIND_PRE;
				else 
					next_state <= ST_CLEAR_RISE_BEHIND_PRE;
				end
            else 
                next_state <= ST_CLEAR_DONE;               
        end
		
        default : begin
            next_state <= ST_IDLE;
        end
    endcase
end

// state machine output
always@(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        spi_tx_byte_valid 	<= 1'b0;
        spi_tx_byte 		<= 8'd0;  
        cnt_byte 			<= 8'd0; 
        spi_cs_n 			<= 1'b1;  
        cnt1 				<= 2'd0;  
        cnt_delay_h			<= 6'h0;
		cnt_delay_l			<= 8'h0;
		cnt_wait			<= 8'd0;
		cnt_clear			<= 4'd0;
        rise 				<= 32'd0;
        fall 				<= 32'd0;
        rise_1 				<= 32'd0;
        fall_1 				<= 32'd0;
        rise_2 				<= 32'd0;
        fall_2 				<= 32'd0;		
        middle_result 		<= 32'd0;
        start_result 		<= 32'd0;
        rise_result 		<= 32'd0;
        fall_result 		<= 32'd0;
        measure_data 		<= 32'd0;
        read_config_value 	<= 144'd0;
    end
    else begin
        case (next_state)
            ST_IDLE : begin
                spi_tx_byte_valid 	<= 1'b0;
                spi_tx_byte 		<= 8'd0;  
                cnt_byte 			<= 8'd0; 
                spi_cs_n 			<= 1'b1;  
                cnt1 				<= 2'd0;  
				cnt_delay_h			<= 6'h0;
				cnt_delay_l			<= 8'h0;
				cnt_wait			<= 8'd0;
				cnt_clear			<= 4'd0;
                rise 				<= 32'd0;
                fall 				<= 32'd0;
				rise_1 				<= 32'd0;
				fall_1 				<= 32'd0;
				rise_2 				<= 32'd0;
				fall_2 				<= 32'd0;	
                middle_result 		<= 32'd0;
                start_result 		<= 32'd0;
                rise_result 		<= 32'd0;
                fall_result 		<= 32'd0;
                measure_data 		<= 32'd0;
                read_config_value 	<= 144'd0;
            end 

            ST_POWER_ON_RESET_PRE : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0;
            end

            ST_POWER_ON_RESET : begin
                if(spi_tx_ready_reg) begin
                    spi_tx_byte <= OP_CODE_POWER_ON_RESET;
                    spi_tx_byte_valid <= 1'b1;
                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end
            end

            ST_POWER_ON_RESET_POST : begin
				if(cnt_delay_l == 8'hFF)
					cnt_delay_h <= cnt_delay_h + 1'b1;
					
				if(cnt_delay_l == 8'hFF)
					cnt_delay_l	<= 8'h0;
				else
					cnt_delay_l <= cnt_delay_l + 1'b1;
            end

            ST_CONFIG_PRE : begin
				cnt_delay_h	<= 6'h0;
				cnt_delay_l	<= 8'h0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0;
            end

            ST_CONFIG : begin
                if(spi_rx_byte_valid) begin
                    if(NUM_CONFIG_REGISTER + 8'd1 == cnt_byte)
                        cnt_byte <= 8'd0;
                    else
                        cnt_byte <= cnt_byte + 8'd1;
                end

                if(spi_tx_ready_reg) begin
                    if(8'd0 == cnt_byte) begin
                        spi_tx_byte <= OP_CODE_WRITE_CONFIG;
                        spi_tx_byte_valid <= 1'b1;
                    end
                    else if(NUM_CONFIG_REGISTER + 8'd1 <= cnt_byte) begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b0;                       
                    end
                    else begin
                        spi_tx_byte <= CONFIG_VALUE_REG[((cnt_byte << 3) - 8'd1) -: 8];
                        spi_tx_byte_valid <= 1'b1;
                    end   
                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end
            end

            ST_CONFIG_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1;               
            end

            ST_READ_CONFIG_PRE : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0;                
            end

            ST_READ_CONFIG : begin
				if(spi_rx_byte_valid) begin
                    if(NUM_CONFIG_REGISTER + 8'd1 == cnt_byte)
                        cnt_byte <= 8'd0;
                    else
                        cnt_byte <= cnt_byte + 8'd1;
                end

                if(spi_tx_ready_reg) begin
                    if(8'd0 == cnt_byte) begin
                        spi_tx_byte <= OP_CODE_READ_CONFIG;
                        spi_tx_byte_valid <= 1'b1;
                    end
                    else if(NUM_CONFIG_REGISTER + 8'd1 <= cnt_byte) begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b0;
					end
                    else begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b1;
                    end

                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end

                // register read data
                if(spi_rx_byte_valid)  
                    read_config_value <= {spi_rx_byte,read_config_value[143:8]};              
            end

            ST_READ_CONFIG_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1;  
            end

            ST_INIT_PRE : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0;               
            end

            ST_INIT : begin
                if(spi_tx_ready_reg) begin
                    spi_tx_byte <= OP_CODE_INIT;
                    spi_tx_byte_valid <= 1'b1;
                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end
            end

            ST_INIT_POST : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1;                 
            end
			
			ST_WAIT_SIGN : begin
				cnt1 <= 2'd0;
				cnt_clear <= 4'd0;
			end

            ST_WAIT_INTN : begin
				if(1'b0 == as6500_interrupt)
					cnt_wait <= 8'd0;
				else if(NUM_WAIT_INTN_PERIOD <= cnt_wait)
					cnt_wait <= 8'd0;
				else
					cnt_wait <= cnt_wait + 1'b1;
            end
			
			ST_CLEAR_FALL_BEGIN_PRE : begin
				cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_CLEAR_FALL_BEGIN : begin
				if(spi_rx_byte_valid) begin
					if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
						cnt_byte <= 8'd0;
					else
						cnt_byte <= cnt_byte + 8'd1;
				end

				if(spi_tx_ready_reg) begin
					if(8'd0 == cnt_byte) begin
						spi_tx_byte <= OP_CODE_CLEAR_CH3_RESULT;
						spi_tx_byte_valid <= 1'b1;
					end
					else if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b0;                       
					end
					else begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b1;
					end
				end
				else begin
					spi_tx_byte <= OP_CODE_NOP;
					spi_tx_byte_valid <= 1'b0;                    
				end
            end 

            ST_CLEAR_FALL_BEGIN_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
            end 

            ST_READ_START_RESULT_PRE : begin
				cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_READ_START_RESULT : begin
				if(spi_rx_byte_valid) begin
					if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
						cnt_byte <= 8'd0;
					else
						cnt_byte <= cnt_byte + 8'd1;
				end

				if(spi_tx_ready_reg) begin
					if(8'd0 == cnt_byte) begin
						spi_tx_byte <= OP_CODE_READ_CH1_RESULT;
						spi_tx_byte_valid <= 1'b1;
					end
					else if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b0;                       
					end
					else begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b1;
					end
				end
				else begin
					spi_tx_byte <= OP_CODE_NOP;
					spi_tx_byte_valid <= 1'b0;                    
				end

                // register read data
                if(spi_rx_byte_valid)  
                    middle_result <= {middle_result[23:0],spi_rx_byte}; 
            end 

            ST_READ_START_RESULT_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
				if(middle_result != 32'hFFFFFFFF)
					start_result	<= middle_result;
				else
					start_result	<= 32'hFFFF_FFFF;//32'd0;
            end 

            ST_READ_RISE_RESULT_PRE : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_READ_RISE_RESULT : begin
				if(spi_rx_byte_valid) begin
                    if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                        cnt_byte <= 8'd0;
                    else
                        cnt_byte <= cnt_byte + 8'd1;
                end

                if(spi_tx_ready_reg) begin
                    if(8'd0 == cnt_byte) begin
                        spi_tx_byte <= OP_CODE_READ_CH2_RESULT;
                        spi_tx_byte_valid <= 1'b1;
                    end
                    else if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b0;                       
                    end
                    else begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b1;
                    end
                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end

                // register read data
                if(spi_rx_byte_valid) 
					middle_result	<= {middle_result[23:0],spi_rx_byte};
            end 

            ST_READ_RISE_RESULT_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
				if(middle_result != 32'hFFFFFFFF)
					rise_result	<= middle_result;
				else
					rise_result	<= 32'hFFFF_FFFF;//32'd0
            end 

            ST_READ_FALL_RESULT_PRE : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_READ_FALL_RESULT : begin
				if(spi_rx_byte_valid) begin
                    if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
                        cnt_byte <= 8'd0;
                    else
                        cnt_byte <= cnt_byte + 8'd1;
                end

                if(spi_tx_ready_reg) begin
                    if(8'd0 == cnt_byte) begin
                        spi_tx_byte <= OP_CODE_READ_CH3_RESULT;
                        spi_tx_byte_valid <= 1'b1;
                    end
                    else if(NUM_RESULT_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b0;                       
                    end
                    else begin
                        spi_tx_byte <= OP_CODE_NOP;
                        spi_tx_byte_valid <= 1'b1;
                    end
                end
                else begin
                    spi_tx_byte <= OP_CODE_NOP;
                    spi_tx_byte_valid <= 1'b0;                    
                end

                // register read data
                if(spi_rx_byte_valid)  
                    middle_result <= {middle_result[23:0],spi_rx_byte}; 
            end 

            ST_READ_FALL_RESULT_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
				if(middle_result != 32'hFFFFFFFF)
					fall_result	<= middle_result;
				else
					fall_result	<= 32'hFFFF_FFFF;//32'd0
            end

            ST_CAL_RESULT : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 4'd1;
					
				//if(1'b0 == as6500_interrupt)
				if(1'b1 == as6500_interrupt)//tjs
					rise <= 32'hFFFF_FFFF; //32'd0;
				else if(rise_result == 32'd0)
					rise <= 32'hFFFF_FFFF; //32'd0;
				else if(start_result == 32'hFFFF_FFFF)
					rise <= 32'hFFFF_FFFF; //32'd0;   
				else if(rise_result == 32'hFFFF_FFFF)
					rise <= 32'hFFFF_FFFF; //32'd0;                                        
				else begin
					if(4'd0 == cnt1)begin
						rise_1 <= (rise_result[31:24] << 5'd16) - (start_result[31:24] << 5'd16) ;//+ rise_result[15:0] - start_result[15:0]);
						rise_2 <= rise_result[15:0] - start_result[15:0];
					end
					else if(4'd1 == cnt1)
						rise <= rise_1 + rise_2 ;
				end

				//if(1'b0 == as6500_interrupt)
				if(1'b1 == as6500_interrupt)//tjs
					fall <= 32'hFFFF_FFFF;//32'd0;
				else if(fall_result == 32'd0)
					fall <= 32'hFFFF_FFFF;//32'd0;
				else if(start_result == 32'hFFFF_FFFF)
					fall <= 32'hFFFF_FFFF;
				else if(fall_result  == 32'hFFFF_FFFF)
					fall <= 32'hFFFF_FFFF;                    

				else begin
					if(4'd0 == cnt1)	begin				
						fall_1 <= (fall_result[31:24] << 5'd16) - (start_result[31:24] << 5'd16) ;//+ fall_result[15:0] - start_result[15:0]);
						fall_2 <= fall_result[15:0] - start_result[15:0];
					end
					else if(4'd1 == cnt1)
						fall <= fall_1 + fall_2;
				end
            end

            ST_WAIT_CAL_RESULT : begin
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 4'd1;               
            end

            ST_MEASURE_DONE : begin
                if(2'd2 == cnt1) 
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1; 
                if(2'd0 == cnt1)
					measure_data <= {rise[17:2],fall[17:2]};
                if(2'd1 == cnt1) 
                    measure_data <= measure_data;  // store data untill next refresh
            end
			
			ST_CLEAR_START_BEHIND_PRE : begin
				cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_CLEAR_START_BEHIND : begin
				if(spi_rx_byte_valid) begin
					if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
						cnt_byte <= 8'd0;
					else
						cnt_byte <= cnt_byte + 8'd1;
				end

				if(spi_tx_ready_reg) begin
					if(8'd0 == cnt_byte) begin
						spi_tx_byte <= OP_CODE_CLEAR_CH1_RESULT;
						spi_tx_byte_valid <= 1'b1;
					end
					else if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b0;                       
					end
					else begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b1;
					end
				end
				else begin
					spi_tx_byte <= OP_CODE_NOP;
					spi_tx_byte_valid <= 1'b0;                    
				end
            end 

            ST_CLEAR_START_BEHIND_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
            end
			
			ST_CLEAR_RISE_BEHIND_PRE : begin
				cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_CLEAR_RISE_BEHIND : begin
				if(spi_rx_byte_valid) begin
					if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
						cnt_byte <= 8'd0;
					else
						cnt_byte <= cnt_byte + 8'd1;
				end

				if(spi_tx_ready_reg) begin
					if(8'd0 == cnt_byte) begin
						spi_tx_byte <= OP_CODE_CLEAR_CH2_RESULT;
						spi_tx_byte_valid <= 1'b1;
					end
					else if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b0;                       
					end
					else begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b1;
					end
				end
				else begin
					spi_tx_byte <= OP_CODE_NOP;
					spi_tx_byte_valid <= 1'b0;                    
				end
            end 

            ST_CLEAR_RISE_BEHIND_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
            end
			
			ST_CLEAR_FALL_BEHIND_PRE : begin
				cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd0 == cnt1)
                    spi_cs_n <= 1'b1;  
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b0; 
            end

            ST_CLEAR_FALL_BEHIND : begin
				if(spi_rx_byte_valid) begin
					if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 == cnt_byte)
						cnt_byte <= 8'd0;
					else
						cnt_byte <= cnt_byte + 8'd1;
				end

				if(spi_tx_ready_reg) begin
					if(8'd0 == cnt_byte) begin
						spi_tx_byte <= OP_CODE_CLEAR_CH3_RESULT;
						spi_tx_byte_valid <= 1'b1;
					end
					else if(NUM_CLEAR_REGISTER_PER_CHANNEL + 8'd1 <= cnt_byte) begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b0;                       
					end
					else begin
						spi_tx_byte <= OP_CODE_NOP;
						spi_tx_byte_valid <= 1'b1;
					end
				end
				else begin
					spi_tx_byte <= OP_CODE_NOP;
					spi_tx_byte_valid <= 1'b0;                    
				end
            end 

            ST_CLEAR_FALL_BEHIND_POST : begin
                cnt_byte <= 8'd0;
                if(2'd2 == cnt1)
                    cnt1 <= 2'd0;
                else
                    cnt1 <= cnt1 + 1'b1;
                if(2'd1 == cnt1)
                    spi_cs_n <= 1'b1; 
            end
			
			ST_CLEAR_DONE : begin
                if(2'd2 == cnt1) begin
                    cnt1 <= 2'd0;
                    cnt_clear <= cnt_clear + 1'b1;
                    end
                else
                    cnt1 <= cnt1 + 1'b1; 
            end

            default :  begin
                spi_tx_byte_valid <= 1'b0;
                spi_tx_byte <= 8'd0;  
                cnt_byte <= 8'd0; 
				cnt_delay_h	<= 6'h0;
				cnt_delay_l	<= 8'h0;
				cnt_wait <= 8'd0; 
				cnt_clear <= 4'd0;
                spi_cs_n <= 1'b1;  
                cnt1 <= 2'd0;  
                rise <= 32'd0;
                fall <= 32'd0;
                rise_1 <= 32'd0;
                rise_2 <= 32'd0;				
                fall_1 <= 32'd0;
                fall_2 <= 32'd0;				
				middle_result <= 32'd0;
				start_result <= 32'd0;
                rise_result <= 32'd0;
                fall_result <= 32'd0;
                measure_data <= 32'd0;              
            end
        endcase
    end
end

//*****************************************
// end control state machine
//*****************************************

// measure_data_valide
always@(posedge sys_clk, negedge sys_rst_n) begin
	if(!sys_rst_n) begin
        measure_data_valide <= 1'b0;
    end
	else begin
		if(current_state == ST_MEASURE_DONE && 2'd1 <= cnt1)
			measure_data_valide <= 1'b1;
		else
			measure_data_valide <= 1'b0;
	end
end

// verify_success
always@(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        verify_success <= 1'b0;
    end
    else begin
        if(current_state == ST_READ_CONFIG_POST)
           // verify_success <= (read_config_value[143:8] == CONFIG_VALUE_REG) ? 1'b1 : 1'b0;
             verify_success = 1'b1; // tjs just for test
        else
            verify_success <= verify_success;
    end
end

// as6500_config_done
assign as6500_config_done = verify_success;

// as6500_init_done
always@(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        as6500_init_done <= 1'b0;
    end
    else begin
        if(current_state == ST_WAIT_INTN)
            as6500_init_done <= 1'b1;
        else
            as6500_init_done <= 1'b0;
    end
end

endmodule
