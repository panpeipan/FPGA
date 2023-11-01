module top_sd_rw(
    input wire              sys_rst_n               , //系统复位，低电平有效
    input wire              SD_clk_ref              , //PLL
    input wire              SD_clk_ref_180deg       , //PLL
    input wire              source_clk              , //50mhz
    //SD卡接口
    input    wire           sd_miso                 ,  //SD卡SPI串行输入数据信号
    output   wire           sd_clk                  ,  //SD卡SPI时钟信号
    output   wire           sd_cs                   ,  //SD卡SPI片选信号
    output   wire           sd_mosi                 ,  //SD卡SPI串行输出数据信号
    //cmos_record 接口  
    input    wire           sys_cmos_image_save_req ,
    input    wire           sys_image_read_req      ,
    //fifo_16w32r (无SD卡读取图片的需求，此FIFO_port仅保留)
    input    wire           rd_sdfifo_full_flag     ,
    input    wire           rd_sdfifo_empty_flag    ,
    input    wire [10:0]    rd_sdfifo_len           ,
    output   wire           rd_sd_wfifo_clk         ,
    output   wire           rd_sd_wfifo_rst_n       ,
    output   wire           rd_sd_wfifo_req_en      ,
    output   wire [15:0]    rd_sd_wfifo_data        ,
    output   wire           rd_sd_image_done_n      ,
    //fifo_32w16r (有SD卡写入图片的需求，FIFO由CMOS或者DDR写入)
    input    wire           wr_sdfifo_full_flag     ,
    input    wire           wr_sdfifo_empty_flag    ,
    input    wire [9:0]     wr_sdfifo_len           ,
    output   wire           wr_sd_rfifo_clk         ,
    output   wire           wr_sd_rfifo_rst_n       ,
    output   wire           wr_sd_rfifo_req_en      ,
    input    wire [15:0]    wr_sd_rfifo_data        ,
    output   wire           wr_sd_image_done        ,
//-------------------------------------------debug  
    output   reg [19:0]     w_fifo_en_cnt  
    );
//wire define
wire             rd_start_en    ;      //开始写SD卡数据信号
wire     [31:0]  rd_sec_addr    ;      //读数据扇区地址    
wire             sd_init_done   ;      //SD卡初始化完成信号

wire             rd_busy        ;      //读忙信号
wire             rd_val_en      ;      //数据读取有效使能信号
wire     [15:0]  rd_val_data    ;      //读数据

wire             wr_busy        ;
wire             wr_val_en      ;
wire     [15:0]  wr_val_data    ;
wire     [31:0]  wr_sec_addr    ;
//-----------------------------------------------------
wire     [1: 0]  w_state        ;
wire     [15:0]  w_wr_num       ;
wire     [15:0]  w_sd_write_data;
//---------------------------------------------------//
parameter sd_width = 16;
parameter ddr_width = 32;   
parameter sd_fifo_depth = 2048;         //2048
parameter sd_fifo_addr_width = 12;

//---------------------------------------------------//
//rd
//assign rd_sd_wfifo_clk    = SD_clk_ref   ;
//assign rd_sd_wfifo_rst_n  = sys_rst_n    ;
//assign rd_sd_wfifo_req_en = rd_val_en    ;
//assign rd_sd_wfifo_data   = rd_val_data  ;
//wr 
assign wr_sd_rfifo_clk    = SD_clk_ref   ;
assign wr_sd_rfifo_rst_n  = sys_rst_n    ;
assign wr_sd_rfifo_req_en = wr_val_en    ;

//读SD卡数据 
data_gen u_data_gen(
    .clk                     (SD_clk_ref             ),
    .rst_n                   (sys_rst_n              ),
    .sd_init_done            (sd_init_done           ),
    .sys_cmos_image_save_req (sys_cmos_image_save_req),
    .wr_busy                 (wr_busy                ),
    .wr_start_en             (wr_start_en            ),
    .wr_sec_addr             (wr_sec_addr            ),
    .wr_data                 (w_wr_num               ),
    .o_state                 (w_state                ),
    // .wr_req               (wr_req                 ),
    // .wr_data              (wr_data                ),
    // .rd_val_en            (rd_val_en              ),
    // .rd_val_data          (rd_val_data            ),
    .sys_image_read_req      (sys_image_read_req     ),
    .rd_busy                 (rd_busy                ),
    .rd_start_en             (rd_start_en            ),
    .rd_sec_addr             (rd_sec_addr            ),
    .rd_data                 ( rd_val_data           ),
    .rd_data_valid           ( rd_val_en             ),
    // .error_flag           (error_flag             ),
    .fifo_16w32r_full        (    ),
    //.sd_image_done_n_reg     (rd_sd_image_done_n   ),
    .fifo_32w16r_full_flag   (wr_sdfifo_full_flag    ),
    .fifo_32w16r_len         (wr_sdfifo_len          ),
    .wr_sd_image_done        (wr_sd_image_done       )
    
   );   



//SD卡顶层控制模块
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (SD_clk_ref),
    .clk_ref_180deg    (SD_clk_ref_180deg),
    .rst_n             (sys_rst_n),
    .source_clk        (source_clk), //50MHZ，用于初始化
    //SD卡接口
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //用户写SD卡接口
    .wr_start_en       (wr_start_en),
    .wr_sec_addr       (wr_sec_addr),
    .wr_data           (w_sd_write_data),
    .wr_busy           (wr_busy),
    .wr_req            (wr_val_en),
    //用户读SD卡接口
    .rd_start_en       (rd_start_en),
    .rd_sec_addr       (rd_sec_addr),
    .rd_busy           (rd_busy),
    .rd_val_en         (rd_val_en),
    .rd_val_data       (rd_val_data),    
    
    .sd_init_done      (sd_init_done)
    );

always @(posedge SD_clk_ref or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        w_fifo_en_cnt <= 20'b0;
    end 
    else if(wr_val_en)begin
        w_fifo_en_cnt <= w_fifo_en_cnt + 20'b1;
    end 
    else begin
        w_fifo_en_cnt <= w_fifo_en_cnt;
    end
end 


assign w_sd_write_data = (w_state==2'b10) ? wr_sd_rfifo_data :w_wr_num;

endmodule