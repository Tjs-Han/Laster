module div_rill 
(
	input 				clk		,
	input 				rst		, 
	input 				enable	,
	input 		[15:0]	a		, 
	input 		[15:0]	b		, 
	output reg 	[15:0]	yshang	,
	output reg 	[15:0]	yyushu	, 
	output reg			done
);

reg[15:0] tempa = 16'd0;
reg[15:0] tempb = 16'd0;
reg[31:0] temp_a = 32'd0;
reg[31:0] temp_b = 32'd0; 
reg [5:0] status;
parameter s_idle = 6'b000000;
parameter s_init = 6'b000001;
parameter s_calc1 = 6'b000010;
parameter s_calc2 = 6'b000100;
parameter s_done = 6'b001000;
 
reg [15:0] i;
 
always @(posedge clk)
begin
    if(!rst)
        begin
            i <= 16'h0;
            tempa <= 16'h0;
            tempb <= 16'h0;
            yshang <= 16'h0;
            yyushu <= 16'h0;
            done <= 1'b0;
            status <= s_idle;
        end
    else
        begin
            case (status)
            s_idle:
                begin
                    if(enable)
                        begin
                            tempa <= a;
                            tempb <= b;
                            status <= s_init;
                            i <= 16'h0;
                            yshang <= 16'h0;
                            yyushu <= 16'h0;							
                        end
                    else
                        begin
                            status <= s_idle;
							done   <= 1'd0;
                        end
                end
                
            s_init:
                begin
                    temp_a <= {16'h00000000,tempa};
                    temp_b <= {tempb,16'h00000000};
                    status <= s_calc1;
                end
                
            s_calc1:
                begin
                    if(i < 16)
                        begin
                            temp_a <= {temp_a[30:0],1'b0};
                            status <= s_calc2;
                        end
                    else
                        begin
                            status <= s_done;
                        end
                    
                end
                
            s_calc2:
                begin
                    if(temp_a[31:16] >= tempb)
                        begin
                            temp_a <= temp_a - temp_b + 1'b1;
                        end
                    else
                        begin
                            temp_a <= temp_a;
                        end
                    i <= i + 1'b1;    
                    status <= s_calc1;
                end
            
            s_done:
                begin
                    yshang <= temp_a[15:0];
                    yyushu <= temp_a[31:16];
                    done <= 1'b1;
                    
                    status <= s_idle;
                end
            
            default:
                begin
                    status <= s_idle;
                end
            endcase
        end
   
end
 
 
endmodule
