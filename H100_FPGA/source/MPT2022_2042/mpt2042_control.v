`timescale 1ns / 1ps
/*************************************************
 Copyright �Shandong Free Optics., Ltd. All rights reserved. 
 File name: cfg_top
 Author: 			ID   			Version: 			Date:
 luxuan             56              0.0.1               2023.02.16
 Description:   
 Others: 
 History:
 1. Date:
 Author: 							ID:
 Modification:
 2. ...
*************************************************/
module mpt2042_control(
//interface with s1_master
input   wire        sys_clk,                    //80Mhz
input   wire        sys_rst_n,    
input				i_angle_sync	,
input				i_motor_state	,
output  reg         verify_ok,

input   wire        SER_CLK_P,      //K18  LVDS_25
input   wire        SER_CLK_N,      //K17  LVDS_25
input   wire [1:0]  SER_DATA_P,     //P[0] M19 LVDS_25  P[1] K19 LVDS_25
input   wire [1:0]  SER_DATA_N,     //N[0] M20 LVDS_25  N[1] J19 LVDS_25

output  reg         ASIC_RESETN_OUT,//L17  LVCMOS25  RSTN   鑺墖澶嶄綅锛屼綆鏈夋晥

output  reg         SPI_RSTN_OUT,   //D20  LVCMOS25  ENABLE 鑺墖浣胯兘锛屼綆鐢靛钩娓呯┖瀵勫瓨鍣拷??      

output  wire        SPI_SCK_OUT,    //M18  LVCMOS25  max 40Mhz
output  wire        SPI_CSN_OUT,    //E19  LVCMOS25
output  wire        SPI_MOSI_OUT,   //G18  LVCMOS25
input   wire        SPI_MISO_IN,    //H17  LVCMOS25

input   wire        SPI_interrupt_n ,//G20 LVCMOS25      涓柇杈撳嚭锛岃礋鐢靛钩鏈夋�
output  reg         tdc_result_edge_id ,
output  reg   [2:0] tdc_result_channel_id,
output  reg         tdc_result_valid_flag,
output  reg  [18:0] tdc_result
);
/*-------------------------------------------------------------------*\     
                          Parameter Description
\*-------------------------------------------------------------------*/
localparam D 			= 2;

parameter CNT2 		  = 7'd99;
parameter CNT1  		  = 10'd999;

localparam ST_IDLE       = 8'b0000_0001;
localparam ST_ENABLE     = 8'b0000_0010;
localparam ST_RESET      = 8'b0000_0100;
localparam ST_CONFIG     = 8'b0000_1000;
localparam ST_VERIFY     = 8'b0001_0000;
localparam ST_WAIT_INIT  = 8'b0010_0000;
localparam ST_RESULT     = 8'b0100_0000;
localparam ST_ERROR      = 8'b1000_0000;

//step 1 鏃堕挓锟??????
    // CLK_IN 杈撳叆鏃堕挓 = 8M
    //  spi_fb_dp 鍊嶉绯绘暟 = 75 = 0b1001011   f 鍊嶉鏃堕挓 = 8M�5 = 600M
    //  tdc_pll_clk_in_select = 1              TDC 鏃堕挓鏉ユ簮涓哄唴閮紱
    //  top_pll_tdc_clk = 1                    TDC 鏃堕挓鍒嗛绯绘�= 4 鍒嗛锛汿DC 鏃堕�= 600M / 4 = 150M

    //SPI 妯″紡鎺ㄨ崘鏃堕挓閰嶇�
    // top_pll_ser_clk = 0b111锛汱VDS 鏃堕挓鍒嗛绯绘�= 16 鍒嗛�  LVDS 鏃堕�= 600M / 16 = 37.5M
    // top_pll_sys_clk = 0b11锛涚郴缁熸椂閽熷垎棰戠郴 = 16 鍒嗛�    绯荤粺鏃堕挓= 600M / 16 = 37.5M


//step 2 閫氶亾鍚敤
   // chnl_row_mask
     //T0 : T0 = 53 bit1 =  0 enable
     //Ch0: ch0= 21 bit1 =  0 enable
   // spi_chnl_en_num addr 7 [1:0] == 3  杞�chl0 ;   T0-chl0


//step 3 淇″彿鏋佷笌姣旇緝
 //chnl_row_polarity 
    //ch0 = 21 bit0      0 涓嬮檷娌块噰�????? ,鎺ㄨ�璐熻剦鍐诧紱 1 涓婂崌娌块噰�????? ,鎺ㄨ崘姝ｈ剦�?????;
    //ch1 = 33 bit0      0 涓嬮檷娌块噰�????? ,鎺ㄨ�璐熻剦鍐诧紱 1 涓婂崌娌块噰�????? ,鎺ㄨ崘姝ｈ剦�?????;
    //ch2 = 37 bit0      0 涓嬮檷娌块噰�????? ,鎺ㄨ�璐熻剦鍐诧紱 1 涓婂崌娌块噰�????? ,鎺ㄨ崘姝ｈ剦�?????;
    //ch3 = 49 bit0      0 涓嬮檷娌块噰�????? ,鎺ㄨ�璐熻剦鍐诧紱 1 涓婂崌娌块噰�????? ,鎺ㄨ崘姝ｈ剦�?????;
    //T0  = 53 bit0      0 涓嬮檷娌块噰�????? ,鎺ㄨ�璐熻剦鍐诧紱 1 涓婂崌娌块噰�????? ,鎺ㄨ崘姝ｈ剦�?????;

//chnl_row_Thresh 涓洪亾鐨勬瘮杈冨櫒瑙﹀彂锟????? 
  // 饾憠饾憪饾憸饾憵饾憹 = (7 �饾憞鈩庰潙燄潙掟潙犫�)饾憵V  Thresh chnl_row_Thresh[7:0]�????8 浣嶏紝Vcomp 涓烘瘮杈冨櫒鐢靛帇鍊硷紝鏈夋晥鑼冨洿 0~1500mV

//step 4 鍗曡竟娌夸笌鍙岃竟娌块噰�?????  chnl_row_spi_bypass
  //MPT2042 �?????鏈夛�锟介亾鐨嗘湁鍗曡竟娌夸笌鍙岃竟娌块噰鏍锋ā寮忥紝鍦ㄥ弻杈规部妯″紡涓嬶紝閫氶亾鍙湪淇″彿鐨勪笂鍗囨部鍜屼笅闄嶆部鍚屾椂閲囨牱锛屽苟閫氳繃杈撳嚭鏁版嵁�????? edge_id 瀵规暟鎹墍灞炶竟娌胯繘琛屾爣锟??????
  //ch0 = 23 bit7  0 鍗曡竟娌块噰�????? 1 鍙岃竟娌块噰�?????;
  //ch1 = 35 bit7
  //ch2 = 39 bit7
  //ch3 = 51 bit7
  //T0  = 55 bit7

//step 4  T-T0 妯″紡 
 //MPT2042 鍦ㄨ姱鐗囧唴閮ㄥ彲浠ュ閫氶亾璁剧疆�????? T-T0 妯″紡锛屽�T-T0 妯″紡涓嬶紝鑺墖灏嗚嚜琛屽鏁版嵁杩涜浣滃樊澶勭悊
 //chnl_row_reduce_t0_en
  // ch0 = 23 bit2    1 : T-T0, 0:鍘熷鏁版嵁;
  // ch1 = 35 bit2
  // ch2 = 39 bit2
  // ch3 = 51 bit2
  // T0  = 55 bit2

//step 5 鏁版嵁浼犺緭
  //SPI �????? SPI 鏁版嵁浼犺緭鏃讹紝鏁版嵁灏嗕細浣嶄簬鍙瀵勫瓨锟??????107~109  , send data on fall edge , read data on rising edge
    // [23:22] CHANNEL_ID 閫氶亾鏍囪瘑�?????0~3
    // [21] Reserved Reserved
    // [20] TDC fine data valid 鏁版嵁鏈夋晥�?????1
    // [19] edge_id 杈规部鏍囪 鍗曡竟娌挎ā寮忥細0�????? 鍙岃竟娌挎ā寮忥細0/1 
    // [18:0] TDC data TDC 璁℃�

    //浼犺緭锟?????? CSN 淇″彿鎷夐珮鐨勬椂闂翠笉寰楀皬锟?????? 4 涓郴缁熸椂閽熷懆锟??????  106.6ns  

    //鑺墖鍖呭惈 127 涓瘎瀛樺�
    //W(鍐欏�=0锛孯(璇诲�=1


    //SPI 浼犺緭鐩稿叧瀵勫瓨鍣ㄩ厤�?????
    // addr Bit    瀵勫瓨鍣ㄥ悕�?????            �?????
    // 7    2   cfg_ser_data_out_en     0
    // 7    3   cfg_ser_clk_out_en      0
    // 8    2   cfg_ser_mode_en_force   0
    // 8    6   cfg_intb_out_en         1
    // 8    5   cfg_intb_select_trig_en 0
    // 20 [1:0] top_pll_sys_clk        11    

    //SPI 鏁版嵁浼犺緭妯″紡�?????瑕佸鐢ㄥ紩�????? INTB 閰嶅�SPI 鏁版嵁璇诲彇锛屾棤鏁版嵁鏃讹紝INTB 涓洪珮鐢靛钩�?????
    //鑻ヨ姱鐗囧唴閮ㄧ紦瀛樻湁鏁版嵁锛孖NTB 灏嗕繚鎸佷负浣庣數骞筹紝姝ゆ椂鍙粠鍙瀵勫瓨鍣ㄨ�????? TDC 鏁版嵁锟??????
    //鑺墖鍐呴儴缂撳瓨鍙兘鏈夊缁勬暟鎹紝缂撳瓨鐨勬暟鎹湭琚叏閮ㄨ鍙栨椂锛孖NTB 灏嗗缁堜繚鎸佷綆鐢靛钩

/*-------------------------------------------------------------------*\
                          Reg/Wire Description
\*-------------------------------------------------------------------*/
(*MARK_DEBUG="TRUE"*)reg			[7:0] 		current_state;
reg			[7:0] 		next_state;

reg                     enable_flag;
reg                     reset_flag;
reg                     config_flag;
reg                     verify_flag;
reg                     result_flag;

reg       [2:0]         enable_flag_cnt;
reg                     enable_end_pulse;

reg       [2:0]         reset_flag_cnt;
reg                     reset_start_pulse;

reg       [1:0]         config_flag_cnt;
reg                     config_start_pulse;
reg                     config_end_pulse;

reg                     p0_config_end_pulse;
reg                     p1_config_end_pulse;

reg       [2:0]         verify_flag_cnt;
reg                     verify_start_pulse;
(*MARK_DEBUG="TRUE"*)reg                     verify_return_valid;

(*MARK_DEBUG="TRUE"*)reg       [7:0]         verify_return_value;

reg                     verify_done;
reg                     f0_verify_done;
(*MARK_DEBUG="TRUE"*)reg                     verify_error;

reg                     f0_SPI_interrupt_n;
(*MARK_DEBUG="TRUE"*)reg                     f1_SPI_interrupt_n;
reg                     f2_SPI_interrupt_n;

reg        [1:0]        result_flag_cnt;
reg                     result_start_pulse;

reg                     spi_tx_valid;
reg        [7:0]        spi_tx_data;
reg                     spi_rw_flag;
reg                     spi_cmd_type;

wire                    spi_finish_pulse;
(*MARK_DEBUG="TRUE"*)wire        [7:0]       spi_rdat;
(*MARK_DEBUG="TRUE"*)wire                    spi_rd_vld;
wire                    next_byte_vld;

reg         [6:0]       rom_address;
wire        [7:0]       rom_data;

reg                     f0_next_byte_vld;
reg                     f1_next_byte_vld;

(*MARK_DEBUG="TRUE"*)reg                     tdc_result_valid;
//(*MARK_DEBUG="TRUE"*)reg        [18:0]       tdc_result;
//(*MARK_DEBUG="TRUE"*)reg                     tdc_result_edge_id;
//(*MARK_DEBUG="TRUE"*)reg                     tdc_result_valid_flag;
//(*MARK_DEBUG="TRUE"*)reg        [2:0]        tdc_result_channel_id;

reg                     f0_tdc_result_valid;
reg                     f1_tdc_result_valid;
reg        [1:0]        tdc_result_cnt;
/*-------------------------------------------------------------------*\
                          Main Code
\*-------------------------------------------------------------------*/
reg    	  	[6:0]		sys_clk_ns_cnt;
reg         	        one_us_valid;
reg      	[9:0]		sys_clk_us_cnt;
reg         	        one_ms_valid;
reg      	[9:0]		sys_clk_ms_cnt;
reg         	        one_sec_valid;
reg         [1:0]       sys_clk_sec_cnt;
reg                     tdc_start_vld;

always@(posedge sys_clk)begin
    if(!sys_rst_n) begin
		sys_clk_ns_cnt <=#D 16'd0;
    end else if(sys_clk_ns_cnt ==CNT2)begin
		sys_clk_ns_cnt <=#D 16'd0;
    end else begin
		sys_clk_ns_cnt <=#D sys_clk_ns_cnt + 1'b1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		one_us_valid <=#D 1'd0;
    end else begin
		one_us_valid <=#D sys_clk_ns_cnt == CNT2;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		sys_clk_us_cnt <=#D 10'd0;	
    end else if(one_us_valid && sys_clk_us_cnt == CNT1)begin
		sys_clk_us_cnt <=#D 10'd0;
    end else if(one_us_valid)begin
		sys_clk_us_cnt <=#D sys_clk_us_cnt + 10'b1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		one_ms_valid <=#D 1'd0;
    end else begin
		one_ms_valid <=#D one_us_valid && sys_clk_us_cnt == CNT1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		sys_clk_ms_cnt <=#D 10'd0;	
	end else if(one_ms_valid && (sys_clk_ms_cnt == CNT1))begin
		sys_clk_ms_cnt <=#D 10'd0;
    end else if(one_ms_valid)begin
		sys_clk_ms_cnt <=#D sys_clk_ms_cnt + 10'b1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		one_sec_valid <=#D 1'd0;
    end else begin
		one_sec_valid <=#D one_ms_valid && sys_clk_ms_cnt == CNT1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		sys_clk_sec_cnt <=#D 2'd0;	
	end else if(one_sec_valid && (sys_clk_sec_cnt == 2'd3))begin
		sys_clk_sec_cnt <=#D sys_clk_sec_cnt;
    end else if(one_sec_valid)begin
		sys_clk_sec_cnt <=#D sys_clk_sec_cnt + 10'b1;
    end
end

always@(posedge sys_clk) begin
    if(!sys_rst_n) begin
		tdc_start_vld <=#D 1'd0;
    end else begin
		tdc_start_vld <=#D one_sec_valid && (sys_clk_sec_cnt == 2'd2);
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        current_state <=#D ST_IDLE;
    end
    else begin
        current_state <=#D next_state;
    end
end

always @(*) 
begin
    next_state = current_state;
    case(current_state)
        ST_IDLE: begin
            if(tdc_start_vld)
                next_state = ST_ENABLE;
            else
                next_state = ST_IDLE;
        end        

        ST_ENABLE: begin
            if(enable_end_pulse)begin 
                next_state = ST_RESET;
            end else begin
                next_state = ST_ENABLE;
            end
        end
        ST_RESET: begin
            if(reset_start_pulse)begin 
                next_state = ST_CONFIG;
            end else begin
                next_state = ST_RESET;
            end
        end

        ST_CONFIG: begin
            if(config_end_pulse)begin 
                next_state = ST_VERIFY;
            end else begin
                next_state = ST_CONFIG;
            end			
        end

        ST_VERIFY: begin
            if(verify_ok&i_angle_sync&i_motor_state)begin 
                next_state = ST_WAIT_INIT;               
            end else if(verify_error)begin
                next_state = ST_ERROR;	
            end else begin
                next_state = ST_VERIFY;
            end
        end		

        ST_WAIT_INIT: begin
            if(~f1_SPI_interrupt_n&(~f2_SPI_interrupt_n)&(~f0_SPI_interrupt_n))begin 
                next_state = ST_RESULT;
            end else begin
                next_state = ST_WAIT_INIT;
            end
        end			 

        ST_RESULT: begin
            if(f1_tdc_result_valid)begin 
                next_state = ST_WAIT_INIT; 
            end else begin
                next_state = ST_RESULT;					
            end
        end	      

        ST_ERROR: begin
            next_state = ST_ERROR;
        end	                         

        default : next_state = ST_IDLE;
    endcase
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        enable_flag <=#D 1'd0;	
        reset_flag  <=#D 1'd0;
        config_flag <=#D 1'b0;	 
        verify_flag <=#D 1'b0;
        result_flag <=#D 1'b0;                  
    end
    else begin
        case(current_state)
            ST_IDLE : begin
				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;  
                result_flag <=#D 1'b0;                                                                             	                              		
            end
            ST_ENABLE : begin
				enable_flag <=#D 1'b1;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;   
                result_flag <=#D 1'b0;                  
            end
            ST_RESET : begin
				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b1;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;
                result_flag <=#D 1'b0;                                                                             	                	                 
            end            
            ST_CONFIG : begin
				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b1;	  
                verify_flag <=#D 1'b0;    
                result_flag <=#D 1'b0;                                                                                                      
            end
            ST_VERIFY : begin  
				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b1;   
                result_flag <=#D 1'b0;                                                                                                   			
            end
            ST_WAIT_INIT : begin
				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;   
                result_flag <=#D 1'b0;                             
            end
            ST_RESULT : begin  
   				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;  
                result_flag <=#D 1'b1;                                                                                              
            end	
            ST_ERROR : begin
   				enable_flag <=#D 1'b0;	
				reset_flag  <=#D 1'b0;
                config_flag <=#D 1'b0;	  
                verify_flag <=#D 1'b0;  
                result_flag <=#D 1'b0;                              
            end	                                     	                                    	
			default : begin
                enable_flag <=#D enable_flag;
                reset_flag  <=#D reset_flag;
                config_flag <=#D config_flag;
                verify_flag <=#D verify_flag;
                result_flag <=#D result_flag;                                                                                       	         
			end
        endcase
    end
end	

///////////////////////////////////////////////////////////////////// 12.5ns x 2 SPI 瀵勫瓨鍣ㄥ浣嶏紝ENABLE 鎷変綆鑷冲皯 10ns 鍚庢媺锟??????
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        enable_flag_cnt <=#D 3'b0;
    end else if(enable_flag)begin
        enable_flag_cnt <=#D enable_flag_cnt + 3'd1;
    end else begin
        enable_flag_cnt <=#D 3'b0;     
    end
end	

//12.5ns x 2
always @(posedge sys_clk)begin 
    if(!sys_rst_n) begin
        SPI_RSTN_OUT <=#D 1'b1;     
    end else if(enable_flag_cnt == 3'd1)begin
        SPI_RSTN_OUT <=#D 1'b0;        
    end else if(enable_flag_cnt == 3'd3)begin
        SPI_RSTN_OUT <=#D 1'b1;             
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        enable_end_pulse <=#D 1'b0;
    end else begin
        enable_end_pulse <=#D enable_flag_cnt == 3'd3;
    end
end	

///////////////////////////////////////////////////////////////////// 鑺墖宸ヤ綔鐘跺浣嶏紝RESETN 鎷変綆鑷冲皯 10ns 鍚庢媺楂橈紱
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        reset_flag_cnt <=#D 3'b0;      
    end else if(reset_flag)begin
        reset_flag_cnt <=#D reset_flag_cnt + 3'd1;
    end else begin
        reset_flag_cnt <=#D 3'b0;     
    end
end	
//12.5ns x 2
always @(posedge sys_clk)begin 
    if(!sys_rst_n) begin
        ASIC_RESETN_OUT <=#D 1'b1;     
    //end else if(reset_flag_cnt == 3'd1|(i_angle_sync&verify_ok))begin
	end else if(reset_flag_cnt == 3'd1)begin
        ASIC_RESETN_OUT <=#D 1'b0;        
    //end else if(reset_flag_cnt == 3'd3|(i_angle_sync!=1))begin
	end else if(reset_flag_cnt == 3'd3)begin
        ASIC_RESETN_OUT <=#D 1'b1;             
    end
end	


always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        reset_start_pulse <=#D 1'b0;
    end else begin
        reset_start_pulse <=#D reset_flag_cnt == 3'd3;        
    end
end
///////////////////////////////////////////////////////////////////// ST_CONFIG
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        config_flag_cnt <=#D 2'b0;  
    end else if(config_flag && &config_flag_cnt)begin
        config_flag_cnt <=#D config_flag_cnt;          
    end else if(config_flag)begin
        config_flag_cnt <=#D config_flag_cnt + 2'd1;
    end else begin
        config_flag_cnt <=#D 2'b0;     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        config_start_pulse <=#D 1'b0;
    end else begin
        config_start_pulse <=#D config_flag_cnt == 2'd1;        
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        p0_config_end_pulse <=#D 1'b0;
    end else begin
        p0_config_end_pulse <=#D config_flag && spi_finish_pulse;        
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        p1_config_end_pulse <=#D 1'b0;
    end else begin
        p1_config_end_pulse <=#D p0_config_end_pulse;        
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        config_end_pulse <=#D 1'b0;
    end else begin
        config_end_pulse <=#D p1_config_end_pulse;        
    end
end	

///////////////////////////////////////////////////////////////////// ST_VERIFY
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_flag_cnt <=#D 3'b0;   
    end else if(verify_flag && &verify_flag_cnt)begin
        verify_flag_cnt <=#D verify_flag_cnt;          
    end else if(verify_flag)begin
        verify_flag_cnt <=#D verify_flag_cnt + 3'd1;
    end else begin
        verify_flag_cnt <=#D 3'b0;     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_start_pulse <=#D 1'b0;
    end else begin
        verify_start_pulse <=#D verify_flag_cnt == 3'd4;        
    end
end

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_return_valid <=#D 1'b0;
    end else begin
        verify_return_valid <=#D verify_flag && spi_rd_vld;        
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_return_value <=#D 8'b0;
    end else if(verify_flag && spi_rd_vld)begin
        verify_return_value <=#D spi_rdat[7:0];           
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_done <=#D 1'b0;     
    end else begin
        verify_done <=#D verify_flag && spi_finish_pulse;          
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_verify_done <=#D 1'b0;     
    end else begin
        f0_verify_done <=#D verify_done;          
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_error <=#D 1'b0;     
    end else if(verify_return_valid && (verify_return_value != rom_data))begin
        verify_error <=#D 1'b1;    
    end else if(f0_verify_done)begin
        verify_error <=#D 1'b0;                  
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        verify_ok <=#D 1'b0;       
    end else begin
        verify_ok <=#D verify_ok ? (verify_ok&(~verify_error)) :(f0_verify_done & ~verify_error);            
    end
end

///////////////////////////////////////////////////////////////////// ST_WAIT_INIT
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_SPI_interrupt_n <=#D 1'b1;
        f1_SPI_interrupt_n <=#D 1'b1;
		f2_SPI_interrupt_n <=#D 1'b1;      
    end else begin
        f0_SPI_interrupt_n <=#D SPI_interrupt_n;
        f1_SPI_interrupt_n <=#D f0_SPI_interrupt_n; 
        f2_SPI_interrupt_n <=#D f1_SPI_interrupt_n ;		
    end
end	
///////////////////////////////////////////////////////////////////// ST_RESULT
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        result_flag_cnt <=#D 2'b0;  
    end else if(result_flag && &result_flag_cnt)begin
        result_flag_cnt <=#D result_flag_cnt;          
    end else if(result_flag)begin
        result_flag_cnt <=#D result_flag_cnt + 2'd1;
    end else begin
        result_flag_cnt <=#D 2'b0;     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        result_start_pulse <=#D 1'b0;
    end else begin
        result_start_pulse <=#D result_flag_cnt == 2'd1;        
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result_cnt <=#D 2'b0;
    end else if(result_start_pulse)begin
        tdc_result_cnt <=#D 2'b0;            
    end else if(result_flag && spi_rd_vld)begin
        tdc_result_cnt <=#D tdc_result_cnt + 2'd1;   
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result <=#D 19'b0;     
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd0))begin
        tdc_result[7:0] <=#D spi_rdat[7:0];     
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd1))begin
        tdc_result[15:8] <=#D spi_rdat[7:0];     
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd2))begin
        tdc_result[18:16] <=#D spi_rdat[2:0];                     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result_valid_flag <=#D 1'b0;   
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd2))begin
        tdc_result_valid_flag <=#D spi_rdat[4];                     
    end else begin
		tdc_result_valid_flag <=#D tdc_result_valid_flag ? 1'b0:tdc_result_valid_flag;
	end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result_channel_id <=#D 3'b0;   
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd2))begin
        tdc_result_channel_id <=#D spi_rdat[7]; //mpt 2022                    
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result_edge_id <=#D 1'b0;   
    end else if(result_flag && spi_rd_vld && (tdc_result_cnt == 2'd2))begin
        tdc_result_edge_id <=#D spi_rdat[3];                     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        tdc_result_valid <=#D 1'b0;
    end else begin
        tdc_result_valid <=#D result_flag && spi_rd_vld && (tdc_result_cnt == 2'd2);    
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_tdc_result_valid <=#D 1'b0;
        f1_tdc_result_valid <=#D 1'b0;        
    end else begin
        f0_tdc_result_valid <=#D tdc_result_valid;  
        f1_tdc_result_valid <=#D f0_tdc_result_valid;            
    end
end	
////////////////////////////
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_tx_valid <=#D 1'b0;       
    end else begin
        spi_tx_valid <=#D config_start_pulse || verify_start_pulse || result_start_pulse;     
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_rw_flag <=#D 1'b0;              
    end else if(config_start_pulse)begin
        spi_rw_flag <=#D 1'b0;
    end else if(verify_start_pulse || result_start_pulse)begin
        spi_rw_flag <=#D 1'b1;                            
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_cmd_type <=#D 1'b0;              
    end else if(config_start_pulse || verify_start_pulse)begin
        spi_cmd_type <=#D 1'b0;
    end else if(result_start_pulse)begin
        spi_cmd_type <=#D 1'b1;                            
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        spi_tx_data <=#D 8'h00;              
    end else if(config_start_pulse)begin // write address 0
        spi_tx_data <=#D 8'h00;
    end else if(verify_start_pulse)begin // read  address 0
        spi_tx_data <=#D 8'h80;        
    end else if(result_start_pulse)begin
        spi_tx_data <=#D {1'b1,7'd105};  // read address 105        

    end else if(f0_next_byte_vld)begin
        spi_tx_data <=#D rom_data;      // read address 105    

    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f0_next_byte_vld <=#D 1'b0;
    end else begin
        f0_next_byte_vld <=#D next_byte_vld;      
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        f1_next_byte_vld <=#D 1'b0;
    end else begin
        f1_next_byte_vld <=#D f0_next_byte_vld;      
    end
end	
/*wire w_SPI_SCK_OUT;
reg clera_spi_clk ;
assign  SPI_SCK_OUT = w_SPI_SCK_OUT&clera_spi_clk;
always @(posedge sys_clk)begin
	if(current_state==ST_RESULT) begin
		clera_spi_clk <= i_angle_sync ? 1'b0:clera_spi_clk;
	end else begin
		clera_spi_clk <=1'b1;
	end
end*/
mpt2042_spi_top u_mpt2042_spi_top
(
.sys_clk      (sys_clk),
.sys_rst_n    (sys_rst_n),
.spi_tx_valid (spi_tx_valid),
.spi_tx_rw    (spi_rw_flag),

.spi_tx_data  (spi_tx_data),

.spi_cmd_type (spi_cmd_type),  

.spi_so       (SPI_MISO_IN),   
.spi_clk      (SPI_SCK_OUT),   
.spi_ssn      (SPI_CSN_OUT),   
.spi_si       (SPI_MOSI_OUT),     

.next_byte_vld     (next_byte_vld),
.spi_finish_pulse  (spi_finish_pulse),
.spi_rd_vld        (spi_rd_vld),
.spi_rdat          (spi_rdat)
);

reg                no_first_flag;
always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        no_first_flag <=#D 1'b0;
    end else if(verify_start_pulse)begin
        no_first_flag <=#D 1'b0;    
    end else if(verify_flag && next_byte_vld)begin
        no_first_flag <=#D 1'b1;           
    end
end	

always @(posedge sys_clk) begin
    if(!sys_rst_n) begin
        rom_address <=#D 7'b0;       
    end else if(config_start_pulse || verify_start_pulse)begin
        rom_address <=#D  7'd0;   
    end else if(config_flag && next_byte_vld)begin
        rom_address <=#D  rom_address + 7'd1;     
    end else if(verify_flag && no_first_flag && next_byte_vld)begin
        rom_address <=#D  rom_address + 7'd1;                
    end
end	
/*
mpt2042_rom_128x8 u_mpt2042_rom_128x8 (
  .a(rom_address),        // input wire [6 : 0] a
  .clk(sys_clk),          // input wire clk
  //.qspo_rst(~sys_rst_n),  // input wire qspo_rst
  .spo(rom_data)         // output wire [7 : 0] qspo
);*/
mpt2042_rom_128x8 u1 (
	.Address(rom_address), 
	.OutClock(sys_clk), 
	.OutClockEn(1'b1), 
	//.Reset(Reset), 
	.Q(rom_data)
 );
 
endmodule