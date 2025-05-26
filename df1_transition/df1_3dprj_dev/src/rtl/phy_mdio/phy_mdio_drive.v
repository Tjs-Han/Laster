// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jun Gu
// Filename 		: phy_mdio_drive
// Date Created     : 2024/09/25 
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:phy_mdio_drive
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
  Preamble:                 A 32-bit preamble, sent by the MAC, consists of 32 logic "1" bits to synchronize with the PHY chip.
  ST (Start of Frame):      A 2-bit frame start signal, represented by "01".
  OP (Operation Code):      A 2-bit operation code, where "10" indicates a read and "01" indicates a write.
  PHYAD (PHY Address):      A 5-bit PHY address, used to specify which PHY chip to communicate with, allowing a MAC to connect to multiple PHY chips.
  REGAD (Register Address): A 5-bit register address, capable of representing a total of 32 registers.
  TA (Turnaround):          A 2-bit turnaround signal; in a read command, the MDIO changes from being driven by the MAC to being driven by the PHY. 
                            In the first TA bit, the MDIO pin is in a high-impedance state; in the second TA bit, the PHY pulls the MDIO pin low to prepare to send data. 
                            In a write command, the MDIO direction does not change, with the MAC fixed to output "2'b10," followed by writing data.
  DATA:                     A 16-bit data field; in a read command, the PHY chip writes the data from the corresponding REGAD of the specified PHYAD into DATA. 
                            In a write command, the MAC writes the value to be stored in the corresponding REGAD of the specified PHYAD into DATA.
  IDLE:                     Idle state, where the MDIO is in a high-impedance state, generally pulled high by a pull-up resistor.
*/
// -------------------------------------------------------------------------------------------------
// Revision History :V1.0
`timescale 1ns/1ps
module phy_mdio_drive(
    input                   i_clk_100m,    //100Mhz
    input                   i_rst_n,

    //ctrl signal
    input                   i_phy_exec,
    input                   i_phy_rh_wl,
    input  [31:0]           i_phy_wrdata,
    output                  o_phy_ready,
    output                  o_exec_done,
    output [15:0]           o_valid_rdata,
    //mdio signal
    output                  o_phy_mdc, //The maximum clock rate is 25 MHz.There is no minimum clock rate.  6.25Mhz   100M/16 = 6.25M
    inout                   io_phy_mdio, // 16 x 64 = 1024  
    output                  o_phy_reset_n  //Asserting this pin low for atleast 1 µs will force a reset process to occur.

);
	//--------------------------------------------------------------------------------------------------
	// localparam and parameter define
	//--------------------------------------------------------------------------------------------------	
    parameter   ST_IDLE                 = 6'b000000;
    parameter   ST_PHY_EXEC             = 6'b000001;
    parameter   ST_REG_READ             = 6'b000010;
    parameter   ST_REG_WRITE            = 6'b000100;
	//--------------------------------------------------------------------------------------------------
	// reg and wire declarations
	//--------------------------------------------------------------------------------------------------
    wire                phy_mdio_in;
    reg                 phy_mdc;
    reg                 phy_mdo;
    reg                 phy_mdio_direc;
    reg                 phy_reset_n;

    reg  [5:0]          r_curr_state    = ST_IDLE;
    reg  [5:0]          r_next_state    = ST_IDLE;

    reg                 r_phy_ready     =1'b1;
    reg  [31:0]         r_phy_wrdata;
    reg                 r_mdio_com_flag;
    reg  [9:0]          phy_smi_cnt;
    reg  [63:0]         r_mdio_wdata;
    reg                 r_phy_ack;
    reg  [15:0]         r_mdio_rdata;
    reg                 r_mdio_comdone;
    reg  [5:0]          r_delay_cnt;
    reg                 r_exec_done;
    reg                 phy_smi_read_flag;
    reg  [15:0]         r_valid_rdata;

	//--------------------------------------------------------------------------------------------------
	// Flip-flop interface
	//--------------------------------------------------------------------------------------------------
    /*  
        Step 1: reset is high after power on or pin reset_n
        Step 2: start mdio access  phy at 205ms(T3+T4) after power on or pin reset_n;  
        Step 3: link result at 1.6s(T5) after power on;  
        MDC: 6.25M
    */
    //--------------------------------------------------------------------------------------------------
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_reset_n <= 1'b1;                     
        end else begin
    	    phy_reset_n <= 1'b1;                       
        end
    end

    always @ (posedge i_clk_100m)begin
        if(!i_rst_n) begin
            r_curr_state <= 6'h0;            
        end else begin
            r_curr_state <= r_next_state;       
        end
    end

    always @(*) begin
        if(!i_rst_n) begin
          r_next_state = ST_IDLE;
        end else begin
            case (r_curr_state)
                ST_IDLE: begin
                    if(i_phy_exec)
                        r_next_state = ST_PHY_EXEC;
                    else
                        r_next_state = ST_IDLE;
                end
                ST_PHY_EXEC: begin
                    if(i_phy_rh_wl)
                        r_next_state = ST_REG_READ;
                    else
                        r_next_state = ST_REG_WRITE;
                end
                ST_REG_READ: begin
                    if(r_exec_done)
                        r_next_state = ST_IDLE;
                    else
                        r_next_state = ST_REG_READ;
                end
                ST_REG_WRITE: begin
                    if(r_exec_done)
                        r_next_state = ST_IDLE;
                    else
                        r_next_state = ST_REG_WRITE;
                end
                default: r_next_state = ST_IDLE;
            endcase
        end
    end
    //--------------------------------------------------------------------------------------------------
	// read or write PHY reg cfg ctrl
	//--------------------------------------------------------------------------------------------------
    //r_phy_ready
    always@(posedge i_clk_100m)begin
        if(!i_rst_n)
    	    r_phy_ready <= 1'b1; 
        else if(i_phy_exec)
    	    r_phy_ready <= 1'b0;                              
        else if(r_exec_done)
    	    r_phy_ready <= 1'b1;                    
    end

    //r_mdio_com_flag
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_mdio_com_flag <= 1'b0; 
        end else if(r_curr_state == ST_PHY_EXEC)begin
    	    r_mdio_com_flag <= 1'b1;                              
        end else if(&phy_smi_cnt)begin
    	    r_mdio_com_flag <= 1'b0;                    
        end
    end
    
    //phy_smi_cnt
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_smi_cnt <= 10'b0; 
        end else if(r_mdio_com_flag)begin
            phy_smi_cnt <= phy_smi_cnt + 10'd1;
        end else begin
    	    phy_smi_cnt <= 10'b0;                   
        end
    end

    //phy_mdc
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_mdc <= 1'b0; 
        end else if(r_mdio_com_flag && &phy_smi_cnt[2:0])begin
    	    phy_mdc <= ~phy_mdc;                
        end
    end

    //r_mdio_wdata
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
            r_mdio_wdata <= 64'b0;   
        end else if(i_phy_exec)
            r_mdio_wdata <= {32'hFFFFFFFF, i_phy_wrdata};
        else if(r_mdio_com_flag && &phy_smi_cnt[3:0])begin
            r_mdio_wdata <= r_mdio_wdata << 1 ;                               
        end
    end

    //phy_mdo
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_mdo <= 1'b0; 
        end else begin
    	    phy_mdo <= r_mdio_wdata[63];
        end
    end

    //r_phy_ack
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_phy_ack <= 1'b0; 
        end else if(r_mdio_com_flag && &phy_smi_cnt[3:0] && (phy_smi_cnt[9:4]==6'd46))begin
    	    r_phy_ack <= ~phy_mdio_in;
        end else if(r_exec_done)begin
    	    r_phy_ack <= 1'b0;     
        end
    end

    //r_mdio_rdata
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_mdio_rdata <= 16'b0; 
        end else if(r_mdio_com_flag && (phy_smi_cnt == 10'd2))begin
    	    r_mdio_rdata <= 16'b0;      
        end else if(r_mdio_com_flag && (phy_smi_cnt[9:4]>=6'd47) && (phy_smi_cnt[9:4]<=6'd63))begin  
            if((&phy_smi_cnt[2:0]) && ~phy_smi_cnt[3])
    	        r_mdio_rdata    <= {r_mdio_rdata, phy_mdio_in};
            else
                r_mdio_rdata    <= r_mdio_rdata;
        end
    end

    //r_mdio_comdone
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_mdio_comdone <= 1'b0; 
        end else begin
    	    r_mdio_comdone <= &phy_smi_cnt; 
        end
    end

    //r_delay_cnt
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_delay_cnt <= 6'd0;
        end else if(r_mdio_comdone)begin
    	    r_delay_cnt <= 6'd1;
        end else if(|r_delay_cnt)begin
    	    r_delay_cnt <= r_delay_cnt + 1'b1;
        end
    end

    //r_exec_done
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_exec_done <= 1'b0;
        end else begin
    	    r_exec_done <= &r_delay_cnt;
        end
    end
    
    //phy_smi_read_flag
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_smi_read_flag <= 1'b0;
        end else if(r_mdio_com_flag && (phy_smi_cnt == 10'd2))begin
    	    phy_smi_read_flag <= ~r_mdio_wdata[28];
        end
    end

    //phy_mdio_direc
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    phy_mdio_direc <= 1'b0;
        end else if(phy_smi_read_flag && r_mdio_com_flag && (phy_smi_cnt[3:0] == 4'hc) && (phy_smi_cnt[9:4]==6'd45))begin
    	    phy_mdio_direc <= 1'b0;
        end else if(r_mdio_com_flag && (phy_smi_cnt == 10'd1))begin
    	    phy_mdio_direc <= 1'b1;
        end else if(r_mdio_comdone)begin
    	    phy_mdio_direc <= 1'b0;
        end
    end

    //r_valid_rdata
    always@(posedge i_clk_100m)begin
        if(!i_rst_n) begin
    	    r_valid_rdata <= 16'b0; 
        end else if(r_mdio_comdone)begin
    	    r_valid_rdata <= r_mdio_rdata; 
        end
    end

    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
	assign io_phy_mdio	    = phy_mdio_direc ? phy_mdo : 1'bz;
	assign phy_mdio_in      = io_phy_mdio;
    assign o_phy_mdc        = phy_mdc;
    assign o_phy_reset_n    = phy_reset_n;
    assign o_phy_ready      = r_phy_ready;
    assign o_exec_done      = r_exec_done;
    assign o_valid_rdata    = r_valid_rdata;
endmodule