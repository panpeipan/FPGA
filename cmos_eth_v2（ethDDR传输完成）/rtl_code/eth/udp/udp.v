`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns
module udp 
#(
	parameter   BOARD_MAC = 48'h001122334455,
	parameter   BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
	parameter   DES_MAC   = 48'hffffffffffff,
	parameter   DES_IP    = {8'd192,8'd168,8'd1,8'd102},
    parameter   BOARD_PORTNUM  = 16'd1010 ,
    parameter   PC_PORTNUM = 16'd2020
)
(
    input  wire            i_sys_rstn      ,
    input  wire            i_gmii_rx_clk   ,
    input  wire            i_gmii_rx_dv    ,
    input  wire [7: 0]     i_gmii_rx_data  ,
    input  wire            i_gmii_tx_clk   ,
    output wire            o_gmii_tx_dv    ,
    output wire [7: 0]     o_gmii_tx_data  ,

    output wire            o_rec_pkt_done  ,
    output wire            o_rec_data_valid,
    output wire [7: 0]     o_rec_data      ,
    output wire [15: 0]    o_rec_byte_num  ,

    input  wire            i_tx_start_en   ,
    output wire            o_fifo_data_req ,
    input  wire [31: 0]    i_tx_data       ,
    input  wire [15: 0]    i_tx_byte_num   ,
    input  wire [47: 0]    i_des_mac       ,
    input  wire [31: 0]    i_des_ip        ,
    output wire            o_tx_done       ,
    output reg             o_tx_udp_req    ,
    input  wire            i_tx_udp_valid  ,
    input  wire            i_gmii_tx_busy          //gmii_busy ，在忙为0 ， 不忙为1 
);

//----------------------------------------------------//
// wire
//----------------------------------------------------//
wire              w_crc_en  ;
wire              w_crc_clr ;
wire [7 :0]       w_crc_d8  ;
wire [31:0]       w_crc_data;
wire [31:0]       w_crc_next;

//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always@(posedge i_gmii_tx_clk or negedge i_sys_rstn)begin 
    if(!i_sys_rstn)begin 
        o_tx_udp_req <= 1'b0 ;
    end 
    else if (i_tx_udp_valid)begin 
        o_tx_udp_req <= 1'b0 ;
    end 
    else if (i_tx_start_en&&!i_gmii_tx_busy)begin 
        o_tx_udp_req <= 1'b1 ;
    end 
    //else if (o_rec_pkt_done)begin              //LOOP 
    //    o_tx_udp_req <= 1'b1 ;                 //LOOP 
    //end                                        //LOOP 
    else begin 
        o_tx_udp_req <= o_tx_udp_req ;
    end 
end 


udp_rx #(
    .BOARD_MAC     ( 48'h001122334455            ),
    .BOARD_IP      ( {8'd192,8'd168,8'd1,8'd10}  ),
    .DES_MAC       ( 48'hffffffffffff            ),
    .DES_IP        ( {8'd192,8'd168,8'd1,8'd102} ),
    .BOARD_PORTNUM ( BOARD_PORTNUM                    )
)rx_u0
(
    .i_sys_rstn      (i_sys_rstn                  ),
    .i_gmii_rx_clk   (i_gmii_rx_clk               ),
    .i_gmii_rx_dv    (i_gmii_rx_dv                ),
    .i_gmii_rx_data  (i_gmii_rx_data              ),
	.o_udp_rec_done  (o_rec_pkt_done              ),
	.o_rec_dvalid    (o_rec_data_valid            ),
	.o_rec_data      (o_rec_data                  ),
	.o_rec_data_num  (o_rec_byte_num              )
);



udp_tx#(
    .BOARD_MAC     ( 48'h001122334455            ),
    .BOARD_IP      ( {8'd192,8'd168,8'd1,8'd10}  ),
    .DES_MAC       ( 48'hffffffffffff            ),
    .DES_IP        ( {8'd192,8'd168,8'd1,8'd102} ),
	.BOARD_PORTNUM ( BOARD_PORTNUM               ),
	.PC_PORTNUM    ( PC_PORTNUM                  )
)tx_u1
(
   .i_sys_rstn       (i_sys_rstn                  ),
   .i_gmii_tx_clk    (i_gmii_tx_clk               ),
   .i_udp_tx_start_en(o_tx_udp_req&&i_tx_udp_valid),    //以太网开始发送信号
   .i_fifo_tx_data   (i_tx_data                   ),    //以太网待发送数据  
   .o_fifo_data_req  (o_fifo_data_req             ),    //以太网数据请求
   .i_udp_tx_byte_num(i_tx_byte_num               ),    //以太网发送的有效字节数
   .i_des_mac        (i_des_mac                   ),    //发送的目标MAC地址
   .i_des_ip         (i_des_ip                    ),    //发送的目标IP地址    
   .i_crc_data       (w_crc_data                  ),    //CRC校验数据
   .i_crc_next       (w_crc_next[31:24]           ),    //CRC下次校验完成数据
   .o_udp_tx_done    (o_tx_done                   ),    //以太网发送完成信号
   .o_gmii_tx_dv     (o_gmii_tx_dv                ),    //GMII输出数据有效信号
   .o_gmii_tx_data   (o_gmii_tx_data              ),    //GMII输出数据
   .o_crc_en         (w_crc_en                    ),    //CRC开始校验使能
   .o_crc_clr        (w_crc_clr                   )     //CRC数据复位信号 
);

crc32_d8   crc32_d8_u2
(
    .clk             (i_gmii_tx_clk),                      
    .rst_n           (i_sys_rstn   ),                          
    .data            (w_crc_d8     ),            
    .crc_en          (w_crc_en     ),                          
    .crc_clr         (w_crc_clr    ),                         
    .crc_data        (w_crc_data   ),                        
    .crc_next        (w_crc_next   )                         
);

//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign w_crc_d8 = o_gmii_tx_data ;
endmodule 
