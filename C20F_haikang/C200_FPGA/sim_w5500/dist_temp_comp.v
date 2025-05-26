module dist_temp_comp
(
    input            i_temp_comp_flag,                //�²�����
    input [7:0]     i_temp_base_value,              //�¶Ȼ���ֵ
    input [15:0]    i_temp_comp_coe,               //�²�ϵ��
	input [7:0]      i_device_temp,                 //ʵ���¶�ֵ
	input             i_clk_50m,
	input             i_rst_n,
    output reg        o_add_sub_flag,               //������־λ  1:ʵ�ʾ���+�²�����   0��ʵ�ʾ���-�²�����
    output reg [15:0] o_dist_temp_value            //��������

);

   reg [7:0]  r_temp_offset;
   wire [31:0] r_mult1_result;
   
  always@(posedge i_clk_50m or negedge i_rst_n)
	if(!i_rst_n)
	   r_temp_offset <= 8'd0;
	else if(i_device_temp < 8'hEC)
	  begin
	    if(i_device_temp>=i_temp_base_value)
	      r_temp_offset <= i_device_temp-i_temp_base_value;
	    else
	      r_temp_offset <= i_temp_base_value-i_device_temp;
	  end
	 else if(i_device_temp >= 8'hEC)
        r_temp_offset <= i_temp_base_value-i_device_temp;
     else
        r_temp_offset <= 8'd0;		 


  always@(posedge i_clk_50m or negedge i_rst_n)
	if(!i_rst_n)
	  o_add_sub_flag <= 1'd0;
	else if(i_device_temp < 8'hEC)
	  begin
	    if(i_device_temp >= i_temp_base_value)
	      o_add_sub_flag <= 1'd1;
	    else
	      o_add_sub_flag <= 1'd0;
	  end
	else if(i_device_temp >= 8'hEC)
      o_add_sub_flag <= 1'd0;		
	   
  always@(posedge i_clk_50m or negedge i_rst_n)
	if(!i_rst_n)
	  o_dist_temp_value <= 16'd0;
	else if(i_temp_comp_flag==1'd1)
		o_dist_temp_value <= r_mult1_result>>4'd10;
	else
	  o_dist_temp_value <= 16'd0;
		
	  
		  
multiplier multiplier
	(
		.Clock				(i_clk_50m), 
		.ClkEn				(1'b1), 
		
		.Aclr				(1'b0), 
		.DataA				({8'd0,r_temp_offset}), 
		.DataB				(i_temp_comp_coe), 
		.Result				(r_mult1_result)
	);
		  
		  
endmodule		  
		  