`timescale 1ns / 1ps 
module tb (
    
);
reg clk_50M;
reg rst_n;
reg zero_signal ;
reg opto_switch ;  

reg [31:0]cnt_opto;
reg [31:0]cnt_zero;

wire [31:0]o_ram_rdata;
reg [5:0] i_ram_raddr;
reg i_ram_ren;
reg [6:0]cnt;

initial begin
    clk_50M=0;
    rst_n=0;
    #100 rst_n=1'b1;
end
always #10 clk_50M=~clk_50M;
always @(posedge clk_50M) begin
    if (rst_n==0) begin
        zero_signal <= 0;
        opto_switch <= 0;
        cnt_zero <='b0;
        cnt_opto <='b0;
    end else begin
        if(cnt_zero==100000) begin
            zero_signal <=1'b1;
            cnt_zero <= 0;
        end else begin
            cnt_zero <= cnt_zero+1'b1;
            zero_signal <=1'b0;
        end

        if(cnt_opto==512) begin
            opto_switch <=1'b1;
            cnt_opto <= 0;
        end else begin
            cnt_opto <= cnt_opto+1'b1;
            opto_switch <=1'b0;
        end        
    end
end
always @(posedge clk_50M) begin
    if (rst_n==0) begin
        i_ram_raddr <= 6'b0;
        i_ram_ren <= 1'b0;
        cnt <= 7'h0;
    end else begin
        i_ram_raddr <= i_ram_raddr+i_ram_ren;
        i_ram_ren <= cnt==127 ? 1'b1:1'b0;
        cnt<=cnt+1'b1;
    end
end
statistics_cycle statistics_cycle( //module statistics_cycle (
    .i_clk_50m(clk_50M),// input			i_clk_50m    		,
    .i_rst_n  (rst_n),//input			i_rst_n      		,

/*Statistics signal*/
    .i_opto_switch(opto_switch),//input			i_opto_switch		,//码盘信号输入
    .i_zero_sign  (zero_signal  ),//input           i_zero_sign         ,//零点信号
    .i_motor_state (1'b1),//input           i_motor_state       ,//调速完�
/*ram read*/
    .i_ram_raddr (i_ram_raddr),//input   [5:0]   i_ram_raddr         ,// ram read data addr
    .i_ram_ren   (i_ram_ren  ),//input           i_ram_ren           ,// ram read enable
    .o_ram_rdata (o_ram_rdata)//output  [31:0]  o_ram_rdata         // ram read data                                                           
);

GSR GSR_INST(.GSR(1'b1));
PUR PUR_INST(.PUR(1'b1));    

endmodule