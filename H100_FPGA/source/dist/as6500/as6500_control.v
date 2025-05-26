module as6500_control
(
	input				i_clk_50m		,
	input				i_clk_100m		,
	input				i_rst_n      	,
	
	input				i_angle_sync	,
	input				i_motor_state	,
	
	input				i_tdc_init 		,
	input				i_tdc_spi_miso	,
	output				o_tdc_spi_mosi	,
	output				o_tdc_spi_ssn 	,
	output				o_tdc_spi_clk 	,

	output		[15:0]	o_rise_data		,//ÏÂ½µÑØ
	output		[15:0]	o_fall_data		,//ÏÂ½µÑØ
	output				o_tdc_err_sig	,
	output				o_tdc_new_sig   	
);

	// inst as6500_ctrl
	wire   			spi_tx_ready;
	wire   			spi_rx_byte_valid;
	wire   	[7:0]  spi_rx_byte;
	wire  	[7:0]  spi_tx_byte;
	wire  			spi_tx_byte_valid;

	wire   [31:0]  as6500_measure_data;
	wire   			as6500_measure_data_valid;
	wire   			as6500_config_done;
	
	assign			o_tdc_new_sig 	= as6500_measure_data_valid;
	assign			o_tdc_err_sig 	= ~as6500_config_done;
	assign			o_rise_data		= as6500_measure_data[31:16];
	assign			o_fall_data		= as6500_measure_data[15:0];

	as6500_ctrl  U1 
	(
		.sys_clk                 ( i_clk_50m                    ),
		.sys_rst_n               ( i_rst_n                      ),
		.en_as6500_measure       ( i_motor_state                ),
		.sign_as6500_measure     ( i_angle_sync                 ),
		.as6500_interrupt        ( i_tdc_init             		 ),
		.spi_tx_ready            ( spi_tx_ready                 ),
		.spi_rx_byte_valid       ( spi_rx_byte_valid            ),
		.spi_rx_byte             ( spi_rx_byte                  ),
		.as6500_init_done        (              			     ),   

		.spi_cs_n                ( o_tdc_spi_ssn                ),
		.as6500_config_done      ( as6500_config_done           ),
		.measure_data            ( as6500_measure_data          ),
		.measure_data_valide     ( as6500_measure_data_valid    ),
		.spi_tx_byte             ( spi_tx_byte                  ),
		.spi_tx_byte_valid       ( spi_tx_byte_valid            )
	);

	// inst SPI_Master module
	/* AS6500 SPI Mode 
	Clock Polarity : 0
	 Clock Phase   : 1
	*/
	/*SPI_Master #(
		.SPI_MODE(1),
		.CLKS_PER_HALF_BIT ( 1 ))  
	 SPI_Master_inst (
		.i_Rst_L                 ( i_rst_n                  ),
		.i_Clk                   ( i_clk_100m               ),
		.i_TX_Byte               ( spi_tx_byte              ),
		.i_TX_DV                 ( spi_tx_byte_valid        ),
		.i_SPI_MISO              ( i_tdc_spi_miso           ),

		.o_TX_Ready              ( spi_tx_ready             ),
		.o_RX_DV                 ( spi_rx_byte_valid        ),
		.o_RX_Byte               ( spi_rx_byte              ),
		.o_SPI_Clk               ( o_tdc_spi_clk            ),
		.o_SPI_MOSI              ( o_tdc_spi_mosi           ) 
	);*/
	
	SPI_Master_2  SPI_Master_inst 
	(
		.i_Rst_L                 ( i_rst_n                  ),
		.i_Clk                   ( i_clk_50m                ),
		.i_Clk_Phase             ( i_clk_100m               ),
		.i_TX_Byte               ( spi_tx_byte              ),
		.i_TX_DV                 ( spi_tx_byte_valid        ),
		.i_SPI_MISO              ( i_tdc_spi_miso           ),

		.o_TX_Ready              ( spi_tx_ready             ),
		.o_RX_DV                 ( spi_rx_byte_valid        ),
		.o_RX_Byte               ( spi_rx_byte              ),
		.o_SPI_Clk               ( o_tdc_spi_clk            ),
		.o_SPI_MOSI              ( o_tdc_spi_mosi           ) 
	);

endmodule 