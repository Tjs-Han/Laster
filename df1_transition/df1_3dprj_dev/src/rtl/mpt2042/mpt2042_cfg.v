// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_cfg
// Date Created 	: 2025/03/27
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:mpt2042_cfg
//      The steps for configuring the mpt2042 register are as follows:
//      1、The SPI register is reset, and the ENABLE is pulled down by at least 10ns and then pulled up.
//      2、The working status of the chip is reset. The RESETN pulls down for at least 10ns and then pulls up.
//      3、After the reset is complete, the host sends the register configuration to the chip, sets the CSN pin to low level，
//         and sets the W/R bit to 0 to start writing the register.
//      4、Specify the register address A[6:0] to write the content，
//         it is recommended to continuously write all register configurations starting from register 0
//      5、The register value of the corresponding address is sent at the falling edge of CLK，
//         and the chip reads it at the rising edge of CLK.
//      6、After the writing is complete, the CSN is pulled up, and the chip immediately works in the current register configuration
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module mpt2042_cfg(
    input                   i_clk,
    input                   i_rst_n,

    // control signal               
    output                  o_tdc_enable,
    output                  o_tdc_resetn,

    //spi master side
    output                  o_module_en,
    output                  o_spi_ssn,
    output                  o_spicom_req,
    output [7:0]            o_spi_wdata,
    input                   i_spicom_ready,
    input                   i_spicom_done,
    input  [7:0]            i_spi_rdbyte,
    output                  o_cfgtdc_state,
    output [7:0]            o_gpio_temp
);
    //--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
    reg  [7:0]	    r_1us_clkcnt 	        = 8'd0;
	reg  [9:0]	    r_1ms_uscnt 	        = 10'd0;	
	reg  [9:0]	    r_sec_mscnt             = 10'd0;
    reg  [7:0]	    r_1sec_dlycnt           = 8'd0;
	reg             r_module_en             = 1'b0;

    reg  [7:0]      r_curr_state            = 8'h0;
    reg  [7:0]      r_next_state            = 8'h0;
    reg  [7:0]      r_dly_clkcnt            = 8'd0;
    reg             r_tdc_enable            = 1'b1;
    reg             r_tdc_resetn            = 1'b1;
    reg             r_spi_ssn               = 1'b1;
    reg  [6:0]      r_mptrom_addr           = 7'd0;
    wire [7:0]      w_mptrom_data;

    reg  [3:0]      r_cfgreg_cnt            = 4'd0;
    reg             r_regcfg_verify         = 1'b1;
    reg             r_regcfg_success        = 1'b1;
    reg             r_tdc_initfail          = 1'b0;
    reg  [7:0]      r_spi_wdata             = 8'd0;
    reg             r_spicom_req            = 1'b0;
    reg             r_spicom_ready          = 1'b0;
    reg  [7:0] 	    r_cnt_byte 			    = 8'd0;
    reg  [7:0]      r_spi_rdbyte            = 8'h0;
    reg             r_cfgtdc_state          = 1'b0;
    reg  [7:0]      r_gpio_temp             = 8'h0;
	
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
    // define localparam
    localparam US_CLK_CNTNUM                        = 8'd79;
    localparam US_CNTNUM                            = 10'd999;
    localparam MS_CNTNUM                            = 10'd999;
    localparam SEC_DLY_NUM	                        = 8'd6;
    localparam INIT_CLKNUM	                        = 8'd8;
    localparam REGISTER_NUM                         = 8'd58;
    localparam CONFIG_MAXCNT                        = 4'd8;

    // as6500 opcode
    localparam WRMPT_START_ADDR                     = 8'h00;
    localparam RDMPT_START_ADDR                     = 8'h80;
    localparam RDMPT_OPCODE                         = 8'h00;

    localparam ST_IDLE                              = 8'd0;
    localparam ST_ENABLE                            = 8'd1;
    localparam ST_RESET                             = 8'd2;
    localparam ST_WRREG                             = 8'd3;
    localparam ST_RDREG                             = 8'd4;
    localparam ST_VERIFY                            = 8'd5;
    localparam ST_END                               = 8'd6;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            r_spicom_ready <= 1'b0;
        else 
            r_spicom_ready <= i_spicom_ready;
    end

    //r_1us_clkcnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1us_clkcnt    <= 8'd0;
		else if(r_1us_clkcnt >= US_CLK_CNTNUM)
			r_1us_clkcnt    <= 8'd0;
        else
            r_1us_clkcnt    <= r_1us_clkcnt + 1'b1;
	end

    //r_1ms_uscnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1ms_uscnt <= 10'd0;
		else if(r_1ms_uscnt >= US_CNTNUM)
			r_1ms_uscnt <= 10'd0;
        else if(r_1us_clkcnt >= US_CLK_CNTNUM)
            r_1ms_uscnt <= r_1ms_uscnt + 1'b1;
        else
            r_1ms_uscnt <= r_1ms_uscnt;
	end

    //r_sec_mscnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_sec_mscnt <= 10'd0;
		else if(r_sec_mscnt >= MS_CNTNUM)
			r_sec_mscnt <= 10'd0;
        else if(r_1ms_uscnt >= US_CNTNUM)
            r_sec_mscnt <= r_sec_mscnt + 1'b1;
        else
            r_sec_mscnt <= r_sec_mscnt;
	end

    //r_1sec_dlycnt
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_1sec_dlycnt <= 8'd0;
		else if(r_1sec_dlycnt >= SEC_DLY_NUM)
			r_1sec_dlycnt <= SEC_DLY_NUM;
        else if(r_sec_mscnt >= MS_CNTNUM)
            r_1sec_dlycnt <= r_1sec_dlycnt + 1'b1;
	end

    //r_module_en
    always @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n)
			r_module_en <= 1'b0;
		else if(r_1sec_dlycnt >= SEC_DLY_NUM)
			r_module_en <= 1'b1;
	end

    // //r_module_en
    // always @(posedge i_clk or negedge i_rst_n) begin
	// 	if (!i_rst_n)
	// 		r_module_en <= 1'b0;
	// 	else if(r_1us_clkcnt >= US_CLK_CNTNUM)
	// 		r_module_en <= 1'b1;
	// end

    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    //r_curr_state
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_curr_state <= ST_IDLE;
        end else begin
            r_curr_state <= r_next_state;
        end
    end

    //r_next_state trans comb logic
    always @(*) begin
        case(r_curr_state)
            ST_IDLE: begin
                if(r_module_en) begin
                    if(r_cfgreg_cnt <= CONFIG_MAXCNT)
                        r_next_state = ST_ENABLE;
                    else
                        r_next_state = ST_END;
                end else
                    r_next_state = ST_IDLE;
            end
            ST_ENABLE: begin
                if(r_dly_clkcnt >= INIT_CLKNUM)
                    r_next_state = ST_RESET;
                else 
                    r_next_state = ST_ENABLE;
            end
            ST_RESET: begin
                if(r_dly_clkcnt >= INIT_CLKNUM)
                    r_next_state = ST_WRREG;
                else
                    r_next_state = ST_RESET;
            end
            ST_WRREG: begin
                if(i_spicom_done) begin
                    if(r_cnt_byte >= REGISTER_NUM)
                        r_next_state = ST_RDREG;
                    else
                        r_next_state = ST_WRREG;
                end else
                   r_next_state = ST_WRREG; 
            end
            ST_RDREG: begin
                if(i_spicom_done) begin
                    if(r_cnt_byte >= REGISTER_NUM)
                        r_next_state = ST_VERIFY;
                    else
                        r_next_state = ST_RDREG;
                end else
                   r_next_state = ST_RDREG;
            end
            ST_VERIFY: begin
                if(r_regcfg_success)
                    r_next_state = ST_END;
                else
                    r_next_state = ST_IDLE;
            end
            ST_END: begin
                r_next_state = ST_END;
            end
            default : begin
                r_next_state = ST_IDLE;
            end
        endcase
    end

    // state machine output
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_dly_clkcnt    <= 8'd0;
            r_tdc_enable    <= 1'b1;
            r_tdc_resetn    <= 1'b1;
            r_mptrom_addr   <= 7'd0;
            r_spicom_req    <= 1'b0;
            r_spi_wdata     <= 8'd0;  
            r_cnt_byte      <= 8'd0; 
            r_spi_ssn       <= 1'b1;
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
                    r_dly_clkcnt    <= 8'd0;
                    r_tdc_enable    <= 1'b1;
                    r_tdc_resetn    <= 1'b1;
                    r_mptrom_addr   <= 7'd0;
                    r_spicom_req    <= 1'b0;
                    r_spi_wdata     <= 8'd0;
                    r_cnt_byte      <= 8'd0;
                    r_spi_ssn       <= 1'b1;
                end 
                ST_ENABLE: begin
                    r_tdc_resetn    <= 1'b1;
                    if(r_dly_clkcnt >= INIT_CLKNUM) begin
                        r_dly_clkcnt    <= 8'd0;
                        r_tdc_enable    <= 1'b1;
                    end else if(r_dly_clkcnt >= 8'd2 && r_dly_clkcnt <= 8'd6) begin
                        r_dly_clkcnt    <= r_dly_clkcnt + 1'b1;
                        r_tdc_enable    <= 1'b0;
                    end else begin
                        r_dly_clkcnt    <= r_dly_clkcnt + 1'b1;
                        r_tdc_enable    <= 1'b1;
                    end
                end
                ST_RESET: begin
                    r_tdc_enable    <= 1'b1;
    				if(r_dly_clkcnt >= INIT_CLKNUM) begin
                        r_dly_clkcnt    <= 8'd0;
                        r_tdc_resetn    <= 1'b1;
                    end else if(r_dly_clkcnt >= 8'd2 && r_dly_clkcnt <= 8'd6) begin
                        r_dly_clkcnt    <= r_dly_clkcnt + 1'b1;
                        r_tdc_resetn    <= 1'b0;
                    end else begin
                        r_dly_clkcnt    <= r_dly_clkcnt + 1'b1;
                        r_tdc_resetn    <= 1'b1;
                    end
                end
                ST_WRREG: begin
                    r_tdc_enable    <= 1'b1;
                    r_tdc_resetn    <= 1'b1;
                    r_spi_ssn       <= 1'b0;
                    if(i_spicom_done) begin
                        if(r_cnt_byte >= REGISTER_NUM) begin
                            r_mptrom_addr   <= 7'd0;
                            r_cnt_byte      <= 8'd0;
                            r_spi_ssn       <= 1'b1;
                        end else begin
                            r_mptrom_addr   <= r_cnt_byte;
                            r_cnt_byte      <= r_cnt_byte + 1'b1;
                            r_spi_ssn       <= 1'b0;
                        end
                    end
    
                    if(r_spicom_ready) begin
                        if(r_cnt_byte == 8'd0) begin
                            r_spi_wdata     <= WRMPT_START_ADDR;
                            r_spicom_req    <= 1'b1;
                        end else begin
                            r_spi_wdata     <= w_mptrom_data;
                            r_spicom_req    <= 1'b1;
                        end
                    end else begin
                        r_spi_wdata     <= r_spi_wdata;
                        r_spicom_req    <= 1'b0;                    
                    end             
                end
                ST_RDREG: begin
                    r_spi_ssn   <= 1'b0;
                    if(i_spicom_done) begin
                        if(r_cnt_byte >= REGISTER_NUM) begin
                            r_mptrom_addr   <= 7'd0;
                            r_cnt_byte      <= 8'd0;
                            r_spi_ssn       <= 1'b1;
                        end else begin
                            r_mptrom_addr   <= r_cnt_byte;
                            r_cnt_byte      <= r_cnt_byte + 8'd1;
                            r_spi_ssn       <= 1'b0;
                        end
                    end
    
                    if(r_spicom_ready) begin
                        if(r_cnt_byte == 8'd0) begin
                            r_spi_wdata     <= RDMPT_START_ADDR;
                            r_spicom_req    <= 1'b1;
                        end else begin
                            r_spi_wdata     <= RDMPT_OPCODE;
                            r_spicom_req    <= 1'b1;
                        end
                    end else begin
                        r_spi_wdata     <= r_spi_wdata;
                        r_spicom_req    <= 1'b0;                    
                    end             
                end
                ST_VERIFY: begin
                    r_spi_ssn   <= 1'b1;
                    r_cnt_byte  <= 8'd0;
                end
                ST_END: begin
                    r_dly_clkcnt    <= 8'd0;
                    r_tdc_enable    <= 1'b1;
                    r_tdc_resetn    <= 1'b1;
                    r_mptrom_addr   <= 7'd0;
                    r_spicom_req    <= 1'b0;
                    r_spi_wdata     <= 8'd0;
                    r_cnt_byte      <= 8'd0;
                    r_spi_ssn       <= 1'b1;
                end
                default: begin
                    r_spicom_req    <= 1'b0;
                    r_spi_wdata     <= 8'd0;  
                    r_cnt_byte      <= 8'd0; 
                    r_spi_ssn       <= 1'b1;             
                end
            endcase
        end
    end

    //----------------------------------------------------------------------------------------------
	// signal monitor according to state machine
	//----------------------------------------------------------------------------------------------
    //r_cfgreg_cnt
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_cfgreg_cnt    <= 4'd0;
        end else if(r_curr_state == ST_VERIFY) begin
            r_cfgreg_cnt    <= r_cfgreg_cnt + 1'b1;
        end
    end

    // r_regcfg_verify
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_regcfg_verify <= 1'b1;
        end else if(r_curr_state == ST_RDREG && r_cnt_byte >= 8'd1) begin
            if(i_spicom_done)
                r_regcfg_verify <= (i_spi_rdbyte == w_mptrom_data) ? 1'b1 : 1'b0;
            else
                r_regcfg_verify <= r_regcfg_verify;
        end
    end

    // r_tdc_initfail
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tdc_initfail <= 1'b0;
        end else if(r_regcfg_verify == 1'b0) begin
            r_tdc_initfail <= 1'b1;
        end
    end

    // r_regcfg_success
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_regcfg_success <= 1'b1;
        end else if(r_curr_state == ST_RDREG && r_cnt_byte >= 8'd1 && i_spicom_done) begin
            if(i_spi_rdbyte != w_mptrom_data) begin
                r_regcfg_success <= 1'b0;
            end
        end
    end

    //r_spi_rdbyte
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_spi_rdbyte    <= 8'h00;
        end else begin
            r_spi_rdbyte    <= i_spi_rdbyte;
        end
    end

    //r_cfgtdc_state
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_cfgtdc_state <= 1'b0;
        end else if(r_curr_state == ST_VERIFY) begin
            r_cfgtdc_state <= r_regcfg_success;
        end
    end

    //r_gpio_temp
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_gpio_temp <= 8'h00;
        end else begin
            r_gpio_temp <= r_spi_rdbyte;
        end
    end

    mpt2042_rom u_mpt2042_rom(
        .OutClock           ( i_clk             ),
        .OutClockEn         ( 1'b1              ),
        .Reset              ( 1'b0              ),
        .Address            ( r_mptrom_addr     ), //input [6:0]
        .Q                  ( w_mptrom_data     )  //output [7:0] 
    );
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_module_en      = r_module_en;
    assign o_tdc_enable     = r_tdc_enable;
    assign o_tdc_resetn     = r_tdc_resetn;
    assign o_spi_ssn        = r_spi_ssn;
    assign o_spicom_req     = r_spicom_req;
    assign o_spi_wdata      = r_spi_wdata;
    assign o_cfgtdc_state   = r_cfgtdc_state;
    assign o_gpio_temp      = r_gpio_temp;
endmodule
