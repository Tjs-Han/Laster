// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: gpx2_cfg
// Date Created 	: 2024/09/06 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:gpx2_cfg
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module gpx2_cfg(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_gpx2_module_en,

    // control signal               
    input                   i_gpx2_measure_en,
    input                   i_gpx2_measure_sign,
    input                   i_gpx2_init,

    //spi master side               
    output                  o_spi_ssn,
    output                  o_spicom_req,
    output [7:0]            o_spi_wdata,
    input                   i_spicom_ready,
    input                   i_spi_rdvalid,
    input  [7:0]            i_spi_rdbyte
);
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
    localparam [135:0]   GPX2_REGDATA_CONFIG ={
                                                8'h00, //reg16
                                                8'h7d, //reg15
                                                8'hf1, //reg14
                                                8'hcc, //reg13
                                                8'hcc, //reg12
                                                8'h0a, //reg11
                                                8'h00, //reg10
                                                8'h13, //reg9
                                                8'hA1, //reg8
                                                8'h53, //reg7   bit[7]=0  0=REFCLK pins.    1=TDC_OSC
                                                // 8'hd3, //reg7    bit[7]=1     1=TDC_OSC 8M OSC
                                                8'hc0, //reg6   LVDS_TEST_PATTERN = 0
                                                // 8'hd0, //reg6    LVDS_TEST_PATTERN = 1
                                                8'h01, //reg5   REFCLK_DIVISIONS = 40000
                                                8'h00, //reg4
                                                8'h00, //reg3
                                                8'h0c, //reg2   REF_INDEX_BITWIDTH = 100(16BIT) STOP_DATA_BITWIDTH = 01(16BIT) SDR
                                                8'h07, //reg1
                                                // 8'h04,
                                                8'h37  //reg0   LVDS_EN,REFCLK input pins active PIN_ENA_REFCLK=1
                                                // 8'h27  //reg0    LVDS_EN,REFCLK input pins not active PIN_ENA_REFCLK=0
                                            };
    //--------------------------------------------------------------------------------------------------
	// wire define
	//--------------------------------------------------------------------------------------------------
    // register state
    reg [7:0]   r_curr_state            = 8'h0;
    reg [7:0]   r_next_state            = 8'h0;
    reg         r_spi_ssn               = 1'b1;

    reg         r_regcfg_verify         = 1'b0;
    reg         r_tdc_initfail          = 1'b0;
    reg         r_as6500_laser_enable   = 1'b1;
    reg [31:0]  r_measure_data          = 32'd0;
    reg         r_measure_data_valid    = 1'b0;
    reg [7:0]   r_spi_wdata             = 8'd0;
    reg         r_spicom_req            = 1'b0;
    reg         r_spicom_ready          = 1'b0;
    reg         r_tdc_reset_sig; 
    reg [15:0]  r_tdcint_delay_cnt;
    
    reg [7:0] 	r_cnt_byte 			    = 8'd0;
    reg [31:0]  r_gpx2_dlycnt           = 32'd0;      
	reg [143:0] r_rdcfg_value	        = 144'd0;
	
    //--------------------------------------------------------------------------------------------------
	// localparam define
	//--------------------------------------------------------------------------------------------------
    // define localparam
    localparam NUM_CONFIG_REGISTER                  = 8'd17;
    localparam NUM_RESULT_REGISTER_PER_CHANNEL      = 8'd4;
    localparam NUM_CLEAR_REGISTER_PER_CHANNEL       = 8'd1;
    localparam NUM_WAIT_INTN_PERIOD                 = 8'd23;

    // as6500 opcode
    localparam OPCODE_NOP                           = 8'h0;
    localparam OPCODE_PORON                         = 8'h30;
    localparam OP_CODE_INIT                         = 8'h18;
    localparam OPCODE_WRCFG_ADDR                    = 8'h80;
    localparam OPCODE_RDCFG_ADDR                    = 8'h40;

    localparam ST_GPX2_IDLE                         = 8'd0;
    localparam ST_GPX2_PORON                        = 8'd1;
    localparam ST_GPX2_PORDLY                       = 8'd2;
    localparam ST_GPX2_WRREG                        = 8'd3;
    localparam ST_GPX2_RDREG                        = 8'd4;
    localparam ST_GPX2_WAIT_EN                      = 8'd5;
    localparam ST_GPX2_INIT                         = 8'd6;
    localparam ST_GPX2_WAIT_SIGN                    = 8'd7;
    localparam ST_GPX2_WAIT_RESULT                  = 8'd8;
    localparam ST_GPX2_END                          = 8'd9;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) 
            r_spicom_ready <= 1'b0;
        else 
            r_spicom_ready <= i_spicom_ready;
    end

    //--------------------------------------------------------------------------------------------------
	// Three-stage state machine
	//--------------------------------------------------------------------------------------------------
    //r_curr_state
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_curr_state <= ST_GPX2_IDLE;
        end else begin
            r_curr_state <= r_next_state;
        end
    end

    //r_next_state trans comb logic
    always @(*) begin
        case(r_curr_state)
            ST_GPX2_IDLE: begin
                if(i_gpx2_module_en)    
                    r_next_state = ST_GPX2_PORON;
                else
                    r_next_state = ST_GPX2_IDLE;
            end
            ST_GPX2_PORON: begin
                if(i_spi_rdvalid)
                    r_next_state = ST_GPX2_PORDLY;
                else 
                    r_next_state = ST_GPX2_PORON;
            end
            ST_GPX2_PORDLY: begin
                if(r_gpx2_dlycnt >= 32'd200_000)
                    r_next_state = ST_GPX2_WRREG;
                else
                    r_next_state = ST_GPX2_PORDLY;
            end
            ST_GPX2_WRREG: begin
                if(i_spi_rdvalid) begin
                    if(r_cnt_byte >= NUM_CONFIG_REGISTER)
                        r_next_state = ST_GPX2_RDREG;
                    else
                        r_next_state = ST_GPX2_WRREG;
                end else
                   r_next_state = ST_GPX2_WRREG; 
            end
            ST_GPX2_RDREG: begin
                if(i_spi_rdvalid) begin
                    if(r_cnt_byte >= NUM_CONFIG_REGISTER)
                        r_next_state = ST_GPX2_WAIT_EN;
                    else
                        r_next_state = ST_GPX2_RDREG;
                end else
                   r_next_state = ST_GPX2_RDREG;
            end
            ST_GPX2_WAIT_EN: begin
                if(i_gpx2_measure_en)
                    r_next_state = ST_GPX2_INIT;
                else
                    r_next_state = ST_GPX2_WAIT_EN;
            end
            ST_GPX2_INIT: begin
                if(i_spi_rdvalid)
                    r_next_state = ST_GPX2_WAIT_SIGN;
                else
                    r_next_state = ST_GPX2_INIT;
            end
            ST_GPX2_WAIT_SIGN: begin
                if(i_gpx2_measure_sign)
                    r_next_state = ST_GPX2_WAIT_RESULT;
                else
                    r_next_state = ST_GPX2_WAIT_SIGN;
            end
            ST_GPX2_WAIT_RESULT: begin
                if(r_gpx2_dlycnt >= 32'd39)
                    r_next_state = ST_GPX2_END;
                    // r_next_state = ST_GPX2_INIT; 
                else
                    r_next_state = ST_GPX2_WAIT_RESULT;
            end
            ST_GPX2_END: begin
                if(i_gpx2_init)
                    r_next_state = ST_GPX2_INIT;
                    // r_next_state = ST_GPX2_WAIT_SIGN;
                else
                    r_next_state = ST_GPX2_END;
            end
            default : begin
                r_next_state = ST_GPX2_IDLE;
            end
        endcase
    end

    // state machine output
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_spicom_req    <= 1'b0;
            r_spi_wdata     <= 8'd0;  
            r_cnt_byte      <= 8'd0; 
            r_spi_ssn       <= 1'b1;   
            r_gpx2_dlycnt   <= 32'd0;
            r_rdcfg_value   <= 144'h0;
        end else begin
            case (r_curr_state)
                ST_GPX2_IDLE: begin
                    r_spicom_req    <= 1'b0;
                    r_spi_wdata     <= 8'd0;  
                    r_cnt_byte      <= 8'd0; 
                    r_spi_ssn       <= 1'b1;  
                    r_gpx2_dlycnt   <= 32'd0;
                    r_rdcfg_value   <= 144'h0;
                end 
                ST_GPX2_PORON: begin
                    r_spi_ssn   <= 1'b0;
                    if(r_spicom_ready) begin
                        r_spi_wdata     <= OPCODE_PORON;
                        r_spicom_req    <= 1'b1;
                    end else begin
                        r_spi_wdata     <= OPCODE_NOP;
                        r_spicom_req    <= 1'b0;                    
                    end
                end
                ST_GPX2_PORDLY: begin
                    r_spi_ssn   <= 1'b1;
    				if(r_gpx2_dlycnt >= 32'd200_000)
    					r_gpx2_dlycnt   <= 32'd0;
    				else
    					r_gpx2_dlycnt   <= r_gpx2_dlycnt + 1'b1;
                end
                ST_GPX2_WRREG: begin
                    r_gpx2_dlycnt   <= 32'd0;
                    r_spi_ssn   <= 1'b0;
                    if(i_spi_rdvalid) begin
                        if(r_cnt_byte >= NUM_CONFIG_REGISTER) begin
                            r_cnt_byte  <= 8'd0;
                            r_spi_ssn   <= 1'b1;
                        end else begin
                            r_cnt_byte  <= r_cnt_byte + 8'd1;
                            r_spi_ssn   <= 1'b0;
                        end
                    end
    
                    if(r_spicom_ready) begin
                        if(r_cnt_byte == 8'd0) begin
                            r_spi_wdata     <= OPCODE_WRCFG_ADDR;
                            r_spicom_req    <= 1'b1;
                        end else begin
                            r_spi_wdata     <= GPX2_REGDATA_CONFIG[((r_cnt_byte << 3) - 8'd1) -: 8];
                            r_spicom_req    <= 1'b1;
                        end
                    end else begin
                        r_spi_wdata     <= OPCODE_NOP;
                        r_spicom_req    <= 1'b0;                    
                    end             
                end
                ST_GPX2_RDREG: begin
                    r_spi_ssn   <= 1'b0;
                    if(i_spi_rdvalid) begin
                        r_rdcfg_value <= {i_spi_rdbyte,r_rdcfg_value[143:8]};
                        if(r_cnt_byte >= NUM_CONFIG_REGISTER) begin
                            r_cnt_byte  <= 8'd0;
                            r_spi_ssn   <= 1'b1;
                        end else begin
                            r_cnt_byte  <= r_cnt_byte + 8'd1;
                            r_spi_ssn   <= 1'b0;
                        end
                    end
    
                    if(r_spicom_ready) begin
                        if(r_cnt_byte == 8'd0) begin
                            r_spi_wdata     <= OPCODE_RDCFG_ADDR;
                            r_spicom_req    <= 1'b1;
                        end else begin
                            r_spi_wdata     <= OPCODE_NOP;
                            r_spicom_req    <= 1'b1;
                        end
                    end else begin
                        r_spi_wdata     <= OPCODE_NOP;
                        r_spicom_req    <= 1'b0;                    
                    end             
                end
                ST_GPX2_WAIT_EN: begin
    	    		r_spi_ssn       <= 1'b1;
                    r_spi_wdata     <= OPCODE_NOP;
                    r_spicom_req    <= 1'b0;
    	    	end
                ST_GPX2_INIT: begin
                    r_gpx2_dlycnt   <= 32'd0;
                    r_spi_ssn   <= 1'b0;
                    if(r_spicom_ready) begin
                        r_spi_wdata <= OP_CODE_INIT;
                        r_spicom_req <= 1'b1;
                    end else begin
                        r_spi_wdata <= OPCODE_NOP;
                        r_spicom_req <= 1'b0;                    
                    end
                end
    			ST_GPX2_WAIT_SIGN: begin
    				r_spi_ssn       <= 1'b1;
                    r_spi_wdata     <= OPCODE_NOP;
                    r_spicom_req    <= 1'b0;
    			end
                ST_GPX2_WAIT_RESULT: begin
                    if(r_gpx2_dlycnt >= 32'd39)
					    r_gpx2_dlycnt   <= 32'd0;
					else
				        r_gpx2_dlycnt   <= r_gpx2_dlycnt + 1'b1;
                end
                ST_GPX2_END: begin
                    r_gpx2_dlycnt   <= 32'd0;
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

    // r_regcfg_verify
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_regcfg_verify <= 1'b0;
        end else begin
            if(r_curr_state == ST_GPX2_WAIT_EN)
                r_regcfg_verify <= (r_rdcfg_value[143:8] == GPX2_REGDATA_CONFIG) ? 1'b1 : 1'b0;
            else
                r_regcfg_verify <= r_regcfg_verify;
        end
    end

    // r_tdc_initfail
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_tdc_initfail <= 1'b0;
        end else if(r_regcfg_verify)
            r_tdc_initfail <= 1'b0;
        else
            r_tdc_initfail <= 1'b1;
    end

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_spi_ssn                = r_spi_ssn;
    assign o_spicom_req             = r_spicom_req;
    assign o_spi_wdata              = r_spi_wdata;
endmodule
