`timescale 1ns/1ns

module img_data_pkt(
    input                 rst_n                          ,   //复位信号，低电平有效
    //图像相关信号 单帧FRAME 
    input                 cam_pclk                       ,   //像素时钟
    input                 img_vsync                      ,   //帧同步信号
    input                 img_data_en                    ,   //数据有效使能信号
    input        [31:0]   img_data                       ,   //有效数据 
    input                 transfer_sigle_frame_flag      ,   //图像开始传输标志,1:开始传输 0:停止传输
    output reg            single_frame_transfer_done     ,   //单帧传输完成
    //图像相关信号 全帧FRAME 
    input                 transfer_all_frame_flag        ,   
    //图像开始传输标志,1:开始传输 0:停止传输 
    output wire           all_frame_transfer_done        ,   
    //全帧传输完成   
    input                 ddr_clk                        ,   //像素时钟
    input                 ddr_data_en                    ,   //数据有效使能信号
    input        [31:0]   ddr_data                       ,   //有效数据 
    input                 ddr_write_pre_first_flag_valid ,   //每帧开始标志
    output reg            ddr_write_pre_first_flag_ready ,
    input                 ddr_single_transfer_done       ,   //全帧传输中的单帧传输 DDR完成      
    output wire  [10:0]   eth_fifo_wrusedw               ,
    output wire           eth_fifo_wrfull                ,         
    output wire           eth_single_frame_eth_done      ,
    //以太网相关信号 
    input                 eth_tx_clk                     ,   //以太网发送时钟
    input                 udp_tx_req                     ,   //udp发送数据请求信号
    input                 udp_tx_done                    ,   //udp发送数据完成信号 
    output  reg           udp_tx_start_en                ,   //udp开始发送信号
    output       [31:0]   udp_tx_data                    ,   //udp发送的数据
    output  reg  [15:0]   udp_tx_byte_num                ,    //udp单包发送的有效字节数
    input wire            i_gmii_tx_busy                 
    );   

reg              ddr_rddone_eth_nondone_state        ;
//parameter define
parameter  CMOS_H_PIXEL   = 16'd1280         ;  //图像水平方向分辨率
parameter  CMOS_V_PIXEL   = 16'd800          ;  //图像垂直方向分辨率
//图像帧头,用于标志一帧数据的开始
parameter  IMG_FRAME_HEAD = {32'hf0_5a_a5_0f};
reg             img_pkt_busyn           ; 
//- SINGLE -------------------
reg             img_vsync_d0            ;  //帧有效信号打拍
reg             img_vsync_d1            ;  //帧有效信号打拍
reg             neg_vsync_d0            ;  //帧有效信号下降沿打拍
//- SINGLE -------------------
reg             wr_signle_fifo_en       ;  //写fifo使能
reg    [31:0]   wr_signle_fifo_data     ;  //写fifo数据
//-  ALL   -------------------
reg             wr_all_fifo_en          ;  //写fifo使能
reg    [31:0]   wr_all_fifo_data        ;  //写fifo数据
//- SINGLE -------------------
reg             img_vsync_txc_d0        ;  //以太网发送时钟域下,帧有效信号打拍
reg             img_vsync_txc_d1        ;  //以太网发送时钟域下,帧有效信号打拍
reg             r_transfer_flag         ;
reg             r_pos_edge_transfer_flag;
//reg             tx_busy_flag            ;  //发送忙信号标志

// wire w_wait ;
// reg [6:0] r_wait_cnt;
//wire define            

//- SINGLE -------------------
wire             udp_tx_single_req       ;
wire    [31:0]   udp_tx_single_data      ;   //udp发送的数据
//-  ALL  --------------------           
wire             udp_tx_all_req          ;
wire    [31:0]   udp_tx_all_data         ;   //udp发送的数据
wire             rd_empty                ;   //all_frame fifo empty 
//- SINGLE -------------------
wire            pos_vsync                ;  //帧有效信号上升沿
wire            neg_vsync                ;  //帧有效信号下降沿
wire            neg_vsync_txc            ;  //以太网发送时钟域下,帧有效信号下降沿
wire            pos_vsync_txc            ;
wire   [10:0]   fifo_single_rdusedw      ;  //当前FIFO缓存的个数
wire   [10:0]   fifo_all_rdusedw         ;
reg    [3:0]    r_trans_frame_num        ;  
//-----------------------------------------------------//
reg             eth_trans_singleN_or_allP;
reg             r_all_frame_trans_state                ; //表征当前为9多摄传输阶段 
//    output  reg  [15:0]   r_cnt        ；
//    output  reg  [19:0]   rd_cnt       ；
//*****************************************************
//**                    main code
//*****************************************************
reg     eth_single_frame_eth_done_d0 ;
reg     eth_single_frame_eth_done_d1 ;
reg     eth_single_frame_eth_done_d2 ;
reg     ddr_single_transfer_done_d0  ;
reg     ddr_single_transfer_done_d1  ;
reg     all_frame_transfer_done_d0   ; 
reg     all_frame_transfer_done_d1   ;
reg     all_frame_transfer_done_d2   ;

wire    ddr_single_transfer_done_pos ;
//信号采沿
assign neg_vsync     = img_vsync_d1      & (~img_vsync_d0)     ;
assign pos_vsync     = ~img_vsync_d1     & img_vsync_d0        ;
assign neg_vsync_txc = img_vsync_txc_d1  & (~img_vsync_txc_d0) ;
assign pos_vsync_txc = ~img_vsync_txc_d1 & img_vsync_txc_d0    ;
//对img_vsync信号延时两个时钟周期,用于采沿
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_d0 <= 1'b0;
        img_vsync_d1 <= 1'b0;
    end
    else begin
        img_vsync_d0 <= img_vsync    ;
        img_vsync_d1 <= img_vsync_d0 ;
    end
end

//寄存neg_vsync信号
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin 
        neg_vsync_d0 <= 1'b0;
    end 
    else begin 
        neg_vsync_d0 <= neg_vsync    ; 
    end 
end    

//将帧头和图像数据写入FIFO
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        wr_signle_fifo_en   <= 1'b0;
        wr_signle_fifo_data <= 1'b0;
    end
    else if (~eth_trans_singleN_or_allP)begin
        if(neg_vsync) begin
            wr_signle_fifo_en <= 1'b1;
            wr_signle_fifo_data <= IMG_FRAME_HEAD;               //帧头
        end
        else if(neg_vsync_d0) begin
            wr_signle_fifo_en <= 1'b1;
            wr_signle_fifo_data <= {CMOS_H_PIXEL,CMOS_V_PIXEL};  //水平和垂直方向分辨率
        end 
        else if(img_data_en) begin
            wr_signle_fifo_en   <= 1'b1;
            wr_signle_fifo_data <= img_data;      
          end
        else begin
            wr_signle_fifo_en <= 1'b0;
            wr_signle_fifo_data <= 1'b0;        
        end
    end
end

//以太网发送时钟域下,对img_vsync信号延时两个时钟周期,用于采沿
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_txc_d0 <= 1'b0;
        img_vsync_txc_d1 <= 1'b0;
    end
    else begin
        img_vsync_txc_d0 <= img_vsync;
        img_vsync_txc_d1 <= img_vsync_txc_d0;
    end
end            

//控制以太网发送的字节数
always @(posedge eth_tx_clk or negedge rst_n) begin      
    if(!rst_n)
        udp_tx_byte_num <= 'd0;
    else if (~eth_trans_singleN_or_allP)begin            //开启单帧传输
        if(neg_vsync_txc)
            udp_tx_byte_num <= CMOS_H_PIXEL+ 16'd8;      //行场2+列场2+验证码4
        else if(udp_tx_done)    
            udp_tx_byte_num <= CMOS_H_PIXEL;
        else 
            udp_tx_byte_num <= udp_tx_byte_num ;
    end 
    else begin
        if(ddr_write_pre_first_flag_valid)
            udp_tx_byte_num <= CMOS_H_PIXEL+ 16'd12;      //行场2+列场2+验证码4+通道数4
        else if(udp_tx_done)    
            udp_tx_byte_num <= CMOS_H_PIXEL;
        else 
            udp_tx_byte_num <= udp_tx_byte_num ;
    end 
end

always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        udp_tx_start_en <= 1'b0;
    end 
    //else if (~w_wait)begin 
    //    udp_tx_start_en <= 1'b0; 
    //end 
    //上位机未发送"开始"命令时,以太网不发送图像数据
    else if (~eth_trans_singleN_or_allP)begin                                            //开启单帧传输
        if(r_pos_edge_transfer_flag == 1'b0) begin                                       //开启单帧传输
            udp_tx_start_en <= 1'b0;                                                     //开启单帧传输
        end                                                                              //开启单帧传输
        else if(!i_gmii_tx_busy && fifo_single_rdusedw >= udp_tx_byte_num[12:2]) begin
            //当FIFO中的个数满足需要发送的字节数时 
            //if(r_cnt<=16'd5)  //TEST
            udp_tx_start_en <= 1'b1;                     //开始控制发送一包数据
        end 
        else begin 
            udp_tx_start_en <= 1'b0; 
        end 
    end 
    else begin 
        if (~r_all_frame_trans_state)begin 
            udp_tx_start_en <= 1'b0;                  
        end 
        else if(!i_gmii_tx_busy && fifo_all_rdusedw >= udp_tx_byte_num[12:2]) begin
            //当FIFO中的个数满足需要发送的字节数时 
            //if(r_cnt<=16'd5)  //TEST
            udp_tx_start_en <= 1'b1;                     //开始控制发送一包数据
        end 
        else begin 
            udp_tx_start_en <= 1'b0; 
        end 
    end 
end

//r_transfer_flag
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n)begin 
        r_transfer_flag <= 1'b0;
        r_pos_edge_transfer_flag <= 1'b0;
        single_frame_transfer_done <= 1'b0;
    end 
    else if (transfer_sigle_frame_flag)begin 
        r_transfer_flag <= 1'b1; 
        r_pos_edge_transfer_flag <= 1'b0;
        single_frame_transfer_done <= 1'b0;
    end 
    else if(pos_vsync_txc && r_transfer_flag)begin 
        r_pos_edge_transfer_flag <= 1'b1; 
        r_transfer_flag <= 1'b0;
        single_frame_transfer_done <= 1'b0;
    end 
    else if (pos_vsync_txc && r_pos_edge_transfer_flag) begin
        r_pos_edge_transfer_flag <= 1'b0; 
        r_transfer_flag <= 1'b0;
        single_frame_transfer_done <= 1'b1;
    end 
    else begin 
        r_transfer_flag <= r_transfer_flag ;
        r_pos_edge_transfer_flag <= r_pos_edge_transfer_flag;
        single_frame_transfer_done <= 1'b0;
    end 
end

//异步FIFO
fifo_eth_8w32r async_fifo_2048x32b_sigle(
    .aclr     (pos_vsync           ),
    .wrclk    (cam_pclk            ),
    .wrreq    (wr_signle_fifo_en   ),
    .data     (wr_signle_fifo_data ),      //WRFIFO
    .rdclk    (eth_tx_clk          ),
    .rdreq    (udp_tx_single_req   ),
    .q        (udp_tx_single_data  ),      //RDFIFO
    .rdempty  (                    ),
    .rdusedw  (fifo_single_rdusedw ),   //  2048 * 8 
    .wrfull   (                    )
    );

//- ALL ----------------------------------------------------
//reg             pos_ddr_write_pre_first_flag_d0        ;
//reg             pos_ddr_write_pre_first_flag_d1        ;
//wire            pos_ddr_write_pre_first_flag           ;
reg             ddr_write_pre_first_flag_d0            ;  //有效信号打拍
reg             ddr_write_pre_first_flag_d1            ;  //有效信号打拍
reg             ddr_write_pre_first_flag_d2            ;  //有效信号打拍
//
//always @(posedge ddr_clk or negedge rst_n) begin
//    if(!rst_n) begin 
//        pos_ddr_write_pre_first_flag_d0 <= 1'b0;
//        pos_ddr_write_pre_first_flag_d1 <= 1'b0;
//    end 
//    else begin 
//        pos_ddr_write_pre_first_flag_d0 <= ddr_write_pre_first_flag        ; 
//        pos_ddr_write_pre_first_flag_d1 <= pos_ddr_write_pre_first_flag_d0 ;
//    end 
//end  
//
always @(posedge ddr_clk or negedge rst_n) begin
    if(!rst_n) begin
        ddr_write_pre_first_flag_d0  <= 1'b0;
        ddr_write_pre_first_flag_d1  <= 1'b0;
        ddr_write_pre_first_flag_d2  <= 1'b0;
    end
    else begin
        ddr_write_pre_first_flag_d0  <= ddr_write_pre_first_flag_ready&ddr_write_pre_first_flag_valid ;
        ddr_write_pre_first_flag_d1  <= ddr_write_pre_first_flag_d0 ;
        ddr_write_pre_first_flag_d2  <= ddr_write_pre_first_flag_d1 ;
    end
end
//assign pos_ddr_write_pre_first_flag = ddr_write_pre_first_flag_d0 & ~ddr_write_pre_first_flag_d1 ;

//将帧头和图像数据写入FIFO
always @(posedge ddr_clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_all_fifo_en <= 1'b0;
        wr_all_fifo_data <= 'b0;
    end
    else if(eth_trans_singleN_or_allP) begin
        if(ddr_write_pre_first_flag_d0) begin
            wr_all_fifo_en   <= 1'b1;
            wr_all_fifo_data <= IMG_FRAME_HEAD;               //帧头
        end
        else if(ddr_write_pre_first_flag_d1) begin
            wr_all_fifo_en   <= 1'b1;
            wr_all_fifo_data <= {CMOS_H_PIXEL,CMOS_V_PIXEL};  //水平和垂直方向分辨率
        end  
        else if(ddr_write_pre_first_flag_d2)begin 
            wr_all_fifo_en   <= 1'b1;
            wr_all_fifo_data <= {28'd0,r_trans_frame_num};  //水平和垂直方向分辨率
        end 
        else if(ddr_data_en) begin
            wr_all_fifo_en   <= 1'b1     ;
            wr_all_fifo_data <= ddr_data ;      
        end
        else begin
            wr_all_fifo_en   <= 1'b0;
            wr_all_fifo_data <= 'b0;        
        end
    end
end

always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        r_trans_frame_num <= 4'b0 ;
    end
    else if (eth_single_frame_eth_done_d0)begin
        r_trans_frame_num <= r_trans_frame_num + 4'd1;
    end 
    else if (r_trans_frame_num==4'd9)begin 
        r_trans_frame_num <= 4'b0 ;
    end 
    else begin 
        r_trans_frame_num <= r_trans_frame_num ;
    end 
end

always @(posedge eth_tx_clk or negedge rst_n) begin                   
    if(!rst_n) begin
        eth_trans_singleN_or_allP <= 1'b0 ;
    end
    else if (img_pkt_busyn & transfer_sigle_frame_flag)begin
        eth_trans_singleN_or_allP <= 1'b0;
    end 
    else if (img_pkt_busyn & transfer_all_frame_flag  )begin 
        eth_trans_singleN_or_allP <= 1'b1 ;
    end 
    else begin 
        eth_trans_singleN_or_allP <= eth_trans_singleN_or_allP ;
    end 
end 

always @(posedge eth_tx_clk or negedge rst_n) begin 
    if(!rst_n) begin
        img_pkt_busyn <= 1'b1 ;
    end
    else if (transfer_sigle_frame_flag | transfer_all_frame_flag )begin
        img_pkt_busyn <= 1'b0;
    end 
    else if (single_frame_transfer_done | all_frame_transfer_done_d0)begin 
        img_pkt_busyn <= 1'b1 ;
    end 
    else begin 
        img_pkt_busyn <= img_pkt_busyn ;
    end 
end 


always @(posedge eth_tx_clk or negedge rst_n) begin                   
    if(!rst_n) begin
        all_frame_transfer_done_d0 <= 1'b0 ;
        all_frame_transfer_done_d1 <= 1'b0 ;
        all_frame_transfer_done_d2 <= 1'b0 ;
    end
    else if ( r_trans_frame_num == 4'd8 && eth_single_frame_eth_done_d0 )begin
        all_frame_transfer_done_d0 <= 1'b1;
    end 
    else begin 
        all_frame_transfer_done_d0 <= 1'b0 ;
        all_frame_transfer_done_d1 <= all_frame_transfer_done_d0 ;
        all_frame_transfer_done_d2 <= all_frame_transfer_done_d1 ;
    end 
end 


always @(posedge eth_tx_clk or negedge rst_n) begin //DDR读单帧完成，以太网传输未完成
    if(!rst_n) begin 
        ddr_single_transfer_done_d0 <= 1'b0 ;
        ddr_single_transfer_done_d1 <= 1'b0 ;
    end 
    else begin 
        ddr_single_transfer_done_d0 <= ddr_single_transfer_done ;
        ddr_single_transfer_done_d1 <= ddr_single_transfer_done_d0 ; 
    end 
end 

always @(posedge eth_tx_clk or negedge rst_n) begin //DDR读单帧完成，以太网传输未完成
    if(!rst_n) 
        ddr_rddone_eth_nondone_state <= 1'b0 ;
    else if (ddr_single_transfer_done_pos)
        ddr_rddone_eth_nondone_state <= 1'b1 ;
    else if (ddr_rddone_eth_nondone_state&&rd_empty&&udp_tx_done)
        ddr_rddone_eth_nondone_state <= 1'b0 ;
    else 
        ddr_rddone_eth_nondone_state <= ddr_rddone_eth_nondone_state ;
end 

always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) 
        r_all_frame_trans_state <= 1'b0 ;
    else if (ddr_write_pre_first_flag_ready)
        r_all_frame_trans_state <= 1'b1 ;
    else if (eth_single_frame_eth_done_d0)
        r_all_frame_trans_state <= 1'b0 ;
    else 
        r_all_frame_trans_state <= r_all_frame_trans_state ;
end 

always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) 
        ddr_write_pre_first_flag_ready <= 1'b0 ;
    else if (ddr_write_pre_first_flag_valid)
        ddr_write_pre_first_flag_ready <= 1'b1 ;
    else if (~ddr_write_pre_first_flag_valid)
        ddr_write_pre_first_flag_ready <= 1'b0 ;
end 

//-ETH 单帧图像传输完成 扩展给ETH ddr_slave
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin 
        eth_single_frame_eth_done_d0 <= 1'b0 ;
        eth_single_frame_eth_done_d1 <= 1'b0 ;
        eth_single_frame_eth_done_d2 <= 1'b0 ;
    end 
    else if (ddr_rddone_eth_nondone_state&&rd_empty&&udp_tx_done) begin 
    //查看udp_tx_done是否在结束后，发生传输完成信号
        eth_single_frame_eth_done_d0 <= 1'b1 ; 
        eth_single_frame_eth_done_d1 <= 1'b0 ;
        eth_single_frame_eth_done_d2 <= 1'b0 ;
    end 
    else begin 
        eth_single_frame_eth_done_d0 <= 1'b0 ; 
        eth_single_frame_eth_done_d1 <= eth_single_frame_eth_done_d0 ;
        eth_single_frame_eth_done_d2 <= eth_single_frame_eth_done_d1 ;
    end 
end 


//异步FIFO
fifo_eth_8w32r async_fifo_2048x32b_all (
    .aclr     ( ddr_write_pre_first_flag_ready ),
    .wrclk    ( ddr_clk                  ),
    .wrreq    ( wr_all_fifo_en           ),
    .data     ( wr_all_fifo_data         ),
    .wrusedw  ( eth_fifo_wrusedw         ),
    .rdclk    ( eth_tx_clk               ),
    .rdreq    ( udp_tx_all_req           ),
    .q        ( udp_tx_all_data          ),
    .rdempty  ( rd_empty                 ),
    .rdusedw  ( fifo_all_rdusedw         ),   //  2048 * 8 
    .wrfull   ( eth_fifo_wrfull          )
    );

assign udp_tx_data       = eth_trans_singleN_or_allP ? udp_tx_all_data : udp_tx_single_data ;
assign udp_tx_all_req    = eth_trans_singleN_or_allP ? udp_tx_req      : 1'b0               ;
assign udp_tx_single_req = eth_trans_singleN_or_allP ? 1'b0            : udp_tx_req         ;
assign eth_single_frame_eth_done = eth_single_frame_eth_done_d0 | eth_single_frame_eth_done_d1 |eth_single_frame_eth_done_d2;
assign  all_frame_transfer_done = all_frame_transfer_done_d0 | all_frame_transfer_done_d1 | all_frame_transfer_done_d2 ;
assign ddr_single_transfer_done_pos = ddr_single_transfer_done_d0 & ~ddr_single_transfer_done_d1 ;




endmodule