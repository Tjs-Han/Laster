module SPI_Master_2
(
	input        	i_Rst_L			,     
	input        	i_Clk			, 
	input			i_Clk_Phase		,

	input 	[7:0]	i_TX_Byte		,        
	input        	i_TX_DV			,          
	output 			o_TX_Ready		,       

	output 			o_RX_DV			,     
	output 	[7:0] 	o_RX_Byte		,   

	output			o_SPI_Clk		,
	input			i_SPI_MISO		,
	output			o_SPI_MOSI
);
	
	reg				r_RX_DV		= 1'b0;
	reg		[7:0]	r_RX_Byte	= 8'd0;
	reg				r_TX_Ready	= 1'b1;
	reg				r_SPI_MOSI	= 1'b0;
	
	reg		[3:0]	r_clk_counter = 4'd0;
	reg		[3:0]	rr_clk_counter = 4'd0;
	reg				r_spi_clk_en = 1'b0;
	reg		[7:0]	r_spi_tx_reg = 8'd0;
	reg				r_tx_sig_reg = 1'b0;
	wire			w_tx_sig_rise;
    reg             tjs_value ;
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_tx_sig_reg	<= 1'b0;
		else
			r_tx_sig_reg	<= i_TX_DV;
			
	assign	w_tx_sig_rise = ~r_tx_sig_reg & i_TX_DV;

	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_clk_counter	<= 4'd0;
		else if(w_tx_sig_rise)
			r_clk_counter	<= 4'd8;
		else if(r_clk_counter > 4'd0)
			r_clk_counter	<= r_clk_counter - 1'b1;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_spi_clk_en	<= 1'b0;
		else if(r_clk_counter > 4'd0)
			r_spi_clk_en	<= 1'b1;
		else
			r_spi_clk_en	<= 1'b0;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)		
			r_spi_tx_reg	<= 8'd0;
		else if(w_tx_sig_rise)
			r_spi_tx_reg	<= i_TX_Byte;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_SPI_MOSI		<= 1'b0;
		else if(r_clk_counter > 4'd0)
			r_SPI_MOSI		<= r_spi_tx_reg[r_clk_counter - 1'b1];
		else
			r_SPI_MOSI		<= 1'b0;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_TX_Ready		<= 1'b1;
		else if(r_clk_counter > 4'd0)
			r_TX_Ready		<= 1'b0;
		else
			r_TX_Ready		<= 1'b1;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_RX_Byte		<= 8'd0;
			tjs_value       <= 0;
		else if(r_clk_counter > 4'd0) begin
			//r_RX_Byte		<= {r_RX_Byte[6:0],i_SPI_MISO};
			r_RX_Byte		<= {r_RX_Byte[6:0],tjs_value};//tjs
			tjs_value		<= ~tjs_value;
		end
		else if(rr_clk_counter == 4'd1 && r_clk_counter == 4'd0) begin
			//r_RX_Byte		<= {r_RX_Byte[6:0],i_SPI_MISO};
			r_RX_Byte		<= {r_RX_Byte[6:0],tjs_value};//tjs
			tjs_value		<= ~tjs_value;
		end	
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			rr_clk_counter	<= 4'd0;
		else
			rr_clk_counter	<= r_clk_counter;
			
	always @(posedge i_Clk or negedge i_Rst_L)
		if(i_Rst_L == 1'b0)
			r_RX_DV			<= 1'b0;
		else if(rr_clk_counter == 4'd1 && r_clk_counter == 4'd0)
			r_RX_DV			<= 1'b1;
		else
			r_RX_DV			<= 1'b0;
			
			
	assign 			o_TX_Ready		= r_TX_Ready;       
	assign 			o_RX_DV			= r_RX_DV;
	assign 			o_RX_Byte		= r_RX_Byte;   
	assign			o_SPI_Clk		= r_spi_clk_en & i_Clk_Phase;
	assign			o_SPI_MOSI		= r_SPI_MOSI;

endmodule
