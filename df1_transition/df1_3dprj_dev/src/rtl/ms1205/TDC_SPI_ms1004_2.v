// *************************************************************************************************
// Vendor 			: Wuhan Free optics Electronic Technology Co., Ltd
// Author 			: Jian Yu Zhao
// Filename 		: MS1005_control
// Date Created 	: 2023/06/28
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	: MS1005_control
// -------------------------------------------------------------------------------------------------
// Revision History : V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module TDC_SPI_ms1004_2
(
		clk,
		i_rst_n,
		SPI_SO,
		CMD_TDCwr,
		CMD_TDCrd,
		CMD_TDC1byte,
		TDC_CMD,
		TDC_Num,
		TDC_WRdata,

		SPI_SCK,
		SPI_SSN,
		SPI_SI,
		TDC_CMDack,
		TDC_RDdata,
		TDC_CMDdone

);
	input				clk;
	input				i_rst_n;
	input				SPI_SO;
	input				CMD_TDCwr;
	input				CMD_TDCrd;
	input				CMD_TDC1byte;
	input [7:0] 		TDC_CMD;
	input [5:0]			TDC_Num;
	input [31:0]		TDC_WRdata;
	
	output				SPI_SCK;
	output				SPI_SSN;
	output				SPI_SI;
	output				TDC_CMDack;
	output[31:0]		TDC_RDdata;
	output				TDC_CMDdone;
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------

	reg 				SPI_SCK			=1'b0;
	reg 				SPI_SSN			=1'b1;
	reg 				SPI_SI			=1'b0;
	reg 				TDC_CMDack		=1'b0;
	reg [31:0] 			TDC_RDdata		=32'd0;
	reg 				TDC_CMDdone		=1'b0;

	reg [5:0] 			TDCspi_state	=6'd0;
	reg [7:0] 			SPI_OPcode		=8'd0;
	reg [31:0] 			TDC_Tdata		=32'd0;
	reg [15:0] 			SCK_i			=16'd0;
	reg [2:0] 			SPI_cnt			=3'd0;

	parameter 			TDCspi_Idle 	= 'b00_0000,
						TDCspi_OPcode 	= 'b00_0010,
						TDCspi_WR 		= 'b00_0100,
						TDCspi_RD 		= 'b00_1000,
						TDCspi_End 		= 'b01_0000,
						TDCspi_Over		= 'b10_0000;
			 

always@(posedge clk or negedge i_rst_n)
	if(i_rst_n == 1'b0)begin
		SPI_SSN 		<= 1'b1;
		SPI_SCK 		<= 1'b0;
		SPI_SI 			<= 1'b0;
		SCK_i 			<= 16'd0;
		TDC_CMDdone 	<= 1'b0;
		TDC_CMDack 		<= 1'b0;
		SPI_OPcode 		<= 8'd0;
		TDC_Tdata  		<= 32'd0;
		TDC_RDdata 		<= 32'd0;
		SPI_cnt    		<= 3'd0;
		TDCspi_state 	<= TDCspi_Idle;
		end
	else begin
		case(TDCspi_state)
			TDCspi_Idle : begin
				SPI_SSN <= 1'b1;
				SPI_SCK <= 1'b0;
				SPI_SI <= 1'b0;
				SCK_i <= 16'd0;
				TDCspi_state <= TDCspi_Idle;
				if(CMD_TDCwr==1'b1) begin
					SPI_OPcode <= TDC_CMD;
					TDC_Tdata <= TDC_WRdata;
					TDC_CMDack <= 1'b1;
					TDC_CMDdone <= 1'b0;
					TDCspi_state <= TDCspi_WR;
					end
				else if(CMD_TDCrd==1'b1) begin
					SPI_OPcode <= TDC_CMD;
					//TDC_Tdata <= TDC_Data[31:0];
					TDC_CMDack <= 1'b1;
					TDC_CMDdone <= 1'b0;
					TDCspi_state <= TDCspi_RD;
					end
				else if(CMD_TDC1byte==1'b1) begin
					SPI_OPcode <= TDC_CMD;
					//TDC_Tdata <= TDC_Data[31:0];
					TDC_CMDack <= 1'b1;
					TDC_CMDdone <= 1'b0;
					TDCspi_state <= TDCspi_OPcode;
					end
				else begin
					SPI_OPcode <= 8'd0;
					TDC_Tdata <= 32'd0;
					TDC_CMDack <= 1'b0;
					TDC_CMDdone <= 1'b0;
					end
				end
			TDCspi_OPcode : begin
				TDC_CMDack <= 1'b0;
				SCK_i <= SCK_i+1'b1;
				case(SCK_i)
					16'd0 : begin
						SPI_SSN <= 1'b1;
						SPI_SCK <= 1'b0;
						SPI_SI <= 1'b0;
						end
					16'd1 : SPI_SSN <= 1'b0;
					16'd3 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[7];
						end
					16'd4 : SPI_SCK <= 1'b0; //----OPcode 7
					16'd5 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[6];
						end
					16'd6 : SPI_SCK <= 1'b0; //----OPcode 6
					16'd7 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[5];
						end
					16'd8 : SPI_SCK <= 1'b0; //----OPcode 5
					16'd9 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[4];
						end
					16'd10 : SPI_SCK <= 1'b0; //----OPcode 4
					16'd11 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[3];
						end
					16'd12 : SPI_SCK <= 1'b0; //----OPcode 3
					16'd13 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[2];
						end
					16'd14 : SPI_SCK <= 1'b0; //----OPcode 2
					16'd15 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[1];
						end
					16'd16 : SPI_SCK <= 1'b0; //----OPcode 1
					16'd17 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[0];
						end
					16'd18 : SPI_SCK <= 1'b0; //----OPcode 0
					16'd19 : SPI_SI <= 1'b0;
					16'd21 : SPI_SSN <= 1'b1;
					16'd22 : begin
						SCK_i <= 16'd0;
						SPI_SCK <= 1'b0;
						TDCspi_state <= TDCspi_End;
						end
					default : ;
					endcase
				end
			TDCspi_WR : begin
				TDC_CMDack <= 1'b0;
				SCK_i <= SCK_i+1'b1;
				case(SCK_i)
					16'd0 : begin
						SPI_SSN <= 1'b1;
						SPI_SCK <= 1'b0;
						SPI_SI <= 1'b0;
						end
					16'd1 : SPI_SSN <= 1'b0;
					16'd5 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[7];
						end
					16'd6 : SPI_SCK <= 1'b0; //----OPcode 7
					16'd7 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[6];
						end
					16'd8 : SPI_SCK <= 1'b0; //----OPcode 6
					16'd9 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[5];
						end
					16'd10 : SPI_SCK <= 1'b0; //----OPcode 5
					16'd11 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[4];
						end
					16'd12 : SPI_SCK <= 1'b0; //----OPcode 4
					16'd13 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[3];
						end
					16'd14 : SPI_SCK <= 1'b0; //----OPcode 3
					16'd15 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[2];
						end
					16'd16 : SPI_SCK <= 1'b0; //----OPcode 2
					16'd17 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[1];
						end
					16'd18 : SPI_SCK <= 1'b0; //----OPcode 1
					16'd19 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[0];
						end
					16'd20 : SPI_SCK <= 1'b0; //----OPcode 0
					16'd21 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[31];
						end
					16'd22 : SPI_SCK <= 1'b0; //----Tdata 31
					16'd23 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[30];
						end
					16'd24 : SPI_SCK <= 1'b0; //----Tdata 30
					16'd25 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[29];
						end
					16'd26 : SPI_SCK <= 1'b0; //----Tdata 29
					16'd27 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[28];
						end
					16'd28 : SPI_SCK <= 1'b0; //----Tdata 28
					16'd29 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[27];
						end
					16'd30 : SPI_SCK <= 1'b0; //----Tdata 27
					16'd31 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[26];
						end
					16'd32 : SPI_SCK <= 1'b0; //----Tdata 26
					16'd33 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[25];
						end
					16'd34 : SPI_SCK <= 1'b0; //----Tdata 25
					16'd35 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[24];
						end
					16'd36 : SPI_SCK <= 1'b0; //----Tdata 24
					16'd37 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[23];
						end
					16'd38 : SPI_SCK <= 1'b0; //----Tdata 23
					16'd39 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[22];
						end
					16'd40 : SPI_SCK <= 1'b0; //----Tdata 22
					16'd41 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[21];
						end
					16'd42 : SPI_SCK <= 1'b0; //----Tdata 21
					16'd43 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[20];
						end
					16'd44 : SPI_SCK <= 1'b0; //----Tdata 20
					16'd45 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[19];
						end
					16'd46 : SPI_SCK <= 1'b0; //----Tdata 19
					16'd47 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[18];
						end
					16'd48 : SPI_SCK <= 1'b0; //----Tdata 18
					16'd49 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[17];
						end
					16'd50 : SPI_SCK <= 1'b0; //----Tdata 17
					16'd51 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[16];
						end
					16'd52 : SPI_SCK <= 1'b0; //----Tdata 16
					16'd53 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[15];
						end
					16'd54 : SPI_SCK <= 1'b0; //----Tdata 15
					16'd55 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[14];
						end
					16'd56 : SPI_SCK <= 1'b0; //----Tdata 14
					16'd57 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[13];
						end
					16'd58 : SPI_SCK <= 1'b0; //----Tdata 13
					16'd59 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[12];
						end
					16'd60 : SPI_SCK <= 1'b0; //----Tdata 12
					16'd61 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[11];
						end
					16'd62 : SPI_SCK <= 1'b0; //----Tdata 11
					16'd63 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[10];
						end
					16'd64 : SPI_SCK <= 1'b0; //----Tdata 10
					16'd65 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[9];
						end
					16'd66 : SPI_SCK <= 1'b0; //----Tdata 9
					16'd67 :begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[8];
						end
					16'd68 : SPI_SCK <= 1'b0; //----Tdata 8
					16'd69 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[7];
						end
					16'd70 : SPI_SCK <= 1'b0; //----Tdata 7
					16'd71 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[6];
						end
					16'd72 : SPI_SCK <= 1'b0; //----Tdata 6
					16'd73 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[5];
						end
					16'd74 : SPI_SCK <= 1'b0; //----Tdata 5
					16'd75 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[4];
						end
					16'd76 : SPI_SCK <= 1'b0; //----Tdata 4
					16'd77 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[3];
						end
					16'd78 : SPI_SCK <= 1'b0; //----Tdata 3
					16'd79 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[2];
						end
					16'd80 : SPI_SCK <= 1'b0; //----Tdata 2
					16'd81 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[1];
						end
					16'd82 : SPI_SCK <= 1'b0; //----Tdata 1
					16'd83 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= TDC_Tdata[0];
						end
					16'd84 : SPI_SCK <= 1'b0; //----Tdata 0
					
					16'd85 : SPI_SI <= 1'b0;
					16'd87 : SPI_SSN <= 1'b1;
					16'd88 : begin
						SCK_i <= 16'd0;
						SPI_SCK <= 1'b0;
						TDCspi_state <= TDCspi_End;
						end
					default : ;
					endcase
				end
			TDCspi_RD : begin
				TDC_CMDack <= 1'b0;
				SCK_i <= SCK_i+1'b1;
				case(SCK_i)
					16'd0 : begin
						SPI_SSN <= 1'b1;
						SPI_SCK <= 1'b0;
						SPI_SI <= 1'b0;
						end
					16'd1 : SPI_SSN <= 1'b0;
					16'd3 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[7];
						end
					16'd4 : SPI_SCK <= 1'b0; //----OPcode 7
					16'd5 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[6];
						end
					16'd6 : SPI_SCK <= 1'b0; //----OPcode 6
					16'd7 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[5];
						end
					16'd8 : SPI_SCK <= 1'b0; //----OPcode 5
					16'd9 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[4];
						end
					16'd10 : SPI_SCK <= 1'b0; //----OPcode 4
					16'd11 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[3];
						end
					16'd12 : SPI_SCK <= 1'b0; //----OPcode 3
					16'd13 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[2];
						end
					16'd14 : SPI_SCK <= 1'b0; //----OPcode 2
					16'd15 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[1];
						end
					16'd16 : SPI_SCK <= 1'b0; //----OPcode 1
					16'd17 : begin
						SPI_SCK <= 1'b1;
						SPI_SI <= SPI_OPcode[0];
						end
					16'd18 : SPI_SCK <= 1'b0; //----OPcode 0
					16'd19 : begin
						SPI_SI <= 1'b0;
						SPI_SCK <= 1'b1;
						end
					16'd20 : begin
						SPI_SCK <= 1'b0;

						end
					16'd21 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[31] <= SPI_SO; //----Rdata 31
						end
					16'd22 : begin
						SPI_SCK <= 1'b0;

						end
					16'd23 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[30] <= SPI_SO; //----Rdata 30
						end
					16'd24 : begin
						SPI_SCK <= 1'b0;

						end
					16'd25 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[29] <= SPI_SO; //----Rdata 29
						end
					16'd26 : begin
						SPI_SCK <= 1'b0;

						end
					16'd27 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[28] <= SPI_SO; //----Rdata 28
						end
					16'd28 : begin
						SPI_SCK <= 1'b0;

						end
					16'd29 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[27] <= SPI_SO; //----Rdata 27
						end
					16'd30 : begin
						SPI_SCK <= 1'b0;

						end
					16'd31 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[26] <= SPI_SO; //----Rdata 26
						end
					16'd32 : begin
						SPI_SCK <= 1'b0;

						end
					16'd33 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[25] <= SPI_SO; //----Rdata 25
						end
					16'd34 : begin
						SPI_SCK <= 1'b0;

						end
					16'd35 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[24] <= SPI_SO; //----Rdata 24
						end
					16'd36 : begin
						SPI_SCK <= 1'b0;

						end
					16'd37 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[23] <= SPI_SO; //----Rdata 23
						end
					16'd38 : begin
						SPI_SCK <= 1'b0;

						end
					16'd39 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[22] <= SPI_SO; //----Rdata 22
						end
					16'd40 : begin
						SPI_SCK <= 1'b0;

						end
					16'd41 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[21] <= SPI_SO; //----Rdata 21
						end
					16'd42 : begin
						SPI_SCK <= 1'b0;

						end
					16'd43 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[20] <= SPI_SO; //----Rdata 20
						end
					16'd44 : begin
						SPI_SCK <= 1'b0;

						end
					16'd45 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[19] <= SPI_SO; //----Rdata 19
						end
					16'd46 : begin
						SPI_SCK <= 1'b0;

						end
					16'd47 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[18] <= SPI_SO; //----Rdata 18
						end
					16'd48 : begin
						SPI_SCK <= 1'b0;

						end
					16'd49 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[17] <= SPI_SO; //----Rdata 17
						end
					16'd50 : begin
						SPI_SCK <= 1'b0;

						end
					16'd51 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[16] <= SPI_SO; //----Rdata 16
						end
					16'd52 : begin
						SPI_SCK <= 1'b0;

						end
					16'd53 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[15] <= SPI_SO; //----Rdata 15
						end
					16'd54 : begin
						SPI_SCK <= 1'b0;

						end
					16'd55 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[14] <= SPI_SO; //----Rdata 14
						end
					16'd56 : begin
						SPI_SCK <= 1'b0;

						end
					16'd57 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[13] <= SPI_SO; //----Rdata 13
						end
					16'd58 : begin
						SPI_SCK <= 1'b0;

						end
					16'd59 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[12] <= SPI_SO; //----Rdata 12
						end
					16'd60 : begin
						SPI_SCK <= 1'b0;

						end
					16'd61 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[11] <= SPI_SO; //----Rdata 11
						end
					16'd62 : begin
						SPI_SCK <= 1'b0;

						end
					16'd63 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[10] <= SPI_SO; //----Rdata 10
						end
					16'd64 : begin
						SPI_SCK <= 1'b0;

						end
					16'd65 : begin
						SPI_SCK <= 1'b1;
						TDC_RDdata[9] <= SPI_SO; //----Rdata 9
						end
					16'd66 : begin
						SPI_SCK <= 1'b0;
						end
					16'd67 : begin
						SPI_SCK <= 1'b0;
						TDC_RDdata[8] <= SPI_SO; //----Rdata 8
						end						
												

					16'd68 : SPI_SSN <= 1'b1;
					16'd69 : begin
						SCK_i <= 16'd0;
						SPI_SI <= 1'b0;
						SPI_SCK <= 1'b0;
						TDCspi_state <= TDCspi_End;
						end
					default : ;
					endcase
				end
			TDCspi_End : begin
					TDC_CMDdone <= 1'b1;
					SPI_SSN <= 1'b1;
					SPI_SI <= 1'b0;
					SPI_SCK <= 1'b0;
					SCK_i <= 16'd0;
					TDCspi_state <= TDCspi_Over;
					end
			TDCspi_Over : begin
				TDC_CMDdone <= 1'b0;
				if(SPI_cnt>=3'd5) begin
					SPI_cnt <= 3'd0;
					//TDC_CMDdone <= 1'b0;
					TDCspi_state <= TDCspi_Idle;
					end
				else begin
					SPI_cnt <= SPI_cnt+1'b1;
					TDCspi_state <= TDCspi_Over;
					end
				end
			default : TDCspi_state <= TDCspi_Idle;
			endcase
		end

endmodule 