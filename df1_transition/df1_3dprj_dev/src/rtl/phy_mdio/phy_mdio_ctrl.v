// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: phy_mdio_ctrl
// Date Created     : 2024/09/25 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:phy_mdio_ctrl
// This file is accroding to DP83822 manual
// The format of the read/write communication protocol for the MDIO interface is as follows:
/* _______________________________________________________________________________________________
  |         |                         Management Frame Fields                                     |
  |         |—————————————————————————————————————————————————————————————————————————————————————|
  |         | Preamble | ST | OP |   PHYAD   |   REGAD   | TA |            DATA            | IDLE |
  |—————————|——————————|————|————|———————————|———————————|————|————————————————————————————|——————|
  |  Read   |  0xFFFF  | 01 | 10 |  'b00111  |  'bxxxxx  | Z0 |           'hxxxx           |   Z  |
  |———————————————————————————————————————————————————————————————————————————————————————————————
  |  Write  |  0xFFFF  | 01 | 01 |  'b00111  |  'bxxxxx  | 10 |           'hxxxx           |   Z  |
   ———————————————————————————————————————————————————————————————————————————————————————————————
    Extended Register Space Access:
        Register Control Register (REGCR, address 0x000D)
        Device Address:
            Bits[4:0] are the device address, DEVAD, that directs any accesses
            of ADDAR register (0x000E) to the appropriate MMD. Specifically, the
            DP83822 uses the vendor specific DEVAD [4:0] = "11111" for
            accesses to registers 0x04D1 and lower. For MMD3 access, the
            DEVAD[4:0] = '00011'. For MMD7 access, the DEVAD[4:0] = '00111'.
            All accesses through registers REGCR and ADDAR should use the
            DEVAD for either MMD, MMD3 or MMD7. Transactions with other
            DEVAD are ignored
        Example Write Operation (No Post Increment):
            The following example will demonstrate a write operation with no post increment. In this example, the MAC
            impedance will be adjusted to 99.25 Ω using the IO MUX GPIO Control Register (IOCTRL, address 0x0461).
            1. Write the value 0x001F to register 0x000D.
            2. Write the value 0x0461 to register 0x000E. (Sets desired register to the IOCTRL)
            3. Write the value 0x401F to register 0x000D.
            4. Write the value 0x0400 to register 0x000E. (Sets MAC impedance to 99.25 Ω)
*/
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module phy_mdio_ctrl(
    input                   i_clk_100m,    //100Mhz
    input                   i_rst_n,

    //3.3-V VDDIO       
    output                  o_phy_mdc, //The maximum clock rate is 25 MHz.There is no minimum clock rate.  6.25Mhz   100M/16 = 6.25M
    inout                   io_phy_mdio, // 16 x 64 = 1024  
    output                  o_phy_reset_n  //Asserting this pin low for atleast 1 µs will force a reset process to occur.

);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    localparam NS_DLYCNT                    = 17'd100_000;
    localparam ST_CODE                      = 2'b01;
    localparam OPCODE_READ                  = 2'b10;
    localparam OPCODE_WRITE                 = 2'b01;
    // localparam PHY_ADDR                     = 5'b00111;
    localparam PHY_ADDR                     = 5'b00001;
    localparam BMCR_ADDR                    = 5'h00;
    localparam BMSR_ADDR                    = 5'h01;
    localparam ANAR_ADDR                    = 5'h04;
    localparam CR3_ADDR                     = 5'h0B;
    localparam REG_REGCR                    = 5'h0d;
    localparam REG_ADDAR                    = 5'h0e;
    localparam PHYSTS_ADDR                  = 5'h10;
    localparam RCSR_ADDR                    = 5'h17;
    localparam PHYCR_ADDR                   = 5'h19;
    localparam IOCTRL1_ADDR                 = 16'h0462;
    localparam SOR1_ADDR                    = 16'h0467;

    localparam TACODE_READ                  = 2'b00;
    localparam TACODE_WRITE                 = 2'b10;

    localparam PHY_SOFT_RESET               = 16'hb100; 
    localparam PHY_CFG_BMCR                 = 16'h3100; // bit[12]=1: Auto-Negotiation Enable
    // localparam PHY_CFG_BMCR                 = 16'h2100; // bit[12]=0: Auto-Negotiation Disable   bit[13]=1 Speed Select 100 Mbps     bit[8]=1: Full-Duplex
    localparam PHY_CFG_REG9                 = 16'h01fe; //
    localparam PHY_CFG_REGCR                = 16'h001f; //When DEVAD is "11111," it points to registers at 0x04D1 and below.
    localparam PHY_CFG_NPREGCR              = 16'h401f; //No Post Increment
    localparam PHY_CFG_RCSR                 = 16'h0061; //bit[7]=0: 25M clk ref  bit[5]=1: Enable RMII mode of operation
    // localparam PHY_CFG_RCSR                 = 16'h0062;
    // localparam PHY_CFG_PHYCR                = 16'h4021; //bit[14]=0: Normal operation (MDI)  bit[14]=1: Force MDI pairs to cross (MDIX)
    localparam PHY_CFG_PHYCR                = 16'h8021; //bit[15]=0: Disable Auto-MDIX  bit[14]=0: Normal operation (MDI)
    localparam PHY_CFG_IOCTRL1              = 16'h4301;

    //state 
    localparam ST_IDLE                      = 6'd0;
    localparam ST_WAIT_POWER_ON             = 6'd1;
    localparam ST_POWER_POST                = 6'd2;
    localparam ST_SOFT_RESET                = 6'd3;
    localparam ST_WAIT_RESET                = 6'd4;
    localparam ST_WRITE_PHY_BMCR            = 6'd5;
    localparam ST_READ_PHY_BMCR             = 6'd6;
    localparam ST_WRITE_PHY_RCSR            = 6'd7;
    localparam ST_READ_PHY_RCSR             = 6'd8;
    localparam ST_WRITE_PHYCR               = 6'd9;
    localparam ST_READ_PHYCR                = 6'd10;
    localparam ST_WRITE_PHY_REGCR           = 6'd11;
    localparam ST_WRITE_PHY_EXADDR          = 6'd12;
    localparam ST_WRITE_PHY_NPREGCR         = 6'd13;
    localparam ST_WRITE_PHY_NPADDR          = 6'd14;
    localparam ST_READ_PHY_NPADDR_DATA      = 6'd15;
    localparam ST_READ_PHY_BMSR             = 6'd16;
    localparam ST_READ_PHY_PHYSTS           = 6'd17; 
    localparam ST_READ_PHY_ANAR             = 6'd18;
    localparam ST_READ_CR3                  = 6'd19;
    localparam ST_WAIT_PHYLINK              = 6'd20;
    localparam ST_LINK_DETEC                = 6'd21;
    localparam ST_WAIT_DONE                 = 6'd22;
    localparam ST_LINK_DONE                 = 6'd23;
    
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
    reg             eth_phy_en              = 1'b0;
    reg  [16:0]		r_delay_ns_cnt	        = 17'd0;
	reg  [15:0]		r_delay_ms_cnt	        = 16'd0;

    reg  [5:0]      r_curr_state            = ST_IDLE;
    reg  [5:0]      r_next_state            = ST_IDLE;

    reg             r_phy_exec              = 1'b0;
    reg             r_phy_rh_wl             = 1'b0;
    reg  [31:0]     r_phy_wrdata            = 32'h0;
    reg             r_verify_suc            = 1'b0;
    reg             r_link_status           = 1'b0;

    reg             wait_poer_on_done       = 1'b0;
    reg             r_wait_reset_done       = 1'b0;
    reg             wait_power_on_flag      = 1'b0;
    reg  [6:0]      wait_power_on_ns_cnt    = 7'b0;
    reg             wait_power_on_us_valid  = 1'b0;
    reg  [9:0]      wait_power_on_us_cnt    = 10'b0;
    reg             wait_power_on_ms_valid  = 1'b0;
    reg  [7:0]      wait_power_on_ms_cnt    = 8'b0;

    wire            w_phy_ready;
    wire            w_exec_done;
    wire [15:0]     w_valid_rdata;

    reg  [15:0]     r_bmcr_rdata            = 16'h0;
    reg  [15:0]     r_bmsr_rdata            = 16'h0;
    reg  [15:0]     r_anar_rdata            = 16'h0;
    reg  [15:0]     r_physts_rdata          = 16'h0;
    reg  [15:0]     r_cr3_rdata             = 16'h0;
    reg  [15:0]     r_rcsr_rdata            = 16'h0;
    reg  [15:0]     r_phycr_rdata           = 16'h0;
    reg  [15:0]     r_ioctrl1_rdata         = 16'h0;
    reg  [15:0]     r_sor1_rdata            = 16'h0;
    reg             r_link_done             = 1'b0;
    //--------------------------------------------------------------------------------------------------
	// Flip-flop interface
    // temprory for debug
	//--------------------------------------------------------------------------------------------------
    always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0) begin
			r_delay_ns_cnt	<= 16'd0;
			r_delay_ms_cnt	<= 16'd0;
		end else if(r_delay_ms_cnt >= 16'd4999)
			r_delay_ms_cnt <= 16'd4999;
		else begin
			if(r_delay_ns_cnt >= NS_DLYCNT-1) begin
				r_delay_ns_cnt	<= 16'd0;
				r_delay_ms_cnt 	<= r_delay_ms_cnt + 1'b1;
			end else
				r_delay_ns_cnt 	<= r_delay_ns_cnt + 1'b1;
		end
	end

    //eth_phy_en
    always@(posedge i_clk_100m or negedge i_rst_n) begin
		if(i_rst_n == 0)
			eth_phy_en	<= 1'b0;
		else if(r_delay_ms_cnt >= 16'd4999)
			eth_phy_en	<= 1'b1;
		else
			eth_phy_en	<= 1'b0;
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
        case(r_curr_state)
            ST_IDLE: begin
                if(eth_phy_en)
                    r_next_state = ST_WAIT_POWER_ON;
                else
                    r_next_state = ST_IDLE;
            end
            ST_WAIT_POWER_ON: begin
                if(wait_poer_on_done)begin
                    r_next_state = ST_WRITE_PHY_BMCR;
                  end else begin
                    r_next_state = ST_WAIT_POWER_ON;
                end
            end
            ST_WRITE_PHY_BMCR: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_BMCR;
                end else begin
                    r_next_state = ST_WRITE_PHY_BMCR;
                end
            end
            ST_READ_PHY_BMCR: begin
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHY_RCSR;
                end else begin
                    r_next_state = ST_READ_PHY_BMCR;                
                end
            end
            ST_WRITE_PHY_RCSR: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_RCSR;
                end else begin
                    r_next_state = ST_WRITE_PHY_RCSR;
                end
            end
            ST_READ_PHY_RCSR: begin
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHYCR;
                end else begin
                    r_next_state = ST_READ_PHY_RCSR;
                end
            end
            ST_WRITE_PHYCR: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHYCR;
                end else begin
                    r_next_state = ST_WRITE_PHYCR;
                end
            end
            ST_READ_PHYCR: begin
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHY_REGCR;
                end else begin
                    r_next_state = ST_READ_PHYCR;
                end
            end
            ST_WRITE_PHY_REGCR: begin   //step1
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHY_EXADDR;
                end else begin
                    r_next_state = ST_WRITE_PHY_REGCR;                
                end
            end
            ST_WRITE_PHY_EXADDR: begin  //step2
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHY_NPREGCR;
                end else begin
                    r_next_state = ST_WRITE_PHY_EXADDR;                
                end
            end
            ST_WRITE_PHY_NPREGCR: begin //step3
                if(w_exec_done)begin
                    r_next_state = ST_WRITE_PHY_NPADDR;
                end else begin
                    r_next_state = ST_WRITE_PHY_NPREGCR;                
                end
            end
            ST_WRITE_PHY_NPADDR: begin  //step4
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_NPADDR_DATA;
                end else begin
                    r_next_state = ST_WRITE_PHY_NPADDR;                
                end
            end
            ST_READ_PHY_NPADDR_DATA: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_BMSR;
                end else begin
                    r_next_state = ST_READ_PHY_NPADDR_DATA;                
                end
            end
            ST_READ_PHY_BMSR: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_PHYSTS;
                end else begin
                    r_next_state = ST_READ_PHY_BMSR;                
                end
            end
            ST_READ_PHY_PHYSTS: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_PHY_ANAR;
                end else begin
                    r_next_state = ST_READ_PHY_PHYSTS;                
                end
            end
            ST_READ_PHY_ANAR: begin
                if(w_exec_done)begin
                    r_next_state = ST_READ_CR3;
                end else begin
                    r_next_state = ST_READ_PHY_ANAR;                
                end
            end
            ST_READ_CR3: begin
                if(w_exec_done)begin
                    r_next_state = ST_WAIT_PHYLINK;
                end else begin
                    r_next_state = ST_READ_CR3;                
                end
            end
            ST_WAIT_PHYLINK: begin
                r_next_state = ST_LINK_DETEC;
            end
            ST_LINK_DETEC: begin
                if(r_link_status)
                    r_next_state = ST_WAIT_DONE;
                else
                    r_next_state = ST_READ_PHY_BMSR;
            end
            ST_WAIT_DONE: begin
                if(r_link_done)
                    // r_next_state = ST_LINK_DONE;
                    r_next_state = ST_READ_PHY_BMSR;
                else
                    r_next_state = ST_WAIT_DONE;
            end
            ST_LINK_DONE: r_next_state = ST_LINK_DONE;
            default: r_next_state = ST_IDLE;
        endcase
    end

    // state machine output
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_phy_exec      <= 1'b0;
            r_phy_rh_wl     <= 1'b0;
            r_phy_wrdata    <= 32'h0;
            r_link_status      <= 1'b0;
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
                    r_phy_exec      <= 1'b0;
                    r_phy_rh_wl     <= 1'b0;
                    r_phy_wrdata    <= 32'h0;
                    r_link_status      <= 1'b0;
                end
                ST_WAIT_POWER_ON: begin
                    r_phy_exec      <= 1'b0;
                    r_phy_rh_wl     <= 1'b0;
                    r_phy_wrdata    <= 32'h0;
                end
                ST_SOFT_RESET: begin
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, BMCR_ADDR, TACODE_WRITE, PHY_SOFT_RESET};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_BMCR: begin    //cfg Basic Mode Control Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, BMCR_ADDR, TACODE_WRITE, PHY_CFG_BMCR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_BMCR: begin     //read cfg Basic Mode Control Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, BMCR_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_RCSR: begin    //cfg RMII and Status Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, RCSR_ADDR, TACODE_WRITE, PHY_CFG_RCSR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_RCSR: begin     //read cfg RMII and Status Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, RCSR_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHYCR: begin    //cfg RMII and Status Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, PHYCR_ADDR, TACODE_WRITE, PHY_CFG_PHYCR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHYCR: begin     //read cfg RMII and Status Register
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, PHYCR_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_REGCR: begin   //opration extend register  step1: Write the value 0x001F to register 0x000D
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, REG_REGCR, TACODE_WRITE, PHY_CFG_REGCR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_EXADDR: begin  // step2: Write ADDR value to Register 0x000E
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, REG_ADDAR, TACODE_WRITE, IOCTRL1_ADDR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_NPREGCR: begin // step3: Write the value 0x401F to register 0x000D
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, REG_REGCR, TACODE_WRITE, PHY_CFG_NPREGCR};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WRITE_PHY_NPADDR: begin // step4: Write the data to 0x000E
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b0;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_WRITE, PHY_ADDR, REG_ADDAR, TACODE_WRITE, PHY_CFG_IOCTRL1};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_NPADDR_DATA: begin // step4: Read the value of register 0x000E
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, REG_ADDAR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_BMSR: begin
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, BMSR_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_PHYSTS: begin
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, PHYSTS_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_PHY_ANAR: begin
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, ANAR_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_READ_CR3: begin
                    if(w_phy_ready) begin
                        r_phy_exec      <= 1'b1;
                        r_phy_rh_wl     <= 1'b1;
                        r_phy_wrdata    <= {ST_CODE, OPCODE_READ, PHY_ADDR, CR3_ADDR, TACODE_READ, 16'h0};
                    end else
                        r_phy_exec      <= 1'b0;
                end
                ST_WAIT_PHYLINK: begin
                    r_link_status  <= r_bmsr_rdata[2];
                end
                default: begin
                    r_phy_exec      <= 1'b0;
                    r_phy_rh_wl     <= 1'b0;
                    r_phy_wrdata    <= 16'h0;
                end
            endcase
        end
    end
	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    ///wait 205ms(T3+T4) after power on or pin reset_n
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_power_on_flag <= 1'b0;                     
        end else if(r_curr_state == ST_WAIT_POWER_ON || r_curr_state == ST_WAIT_DONE)begin
    	    wait_power_on_flag <= 1'b1;       
        end else begin
    	    wait_power_on_flag <= 1'b0;                         
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_power_on_ns_cnt <= 7'b0; 
        end else if(wait_power_on_flag && (wait_power_on_ns_cnt==7'd99))begin
    	    wait_power_on_ns_cnt <= 7'b0;
        end else if(wait_power_on_flag)begin
            wait_power_on_ns_cnt <= wait_power_on_ns_cnt + 7'b1;
        end else begin
    	    wait_power_on_ns_cnt <= 7'b0;
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_power_on_us_valid <= 1'b0;
        end else begin
    	    wait_power_on_us_valid <= wait_power_on_flag && (wait_power_on_ns_cnt==7'd99);
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_power_on_us_cnt <= 10'b0;
        end else if( wait_power_on_us_valid && (wait_power_on_us_cnt==10'd999))begin
            wait_power_on_us_cnt <= 10'b0;
        end else if( wait_power_on_us_valid)begin
            wait_power_on_us_cnt <= wait_power_on_us_cnt + 10'd1;
        end else if(~wait_power_on_flag)begin
            wait_power_on_us_cnt <= 10'b0;
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
            wait_power_on_ms_valid <= 1'b0;
        end else begin
            wait_power_on_ms_valid <= wait_power_on_us_valid && (wait_power_on_us_cnt==10'd999);
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_power_on_ms_cnt <= 8'b0;                         
        end else if( wait_power_on_ms_valid)begin
            wait_power_on_ms_cnt <= wait_power_on_ms_cnt + 8'd1;
        end else if(~wait_power_on_flag)begin
    	    wait_power_on_ms_cnt <= 8'b0;                           
        end
    end

    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    wait_poer_on_done <= 1'b0;                     
        end else begin
    	    wait_poer_on_done <= wait_power_on_ms_valid && (wait_power_on_ms_cnt==8'd204);
        end
    end

    //r_wait_reset_done
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_wait_reset_done <= 1'b0;                     
        end else begin
    	    r_wait_reset_done <= wait_power_on_ms_valid && (wait_power_on_ms_cnt==8'd24);
        end
    end

    //r_bmcr_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_bmcr_rdata    <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_BMCR && w_exec_done)
            r_bmcr_rdata <= w_valid_rdata;
        else
            r_bmcr_rdata <= r_bmcr_rdata;
    end

    //r_bmsr_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_bmsr_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_BMSR && w_exec_done) 
            r_bmsr_rdata <= w_valid_rdata;
        else
            r_bmsr_rdata <= r_bmsr_rdata;
    end

    //r_anar_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_anar_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_ANAR && w_exec_done) 
            r_anar_rdata <= w_valid_rdata;
        else
            r_anar_rdata <= r_anar_rdata;
    end

    //r_cr3_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_cr3_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_CR3 && w_exec_done) 
            r_cr3_rdata <= w_valid_rdata;
        else
            r_cr3_rdata <= r_cr3_rdata;
    end

    //r_physts_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_physts_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_PHYSTS && w_exec_done) 
            r_physts_rdata <= w_valid_rdata;
        else
            r_physts_rdata <= r_physts_rdata;
    end

    //r_rcsr_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_rcsr_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_RCSR && w_exec_done) 
            r_rcsr_rdata <= w_valid_rdata;
        else
            r_rcsr_rdata <= r_rcsr_rdata;
    end

    //r_phycr_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_phycr_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHYCR && w_exec_done) 
            r_phycr_rdata <= w_valid_rdata;
        else
            r_phycr_rdata <= r_phycr_rdata;
    end

    //r_ioctrl1_rdata
    always@(posedge i_clk_100m or negedge i_rst_n) begin
        if(!i_rst_n)
            r_ioctrl1_rdata <= 16'h0;
        else if(r_curr_state == ST_READ_PHY_NPADDR_DATA && w_exec_done) 
            r_ioctrl1_rdata <= w_valid_rdata;
        else
            r_ioctrl1_rdata <= r_ioctrl1_rdata;
    end

    //r_link_done
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_link_done <= 1'b0;                     
        end else begin
    	    r_link_done <= wait_power_on_ms_valid && (wait_power_on_ms_cnt==8'd3);
        end
    end
    //----------------------------------------------------------------------------------------------
	// inst domain
	//----------------------------------------------------------------------------------------------
	phy_mdio_drive u_phy_mdio_drive (
	    .i_clk_100m    		( i_clk_100m			),
	    .i_rst_n  			( i_rst_n				),

        //ctrl signal
        .i_phy_exec         ( r_phy_exec            ),
        .i_phy_rh_wl        ( r_phy_rh_wl           ),
        .i_phy_wrdata       ( r_phy_wrdata          ),
        .o_phy_ready        ( w_phy_ready           ),
        .o_exec_done        ( w_exec_done           ),
        .o_valid_rdata      ( w_valid_rdata         ),

	    //mdio signa
	    .o_phy_mdc    		( o_phy_mdc				),
	    .io_phy_mdio		( io_phy_mdio			),
	    .o_phy_reset_n    	( o_phy_reset_n			)
	);
endmodule