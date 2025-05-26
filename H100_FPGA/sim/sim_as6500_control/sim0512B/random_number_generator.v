module random_number_generator(
    input 			clk,
    input 			reset_n,
	
	input	[5:0]	random_seed,
	input			generator_en,
	
    output	[5:0] 	random_number
);
	 
	// 伪随机数发生器
	reg	[5:0]	r_rand_num = 6'd0;
	 
	always @(posedge clk) begin
		if (!reset_n) begin
			r_rand_num 		<= random_seed; 
		end 
		else if(generator_en)begin
			r_rand_num[0]	<= r_rand_num[5];
			r_rand_num[1]	<= r_rand_num[0];
			r_rand_num[2]	<= r_rand_num[1] ^ r_rand_num[5];
			r_rand_num[3]	<= r_rand_num[2] ^ r_rand_num[5];
			r_rand_num[4]	<= r_rand_num[3] ^ r_rand_num[5];
			r_rand_num[5]	<= r_rand_num[4];
		end
		else begin
			r_rand_num 		<= r_rand_num;
		end
	end

	assign random_number = r_rand_num;
 
endmodule 