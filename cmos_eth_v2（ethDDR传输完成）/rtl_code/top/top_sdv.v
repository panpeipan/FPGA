//`include"../rtl_code/include/myparam.v"
module top_sdv#(
//    `ifdef simulate 
//    parameter addr_max = 23'd768            //1280*768/4 = 245760  64*48/4=768
//    `else 
//    parameter addr_max = 23'd245760
//    `endif
    parameter addr_max = 23'd256000
)(

	input  wire          source_clk        ,             //输入系统时钟50Mhz
	input  wire          sys_rst_n         ,
    input  wire          switch_key        ,
    input  wire          close_key         ,
    input  wire          i_arp_key         ,
    input  wire          i_sd_save_key     ,
//----------------------------------------  
//DDR2_port
    output wire [ 12: 0] mem_addr          ,
    output wire [  2: 0] mem_ba            ,
    output wire          mem_cas_n         ,
    output wire [  0: 0] mem_cke           ,
    inout  wire [  0: 0] mem_clk           ,
    inout  wire [  0: 0] mem_clk_n         ,
    output wire [  0: 0] mem_cs_n          ,
    output wire [  1: 0] mem_dm            ,
    inout  wire [ 15: 0] mem_dq            ,
    inout  wire [  1: 0] mem_dqs           ,
    output wire [  0: 0] mem_odt           ,
    output wire          mem_ras_n         ,
    output wire          mem_we_n          ,
//----------------------------------------  
//SD_port 
    input  wire          sd_miso           ,
    output wire          sd_clk            ,
    output wire          sd_cs             ,
    output wire          sd_mosi           ,
//----------------------------------------  
//VGA_port 
    output wire          vga_hs            ,             //行同步信号
	output wire          vga_vs            ,             //列同步信号
	output wire [4:0]    vga_r             ,
	output wire [5:0]    vga_g             ,
	output wire [4:0]    vga_b             ,
//---------------------------------------- 
//debug led
//    output wire       camera_init_done_n    ,             //LED0 for sd
//    output wire       led_first_image_done_n,
//    output wire       local_init_done_n     ,
    
//----------------------------------------
//OV9281_port m0
    output wire         m0_i2c_sclk         ,
    inout  wire         m0_i2c_sdat         ,
    output wire         m0_camera_pwdn      ,
    output wire         m0_camera_xclk      ,    
    input  wire         m0_camera_pclk      ,
    input  wire         m0_camera_href      ,
    input  wire         m0_camera_vsync     ,
    input  wire [7:0]   m0_camera_data      ,
//----------------------------------------  
//OV9281_port m1
    output wire         m1_i2c_sclk         ,
    inout  wire         m1_i2c_sdat         ,
    output wire         m1_camera_pwdn      ,
    output wire         m1_camera_xclk      ,    
    input  wire         m1_camera_pclk      ,
    input  wire         m1_camera_href      ,
    input  wire         m1_camera_vsync     ,
    input  wire [7:0]   m1_camera_data      ,

//----------------------------------------  
//OV9281_port m2
    output wire         m2_i2c_sclk         ,
    inout  wire         m2_i2c_sdat         ,
    output wire         m2_camera_pwdn      ,
    output wire         m2_camera_xclk      ,    
    input  wire         m2_camera_pclk      ,
    input  wire         m2_camera_href      ,
    input  wire         m2_camera_vsync     ,
    input  wire [7:0]   m2_camera_data      ,
//----------------------------------------  
//OV9281_port m3
    output wire         m3_i2c_sclk         ,
    inout  wire         m3_i2c_sdat         ,
    output wire         m3_camera_pwdn      ,
    output wire         m3_camera_xclk      ,                 // xclk 24m 外部提供          
    input  wire         m3_camera_pclk      ,
    input  wire         m3_camera_href      ,
    input  wire         m3_camera_vsync     ,
    input  wire [7:0]   m3_camera_data      ,
//----------------------------------------  
//OV9281_port m4
    output wire         m4_i2c_sclk         ,
    inout  wire         m4_i2c_sdat         ,
    output wire         m4_camera_pwdn      ,
    output wire         m4_camera_xclk      ,    
    input  wire         m4_camera_pclk      ,
    input  wire         m4_camera_href      ,
    input  wire         m4_camera_vsync     ,
    input  wire [7:0]   m4_camera_data      ,
//----------------------------------------  
//OV9281_port m5
    output wire         m5_i2c_sclk         ,
    inout  wire         m5_i2c_sdat         ,
    output wire         m5_camera_pwdn      ,
    output wire         m5_camera_xclk      ,    
    input  wire         m5_camera_pclk      ,
    input  wire         m5_camera_href      ,
    input  wire         m5_camera_vsync     ,
    input  wire [7:0]   m5_camera_data      ,
//----------------------------------------  
//OV9281_port m6
//    output wire         m6_i2c_sclk         ,
//    inout  wire         m6_i2c_sdat         ,
//    output wire         m6_camera_pwdn      ,
//    output wire         m6_camera_xclk      ,                 // xclk 24m 外部提供          
//    input  wire         m6_camera_pclk      ,
//    input  wire         m6_camera_href      ,
//    input  wire         m6_camera_vsync     ,
//    input  wire [7:0]   m6_camera_data      ,
////----------------------------------------  
////OV9281_port m7
//    output wire         m7_i2c_sclk         ,
//    inout  wire         m7_i2c_sdat         ,
//    output wire         m7_camera_pwdn      ,
//    output wire         m7_camera_xclk      ,    
//    input  wire         m7_camera_pclk      ,
//    input  wire         m7_camera_href      ,
//    input  wire         m7_camera_vsync     ,
//    input  wire [7:0]   m7_camera_data      ,
////----------------------------------------  
////OV9281_port m8
//    output wire         m8_i2c_sclk         ,
//    inout  wire         m8_i2c_sdat         ,
//    output wire         m8_camera_pwdn      ,
//    output wire         m8_camera_xclk      ,    
//    input  wire         m8_camera_pclk      ,
//    input  wire         m8_camera_href      ,
//    input  wire         m8_camera_vsync     ,
//    input  wire [7:0]   m8_camera_data      ,
////---------------------------------------- 
////for modelsim_debug
//    output wire       ddr_initial_done    
//    `endif   
//-----------------------------------------
//ETH_PORT         
	output wire         e_reset           ,
    output wire         e_mdc             ,  //NULL
	inout  wire         e_mdio            ,  //NULL
//rec                       
	input  wire         e_rxc             ,  //125Mhz ethernet gmii rx clock
	input  wire         e_rxdv            ,	
	input  wire         e_rxer            ,	//NULL					
	input  wire [7:0]   e_rxd             ,        
//tx                                 
	input  wire         e_txc             ,  //NULL 25Mhz ethernet mii tx clock       
	output wire         e_gtxc            ,  //25Mhz ethernet gmii tx clock  
	output wire         e_txen            , 
	output wire         e_txer            ,
	output wire [7:0]   e_txd	          
);


    wire         m6_i2c_sclk         ;
    wire         m6_i2c_sdat         ;
    wire         m6_camera_pwdn      ;
    wire         m6_camera_xclk      ;                 // xclk 24m 外部提供          
    wire         m6_camera_pclk      ;
    wire         m6_camera_href      ;
    wire         m6_camera_vsync     ;
    wire [7:0]   m6_camera_data      ;
    wire         m7_i2c_sclk         ;
    wire         m7_i2c_sdat         ;
    wire         m7_camera_pwdn      ;
    wire         m7_camera_xclk      ;    
    wire         m7_camera_pclk      ;
    wire         m7_camera_href      ;
    wire         m7_camera_vsync     ;
    wire [7:0]   m7_camera_data      ;
    wire         m8_i2c_sclk         ;
    wire         m8_i2c_sdat         ;
    wire         m8_camera_pwdn      ;
    wire         m8_camera_xclk      ;    
    wire         m8_camera_pclk      ;
    wire         m8_camera_href      ;
    wire         m8_camera_vsync     ;
    wire [7:0]   m8_camera_data      ;
//----------------------------------------
//----------------------------------------
        //parameter  DATA_WIDTH   = 32           ;  //总线数据宽度
        //parameter  ADDR_WIDTH   = 25           ;  //总线地址宽度
        //parameter  CMOS_H_PIXEL = 16'd1280     ;  //CMOS水平方向像素个数
        //parameter  CMOS_V_PIXEL = 16'd800      ;  //CMOS垂直方向像素个数
//DEFINE
wire	                       	   ddr_init_done     ;     //ddr_初始化完成
wire	                       	   ddr_clk                ;
wire                               pll_locked_u1          ;
wire                               pll_locked_u2          ;
wire                               rst_n                  ;     //全局复位
wire                               sd_clk25m,sd_clk25m_ref;
reg                                img_vsync_d0           ;
reg                                img_vsync_d1           ;

//----------------------------------------------------------
//   fifo 32-32
//----------------------------------------------------------
//-cmos_m0
wire                               FIFO_m0_EMPTY           ;
wire                               FIFO_m0_FULL            ;
wire [8:0]                         FIFO_m0_LEN             ;
//-cmos_m1                                                 
wire                               FIFO_m1_EMPTY           ;
wire                               FIFO_m1_FULL            ;
wire [8:0]                         FIFO_m1_LEN             ;
//-cmos_m2                                                 
wire                               FIFO_m2_EMPTY           ;
wire                               FIFO_m2_FULL            ;
wire [8:0]                         FIFO_m2_LEN             ;
//-cmos_m3                                                 
wire                               FIFO_m3_EMPTY           ;
wire                               FIFO_m3_FULL            ;
wire [8:0]                         FIFO_m3_LEN             ;
//-cmos_m4                                                 
wire                               FIFO_m4_EMPTY           ;
wire                               FIFO_m4_FULL            ;
wire [8:0]                         FIFO_m4_LEN             ;
//-cmos_m5                                                
wire                               FIFO_m5_EMPTY           ;
wire                               FIFO_m5_FULL            ;
wire [8:0]                         FIFO_m5_LEN             ;
//-cmos_m6                                               
wire                               FIFO_m6_EMPTY           ;
wire                               FIFO_m6_FULL            ;
wire [8:0]                         FIFO_m6_LEN             ;
//-cmos_m7                                              
wire                               FIFO_m7_EMPTY           ;
wire                               FIFO_m7_FULL            ;
wire [8:0]                         FIFO_m7_LEN             ;
//-cmos_m8                                              
wire                               FIFO_m8_EMPTY           ;
wire                               FIFO_m8_FULL            ;
wire [8:0]                         FIFO_m8_LEN             ;
//-cmos_sel                                              
wire                               FIFO_sel_EMPTY          ;
wire                               FIFO_sel_FULL           ;
wire [8:0]                         FIFO_sel_LEN            ;
//-neg_vga_vs                                              
wire                               neg_vga_vs              ;
//----------------------------------------------------------
//   camera_ov9281_m0
//----------------------------------------------------------
wire                               CLK_24M                 ;
wire                               CLK_20K                 ;
assign                             m0_camera_xclk = CLK_24M; 
assign                             m1_camera_xclk = CLK_24M; 
assign                             m2_camera_xclk = CLK_24M; 
assign                             m3_camera_xclk = CLK_24M; 
assign                             m4_camera_xclk = CLK_24M; 
assign                             m5_camera_xclk = CLK_24M; 
assign                             m6_camera_xclk = CLK_24M; 
assign                             m7_camera_xclk = CLK_24M; 
assign                             m8_camera_xclk = CLK_24M; 
//`ifdef simulate
//assign                             m3_camera_xclk = CLK_24M; 
//`endif
//-coms_m0                         
wire                               m0_camera_vsync_rst     ;
wire [31: 0]                       m0_camera_wfifo_data    ;
wire                               m0_camera_wfifo_req     ;
wire [8:0]                         m0_reg_index            ;
wire [23:0]                        m0_lut_data             ;
wire                               m0_reg_conf_done        ;  
//-coms_m1                                                 
wire                               m1_camera_vsync_rst     ;
wire [31: 0]                       m1_camera_wfifo_data    ;
wire                               m1_camera_wfifo_req     ;
wire [8:0]                         m1_reg_index            ;
wire [23:0]                        m1_lut_data             ;
wire                               m1_reg_conf_done        ; 
//-coms_m2                                                 
wire                               m2_camera_vsync_rst     ;
wire [31: 0]                       m2_camera_wfifo_data    ;
wire                               m2_camera_wfifo_req     ;
wire [8:0]                         m2_reg_index            ;
wire [23:0]                        m2_lut_data             ;
wire                               m2_reg_conf_done        ;
//-coms_m3                                                 
wire                               m3_camera_vsync_rst     ;
wire [31: 0]                       m3_camera_wfifo_data    ;
wire                               m3_camera_wfifo_req     ;
wire [8:0]                         m3_reg_index            ;
wire [23:0]                        m3_lut_data             ;
wire                               m3_reg_conf_done        ;
//-coms_m4                                                
wire                               m4_camera_vsync_rst     ;
wire [31: 0]                       m4_camera_wfifo_data    ;
wire                               m4_camera_wfifo_req     ;
wire [8:0]                         m4_reg_index            ;
wire [23:0]                        m4_lut_data             ;
wire                               m4_reg_conf_done        ;
//-coms_m5                                                 
wire                               m5_camera_vsync_rst     ;
wire [31: 0]                       m5_camera_wfifo_data    ;
wire                               m5_camera_wfifo_req     ;
wire [8:0]                         m5_reg_index            ;
wire [23:0]                        m5_lut_data             ;
wire                               m5_reg_conf_done        ;
//-coms_m6                                                
wire                               m6_camera_vsync_rst     ;
wire [31: 0]                       m6_camera_wfifo_data    ;
wire                               m6_camera_wfifo_req     ;
wire [8:0]                         m6_reg_index            ;
wire [23:0]                        m6_lut_data             ;
wire                               m6_reg_conf_done        ;
//-coms_m7                                          
wire                               m7_camera_vsync_rst     ;
wire [31: 0]                       m7_camera_wfifo_data    ;
wire                               m7_camera_wfifo_req     ;
wire [8:0]                         m7_reg_index            ;
wire [23:0]                        m7_lut_data             ;
wire                               m7_reg_conf_done        ;
//-coms_m8                                                 
wire                               m8_camera_vsync_rst     ;
wire [31: 0]                       m8_camera_wfifo_data    ;
wire                               m8_camera_wfifo_req     ;
wire [8:0]                         m8_reg_index            ;
wire [23:0]                        m8_lut_data             ;
wire                               m8_reg_conf_done        ;
//----------------------------------------------------------
//-slave_arbitrate_interface-
//----------------------------------------------------------
wire [9:0]                         arbitrate_valid         ;
//slave0                                                   
wire                               slave0_req              ;
wire [24:0]                        slave0_waddr            ;
wire [9 :0]                        slave0_Wlen             ;
wire [31:0]                        slave0_data             ;
wire                               slave0_ren              ;
//slave1                                                   
wire                               slave1_req              ;
wire [24:0]                        slave1_waddr            ;
wire [9 :0]                        slave1_Wlen             ;
wire [31:0]                        slave1_data             ;
wire                               slave1_ren              ;
//slave2                                                   
wire                               slave2_req              ;
wire [24:0]                        slave2_waddr            ;
wire [9 :0]                        slave2_Wlen             ;
wire [31:0]                        slave2_data             ;
wire                               slave2_ren              ;
//slave3                                                   
wire                               slave3_req              ;
wire [24:0]                        slave3_waddr            ;
wire [9 :0]                        slave3_Wlen             ;
wire [31:0]                        slave3_data             ;
wire                               slave3_ren              ;
//slave4                                                   
wire                               slave4_req              ;
wire [24:0]                        slave4_waddr            ;
wire [9 :0]                        slave4_Wlen             ;
wire [31:0]                        slave4_data             ;
wire                               slave4_ren              ;
//slave5                                                   
wire                               slave5_req              ;
wire [24:0]                        slave5_waddr            ;
wire [9 :0]                        slave5_Wlen             ;
wire [31:0]                        slave5_data             ;
wire                               slave5_ren              ;
//slave6                                                 
wire                               slave6_req              ;
wire [24:0]                        slave6_waddr            ;
wire [9 :0]                        slave6_Wlen             ;
wire [31:0]                        slave6_data             ;
wire                               slave6_ren              ;
//slave7                                           
wire                               slave7_req              ;
wire [24:0]                        slave7_waddr            ;
wire [9 :0]                        slave7_Wlen             ;
wire [31:0]                        slave7_data             ;
wire                               slave7_ren              ;
//slave8                                                   
wire                               slave8_req              ;
wire [24:0]                        slave8_waddr            ;
wire [9 :0]                        slave8_Wlen             ;
wire [31:0]                        slave8_data             ;
wire                               slave8_ren              ;
//sel                                                   
wire                               slave_sel_req            ;
wire [24:0]                        slave_sel_waddr          ;
wire [9 :0]                        slave_sel_Wlen           ;
wire [31:0]                        slave_sel_data           ;
wire                               slave_sel_ren            ;
//----------------------------------------------------------
//-ddr_wr_ctrl- 控制端
//----------------------------------------------------------
//arbitrate to ddr 
wire [24:0]                        arb_wddr_addr           ;
wire [9: 0]                        arb_wddr_len            ;
wire                               mem_wen                 ;
wire                               mem_wen_valid           ;
wire                               wr_burst_data_req       ;
wire [31:0]                        wr_burst_data           ;
wire                               wr_burst_finish         ;
//ddr_wdisplayfifo to ddr
wire [24:0]                        aribitrate_rddr_addr    ;
wire [9 : 0 ]                      rd_len                  ;
wire                               mem_ren                 ;
wire                               mem_ren_valid           ;    
wire                               rd_burst_data_valid     ;
wire [31:0]                        rd_burst_data           ;
wire                               rd_burst_finish         ;
//----------------------------------------------------------
// bank_switch_ctrl
//----------------------------------------------------------
//-slave m0
wire                               slave0_wr_load          ;
wire  [1:0]                        slave0_wr_bank          ;
wire                               slave0_rd_load          ;
wire  [1:0]                        slave0_rd_bank          ;
wire                               slave0_frame_rd_done    ;
wire                               slave0_frame_wr_done    ;
//-slave m1                        
wire                               slave1_wr_load          ;
wire  [1:0]                        slave1_wr_bank          ;
wire                               slave1_rd_load          ;
wire  [1:0]                        slave1_rd_bank          ;
wire                               slave1_frame_rd_done    ;
wire                               slave1_frame_wr_done    ;
//-slave m2                        
wire                               slave2_wr_load          ;
wire  [1:0]                        slave2_wr_bank          ;
wire                               slave2_rd_load          ;
wire  [1:0]                        slave2_rd_bank          ;
wire                               slave2_frame_rd_done    ;
wire                               slave2_frame_wr_done    ;
//-slave m3                        
wire                               slave3_wr_load          ;
wire  [1:0]                        slave3_wr_bank          ;
wire                               slave3_rd_load          ;
wire  [1:0]                        slave3_rd_bank          ;
wire                               slave3_frame_rd_done    ;
wire                               slave3_frame_wr_done    ;
//-slave m4                       
wire                               slave4_wr_load          ;
wire  [1:0]                        slave4_wr_bank          ;
wire                               slave4_rd_load          ;
wire  [1:0]                        slave4_rd_bank          ;
wire                               slave4_frame_rd_done    ;
wire                               slave4_frame_wr_done    ;
//-slave m5                        
wire                               slave5_wr_load          ;
wire  [1:0]                        slave5_wr_bank          ;
wire                               slave5_rd_load          ;
wire  [1:0]                        slave5_rd_bank          ;
wire                               slave5_frame_rd_done    ;
wire                               slave5_frame_wr_done    ;
//-slave m6                     
wire                               slave6_wr_load          ;
wire  [1:0]                        slave6_wr_bank          ;
wire                               slave6_rd_load          ;
wire  [1:0]                        slave6_rd_bank          ;
wire                               slave6_frame_rd_done    ;
wire                               slave6_frame_wr_done    ;
//-slave m7                     
wire                               slave7_wr_load          ;
wire  [1:0]                        slave7_wr_bank          ;
wire                               slave7_rd_load          ;
wire  [1:0]                        slave7_rd_bank          ;
wire                               slave7_frame_rd_done    ;
wire                               slave7_frame_wr_done    ;
//-slave m8                      
wire                               slave8_wr_load          ;
wire  [1:0]                        slave8_wr_bank          ;
wire                               slave8_rd_load          ;
wire  [1:0]                        slave8_rd_bank          ;
wire                               slave8_frame_rd_done    ;
wire                               slave8_frame_wr_done    ;

//----------------------------------------------------------
// ddr_wr_ctrl
//----------------------------------------------------------
wire [9:0]                         wr_burst_len            ;
wire [9:0]                         rd_burst_len            ;
wire                               wr_burst_req            ;
wire                               rd_burst_req            ;
//----------------------------------------------------------
// fifo 32-8
//----------------------------------------------------------
wire                               fifo_clearn             ;
//dirs fifo
wire                               w_vga_fifo_clk          ;
wire                               w_vga_fifo_en           ;
wire [31 :0 ]                      w_vga_fifo_data         ;
//eth fifo 
wire                               w_eth_fifo_clk          ;
wire                               w_eth_fifo_en           ;
wire [31 :0 ]                      w_eth_fifo_data         ;
//DDR_state flag
wire                               ddr_ready               ;
// wire [10:0]FIFO_LEN_0;   32-32 fifo
wire [8:0]                         fifo_len_display        ;   
//----------------------------------------------------------
// arbitrate_ctrl_rd_ddr
//----------------------------------------------------------
wire [5:0]                         Rslave_valid            ;
//----------------------------------------------------------
// DDR_RD_SLAVE 0
//----------------------------------------------------------
wire                               Rslave0_req             ;
wire [24: 0]                       Rslave0_Raddr           ;
wire [9 : 0]                       Rslave0_Rlen            ;
wire [31: 0]                       Rslave0_data            ;
wire                               Rslave0_wen             ;
//----------------------------------------------------------
// DDR_RD_SLAVE 1
//----------------------------------------------------------
wire                               Rslave1_req             ;
wire [24: 0]                       Rslave1_Raddr           ;
wire [9 : 0]                       Rslave1_Rlen            ;
wire [31: 0]                       Rslave1_data            ;
wire                               Rslave1_wen             ;
//----------------------------------------------------------
// DDR_RD_SLAVE 2
//----------------------------------------------------------
wire                               Rslave2_req             ;
wire [24: 0]                       Rslave2_Raddr           ;
wire [9 : 0]                       Rslave2_Rlen            ;
wire [31: 0]                       Rslave2_data            ;
wire                               Rslave2_wen             ;
//----------------------------------------------------------
// display 
//----------------------------------------------------------
wire [3:0]                         read_channal            ;
wire                               frame_wr_done           ;
wire                               display_rfifo_en        ;
wire                               fifo_dis_full           ;
wire                               fifo_dis_empty          ;        
wire [7:0]                         display_rfifo_data      ;
wire                               vga_clk                 ;   
//----------------------------------------------------------
// eth 
//----------------------------------------------------------
wire                               eth_slave0_rd_load      ;
wire  [1:0]                        eth_slave0_rd_bank      ;
wire                               eth_slave1_rd_load      ;
wire  [1:0]                        eth_slave1_rd_bank      ;
wire                               eth_slave2_rd_load      ;
wire  [1:0]                        eth_slave2_rd_bank      ;
wire                               eth_slave3_rd_load      ;
wire  [1:0]                        eth_slave3_rd_bank      ;
wire                               eth_slave4_rd_load      ;
wire  [1:0]                        eth_slave4_rd_bank      ;
wire                               eth_slave5_rd_load      ;
wire  [1:0]                        eth_slave5_rd_bank      ;
wire                               eth_slave6_rd_load      ;
wire  [1:0]                        eth_slave6_rd_bank      ;
wire                               eth_slave7_rd_load      ;
wire  [1:0]                        eth_slave7_rd_bank      ;
wire                               eth_slave8_rd_load      ;
wire  [1:0]                        eth_slave8_rd_bank      ;


wire [3:0]                         eth_read_channal      ;
wire                               w_transfer_single_flag;
wire                               w_transfer_all_flag   ;
wire                               w_gmii_rec_clk        ;
wire                               w_udp_rec_pkt_done    ;
wire                               w_udp_rec_data_valid  ;
wire [ 7: 0]                       w_udp_rec_data        ;
wire [15: 0]                       w_udp_rec_byte_num    ;
wire                               w_gmii_tx_clk         ;
wire                               w_udp_tx_pkt_done     ;
wire                               w_tx_start_en         ;
wire                               w_fifo_data_req       ;
wire [31: 0]                       w_tx_data             ;
wire [15: 0]                       w_tx_byte_num         ;
//----------------------------------------------------------
// sel_bank 
//----------------------------------------------------------
wire                               eth_slave_sel_rd_load ; 
wire [1:0]                         eth_slave_sel_rd_bank ;
//----------------------------------------------------------
// sel_bank 
//----------------------------------------------------------
wire                               slave_sel_rd_load     ; 
wire [1:0]                         slave_sel_rd_bank     ;
//----------------------------------------------------------
// sd                                                     
//----------------------------------------------------------
wire                               w_slave_sel_frame_done;         //DDR_CLK下的一帧图像传输完成
wire                               w_cmos_sel_channal_sw ;         //用于传输一帧图像至SD卡所在的DDR区域
wire                               pos_vsync             ;
wire                               w_rdsd_fifo_clk       ;
wire                               w_rdsd_fifo_dv        ;
wire  [15:0]                       w_rdsd_fifo_data      ;
wire                               w_wrsd_fifo_full_flag ;
wire                               w_rdsd_fifo_full_flag ;
wire  [9:0]                        w_rdsd_fifo_len       ;
wire  [8:0]                        w_wrsd_fifo_len       ;
wire                               w_wrsd_fifo_clk       ;
wire                               w_wrsd_fifo_dv        ;
wire [31:0]                        w_wrsd_fifo_data      ;
wire                               o_sd_save_key         ;
//----------------------------------------------------------
wire                               w_sd_cmos_sel_pclk    ;
wire [31: 0]                       w_sd_cmos_sel_data    ;
wire                               w_sd_cmos_sel_dreq    ;
wire                               w_sd_cmos_sel_vsync   ;
//----------------------------------------------------------
//eth cmos sel 
wire [3:0]                         w_eth_transfer_cmos_sel ;
wire                               w_eth_cmos_sel_pclk     ;
wire [31: 0]                       w_eth_cmos_sel_data     ;
wire                               w_eth_cmos_sel_dreq     ;
wire                               w_eth_cmos_sel_vsync    ;
//----------------------------------------------------------
// eth:ddr slave 2                                                  
//----------------------------------------------------------
wire                              w_transfer_all_frame_flag           ;
wire                              w_eth_single_frame_eth_done_valid   ;
wire                              w_eth_single_frame_eth_done_ready   ;
wire                              w_eth_single_frame_eth_done         ;  
wire                              w_frame_transfer_done               ;
wire [10:0]                       eth_fifo_wrusedw                    ;
wire                              eth_fifo_wrfull                     ;
wire                              w_ddr_write_pre_first_flag_valid    ;
wire                              w_ddr_write_pre_first_flag_ready    ;
wire                              w_ddr_single_transfer_done          ;
wire                              all_frame_transfer_done             ;
wire                              w_gmii_tx_busy                      ;
//----------------------------------------------------------
// error flag
//----------------------------------------------------------
//wire                               mem_ren_fail            ; //读写冲突标志

wire                               show_state              ;
//00000000000000000000000000000000未整理
reg r_slave_sel_frame_done_sdclk_d0,r_slave_sel_frame_done_sdclk_d1;
wire pos_slave_sel_frame_done_sdlck;
//----------------------------------------------------------
//debounce_sd_save_key 
//----------------------------------------------------------
debounce 
#( .hold_time (2_000_000))
debounce_sd_save_key
(
    .clk                      (ddr_clk              ),
    .rst_n                    (rst_n                ),
    .signal_i                 (i_sd_save_key        ),
    .signal_o                 (o_sd_save_key        )
);
// 用于开关SD的存储数据通道 
vsync_pos_switch sd_channal_sw(
    .i_ddr_clk                (ddr_clk              ),
    .i_rst_n                  (rst_n                ),
    .i_sd_save_key            (o_sd_save_key        ),
    .i_sel_vsync              (w_sd_cmos_sel_vsync  ),
    .o_cmos_sel_channal_sw    (w_cmos_sel_channal_sw)
);
//----------------------------------------------------------
//----Camera----config----sellect 
//----------------------------------------------------------
camera_config_sel u_camera_config_sel(
//-camera_slave 0 
    .slave0_reg_index         (m0_reg_index        ),
    .slave0_lut_data          (m0_lut_data         ),
    .slave0_config_done       (m0_reg_conf_done    ),
//-camera_slave 1
    .slave1_reg_index         (m1_reg_index        ),
    .slave1_lut_data          (m1_lut_data         ),
    .slave1_config_done       (m1_reg_conf_done    ),
//-camera_slave 2 
    .slave2_reg_index         (m2_reg_index        ),
    .slave2_lut_data          (m2_lut_data         ),
    .slave2_config_done       (m2_reg_conf_done    ),
//-camera_slave 3
    .slave3_reg_index         (m3_reg_index        ),
    .slave3_lut_data          (m3_lut_data         ),
    .slave3_config_done       (m3_reg_conf_done    ),
//-camera_slave 4
    .slave4_reg_index         (m4_reg_index        ),
    .slave4_lut_data          (m4_lut_data         ),
    .slave4_config_done       (m4_reg_conf_done    ),
//-camera_slave 5
    .slave5_reg_index         (m5_reg_index        ),
    .slave5_lut_data          (m5_lut_data         ),
    .slave5_config_done       (m5_reg_conf_done    ),
//-camera_slave 6
    .slave6_reg_index         (m6_reg_index        ),
    .slave6_lut_data          (m6_lut_data         ),
    .slave6_config_done       (m6_reg_conf_done    ),
//-camera_slave 7
    .slave7_reg_index         (m7_reg_index        ),
    .slave7_lut_data          (m7_lut_data         ),
    .slave7_config_done       (m7_reg_conf_done    ),
//-camera_slave 8
    .slave8_reg_index         (m8_reg_index        ),
    .slave8_lut_data          (m8_lut_data         ),
    .slave8_config_done       (m8_reg_conf_done    )
);
//----------------------------------------------------------
//M0----Camera-fifo-interface-arbitrate_ctrl
//----------------------------------------------------------
camera_ov9281 camera_m0
(
    .CLK_24M                    (CLK_24M             ),                //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281 
    .o_reg_index                (m0_reg_index        ),
    .i_lut_data                 (m0_lut_data         ),
    .reg_conf_done              (m0_reg_conf_done    ),    
    .i2c_sclk                   (m0_i2c_sclk         ),
    .i2c_sdat                   (m0_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m0_camera_pwdn      ),
    .camera_vsync_rst           (m0_camera_vsync_rst ),   

    .camera_data                (m0_camera_data      ),             //ov9281 write fifo32/32
    .camera_pclk                (m0_camera_pclk      ),
    .camera_href                (m0_camera_href      ),
    .camera_vsync               (m0_camera_vsync     ),
    
//    .camera_init_done           (                     ),
    .camera_wfifo_req           (m0_camera_wfifo_req  ),
    .camera_wfifo_data          (m0_camera_wfifo_data )
);
fifo_32w32r fifo_camera_m0
(
    .aclr                       (m0_camera_vsync_rst ),
	.data                       (m0_camera_wfifo_data),
	.wrclk                      (m0_camera_pclk      ),
	.wrreq                      (m0_camera_wfifo_req ),
	.rdclk                      (ddr_clk             ),// change
	.rdreq                      (slave0_ren          ),// change
	.q                          (slave0_data         ),// change
	.rdempty                    (FIFO_m0_EMPTY       ),
	.rdfull                     (FIFO_m0_FULL        ),
	.rdusedw                    (FIFO_m0_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0000),
    .MAXADDR                    (addr_max)
)slave_m0
(   
    .ddr_clk                    (ddr_clk             ),
    .sys_rstn                   (rst_n               ),
//-----------------------------------------------------
    .camera_vsync_neg           (m0_camera_vsync_rst ),   
    .fifo_full_flag             (FIFO_m0_FULL        ),
    .fifo_empty_flag            (FIFO_m0_EMPTY       ),
    .fifo_len                   (FIFO_m0_LEN         ),
    .slave_req                  (slave0_req          ),
    .arbitrate_valid            (arbitrate_valid[0]  ),
    .slave_wr_load              (slave0_wr_load      ), //暂时未用
    .slave_wrbank               (slave0_wr_bank      ),
    .slave_waddr                (slave0_waddr        ),
    .slave_wburst_len           (slave0_Wlen         )
    );
//--------------------------------------------------
//M1----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m1
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                               
    .o_reg_index                (m1_reg_index        ),
    .i_lut_data                 (m1_lut_data         ),
    .reg_conf_done              (m1_reg_conf_done    ), 
    .i2c_sclk                   (m1_i2c_sclk         ),
    .i2c_sdat                   (m1_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m1_camera_pwdn      ),
    .camera_vsync_rst           (m1_camera_vsync_rst ),
    
    .camera_data                (m1_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m1_camera_pclk      ),
    .camera_href                (m1_camera_href      ),
    .camera_vsync               (m1_camera_vsync     ),
    
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m1_camera_wfifo_req ),
    .camera_wfifo_data          (m1_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m1
(
    .aclr                       (m1_camera_vsync_rst ),
	.data                       (m1_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave1_ren          ),
	.wrclk                      (m1_camera_pclk      ),
	.wrreq                      (m1_camera_wfifo_req ),
	.q                          (slave1_data         ),           
	.rdempty                    (FIFO_m1_EMPTY       ),           
	.rdfull                     (FIFO_m1_FULL        ),           
	.rdusedw                    (FIFO_m1_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0001),
    .MAXADDR                    (addr_max)
)slave_m1
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//-----------------------------------------------------
    .camera_vsync_neg           (m1_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m1_FULL       ),
    .fifo_empty_flag            (FIFO_m1_EMPTY      ),
    .fifo_len                   (FIFO_m1_LEN        ),
    .slave_req                  (slave1_req         ),
    .arbitrate_valid            (arbitrate_valid[1] ),
    .slave_wr_load              (slave1_wr_load     ), //暂时未用
    .slave_wrbank               (slave1_wr_bank     ),
    .slave_waddr                (slave1_waddr       ),
    .slave_wburst_len           (slave1_Wlen        )
);
//--------------------------------------------------
//M2----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m2
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281              
    .o_reg_index                (m2_reg_index        ),
    .i_lut_data                 (m2_lut_data         ),
    .reg_conf_done              (m2_reg_conf_done    ),     
    .i2c_sclk                   (m2_i2c_sclk         ),
    .i2c_sdat                   (m2_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m2_camera_pwdn      ),
    .camera_vsync_rst           (m2_camera_vsync_rst ),
    .camera_data                (m2_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m2_camera_pclk      ),
    .camera_href                (m2_camera_href      ),
    .camera_vsync               (m2_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m2_camera_wfifo_req ),
    .camera_wfifo_data          (m2_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m2
(
    .aclr                       (m2_camera_vsync_rst ),
	.data                       (m2_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave2_ren          ),
	.wrclk                      (m2_camera_pclk      ),
	.wrreq                      (m2_camera_wfifo_req ),
	.q                          (slave2_data         ),           
	.rdempty                    (FIFO_m2_EMPTY       ),           
	.rdfull                     (FIFO_m2_FULL        ),           
	.rdusedw                    (FIFO_m2_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0010),
    .MAXADDR                    (addr_max)
)slave_m2
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//-----------------------------------------------------
    .camera_vsync_neg           (m2_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m2_FULL       ),
    .fifo_empty_flag            (FIFO_m2_EMPTY      ),
    .fifo_len                   (FIFO_m2_LEN        ),
    .slave_req                  (slave2_req         ),
    .arbitrate_valid            (arbitrate_valid[2] ),
    .slave_wr_load              (slave2_wr_load     ), //暂时未用
    .slave_wrbank               (slave2_wr_bank     ),
    .slave_waddr                (slave2_waddr       ),
    .slave_wburst_len           (slave2_Wlen        )
);

//--------------------------------------------------
//M3----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m3
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                  
    .o_reg_index                (m3_reg_index        ),
    .i_lut_data                 (m3_lut_data         ),
    .reg_conf_done              (m3_reg_conf_done    ),     
    .i2c_sclk                   (m3_i2c_sclk         ),
    .i2c_sdat                   (m3_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m3_camera_pwdn      ),
    .camera_vsync_rst           (m3_camera_vsync_rst ),
    .camera_data                (m3_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m3_camera_pclk      ),
    .camera_href                (m3_camera_href      ),
    .camera_vsync               (m3_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m3_camera_wfifo_req ),
    .camera_wfifo_data          (m3_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m3
(
    .aclr                       (m3_camera_vsync_rst ),
	.data                       (m3_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave3_ren          ),
	.wrclk                      (m3_camera_pclk      ),
	.wrreq                      (m3_camera_wfifo_req ),
	.q                          (slave3_data         ),           
	.rdempty                    (FIFO_m3_EMPTY       ),           
	.rdfull                     (FIFO_m3_FULL        ),           
	.rdusedw                    (FIFO_m3_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0011),
    .MAXADDR                    (addr_max)
)slave_m3
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//-----------------------------------------------------
    .camera_vsync_neg           (m3_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m3_FULL       ),
    .fifo_empty_flag            (FIFO_m3_EMPTY      ),
    .fifo_len                   (FIFO_m3_LEN        ),
    .slave_req                  (slave3_req         ),
    .arbitrate_valid            (arbitrate_valid[3] ),
    .slave_wr_load              (slave3_wr_load     ), //暂时未用
    .slave_wrbank               (slave3_wr_bank     ),
    .slave_waddr                (slave3_waddr       ),
    .slave_wburst_len           (slave3_Wlen        )
);
//--------------------------------------------------
//M4----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m4
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281     
    .o_reg_index                (m4_reg_index        ),
    .i_lut_data                 (m4_lut_data         ),
    .reg_conf_done              (m4_reg_conf_done    ),     
    .i2c_sclk                   (m4_i2c_sclk         ),
    .i2c_sdat                   (m4_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m4_camera_pwdn      ),
    .camera_vsync_rst           (m4_camera_vsync_rst ),
    .camera_data                (m4_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m4_camera_pclk      ),
    .camera_href                (m4_camera_href      ),
    .camera_vsync               (m4_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m4_camera_wfifo_req ),
    .camera_wfifo_data          (m4_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m4
(
    .aclr                       (m4_camera_vsync_rst ),
	.data                       (m4_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave4_ren          ),
	.wrclk                      (m4_camera_pclk      ),
	.wrreq                      (m4_camera_wfifo_req ),
	.q                          (slave4_data         ),           
	.rdempty                    (FIFO_m4_EMPTY       ),           
	.rdfull                     (FIFO_m4_FULL        ),           
	.rdusedw                    (FIFO_m4_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0100),
    .MAXADDR                    (addr_max)
)slave_m4
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//----------------------------------------------------
    .camera_vsync_neg           (m4_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m4_FULL       ),
    .fifo_empty_flag            (FIFO_m4_EMPTY      ),
    .fifo_len                   (FIFO_m4_LEN        ),
    .slave_req                  (slave4_req         ),
    .arbitrate_valid            (arbitrate_valid[4] ),
    .slave_wr_load              (slave4_wr_load     ), //暂时未用
    .slave_wrbank               (slave4_wr_bank     ),
    .slave_waddr                (slave4_waddr       ),
    .slave_wburst_len           (slave4_Wlen        )
);
//--------------------------------------------------
//M5----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m5
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                
    .o_reg_index                (m5_reg_index        ),
    .i_lut_data                 (m5_lut_data         ),
    .reg_conf_done              (m5_reg_conf_done    ),     
    .i2c_sclk                   (m5_i2c_sclk         ),
    .i2c_sdat                   (m5_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m5_camera_pwdn      ),
    .camera_vsync_rst           (m5_camera_vsync_rst ),
    .camera_data                (m5_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m5_camera_pclk      ),
    .camera_href                (m5_camera_href      ),
    .camera_vsync               (m5_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m5_camera_wfifo_req ),
    .camera_wfifo_data          (m5_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m5
(
    .aclr                       (m5_camera_vsync_rst ),
	.data                       (m5_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave5_ren          ),
	.wrclk                      (m5_camera_pclk      ),
	.wrreq                      (m5_camera_wfifo_req ),
	.q                          (slave5_data         ),           
	.rdempty                    (FIFO_m5_EMPTY       ),           
	.rdfull                     (FIFO_m5_FULL        ),           
	.rdusedw                    (FIFO_m5_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0101            ),
    .MAXADDR                    (addr_max           )
)slave_m5
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//----------------------------------------------------
    .camera_vsync_neg           (m5_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m5_FULL       ),
    .fifo_empty_flag            (FIFO_m5_EMPTY      ),
    .fifo_len                   (FIFO_m5_LEN        ),
    .slave_req                  (slave5_req         ),
    .arbitrate_valid            (arbitrate_valid[5] ),
    .slave_wr_load              (slave5_wr_load     ), //暂时未用
    .slave_wrbank               (slave5_wr_bank     ),
    .slave_waddr                (slave5_waddr       ),
    .slave_wburst_len           (slave5_Wlen        )
);

//--------------------------------------------------
//M6----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m6
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281             
    .o_reg_index                (m6_reg_index        ),
    .i_lut_data                 (m6_lut_data         ),
    .reg_conf_done              (m6_reg_conf_done    ),     
    .i2c_sclk                   (m6_i2c_sclk         ),
    .i2c_sdat                   (m6_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m6_camera_pwdn      ),
    .camera_vsync_rst           (m6_camera_vsync_rst ),
    .camera_data                (m6_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m6_camera_pclk      ),
    .camera_href                (m6_camera_href      ),
    .camera_vsync               (m6_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m6_camera_wfifo_req ),
    .camera_wfifo_data          (m6_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m6
(
    .aclr                       (m6_camera_vsync_rst ),
	.data                       (m6_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave6_ren          ),
	.wrclk                      (m6_camera_pclk      ),
	.wrreq                      (m6_camera_wfifo_req ),
	.q                          (slave6_data         ),           
	.rdempty                    (FIFO_m6_EMPTY       ),           
	.rdfull                     (FIFO_m6_FULL        ),           
	.rdusedw                    (FIFO_m6_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0110            ),
    .MAXADDR                    (addr_max           )
)slave_m6
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//--------------------------------------------------- 
    .camera_vsync_neg           (m6_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m6_FULL       ),
    .fifo_empty_flag            (FIFO_m6_EMPTY      ),
    .fifo_len                   (FIFO_m6_LEN        ),
    .slave_req                  (slave6_req         ),
    .arbitrate_valid            (arbitrate_valid[6] ),
    .slave_wr_load              (slave6_wr_load     ), //暂时未用
    .slave_wrbank               (slave6_wr_bank     ),
    .slave_waddr                (slave6_waddr       ),
    .slave_wburst_len           (slave6_Wlen        )
);


//--------------------------------------------------
//M7----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m7
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                                      
    .o_reg_index                (m7_reg_index        ),
    .i_lut_data                 (m7_lut_data         ),
    .reg_conf_done              (m7_reg_conf_done    ),     
    .i2c_sclk                   (m7_i2c_sclk         ),
    .i2c_sdat                   (m7_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m7_camera_pwdn      ),
    .camera_vsync_rst           (m7_camera_vsync_rst ),
    .camera_data                (m7_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m7_camera_pclk      ),
    .camera_href                (m7_camera_href      ),
    .camera_vsync               (m7_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m7_camera_wfifo_req ),
    .camera_wfifo_data          (m7_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m7
(
    .aclr                       (m7_camera_vsync_rst ),
	.data                       (m7_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave7_ren          ),
	.wrclk                      (m7_camera_pclk      ),
	.wrreq                      (m7_camera_wfifo_req ),
	.q                          (slave7_data         ),           
	.rdempty                    (FIFO_m7_EMPTY       ),           
	.rdfull                     (FIFO_m7_FULL        ),           
	.rdusedw                    (FIFO_m7_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b0111            ),
    .MAXADDR                    (addr_max           )
)slave_m7
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//----------------------------------------------------
    .camera_vsync_neg           (m7_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m7_FULL       ),
    .fifo_empty_flag            (FIFO_m7_EMPTY      ),
    .fifo_len                   (FIFO_m7_LEN        ),
    .slave_req                  (slave7_req         ),
    .arbitrate_valid            (arbitrate_valid[7] ),
    .slave_wr_load              (slave7_wr_load     ), //暂时未用
    .slave_wrbank               (slave7_wr_bank     ),
    .slave_waddr                (slave7_waddr       ),
    .slave_wburst_len           (slave7_Wlen        )
);

//--------------------------------------------------
//M8----Camera-fifo-interface-arbitrate_ctrl
//--------------------------------------------------
camera_ov9281 camera_m8
(
    .CLK_24M                    (CLK_24M             ), //24mhz
    .CLK_20K                    (CLK_20K             ),
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                            
    .o_reg_index                (m8_reg_index        ),
    .i_lut_data                 (m8_lut_data         ),
    .reg_conf_done              (m8_reg_conf_done    ),     
    .i2c_sclk                   (m8_i2c_sclk         ),
    .i2c_sdat                   (m8_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m8_camera_pwdn      ),
    .camera_vsync_rst           (m8_camera_vsync_rst ),
    .camera_data                (m8_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m8_camera_pclk      ),
    .camera_href                (m8_camera_href      ),
    .camera_vsync               (m8_camera_vsync     ),
//    .camera_init_done           (                    ),
    .camera_wfifo_req           (m8_camera_wfifo_req ),
    .camera_wfifo_data          (m8_camera_wfifo_data)
);
//wire sw_req_m1;
//assign sw_req_m1 = show_state ? m1_camera_wfifo_req :1'b0;
fifo_32w32r fifo_camera_m8
(
    .aclr                       (m8_camera_vsync_rst ),
	.data                       (m8_camera_wfifo_data),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave8_ren          ),
	.wrclk                      (m8_camera_pclk      ),
	.wrreq                      (m8_camera_wfifo_req ),
	.q                          (slave8_data         ),           
	.rdempty                    (FIFO_m8_EMPTY       ),           
	.rdfull                     (FIFO_m8_FULL        ),           
	.rdusedw                    (FIFO_m8_LEN         )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (4'b1000            ),
    .MAXADDR                    (addr_max           )
)slave_m8
(   
    .ddr_clk                    (ddr_clk            ),
    .sys_rstn                   (rst_n              ),
//----------------------------------------------------
    .camera_vsync_neg           (m8_camera_vsync_rst),   
    .fifo_full_flag             (FIFO_m8_FULL       ),
    .fifo_empty_flag            (FIFO_m8_EMPTY      ),
    .fifo_len                   (FIFO_m8_LEN        ),
    .slave_req                  (slave8_req         ),
    .arbitrate_valid            (arbitrate_valid[8] ),
    .slave_wr_load              (slave8_wr_load     ), //暂时未用
    .slave_wrbank               (slave8_wr_bank     ),
    .slave_waddr                (slave8_waddr       ),
    .slave_wburst_len           (slave8_Wlen        )
);

//--------------------------------------------------------------------------------//         
// SD_WR_DDR SELLECT                                                                           
//--------------------------------------------------------------------------------//  
cmos_switch_mould   //FOR SD                                   
#(                                                             
    .cmos_num (4'd3 )                                          
)cmos_sd_sel(                                                  
    .i_sel_channal_sw    (w_cmos_sel_channal_sw  ),                     
    .i_eth_cmos_sel      (read_channal           ),            
    //----------------------------------------------------//
    // cmos_port_0
    //----------------------------------------------------//
    .i_cmos0_pclk        (m0_camera_pclk         ),
    .i_cmos0_data        (m0_camera_wfifo_data   ),
    .i_cmos0_dreq        (m0_camera_wfifo_req    ),
    .i_cmos0_vsync       (m0_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_1
    //----------------------------------------------------//
    .i_cmos1_pclk        (m1_camera_pclk         ), 
    .i_cmos1_data        (m1_camera_wfifo_data   ), 
    .i_cmos1_dreq        (m1_camera_wfifo_req    ), 
    .i_cmos1_vsync       (m1_camera_vsync        ), 
    //----------------------------------------------------//
    // cmos_port_2
    //----------------------------------------------------//
    .i_cmos2_pclk        (m2_camera_pclk         ),
    .i_cmos2_data        (m2_camera_wfifo_data   ),
    .i_cmos2_dreq        (m2_camera_wfifo_req    ),
    .i_cmos2_vsync       (m2_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_3
    //----------------------------------------------------//
    .i_cmos3_pclk        (m3_camera_pclk         ),
    .i_cmos3_data        (m3_camera_wfifo_data   ),
    .i_cmos3_dreq        (m3_camera_wfifo_req    ),
    .i_cmos3_vsync       (m3_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_4
    //----------------------------------------------------//
    .i_cmos4_pclk        (m4_camera_pclk         ),
    .i_cmos4_data        (m4_camera_wfifo_data   ),
    .i_cmos4_dreq        (m4_camera_wfifo_req    ),
    .i_cmos4_vsync       (m4_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_5
    //----------------------------------------------------//
    .i_cmos5_pclk        (m5_camera_pclk         ),
    .i_cmos5_data        (m5_camera_wfifo_data   ),
    .i_cmos5_dreq        (m5_camera_wfifo_req    ),
    .i_cmos5_vsync       (m5_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_6
    //----------------------------------------------------//
    .i_cmos6_pclk        (m6_camera_pclk         ),
    .i_cmos6_data        (m6_camera_wfifo_data   ),
    .i_cmos6_dreq        (m6_camera_wfifo_req    ),
    .i_cmos6_vsync       (m6_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_7
    //----------------------------------------------------//
    .i_cmos7_pclk        (m7_camera_pclk         ),
    .i_cmos7_data        (m7_camera_wfifo_data   ),
    .i_cmos7_dreq        (m7_camera_wfifo_req    ),
    .i_cmos7_vsync       (m7_camera_vsync        ),
    //----------------------------------------------------//
    // cmos_port_8
    //----------------------------------------------------//
    .i_cmos8_pclk        (m8_camera_pclk         ),
    .i_cmos8_data        (m8_camera_wfifo_data   ),
    .i_cmos8_dreq        (m8_camera_wfifo_req    ),
    .i_cmos8_vsync       (m8_camera_vsync        ),
    //----------------------------------------------------//   
    // cmos_port_sel                                           
    //----------------------------------------------------//   
    .o_cmos_sel_pclk     (w_sd_cmos_sel_pclk     ),            
    .o_cmos_sel_data     (w_sd_cmos_sel_data     ),            
    .o_cmos_sel_dreq     (w_sd_cmos_sel_dreq     ),            
    .o_cmos_sel_vsync    (w_sd_cmos_sel_vsync    )             
);
//--------------------------------------------------------------------------------//         
// SD_WR_DDR SELLECT  的测试模块 从该模块写出的是完整的图像数据                                                                         
//--------------------------------------------------------------------------------// 
// reg [24:0]r_cnt_sd_sel_num; 
//always @(posedge w_sd_cmos_sel_pclk or negedge rst_n) begin  
//    if(!rst_n) begin                                
//        r_cnt_sd_sel_num <= 25'b0;                                            
//    end                                             
//    else if(w_sd_cmos_sel_vsync)begin                                      
//        r_cnt_sd_sel_num <= 25'b0;                 
//    end  
//    else if(w_sd_cmos_sel_dreq)begin                                      
//        r_cnt_sd_sel_num <= r_cnt_sd_sel_num + 25'd1;                 
//    end   
//    else begin 
//        r_cnt_sd_sel_num <= r_cnt_sd_sel_num ;      
//    end 
//end 

//cmos 传输速率远远快于 SD卡所能存储的速率 ，尝试提高SD的参考频率， 如果不行，需要DDR作为中间的转存的媒介
//测试，SD卡速率太低，不满足要求，用DDR作为缓存
//对于筛选出的数据流，进行传输至DDR中，走SLAVE_ARBITRATE_INTERFACE

assign pos_vsync = ~img_vsync_d1 & img_vsync_d0;     //例化成模块
always @(posedge sd_clk25m or negedge rst_n) begin   //例化成模块
    if(!rst_n) begin                                 //例化成模块
        img_vsync_d0 <= 1'b0;                        //例化成模块
        img_vsync_d1 <= 1'b0;                        //例化成模块
    end                                              //例化成模块
    else begin                                       //例化成模块
        img_vsync_d0 <= w_sd_cmos_sel_vsync;         //例化成模块
        img_vsync_d1 <= img_vsync_d0;                //例化成模块
    end                                              //例化成模块
end                                                  //例化成模块
//--------------------------------------------------------------------------------//         
// SD_WR_DDR SELLECT     FIFO                                                                        
//--------------------------------------------------------------------------------//  
fifo_32w32r fifo_camera_sel_sd 
(
    .aclr                       (pos_vsync           ),
	.data                       (w_sd_cmos_sel_data  ),
	.rdclk                      (ddr_clk             ),
	.rdreq                      (slave_sel_ren       ),
	.wrclk                      (w_sd_cmos_sel_pclk  ),
	.wrreq                      (w_sd_cmos_sel_dreq  ),
	.q                          (slave_sel_data      ),           
	.rdempty                    (FIFO_sel_EMPTY      ),           
	.rdfull                     (FIFO_sel_FULL       ),           
	.rdusedw                    (FIFO_sel_LEN        )
);

slave_arbitrate_interface_sd
#(
    .SLAVE_NUMBER               (4'b1111               ),  //4bit 
    .PARAM_BIT                  (1'b1                  ),
    .MAXADDR                    (addr_max              )
)slave_sel_sd
(   
    .ddr_clk                    (ddr_clk               ),
    .sys_rstn                   (rst_n                 ),
    //fifo flag                               
    .camera_vsync_neg           (pos_vsync             ),   
    .fifo_full_flag             (FIFO_sel_FULL         ),
    .fifo_empty_flag            (FIFO_sel_EMPTY        ),
    .fifo_len                   (FIFO_sel_LEN          ),
    //req & valid                             
    .slave_req                  (slave_sel_req         ),
    .arbitrate_valid            (arbitrate_valid[9]    ),
    .slave_wr_load              (                      ), //对于SD卡存储DDR中 ，此时无BANK切换功能，仅在bank0工作
    .slave_wrbank               (                      ), //对于SD卡存储DDR中 ，此时无BANK切换功能，仅在bank0工作
    .slave_waddr                (slave_sel_waddr       ),
    .slave_wburst_len           (slave_sel_Wlen        ),
    .slave_frame_finished       (w_slave_sel_frame_done)  //表征SD存储一帧图像完成    
);
//--------------------------------------------------------------------------------//         
// arbitrate_ctrl               仲裁控制器 
//--------------------------------------------------------------------------------//  
arbitrate_ctrl  
#(
    .slave_num                  ( 4'd6 )
)arbitrate_ctrl_u0
(
    .ddr_clk                    (ddr_clk              ),
    .sys_rstn                   (rst_n                ),
//slave0
    .slave0_req                 (slave0_req           ),
    .slave0_Waddr               (slave0_waddr         ),
    .slave0_Wlen                (slave0_Wlen          ),
    .slave0_data                (slave0_data          ),
    .slave0_ren                 (slave0_ren           ),
//slave1
    .slave1_req                 (slave1_req           ),
    .slave1_Waddr               (slave1_waddr         ),
    .slave1_Wlen                (slave1_Wlen          ),
    .slave1_data                (slave1_data          ),
    .slave1_ren                 (slave1_ren           ),
//slave2
    .slave2_req                 (slave2_req           ),
    .slave2_Waddr               (slave2_waddr         ),
    .slave2_Wlen                (slave2_Wlen          ),
    .slave2_data                (slave2_data          ),
    .slave2_ren                 (slave2_ren           ),
//slave3
    .slave3_req                 (slave3_req           ),
    .slave3_Waddr               (slave3_waddr         ),
    .slave3_Wlen                (slave3_Wlen          ),
    .slave3_data                (slave3_data          ),
    .slave3_ren                 (slave3_ren           ),
//slave4                                              
    .slave4_req                 (slave4_req           ),
    .slave4_Waddr               (slave4_waddr         ),
    .slave4_Wlen                (slave4_Wlen          ),
    .slave4_data                (slave4_data          ),
    .slave4_ren                 (slave4_ren           ),
//slave5                                              
    .slave5_req                 (slave5_req           ),
    .slave5_Waddr               (slave5_waddr         ),
    .slave5_Wlen                (slave5_Wlen          ),
    .slave5_data                (slave5_data          ),
    .slave5_ren                 (slave5_ren           ),
//slave6
    .slave6_req                 (slave6_req           ),
    .slave6_Waddr               (slave6_waddr         ),
    .slave6_Wlen                (slave6_Wlen          ),
    .slave6_data                (slave6_data          ),
    .slave6_ren                 (slave6_ren           ),
//slave7                                             
    .slave7_req                 (slave7_req           ),
    .slave7_Waddr               (slave7_waddr         ),
    .slave7_Wlen                (slave7_Wlen          ),
    .slave7_data                (slave7_data          ),
    .slave7_ren                 (slave7_ren           ),
//slave8                                            
    .slave8_req                 (slave8_req           ),
    .slave8_Waddr               (slave8_waddr         ),
    .slave8_Wlen                (slave8_Wlen          ),
    .slave8_data                (slave8_data          ),
    .slave8_ren                 (slave8_ren           ),
//slave_Sd
    .slave_sd_req               (slave_sel_req        ),
    .slave_sd_Waddr             (slave_sel_waddr      ),
    .slave_sd_Wlen              (slave_sel_Wlen       ),
    .slave_sd_data              (slave_sel_data       ),
    .slave_sd_ren               (slave_sel_ren        ),
//--valid--
    .slave_valid                (arbitrate_valid      ),
    //from ddr_wr_crtl                                
    .ready                      (ddr_ready            ),
    .ddr_write_finish           (wr_burst_finish      ),
    //to ddr_wrctrl                                   
    .arb_wddr_addr              (arb_wddr_addr        ),
    .arb_wddr_len               (arb_wddr_len         ),
    .ddr_Rfifo_en               (wr_burst_data_req    ),
    .ddr_Rfifo_data             (wr_burst_data        ),
    .mem_wen                    (mem_wen              ),
    .mem_wen_valid              (mem_wen_valid        )
);
//--------------------------------------------------------------------------------//         
// bank_switch_ctrl               BANK反转控制器 
//--------------------------------------------------------------------------------//  
bank_switch_ctrl bank_switch_ctrl_u0
(
    .ddr_clk                    (ddr_clk              ),
    .sys_rstn                   (rst_n                ),
    //slave0_bank_switch                              
    .slave0_valid               (m0_camera_vsync      ),
    .slave0_frame_wr_done       (slave0_frame_wr_done ),
    .slave0_frame_rd_done       (slave0_frame_rd_done ),
    .slave0_wr_load             (slave0_wr_load       ),
    .slave0_wr_bank             (slave0_wr_bank       ),
    .slave0_rd_load             (slave0_rd_load       ),
    .slave0_rd_bank             (slave0_rd_bank       ),
    //slave1_bank_switch                              
    .slave1_valid               (m1_camera_vsync      ),
    .slave1_frame_wr_done       (slave1_frame_wr_done ),
    .slave1_frame_rd_done       (slave1_frame_rd_done ),
    .slave1_wr_load             (slave1_wr_load       ),
    .slave1_wr_bank             (slave1_wr_bank       ),
    .slave1_rd_load             (slave1_rd_load       ),
    .slave1_rd_bank             (slave1_rd_bank       ),
    //slave2_bank_switch                              
    .slave2_valid               (m2_camera_vsync      ),
    .slave2_frame_wr_done       (slave2_frame_wr_done ),
    .slave2_frame_rd_done       (slave2_frame_rd_done ),
    .slave2_wr_load             (slave2_wr_load       ),
    .slave2_wr_bank             (slave2_wr_bank       ),
    .slave2_rd_load             (slave2_rd_load       ),
    .slave2_rd_bank             (slave2_rd_bank       ),
    //slave3_bank_switch                              
    .slave3_valid               (m3_camera_vsync      ),
    .slave3_frame_wr_done       (slave3_frame_wr_done ),
    .slave3_frame_rd_done       (slave3_frame_rd_done ),
    .slave3_wr_load             (slave3_wr_load       ),
    .slave3_wr_bank             (slave3_wr_bank       ),
    .slave3_rd_load             (slave3_rd_load       ),
    .slave3_rd_bank             (slave3_rd_bank       ),
    //slave4_bank_switch
    .slave4_valid               (m4_camera_vsync      ),
    .slave4_frame_wr_done       (slave4_frame_wr_done ),
    .slave4_frame_rd_done       (slave4_frame_rd_done ),
    .slave4_wr_load             (slave4_wr_load       ),
    .slave4_wr_bank             (slave4_wr_bank       ),
    .slave4_rd_load             (slave4_rd_load       ),
    .slave4_rd_bank             (slave4_rd_bank       ), 
    //slave5_bank_switch
    .slave5_valid               (m5_camera_vsync      ),
    .slave5_frame_wr_done       (slave5_frame_wr_done ),
    .slave5_frame_rd_done       (slave5_frame_rd_done ),
    .slave5_wr_load             (slave5_wr_load       ),
    .slave5_wr_bank             (slave5_wr_bank       ),
    .slave5_rd_load             (slave5_rd_load       ),
    .slave5_rd_bank             (slave5_rd_bank       ),
    //slave3_bank_switch                              
    .slave6_valid               (m6_camera_vsync      ),
    .slave6_frame_wr_done       (slave6_frame_wr_done ),
    .slave6_frame_rd_done       (slave6_frame_rd_done ),
    .slave6_wr_load             (slave6_wr_load       ),
    .slave6_wr_bank             (slave6_wr_bank       ),
    .slave6_rd_load             (slave6_rd_load       ),
    .slave6_rd_bank             (slave6_rd_bank       ),
    //slave4_bank_switch
    .slave7_valid               (m7_camera_vsync      ),
    .slave7_frame_wr_done       (slave7_frame_wr_done ),
    .slave7_frame_rd_done       (slave7_frame_rd_done ),
    .slave7_wr_load             (slave7_wr_load       ),
    .slave7_wr_bank             (slave7_wr_bank       ),
    .slave7_rd_load             (slave7_rd_load       ),
    .slave7_rd_bank             (slave7_rd_bank       ), 
    //slave5_bank_switch
    .slave8_valid               (m8_camera_vsync      ),
    .slave8_frame_wr_done       (slave8_frame_wr_done ),
    .slave8_frame_rd_done       (slave8_frame_rd_done ),
    .slave8_wr_load             (slave8_wr_load       ),
    .slave8_wr_bank             (slave8_wr_bank       ),
    .slave8_rd_load             (slave8_rd_load       ),
    .slave8_rd_bank             (slave8_rd_bank       )
);
//--------------------------------------------------------------------------------//         
// slave_rd_bank_sel_module      读BANK反转控制器 
//--------------------------------------------------------------------------------//  
slave_rd_bank_sel_module sel_mod
(    
    .read_channal                (read_channal     ),
    .slave0_rd_load              (slave0_rd_load   ),
    .slave0_rd_bank              (slave0_rd_bank   ),
    .slave1_rd_load              (slave1_rd_load   ),
    .slave1_rd_bank              (slave1_rd_bank   ),
    .slave2_rd_load              (slave2_rd_load   ),
    .slave2_rd_bank              (slave2_rd_bank   ),
    .slave3_rd_load              (slave3_rd_load   ),
    .slave3_rd_bank              (slave3_rd_bank   ),
    .slave4_rd_load              (slave4_rd_load   ),
    .slave4_rd_bank              (slave4_rd_bank   ),
    .slave5_rd_load              (slave5_rd_load   ),
    .slave5_rd_bank              (slave5_rd_bank   ),
    .slave6_rd_load              (slave6_rd_load   ),
    .slave6_rd_bank              (slave6_rd_bank   ),
    .slave7_rd_load              (slave7_rd_load   ),
    .slave7_rd_bank              (slave7_rd_bank   ),
    .slave8_rd_load              (slave8_rd_load   ),
    .slave8_rd_bank              (slave8_rd_bank   ),
    .slave_sel_rd_load           (slave_sel_rd_load),
    .slave_sel_rd_bank           (slave_sel_rd_bank)                  
); 
//--------------------------------------------------------------------------------//         
// slave_rd_bank_sel_module      读BANK反转控制器 
//--------------------------------------------------------------------------------//  
slave_rd_bank_sel_module sel_eth_mod
(    
    .read_channal                (eth_read_channal      ),
    .slave0_rd_bank              (eth_slave0_rd_bank    ),
    .slave1_rd_bank              (eth_slave1_rd_bank    ),
    .slave2_rd_bank              (eth_slave2_rd_bank    ),
    .slave3_rd_bank              (eth_slave3_rd_bank    ),
    .slave4_rd_bank              (eth_slave4_rd_bank    ),
    .slave5_rd_bank              (eth_slave5_rd_bank    ),
    .slave6_rd_bank              (eth_slave6_rd_bank    ),
    .slave7_rd_bank              (eth_slave7_rd_bank    ),
    .slave8_rd_bank              (eth_slave8_rd_bank    ),
    .slave_sel_rd_bank           (eth_slave_sel_rd_bank )                  
); 
//--------------------------------------------
//   ddr2wr_fifo
//--------------------------------------------
ddr_wr_ctrl#
(
    .MAX_ADDR                   (addr_max )   //256760 - 256 =245_504
) ddr_wr_ctrl
(   
//----------------------------------------------------
//DDR2_PORT
    .mem_addr                   (mem_addr            ),
    .mem_ba                     (mem_ba              ),
    .mem_cas_n                  (mem_cas_n           ),
    .mem_cke                    (mem_cke             ),
    .mem_clk                    (mem_clk             ),
    .mem_clk_n                  (mem_clk_n           ),
    .mem_cs_n                   (mem_cs_n            ),
    .mem_dm                     (mem_dm              ),
    .mem_dq                     (mem_dq              ),
    .mem_dqs                    (mem_dqs             ),
    .mem_odt                    (mem_odt             ),
    .mem_ras_n                  (mem_ras_n           ),
    .mem_we_n                   (mem_we_n            ),
//----------------------------------------------------
//LOCAL_PORT
    .source_clk                 (source_clk          ),
    .ddr_clk                    (ddr_clk             ),
    .rst_n                      (rst_n               ),
    .ddr_initial_done           (ddr_init_done       ),
//------------------------------------------------
//slave0
    .slave0_frame_wr_done       (slave0_frame_wr_done),
    .slave0_frame_rd_done       (slave0_frame_rd_done),
//------------------------------------------------
//slave1
    .slave1_frame_wr_done       (slave1_frame_wr_done),
    .slave1_frame_rd_done       (slave1_frame_rd_done),
//------------------------------------------------
//slave2
    .slave2_frame_wr_done       (slave2_frame_wr_done),
    .slave2_frame_rd_done       (slave2_frame_rd_done),
//------------------------------------------------
//slave3
    .slave3_frame_wr_done       (slave3_frame_wr_done),
    .slave3_frame_rd_done       (slave3_frame_rd_done),
//------------------------------------------------
//slave4
    .slave4_frame_wr_done       (slave4_frame_wr_done),
    .slave4_frame_rd_done       (slave4_frame_rd_done),
//------------------------------------------------
//slave5
    .slave5_frame_wr_done       (slave5_frame_wr_done),
    .slave5_frame_rd_done       (slave5_frame_rd_done),
//------------------------------------------------
//slave6
    .slave6_frame_wr_done       (slave6_frame_wr_done),
    .slave6_frame_rd_done       (slave6_frame_rd_done),
//------------------------------------------------
//slave7
    .slave7_frame_wr_done       (slave7_frame_wr_done),
    .slave7_frame_rd_done       (slave7_frame_rd_done),
//------------------------------------------------
//slave8
    .slave8_frame_wr_done       (slave8_frame_wr_done),
    .slave8_frame_rd_done       (slave8_frame_rd_done),
//------------------------------------------------
//state 
    .ready                      (ddr_ready           ),
  //------------------------------------------------
  //from arbitrate_wr
    .wr_addr                    (arb_wddr_addr       ),
    .w_len                      (arb_wddr_len        ),
    .mem_wen                    (mem_wen             ),
    .mem_wen_valid              (mem_wen_valid       ),
    .wr_burst_data_req          (wr_burst_data_req   ),
    .wr_burst_data              (wr_burst_data       ),
    .wr_burst_finish            (wr_burst_finish     ),
  //------------------------------------------------
  //from arbitrate_rd                               
    .rd_addr                    (aribitrate_rddr_addr),  
    .r_len                      (rd_len              ),       
    .mem_ren                    (mem_ren             ),
    .mem_ren_valid              (mem_ren_valid       ),
    .rd_burst_data_valid        (rd_burst_data_valid ),
    .rd_burst_data              (rd_burst_data       ),
    .rd_burst_finish            (rd_burst_finish     ),
  //------------------------------------------------
  //debug flag
//    .mem_ren_fail               (mem_ren_fail        ),//for ddrwfifo
    .frame_wr_done              (frame_wr_done       )
);
//`ifdef simulate
//key_bank_switch 
//#(    .hold_time         (200)
//)key_bank_sw
//(
//      .clk               (ddr_clk), //166.7mhz 
//      .rstn              (rst_n  ),
//      .key_bottom        (switch_key),
//      .read_channal      (read_channal)
//);
//`else 
key_bank_switch 
#(    

    .slave_num                       (4'd9        ),
    .hold_time                       (2000000     )
)key_bank_sw                         
(                                    
    .clk                             (ddr_clk     ), //166.7mhz 
    .rstn                            (rst_n       ),
    .key_bottom                      (switch_key  ),
    .read_channal                    (read_channal)
);                                   
switch_show                          
#(    .hold_time                     (2000000    )
)sw_show(                            
    .clk                             (ddr_clk    ),
    .rstn                            (rst_n      ),
    .key_input                       (close_key  ),
    .show_state                      (show_state )
);

arbitrate_ctrl_rd_ddr arbitrate_ctrl_rd_ddr_m
(
    .ddr_clk                         (ddr_clk             ),
    .sys_rstn                        (rst_n               ),
    .slave_valid                     (Rslave_valid        ),
//slave0
    .Rslave0_req                     (Rslave0_req&show_state),
    .Rslave0_Raddr                   (Rslave0_Raddr       ),
    .Rslave0_Rlen                    (Rslave0_Rlen        ),
    .Rslave0_data                    (Rslave0_data        ),
    .Rslave0_wen                     (Rslave0_wen         ),
//slave1                         
    .Rslave1_req                     (Rslave1_req         ),
    .Rslave1_Raddr                   (Rslave1_Raddr       ),
    .Rslave1_Rlen                    (Rslave1_Rlen        ),
    .Rslave1_data                    (Rslave1_data        ),
    .Rslave1_wen                     (Rslave1_wen         ),
//slave2                         
    .Rslave2_req                     (Rslave2_req         ),
    .Rslave2_Raddr                   (Rslave2_Raddr       ),
    .Rslave2_Rlen                    (Rslave2_Rlen        ),
    .Rslave2_data                    (Rslave2_data        ),
    .Rslave2_wen                     (Rslave2_wen         ),
//from ddr_wr_crtl               
    .ready                           (ddr_ready           ),
    .ddr_read_finish                 (rd_burst_finish     ),
//to ddr_wrctrl                  
    .arb_rddr_addr                   (aribitrate_rddr_addr),
    .arb_rddr_len                    (rd_len              ),
    .ddr_Wfifo_en                    (rd_burst_data_valid ),
    .ddr_Wfifo_data                  (rd_burst_data       ),      
    .mem_ren                         (mem_ren             ),
    .mem_ren_valid                   (mem_ren_valid       )
);

//-----------------------------------------------------------
//   vga_slave 0                                
//-----------------------------------------------------------
ddr_wdisplay_slave
#(
    .MAXADDR                         (addr_max              )
)Rslave0
(    
    //ddr_wr_ctrl                                        
    .ddr_clk                         (ddr_clk               ),
    .ddr_rstn                        (rst_n                 ),
    .rd_burst_data_valid             (Rslave0_wen           ),
    .rd_burst_data                   (Rslave0_data          ),
    //w_fifo                                                
    .w_fifo_clk                      (w_vga_fifo_clk        ),
    .w_fifo_en                       (w_vga_fifo_en         ),
    .w_fifo_data                     (w_vga_fifo_data       ),
    //arbitrate _ port 
    .slave_req                       (Rslave0_req           ),
    .slave_valid                     (Rslave_valid[0]       ),
    .slave_raddr                     (Rslave0_Raddr         ),
    .rd_len                          (Rslave0_Rlen          ),
    //fifo_32w8r 状态                                           
    .fifo_len                        (fifo_len_display      ),
    .fifo_full_flag                  (fifo_dis_full         ), 
    .fifo_clearn                     (fifo_clearn           ),
    //read_bank 
    .slave_sel_rd_load               (slave_sel_rd_load     ),
    .slave_sel_rd_bank               (slave_sel_rd_bank     ),
    .read_channal                    (read_channal          ),  
    .neg_vga_vs                      (neg_vga_vs            ),
    .frame_wr_done                   (frame_wr_done         )                
); 
//-----------------------------------------------------------
//   vga_fifo   32bit * 512 -> depth
//-----------------------------------------------------------
fifo_32w8r fifo_ddr2vga(          
    .aclr                            (~fifo_clearn          ),
	.wrclk                           (w_vga_fifo_clk        ),
	.wrreq                           (w_vga_fifo_en         ),
	.data                            (w_vga_fifo_data       ),
	.wrempty                         (fifo_dis_empty        ),
	.wrfull                          (fifo_dis_full         ),
	.wrusedw                         (fifo_len_display      ), //10为 1024*32
	.rdclk                           (vga_clk               ),
	.rdreq                           (display_rfifo_en      ),
	.q                               (display_rfifo_data    )
);
//-----------------------------------------------------------
//   vga_display                               
//-----------------------------------------------------------
vga_display vga_m0(
    .vga_clk                         (vga_clk               ),   //需要 PLL 产生79.5MHZ
	.rstn                            (rst_n                 ),   //对应的
	.vga_hs                          (vga_hs                ),   //行同步信号
	.vga_vs                          (vga_vs                ),   //列同步信号
	.vga_r                           (vga_r                 ),
	.vga_g                           (vga_g                 ),
	.vga_b                           (vga_b                 ),
    .rfifo_req                       (display_rfifo_en      ),
    .rfifo_data                      (display_rfifo_data    ),
    .FIFO_EMPTY                      (fifo_dis_empty        ),
    .neg_vga_vs_o                    (neg_vga_vs            ),
    .vga_valid                       (             )
);
//-----------------------------------------------------------
//   sd_slave 1                                
//-----------------------------------------------------------
sd_rdaddr_slave1
#(
    .MAXADDR                         (addr_max              )
)Rslave1
(    
    //ddr_wr_ctrl                                        
    .ddr_clk                         (ddr_clk               ),
    .ddr_rstn                        (rst_n                 ),
    .rd_burst_data_valid             (Rslave1_wen           ),
    .rd_burst_data                   (Rslave1_data          ),
    //w_fifo                                                
    .w_fifo_clk                      (w_wrsd_fifo_clk       ),
    .w_fifo_en                       (w_wrsd_fifo_dv        ),
    .w_fifo_data                     (w_wrsd_fifo_data      ),
    //arbitrate _ port 
    .slave_req                       (Rslave1_req           ),
    .slave_valid                     (Rslave_valid[1]       ),
    .slave_raddr                     (Rslave1_Raddr         ),
    .rd_len                          (Rslave1_Rlen          ),
    //fifo_32w16r 状态                                           
    .fifo_len                        (w_wrsd_fifo_len       ),
    .fifo_full_flag                  (w_wrsd_fifo_full_flag ),
    .read_channal                    (read_channal          ),  //表征当前存储与显示的图像通道
    .wr_sd_sec_done                  (w_slave_sel_frame_done)                   
); 

//--------------------------------------------------------------------------------//         
// ETH_TRANS                                                                             
//--------------------------------------------------------------------------------//    
cmos_switch_mould   //FOR ETH 
#(
    .cmos_num (4'd3 )
)cmos_eth_sel(
    .i_sel_channal_sw                 (1'b1                   ),
    .i_eth_cmos_sel                   (w_eth_transfer_cmos_sel),                                    
    //----------------------------------------------------//
    // cmos_port_0
    //----------------------------------------------------//
    .i_cmos0_pclk                     (m0_camera_pclk        ),
    .i_cmos0_data                     (m0_camera_wfifo_data  ),
    .i_cmos0_dreq                     (m0_camera_wfifo_req   ),
    .i_cmos0_vsync                    (m0_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_1
    //----------------------------------------------------//
    .i_cmos1_pclk                     (m1_camera_pclk        ),
    .i_cmos1_data                     (m1_camera_wfifo_data  ),
    .i_cmos1_dreq                     (m1_camera_wfifo_req   ),
    .i_cmos1_vsync                    (m1_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_2
    //----------------------------------------------------//
    .i_cmos2_pclk                     (m2_camera_pclk        ), 
    .i_cmos2_data                     (m2_camera_wfifo_data  ), 
    .i_cmos2_dreq                     (m2_camera_wfifo_req   ), 
    .i_cmos2_vsync                    (m2_camera_vsync       ), 
    //----------------------------------------------------//
    // cmos_port_3
    //----------------------------------------------------//
    .i_cmos3_pclk                     (m3_camera_pclk        ),
    .i_cmos3_data                     (m3_camera_wfifo_data  ),
    .i_cmos3_dreq                     (m3_camera_wfifo_req   ),
    .i_cmos3_vsync                    (m3_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_4
    //----------------------------------------------------//
    .i_cmos4_pclk                     (m4_camera_pclk        ),
    .i_cmos4_data                     (m4_camera_wfifo_data  ),
    .i_cmos4_dreq                     (m4_camera_wfifo_req   ),
    .i_cmos4_vsync                    (m4_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_5
    //----------------------------------------------------//
    .i_cmos5_pclk                     (m5_camera_pclk        ),
    .i_cmos5_data                     (m5_camera_wfifo_data  ),
    .i_cmos5_dreq                     (m5_camera_wfifo_req   ),
    .i_cmos5_vsync                    (m5_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_6
    //----------------------------------------------------//
    .i_cmos6_pclk                     (m6_camera_pclk        ),
    .i_cmos6_data                     (m6_camera_wfifo_data  ),
    .i_cmos6_dreq                     (m6_camera_wfifo_req   ),
    .i_cmos6_vsync                    (m6_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_7
    //----------------------------------------------------//
    .i_cmos7_pclk                     (m7_camera_pclk        ),
    .i_cmos7_data                     (m7_camera_wfifo_data  ),
    .i_cmos7_dreq                     (m7_camera_wfifo_req   ),
    .i_cmos7_vsync                    (m7_camera_vsync       ),
    //----------------------------------------------------//
    // cmos_port_8
    //----------------------------------------------------//
    .i_cmos8_pclk                     (m8_camera_pclk        ),
    .i_cmos8_data                     (m8_camera_wfifo_data  ),
    .i_cmos8_dreq                     (m8_camera_wfifo_req   ),
    .i_cmos8_vsync                    (m8_camera_vsync       ),
    //----------------------------------------------------//         
    // cmos_port_sel                                                 
    //----------------------------------------------------//         
    .o_cmos_sel_pclk                  (w_eth_cmos_sel_pclk   ),                   
    .o_cmos_sel_data                  (w_eth_cmos_sel_data   ),                   
    .o_cmos_sel_dreq                  (w_eth_cmos_sel_dreq   ),                   
    .o_cmos_sel_vsync                 (w_eth_cmos_sel_vsync  )
);

//开始传输控制模块   
//此模块目的用于判断接收道德数据长度是否为 1 ，如果为1字节，并符合开始传输标志或停止传输标志
start_transfer_ctrl u_start_transfer_ctrl(
    .clk                             (w_gmii_rec_clk          ),   //时钟信号
    .rst_n                           (rst_n                   ),   //复位信号，低电平有效
    .udp_rec_pkt_done                (w_udp_rec_pkt_done      ),   //UDP单包数据接收完成信号
    .udp_rec_en                      (w_udp_rec_data_valid    ),   //UDP接收的数据使能信号 
    .udp_rec_data                    (w_udp_rec_data          ),   //UDP接收的数据
    .udp_rec_byte_num                (w_udp_rec_byte_num      ),   //UDP接收到的字节数
    .transfer_all_frame_flag         (w_transfer_all_frame_flag),
    .transfer_signle_frame_flag      (w_transfer_single_flag  ),    //图像开始传输标志,1:开始传输 0:停止传输
    .transfer_cmos_sel               (w_eth_transfer_cmos_sel )
);     
reg r_transfer_all_frame_flag_d0 ; 
reg r_transfer_all_frame_flag_d1 ; 
wire w_transfer_all_frame_flag_pos,w_transfer_all_frame_flag_neg;
always @(posedge ddr_clk or negedge rst_n) begin
    if (!rst_n) begin
        r_transfer_all_frame_flag_d0 <= 1'b0 ; 
        r_transfer_all_frame_flag_d1 <= 1'b0 ;
    end 
    else begin 
        r_transfer_all_frame_flag_d0 <= w_transfer_all_frame_flag    ; 
        r_transfer_all_frame_flag_d1 <= r_transfer_all_frame_flag_d0 ;
    end 
end
assign w_transfer_all_frame_flag_pos = r_transfer_all_frame_flag_d0 & ~r_transfer_all_frame_flag_d1;
assign w_transfer_all_frame_flag_neg = ~r_transfer_all_frame_flag_d0& r_transfer_all_frame_flag_d1 ;




eth_trans_slave 
#(
    .MAXADDR                         (addr_max              )
)Rslave2
(    
    // --
    //.transfer_all_frame_flag         (w_transfer_all_flag   ), //表征以太网传输DDR图像 NULL ETH_CLK
    .transfer_all_frame_flag         (w_transfer_all_frame_flag_neg        ),
    .eth_single_frame_eth_done       (w_eth_single_frame_eth_done),
    //.eth_single_frame_eth_done_valid (w_eth_single_frame_eth_done_valid),
    //.eth_single_frame_eth_done_ready (w_eth_single_frame_eth_done_ready),

    .all_frame_eth_done              (all_frame_transfer_done          ), //表针一帧图像传输完成  NULL  --可有打包模块传输
    .ddr_write_pre_first_flag_valid  (w_ddr_write_pre_first_flag_valid  ),
    .ddr_write_pre_first_flag_ready  (w_ddr_write_pre_first_flag_ready  ),
    .ddr_single_transfer_done        (w_ddr_single_transfer_done       ),
    //ddr_wr_ctrl                                                      
    .ddr_clk                         (ddr_clk                          ),
    .ddr_rstn                        (rst_n|w_transfer_all_frame_flag_pos),
    .rd_burst_data_valid             (Rslave2_wen                      ),  //eth rd ddr 
    .rd_burst_data                   (Rslave2_data                     ),  //eth rd ddr 
    //w_fifo                                                           
    .w_fifo_clk                      (w_eth_fifo_clk                   ),
    .w_fifo_en                       (w_eth_fifo_en                    ),
    .w_fifo_data                     (w_eth_fifo_data                  ),
    //arbitrate _ port                                                 
    .slave_req                       (Rslave2_req                      ),  //仲裁--请求与回应
    .slave_valid                     (Rslave_valid[2]                  ),  //仲裁--请求与回应
    .slave_raddr                     (Rslave2_Raddr                    ),
    .rd_len                          (Rslave2_Rlen                     ),
    //fifo_32w8r 状态                                                      
    .fifo_len                        (eth_fifo_wrusedw                 ),
    .fifo_full_flag                  (eth_fifo_wrfull                  ),  
    //fifo_32w8r 状态                                                  
    .slave_sel_rd_bank               (eth_slave_sel_rd_bank            ),
    .eth_read_channal                (eth_read_channal                 )     //后续可加入按键消抖，进行摄像头的跳转
//    input wire              camera_vsync                    , //for debug                             
); 

//图像封装模块     
//将图像数据以包的形式打包，第一包数据具有行列长度信息与校验信息
img_data_pkt eth_img_pkt(                        
    .rst_n                           (rst_n                             ),   //复位信号，低电平有效
    //图像相关信号 单帧FRAME         
    .cam_pclk                        (w_eth_cmos_sel_pclk               ),   //像素时钟
    .img_vsync                       (w_eth_cmos_sel_vsync              ),   //帧同步信号
    .img_data_en                     (w_eth_cmos_sel_dreq               ),   //数据有效使能信号
    .img_data                        (w_eth_cmos_sel_data               ),   //有效数据 
    .transfer_sigle_frame_flag       (w_transfer_single_flag            ),   //图像开始传输标志,1:开始传输 0:停止传输
    .single_frame_transfer_done      (w_frame_transfer_done             ),   //单帧传输完成
    //图像相关信号 全帧FRAME         
    .ddr_clk                         (ddr_clk                           ),   //像素时钟
    .ddr_write_pre_first_flag_valid  (w_ddr_write_pre_first_flag_valid  ),
    .ddr_write_pre_first_flag_ready  (w_ddr_write_pre_first_flag_ready  ),

    .ddr_data_en                     (w_eth_fifo_en                     ),   //数据有效使能信号
    .ddr_data                        (w_eth_fifo_data                   ),   //有效数据 
    .transfer_all_frame_flag         (w_transfer_all_frame_flag         ),   //图像开始传输标志,1:开始传输 0:停止传输 
    .ddr_single_transfer_done        (w_ddr_single_transfer_done        ),   //全帧传输中的单帧传输 DDR完成      
    .eth_fifo_wrusedw                (eth_fifo_wrusedw                  ),
    .eth_fifo_wrfull                 (eth_fifo_wrfull                   ),
    //all_frame_single_transfer_done
    .eth_single_frame_eth_done       (w_eth_single_frame_eth_done       ),
    .all_frame_transfer_done         (all_frame_transfer_done           ),   //全帧传输完成                 
    //以太网相关信号                 
    .eth_tx_clk                      (w_gmii_tx_clk                     ),   //以太网发送时钟
    .udp_tx_req                      (w_fifo_data_req                   ),   //udp发送数据请求信号
    .udp_tx_done                     (w_udp_tx_pkt_done                 ),   //udp发送数据完成信号 
    .udp_tx_start_en                 (w_tx_start_en                     ),   //udp开始发送信号
    .udp_tx_data                     (w_tx_data                         ),   //udp发送的数据
    .udp_tx_byte_num                 (w_tx_byte_num                     ),    //udp单包发送的有效字节数
    .i_gmii_tx_busy                  (w_gmii_tx_busy                    )
    );  

ethernet_top eth_top(
	.reset_n                         (rst_n                             ),   
    .i_touch_key                     (i_arp_key                         ),  //arp_key
	.e_reset                         (e_reset                           ),                 
    .e_mdc                           (e_mdc                             ), 
	.e_mdio                          (e_mdio                            ), 
    //re  
	.e_rxc                           (e_rxc                             ),  //125Mhz ethernet gmii rx clock
	.e_rxdv                          (e_rxdv                            ),	
	.e_rxer                          (e_rxer                            ),	//NULL					
	.e_rxd                           (e_rxd                             ),        
    //tx     
	.e_txc                           (e_txc                             ),  //NULL 25Mhz ethernet mii tx clock       
	.e_gtxc                          (e_gtxc                            ),  //25Mhz ethernet gmii tx clock  
	.e_txen                          (e_txen                            ), 
	.e_txer                          (e_txer                            ), 					
	.e_txd	                         (e_txd	                            ),
    //rec   
    .o_gmii_rec_clk                  (w_gmii_rec_clk                    ),
    .o_udp_rec_pkt_done              (w_udp_rec_pkt_done                ),   
    .o_udp_rec_data_valid            (w_udp_rec_data_valid              ),   
    .o_udp_rec_data                  (w_udp_rec_data                    ),   
    .o_udp_rec_byte_num              (w_udp_rec_byte_num                ),   
    //tx  
    .o_gmii_tx_clk                   (w_gmii_tx_clk                     ),
    .o_udp_tx_pkt_done               (w_udp_tx_pkt_done                 ),
    .i_tx_start_en                   (w_tx_start_en                     ),   
    .o_fifo_data_req                 (w_fifo_data_req                   ),   
    .i_tx_data                       (w_tx_data                         ),   
    .i_tx_byte_num                   (w_tx_byte_num                     ),
    .o_gmii_tx_busy                  (w_gmii_tx_busy                    )       
);
//--------------------------------------------------------------------------------//         
// SD_RD_DDR SELLECT       FIFO                                                                     
//--------------------------------------------------------------------------------//  
fifo_32w16r cmos_sd_fifo(                         //此模块需要修改
	.aclr                    (pos_slave_sel_frame_done_sdlck             ),
	.wrclk                   (w_wrsd_fifo_clk            ),
	.wrreq                   (w_wrsd_fifo_dv             ),
	.data                    (w_wrsd_fifo_data           ),
	.rdclk                   (w_rdsd_fifo_clk            ),
	.rdreq                   (w_rdsd_fifo_dv             ),
	.q                       (w_rdsd_fifo_data           ),
    .rdfull                  (w_rdsd_fifo_full_flag      ),
	.rdusedw                 (w_rdsd_fifo_len            ),      //32bit * 512  / 16bit * 1024 
	.wrfull                  (w_wrsd_fifo_full_flag      ),
    .wrusedw                 (w_wrsd_fifo_len            )
);

always@(posedge sd_clk25m or negedge rst_n)begin 
    if(!rst_n)begin 
        r_slave_sel_frame_done_sdclk_d0 <= 1'b0 ;
        r_slave_sel_frame_done_sdclk_d1 <= 1'b0 ;
    end 
    else begin 
        r_slave_sel_frame_done_sdclk_d0 <= w_slave_sel_frame_done ;
        r_slave_sel_frame_done_sdclk_d1 <= r_slave_sel_frame_done_sdclk_d0 ;
    end 
end 

assign pos_slave_sel_frame_done_sdlck = r_slave_sel_frame_done_sdclk_d0&!r_slave_sel_frame_done_sdclk_d1;

top_sd_rw sd_rw(
    .sys_rst_n               (rst_n                          ), //系统复位，低电平有效
    .SD_clk_ref              (sd_clk25m                      ), //PLL  25M
    .SD_clk_ref_180deg       (sd_clk25m_ref                  ), //PLL  25M
    .source_clk              (source_clk                     ), //50mhz
    //SD卡接口                                               
    .sd_miso                 (sd_miso                        ),  //SD卡SPI串行输入数据信号
    .sd_clk                  (sd_clk                         ),  //SD卡SPI时钟信号
    .sd_cs                   (sd_cs                          ),  //SD卡SPI片选信号
    .sd_mosi                 (sd_mosi                        ),  //SD卡SPI串行输出数据信号
    //cmos_record 接口                             
    .sys_cmos_image_save_req (pos_slave_sel_frame_done_sdlck ),
    .sys_image_read_req      (                               ),
    //fifo_16w32r (无SD卡读取图片的需求，此FIFO_port仅保留)
    .rd_sdfifo_full_flag     (                               ),
    .rd_sdfifo_empty_flag    (                               ),
    .rd_sdfifo_len           (                               ),
    .rd_sd_wfifo_clk         (                               ),
    .rd_sd_wfifo_rst_n       (                               ),
    .rd_sd_wfifo_req_en      (                               ),
    .rd_sd_wfifo_data        (                               ),
    .rd_sd_image_done_n      (                               ),
    //fifo_32w16r (有SD卡写入图片的需求，FIFO由CMOS或者DDR写入)
    .wr_sdfifo_full_flag     (w_rdsd_fifo_full_flag          ),
    .wr_sdfifo_empty_flag    (                               ),
    .wr_sdfifo_len           (w_rdsd_fifo_len                ),
    .wr_sd_rfifo_clk         (w_rdsd_fifo_clk                ),
    .wr_sd_rfifo_rst_n       (                               ),
    .wr_sd_rfifo_req_en      (w_rdsd_fifo_dv                 ),
    .wr_sd_rfifo_data        (w_rdsd_fifo_data               ),
    .wr_sd_image_done        (                               )
    );

sd_pll pll_sd
(
	.areset     (~sys_rst_n),
	.inclk0     (source_clk),
	.c0         (sd_clk25m),
	.c1         (sd_clk25m_ref),
	.locked     (pll_locked_u2)
);

pll_u0 pll_sdvga
(
	.areset  (~sys_rst_n ),
	.inclk0  (source_clk ),
	.c0      (CLK_24M    ),
	.c1      (vga_clk    ),
    .c2      (CLK_20K),
	.locked  (pll_locked_u1 )
);
//---rst---
assign rst_n     = sys_rst_n & pll_locked_u1 & pll_locked_u2;

//------------------------------------------\\
//           for modelsim_debug             
//    assign ddr_initial_done = ddr_init_done;
endmodule 

