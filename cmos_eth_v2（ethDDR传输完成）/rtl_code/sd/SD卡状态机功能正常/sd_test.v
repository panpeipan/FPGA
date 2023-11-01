
module sd_test(
    input          sys_clk       ,  //时钟信号
    input          sys_rst_n     ,  //复位信号,低电平有效
    
    input   wire   key_save_sd   ,
    
    input          sd_miso       ,  //SD卡SPI串行输入数据信号
    output         sd_clk        ,  //SD卡SPI时钟信号
    output  wire   sd_cs         ,  //SD卡SPI片选信号
    output  wire   sd_mosi         //SD卡SPI串行输出数据信号
    );


wire          sd_24mclk_pll           ; 
wire          sd_24mclk_pll_180deg    ; 
wire          sys_50mclk_pll          ;
wire          sys_cmos_image_save_req ;

debounce           //bottom done = GND
#(
    .hold_time (50_0000) //50MHZ hold_time = 0.001s
)debounce_u1
(
    .clk         (sd_24mclk_pll          ),
    .rst_n       (sys_rst_n              ),
    .signal_i    (key_save_sd            ),
    .signal_o    (sys_cmos_image_save_req)
);



sd_pll sd_pll_u0(
	.areset  (~sys_rst_n          ),
	.inclk0  (sys_clk             ),
	.c0      (sd_24mclk_pll       ),
	.c1      (sd_24mclk_pll_180deg),
	.c2      (sys_50mclk_pll      ),
	.locked  (                    )
    );


top_sd_rw sd_rw_u3(
    .sys_rst_n               (sys_rst_n              ), //系统复位，低电平有效
    .SD_clk_ref              (sd_24mclk_pll          ), //PLL
    .SD_clk_ref_180deg       (sd_24mclk_pll_180deg   ), //PLL
    .source_clk              (sys_50mclk_pll         ), //50mhz
    //SD卡接口
    .sd_miso                 (sd_miso                ),  //SD卡SPI串行输入数据信号
    .sd_clk                  (sd_clk                 ),  //SD卡SPI时钟信号
    .sd_cs                   (sd_cs                  ),  //SD卡SPI片选信号
    .sd_mosi                 (sd_mosi                ),  //SD卡SPI串行输出数据信号
    //cmos_record 接口  
    .sys_cmos_image_save_req (sys_cmos_image_save_req),
    .sys_image_read_req      (),
    //fifo_16w32r (无SD卡读取图片的需求，此FIFO_port仅保留)
    .rd_sdfifo_full_flag     (),
    .rd_sdfifo_empty_flag    (),
    .rd_sdfifo_len           (),
    .rd_sd_wfifo_clk         (),
    .rd_sd_wfifo_rst_n       (),
    .rd_sd_wfifo_req_en      (),
    .rd_sd_wfifo_data        (),
    .rd_sd_image_done_n      (),
    //fifo_32w16r (有SD卡写入图片的需求，FIFO由CMOS或者DDR写入)
    .wr_sdfifo_full_flag     (1'b1),
    .wr_sdfifo_empty_flag    (),
    .wr_sdfifo_len           (),
    .wr_sd_rfifo_clk         (),
    .wr_sd_rfifo_rst_n       (),
    .wr_sd_rfifo_req_en      (),
    .wr_sd_rfifo_data        (16'ha5),
    .wr_sd_image_done        (),
//-------------------------------------------debug  
    .w_fifo_en_cnt           ()
    );

endmodule