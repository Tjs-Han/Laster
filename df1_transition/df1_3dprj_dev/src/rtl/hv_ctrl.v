// -------------------------------------------------------------------------------------------------
// File description  :hv_ctrl
// -------------------------------------------------------------------------------------------------
// Revision History  :V1.0
// *************************************************************************************************
`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------
module	hv_ctrl	
#(
	parameter PWM_HIGHCNT   = 16'd819
)
(
	input				i_clk_50m,
	input				i_rst_n,

    output              o_hv_en,
	output 				o_da_pwm

	);
	//--------------------------------------------------------------------------------------------------
	// reg and wire define
	//--------------------------------------------------------------------------------------------------
	reg [15:0] 			r_pwm_cnt       = 16'd0;
	reg					r_da_pwm        = 1'b1;
    reg                 r_hv_en         = 1'b0;
    reg [31:0]          r_hven_delaycnt = 32'd0;
    //--------------------------------------------------------------------------------------------------
	// sequence define
	//--------------------------------------------------------------------------------------------------
    always@(posedge i_clk_50m or negedge i_rst_n) begin
        if(!i_rst_n) begin
            r_hv_en 		<= 1'b0;
			r_hven_delaycnt	<= 32'd0;
        end else if(r_hven_delaycnt >= 32'd100_000_000)begin
            r_hv_en 		<= 1'b1;
			r_hven_delaycnt	<= r_hven_delaycnt;
		end else begin
			r_hv_en 		<= 1'b0;
			r_hven_delaycnt	<= r_hven_delaycnt + 32'd1;
		end
    end
	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_pwm_cnt <= 16'd0;
		else if(r_pwm_cnt >= 16'd1024)
			r_pwm_cnt <= 16'd0;
		else
			r_pwm_cnt <= r_pwm_cnt + 1'd1;
	end

	always@(posedge i_clk_50m or negedge i_rst_n) begin
		if(!i_rst_n)
			r_da_pwm <= 1'd1;
		else if(r_pwm_cnt <= PWM_HIGHCNT)
			r_da_pwm <= 1'd1;
		else
			r_da_pwm <= 1'd0;
	end
    //----------------------------------------------------------------------------------------------
	// output assign domain
	//----------------------------------------------------------------------------------------------
    assign o_hv_en  = r_hv_en;
	assign o_da_pwm = r_da_pwm;			
endmodule		
			
			
			
			
			
			
			
	