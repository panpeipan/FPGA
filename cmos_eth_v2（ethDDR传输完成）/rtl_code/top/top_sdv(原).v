`include"../rtl_code/include/myparam.v"
module top_sdv#(
//    `ifdef simulate 
//    parameter addr_max = 23'd768            //1280*768/4 = 245760  64*48/4=768
//    `else 
//    parameter addr_max = 23'd245760
//    `endif
        parameter addr_max = 23'd245760
)(

	input  wire      source_clk        ,             //输入系统时钟50Mhz
	input  wire      sys_rst_n         ,
    input  wire      switch_key        ,
    input  wire      close_key         ,
//----------------------------------------  
//DDR2_port
    output  [ 12: 0] mem_addr          ,
    output  [  2: 0] mem_ba            ,
    output           mem_cas_n         ,
    output  [  0: 0] mem_cke           ,
    inout   [  0: 0] mem_clk           ,
    inout   [  0: 0] mem_clk_n         ,
    output  [  0: 0] mem_cs_n          ,
    output  [  1: 0] mem_dm            ,
    inout   [ 15: 0] mem_dq            ,
    inout   [  1: 0] mem_dqs           ,
    output  [  0: 0] mem_odt           ,
    output           mem_ras_n         ,
    output           mem_we_n          ,
//----------------------------------------  
//SD_port 
//    input  wire      sd_miso         ,
//    output wire      sd_clk          ,
//    output wire      sd_cs           ,
//    output wire      sd_mosi         ,
//----------------------------------------  
//VGA_port 
    output wire       vga_hs           ,             //行同步信号
	output wire       vga_vs           ,             //列同步信号
	output wire [4:0] vga_r            ,
	output wire [5:0] vga_g            ,
	output wire [4:0] vga_b            ,
//---------------------------------------- 
//debug led
//    output wire       camera_init_done_n    ,             //LED0 for sd
//    output wire       led_first_image_done_n,
//    output wire       local_init_done_n     ,
    
//----------------------------------------
//OV9281_port m0
    output wire       m0_i2c_sclk         ,
    inout  wire       m0_i2c_sdat         ,
    output wire       m0_camera_pwdn      ,
    output wire       m0_camera_xclk      ,    
    input  wire       m0_camera_pclk      ,
    input  wire       m0_camera_href      ,
    input  wire       m0_camera_vsync     ,
    input  wire [7:0] m0_camera_data      ,
//----------------------------------------  
//OV9281_port m0
    output wire       m1_i2c_sclk         ,
    inout  wire       m1_i2c_sdat         ,
    output wire       m1_camera_pwdn      ,
    output wire       m1_camera_xclk      ,    
    input  wire       m1_camera_pclk      ,
    input  wire       m1_camera_href      ,
    input  wire       m1_camera_vsync     ,
    input  wire [7:0] m1_camera_data      ,

//----------------------------------------  
//OV9281_port m0
    output wire       m2_i2c_sclk         ,
    inout  wire       m2_i2c_sdat         ,
    output wire       m2_camera_pwdn      ,
    output wire       m2_camera_xclk      ,    
    input  wire       m2_camera_pclk      ,
    input  wire       m2_camera_href      ,
    input  wire       m2_camera_vsync     ,
    input  wire [7:0] m2_camera_data      
//----------------------------------------  
//OV9281_port m0
//    `ifdef simulate
//    ,output wire       m3_i2c_sclk         ,
//    inout  wire       m3_i2c_sdat         ,
//    output wire       m3_camera_pwdn      ,
//    output wire       m3_camera_xclk      ,    
//    input  wire       m3_camera_pclk      ,
//    input  wire       m3_camera_href      ,
//    input  wire       m3_camera_vsync     ,
//    input  wire [7:0] m3_camera_data      ,
////---------------------------------------- 
////for modelsim_debug
//    output wire       ddr_initial_done    
//    `endif
);
//----------------------------------------
//---------------------------------------

parameter DATA_WIDTH = 32;           //总线数据宽度
parameter ADDR_WIDTH = 25;           //总线地址宽度

wire	                       	   ddr_init_done     ;     //ddr_初始化完成
wire	                       	   ddr_clk           ;
wire                               pll_locked        ;
wire                               rst_n             ;     //全局复位
//----------------------------------------------------------
//   fifo 32-32
//----------------------------------------------------------
//-cmos_m0
wire                               FIFO_m0_EMPTY           ;
wire                               FIFO_m0_FULL            ;
wire [10:0]                        FIFO_m0_LEN             ;
//-cmos_m1                                                 
wire                               FIFO_m1_EMPTY           ;
wire                               FIFO_m1_FULL            ;
wire [10:0]                        FIFO_m1_LEN             ;

//-cmos_m2                                                 
wire                               FIFO_m2_EMPTY           ;
wire                               FIFO_m2_FULL            ;
wire [10:0]                        FIFO_m2_LEN             ;
//`ifdef simulate
////-cmos_m3                                                 
//wire                               FIFO_m3_EMPTY           ;
//wire                               FIFO_m3_FULL            ;
//wire [10:0]                        FIFO_m3_LEN             ;
//`endif
//-neg_vga_vs                                              
wire                               neg_vga_vs              ;
//----------------------------------------------------------
//   camera_ov9281_m0
//----------------------------------------------------------
wire                               CLK_24M                 ;
assign                             m0_camera_xclk = CLK_24M; 
assign                             m1_camera_xclk = CLK_24M; 
assign                             m2_camera_xclk = CLK_24M; 
//`ifdef simulate
//assign                             m3_camera_xclk = CLK_24M; 
//`endif
//-coms_m0                         
wire                               m0_camera_vsync_rst     ;
wire [31: 0]                       m0_camera_wfifo_data    ;
wire                               m0_camera_wfifo_req     ;
//-coms_m1                                                 
wire                               m1_camera_vsync_rst     ;
wire [31: 0]                       m1_camera_wfifo_data    ;
wire                               m1_camera_wfifo_req     ;
//-coms_m2                                                 
wire                               m2_camera_vsync_rst     ;
wire [31: 0]                       m2_camera_wfifo_data    ;
wire                               m2_camera_wfifo_req     ;
//`ifdef simulate
////-coms_m3                                                 
//wire                               m3_camera_vsync_rst     ;
//wire [31: 0]                       m3_camera_wfifo_data    ;
//wire                               m3_camera_wfifo_req     ;
//`endif

//----------------------------------------------------------
//-slave_arbitrate_interface-
//----------------------------------------------------------
wire [3:0]                         arbitrate_valid         ;
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
//`ifdef simulate
////slave3                                                   
//wire                               slave3_req              ;
//wire [24:0]                        slave3_waddr            ;
//wire [9 :0]                        slave3_Wlen             ;
//wire [31:0]                        slave3_data             ;
//wire                               slave3_ren              ;
//`endif
//----------------------------------------------------------
//-ddr_wr_ctrl- 控制端
//----------------------------------------------------------
//arbitrate to ddr 
wire [22:0]                        arb_wddr_addr           ;
wire [9: 0]                        arb_wddr_len            ;
wire                               mem_wen                 ;
wire                               mem_wen_valid           ;
wire                               wr_burst_data_req       ;
wire [31:0]                        wr_burst_data           ;
wire                               wr_burst_finish         ;
//ddr_wdisplayfifo to ddr
wire [22:0]                        display_rddr_addr       ;
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
//`ifdef simulate
////-slave m3                        
//wire                               slave3_wr_load          ;
//wire  [1:0]                        slave3_wr_bank          ;
//wire                               slave3_rd_load          ;
//wire  [1:0]                        slave3_rd_bank          ;
//wire                               slave3_frame_rd_done    ;
//wire                               slave3_frame_wr_done    ;
//`endif
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
wire [31:0]                        w_fifo_data             ;
wire                               w_fifo_clk              ;
wire                               w_fifo_rstn             ;
wire                               w_fifo_en               ;
//DDR_state flag
wire                               ddr_ready               ;
// wire [10:0]FIFO_LEN_0;   32-32 fifo
wire [9:0]                         fifo_len_display        ;   

//----------------------------------------------------------
// display 
//----------------------------------------------------------
wire [1:0]                         read_channal            ;
wire                               frame_wr_done           ;
wire                               display_rfifo_en        ;
wire                               fifo_dis_full           ;
wire                               fifo_dis_empty          ;        
wire [7:0]                         display_rfifo_data      ;
wire                               vga_clk                 ;   

//----------------------------------------------------------
// error flag
//----------------------------------------------------------
wire                               mem_ren_fail            ; //读写冲突标志
//`ifndef    simulate 
//wire                               show_state              ;
//`endif 
//----------------------------------------------------------
//M0----Camera-fifo-interface-arbitrate_ctrl
//----------------------------------------------------------
camera_ov9281 camera_m0
(
    .CLK_24M                    (CLK_24M             ),                //24mhz
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                               
    .i2c_sclk                   (m0_i2c_sclk         ),
    .i2c_sdat                   (m0_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m0_camera_pwdn      ),
    .camera_vsync_rst           (m0_camera_vsync_rst ),   

    .camera_data                (m0_camera_data      ),             //ov9281 write fifo32/32
    .camera_pclk                (m0_camera_pclk      ),
    .camera_href                (m0_camera_href      ),
    .camera_vsync               (m0_camera_vsync     ),
    
    .camera_init_done           (                    ),
    .camera_wfifo_req           (m0_camera_wfifo_req ),
    .camera_wfifo_data          (m0_camera_wfifo_data)
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
	.rdusedw                    (FIFO_m0_LEN         ),
	.wrempty                    (                    ),
	.wrfull                     (                    ),
	.wrusedw                    (                    )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (2'b00),
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
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                               
    .i2c_sclk                   (m1_i2c_sclk         ),
    .i2c_sdat                   (m1_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m1_camera_pwdn      ),
    .camera_vsync_rst           (m1_camera_vsync_rst ),
    
    .camera_data                (m1_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m1_camera_pclk      ),
    .camera_href                (m1_camera_href      ),
    .camera_vsync               (m1_camera_vsync     ),
    
    .camera_init_done           (                    ),
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
	.rdusedw                    (FIFO_m1_LEN         ),
	.wrempty                    (                    ),
	.wrfull                     (                    ),
	.wrusedw                    (                    )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (2'b01),
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
    .CAMERA_RSTN                (rst_n               ),
    //i2c write ov9281                               
    .i2c_sclk                   (m2_i2c_sclk         ),
    .i2c_sdat                   (m2_i2c_sdat         ),
    .ddr_initial_done           (ddr_init_done       ),
    .camera_pwdn                (m2_camera_pwdn      ),
    .camera_vsync_rst           (m2_camera_vsync_rst ),
    
    .camera_data                (m2_camera_data      ), //ov9281 write fifo32/32
    .camera_pclk                (m2_camera_pclk      ),
    .camera_href                (m2_camera_href      ),
    .camera_vsync               (m2_camera_vsync     ),
    
    .camera_init_done           (                    ),
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
	.rdusedw                    (FIFO_m2_LEN         ),
	.wrempty                    (                    ),
	.wrfull                     (                    ),
	.wrusedw                    (                    )
);
slave_arbitrate_interface 
#(
    .SLAVE_NUMBER               (2'b10),
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
//`ifdef simulate
//camera_ov9281 camera_m3
//(
//    .CLK_24M                    (CLK_24M             ), //24mhz
//    .CAMERA_RSTN                (rst_n               ),
//    //i2c write ov9281
//    .i2c_sclk                   (m3_i2c_sclk         ),
//    .i2c_sdat                   (m3_i2c_sdat         ),
//    .ddr_initial_done           (ddr_init_done       ),
//    .camera_pwdn                (m3_camera_pwdn      ),
//    .camera_vsync_rst           (m3_camera_vsync_rst ),
//    
//    .camera_data                (m3_camera_data      ),  //ov9281 write fifo32/32
//    .camera_pclk                (m3_camera_pclk      ),
//    .camera_href                (m3_camera_href      ),
//    .camera_vsync               (m3_camera_vsync     ),
//    
//    .camera_init_done           (                    ),
//    .camera_wfifo_req           (m3_camera_wfifo_req ),
//    .camera_wfifo_data          (m3_camera_wfifo_data)
//
//);
//fifo_32w32r fifo_camera_m3(
//    .aclr                       (m3_camera_vsync_rst  ),
//	.data                       (m3_camera_wfifo_data ),
//	.rdclk                      (ddr_clk              ),
//	.rdreq                      (slave3_ren           ),
//	.q                          (slave3_data          ),
//	.wrclk                      (m3_camera_pclk       ),
//	.wrreq                      (m3_camera_wfifo_req  ),
//	.rdempty                    (FIFO_m3_EMPTY        ),
//	.rdfull                     (FIFO_m3_FULL         ),
//	.rdusedw                    (FIFO_m3_LEN          ),
//	.wrempty                    (                     ),
//	.wrfull                     (                     ),
//	.wrusedw                    (                     )
//);
//slave_arbitrate_interface 
//#(
//    .SLAVE_NUMBER               ( 2'b11      ),
//    .MAXADDR               (addr_max)
//)slave_m3
//(   
//    .ddr_clk                    (ddr_clk              ),
//    .sys_rstn                   (rst_n                ),
////-----------------------------------------------------
//    .camera_vsync_neg           (m3_camera_vsync_rst  ),  
//    .fifo_full_flag             (FIFO_m3_FULL         ),
//    .fifo_empty_flag            (FIFO_m3_EMPTY        ),
//    .fifo_len                   (FIFO_m3_LEN          ),
//    .slave_req                  (slave3_req           ),
//    .arbitrate_valid            (arbitrate_valid[3]   ),
//    .slave_wr_load              (slave3_wr_load       ), //暂时未用
//    .slave_wrbank               (slave3_wr_bank       ),
//    .slave_waddr                (slave3_waddr         ),
//    .slave_wburst_len           (slave3_Wlen          )
//);
//`endif 

arbitrate_ctrl  
#(
    .slave_num                  ( 4'd4 )
)arbitrate_ctrl_u0
(
    .ddr_clk                    (ddr_clk              ),
    .sys_rstn                   (rst_n                ),

    .slave0_req                 (slave0_req           ),
    .slave0_Waddr               (slave0_waddr         ),
    .slave0_Wlen                (slave0_Wlen          ),
    .slave0_data                (slave0_data          ),
    .slave0_ren                 (slave0_ren           ),

    .slave1_req                 (slave1_req           ),
    .slave1_Waddr               (slave1_waddr         ),
    .slave1_Wlen                (slave1_Wlen          ),
    .slave1_data                (slave1_data          ),
    .slave1_ren                 (slave1_ren           ),

    .slave2_req                 (slave2_req           ),
    .slave2_Waddr               (slave2_waddr         ),
    .slave2_Wlen                (slave2_Wlen          ),
    .slave2_data                (slave2_data          ),
    .slave2_ren                 (slave2_ren           ),
//`ifdef simulate
//    .slave3_req                 (slave3_req           ),
//    .slave3_Waddr               (slave3_waddr         ),
//    .slave3_Wlen                (slave3_Wlen          ),
//    .slave3_data                (slave3_data          ),
//    .slave3_ren                 (slave3_ren           ),
//`endif
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
    .slave2_rd_bank             (slave2_rd_bank       )
//`ifdef simulate 
//    //slave3_bank_switch                              
//    ,.slave3_valid              (m3_camera_vsync      ),
//    .slave3_frame_wr_done       (slave3_frame_wr_done ),
//    .slave3_frame_rd_done       (slave3_frame_rd_done ),
//    .slave3_wr_load             (slave3_wr_load       ),
//    .slave3_wr_bank             (slave3_wr_bank       ),
//    .slave3_rd_load             (slave3_rd_load       ),
//    .slave3_rd_bank             (slave3_rd_bank       )
//`endif 
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
    .slave0_wr_load             (slave0_wr_load      ),
    .slave0_wr_bank             (slave0_wr_bank      ),
    .slave0_rd_load             (slave0_rd_load      ),
    .slave0_rd_bank             (slave0_rd_bank      ),
    .slave0_frame_wr_done       (slave0_frame_wr_done),
    .slave0_frame_rd_done       (slave0_frame_rd_done),
  //------------------------------------------------
  //slave1
    .slave1_wr_load             (slave1_wr_load      ),
    .slave1_wr_bank             (slave1_wr_bank      ),
    .slave1_rd_load             (slave1_rd_load      ),
    .slave1_rd_bank             (slave1_rd_bank      ),
    .slave1_frame_wr_done       (slave1_frame_wr_done),
    .slave1_frame_rd_done       (slave1_frame_rd_done),
  //------------------------------------------------
  //slave2
    .slave2_wr_load             (slave2_wr_load      ),
    .slave2_wr_bank             (slave2_wr_bank      ),
    .slave2_rd_load             (slave2_rd_load      ),
    .slave2_rd_bank             (slave2_rd_bank      ),
    .slave2_frame_wr_done       (slave2_frame_wr_done),
    .slave2_frame_rd_done       (slave2_frame_rd_done),
//`ifdef simulate
//  //------------------------------------------------
//  //slave3
//    .slave3_wr_load             (slave3_wr_load      ),
//    .slave3_wr_bank             (slave3_wr_bank      ),
//    .slave3_rd_load             (slave3_rd_load      ),
//    .slave3_rd_bank             (slave3_rd_bank      ),
//    .slave3_frame_wr_done       (slave3_frame_wr_done),
//    .slave3_frame_rd_done       (slave3_frame_rd_done),
//`endif 
  //------------------------------------------------
  //state 
    .ready                      (ddr_ready           ),
  //------------------------------------------------
  //from arbitrate 
    .wr_addr                    (arb_wddr_addr       ),
    .w_len                      (arb_wddr_len        ),
    .mem_wen                    (mem_wen             ),
    .mem_wen_valid              (mem_wen_valid       ),
    .wr_burst_data_req          (wr_burst_data_req   ),
    .wr_burst_data              (wr_burst_data       ),
    .wr_burst_finish            (wr_burst_finish     ),
  //------------------------------------------------
  //from display                                 
    .rd_addr                    (display_rddr_addr   ),  
    .r_len                      (rd_len              ),       
    .mem_ren                    (mem_ren             ),
    .mem_ren_valid              (mem_ren_valid       ),
    .rd_burst_data_valid        (rd_burst_data_valid ),
    .rd_burst_data              (rd_burst_data       ),
    .rd_burst_finish            (rd_burst_finish     ),
  //------------------------------------------------
  //debug flag
    .mem_ren_fail               (mem_ren_fail        ),//for ddrwfifo
    .frame_wr_done              (frame_wr_done)
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
#(    .hold_time         (2000000)
)key_bank_sw
(
      .clk               (ddr_clk), //166.7mhz 
      .rstn              (rst_n  ),
      .key_bottom        (switch_key),
      .read_channal      (read_channal)
);
switch_show
#(    .hold_time         (2000000)
)sw_show(
    .clk                 (ddr_clk    ),
    .rstn                (rst_n      ),
    .key_input           (close_key  ),
    .show_state          (show_state )
);

//`endif
ddr_wdisplayfifo 
#(
    .MAXADDR                (addr_max)
)ddr_wr_displayfifo
(    
    //ddr_wr_ctrl                                        
    .ddr_clk                     (ddr_clk            ),
    .ddr_rstn                    (rst_n              ),
    .rd_burst_data_valid         (rd_burst_data_valid),
    .rd_burst_data               (rd_burst_data      ),
    //w_fifo                                                
    .w_fifo_clk                  (w_fifo_clk         ),
    .w_fifo_en                   (w_fifo_en          ),
    .w_fifo_data                 (w_fifo_data        ),
    //ddr_wr_ctrl                                    
    .mem_ren                     (mem_ren            ),
    .mem_ren_valid               (mem_ren_valid      ),
    .rd_addr                     (display_rddr_addr  ),
    .rd_len                      (rd_len             ),
    .read_channal                (read_channal),     //后续可加入按键消抖，进行摄像头的跳转
    //                                               
    .ddr_ready                   (ddr_ready          ),
    //fifo_32w8r 状态                                       
    .fifo_len                    (fifo_len_display   ),
    .fifo_full_flag              (fifo_dis_full      ),  
    .fifo_clearn                 (fifo_clearn        ),

    .neg_vga_vs                  (neg_vga_vs         ),
    .frame_wr_done               (frame_wr_done      ),
    //debug                                           
    .addr_u1                     (                   )
);

fifo_32w8r fifo_ddr2vga(
    .aclr                        (~fifo_clearn       ),
	.wrclk                       (w_fifo_clk         ),
	.wrreq                       (w_fifo_en          ),
	.data                        (w_fifo_data        ),
	.wrempty                     (fifo_dis_empty     ),
	.wrfull                      (fifo_dis_full      ),
	.wrusedw                     (fifo_len_display   ), //10为 1024*32
	.rdclk                       (vga_clk            ),
	.rdreq                       (display_rfifo_en   ),
	.q                           (display_rfifo_data ),
	.rdempty                     (                   ),
	.rdfull                      (                   ),
	.rdusedw                     (                   )
    );


vga_display vga_m0(
    .vga_clk                     (vga_clk            ),   //需要 PLL 产生79.5MHZ
	.rstn                        (rst_n              ),   //对应的
	.vga_hs                      (vga_hs             ),   //行同步信号
	.vga_vs                      (vga_vs             ),   //列同步信号
	.vga_r                       (vga_r              ),
	.vga_g                       (vga_g              ),
	.vga_b                       (vga_b              ),
    .rfifo_req                   (display_rfifo_en   ),
    .rfifo_data                  (display_rfifo_data ),
    .FIFO_EMPTY                  (fifo_dis_empty     ),
    .neg_vga_vs_o                (neg_vga_vs         ),
    .vga_valid                   (vga_valid          )
    );


pll_u0 pll_sdvga
(
	.areset  (~sys_rst_n ),
	.inclk0  (source_clk ),
	.c0      (CLK_24M    ),
	.c1      (vga_clk    ),
	.locked  (pll_locked )
);

//---rst---
assign  rst_n = sys_rst_n & pll_locked;
assign test_clk= m0_camera_pclk ;
assign test1_clk= m1_camera_pclk ;

//------------------------------------------\\
//           for modelsim_debug             
//    assign ddr_initial_done = ddr_init_done;
endmodule 

