module arp 
#(
    //parameter define
    //开发板MAC地址 00-11-22-33-44-55
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,    
    //开发板IP地址 192.168.1.10 
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    //目的MAC地址 ff_ff_ff_ff_ff_ff
    parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    //目的IP地址 192.168.1.102     
    parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)(
    input                i_rst_n             , //复位信号，低电平有效
    //GMII接口
    input                i_gmii_rx_clk       , //GMII接收数据时钟
    input                i_gmii_rx_dv        , //GMII输入数据有效信号
    input        [7:0]   i_gmii_rx_data      , //GMII输入数据
    input                i_gmii_tx_clk       , //GMII发送数据时钟
    output               o_gmii_tx_en        , //GMII输出数据有效信号
    output       [7:0]   o_gmii_tx_data      , //GMII输出数据          

    //用户接口
    output               o_arp_rx_done       , //ARP接收完成信号
    output               o_arp_rx_type       , //ARP接收类型 0:请求  1:应答
    output       [47:0]  o_arp_srcmac_addr   , //接收到目的MAC地址
    output       [31:0]  o_arp_srcip_addr    , //接收到目的IP地址    
    input                i_arp_tx_en         , //ARP发送使能信号
    input                i_arp_tx_type       , //ARP发送类型 0:请求  1:应答
    input        [47:0]  i_arp_desmac_addr   , //发送的目标MAC地址
    input        [31:0]  i_arp_desip_addr    , //发送的目标IP地址
    output               o_arp_tx_done         //以太网发送完成信号    
);
     
//----------------------------------------------------//
// local parameter
//----------------------------------------------------//


//----------------------------------------------------//
// state mechine
//----------------------------------------------------//


//----------------------------------------------------//
// reg
//----------------------------------------------------//


//----------------------------------------------------//
// wire
//----------------------------------------------------//
//wire define
wire          w_crc_en  ; //CRC开始校验使能
wire          w_crc_clr ; //CRC数据复位信号 
wire   [7:0]  w_crc_d8  ; //输入待校验8位数据
wire   [31:0] w_crc_data; //CRC校验数据
wire   [31:0] w_crc_next; //CRC下次校验完成数据
    
//----------------------------------------------------//
// main_code
//----------------------------------------------------//


//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign w_crc_d8 = o_gmii_tx_data;

arp_rx 
#(
    .BOARD_MAC (BOARD_MAC),
    .BOARD_IP  (BOARD_IP )
)arp_rx_u0(
    .i_rst_n                (i_rst_n          ),
    .i_gmii_rxc             (i_gmii_rx_clk    ),
    .i_gmii_rx_dv           (i_gmii_rx_dv     ),
    .i_gmii_rxd             (i_gmii_rx_data   ),
    .o_arp_rx_done          (o_arp_rx_done    ),
    .o_arp_rx_type          (o_arp_rx_type    ),
    .o_arp_srcmac_addr      (o_arp_srcmac_addr),
    .o_arp_srcip_addr       (o_arp_srcip_addr )
);

arp_tx 
#(
    .BOARD_MAC (BOARD_MAC),
    .BOARD_IP  (BOARD_IP ),
    .DES_MAC   (DES_MAC ),
    .DES_IP    (DES_IP  )
)arp_tx_u0(
    .i_rst_n            (i_rst_n),
    .i_gmii_tx_clk      (i_gmii_tx_clk),
    .o_gmii_tx_data     (o_gmii_tx_data),
    .o_gmii_tx_en       (o_gmii_tx_en),
    .i_arp_tx_req       (i_arp_tx_en),
    .o_arp_tx_done      (o_arp_tx_done),
    .i_arp_tx_type      (i_arp_tx_type), // ARP发送类型 0：请求 1：应答
    .i_arp_desmac_addr  (i_arp_desmac_addr),
    .i_arp_desip_addr   (i_arp_desip_addr),
    .i_crc_data         (w_crc_data),
    .i_crc_next         (w_crc_next[31:24]),
    .o_crc_en           (w_crc_en),
    .o_crc_clr          (w_crc_clr)
);
crc32_d8   u_crc32_d8(
    .clk             (i_gmii_tx_clk),                      
    .rst_n           (i_rst_n      ),                          
    .data            (w_crc_d8     ),            
    .crc_en          (w_crc_en     ),                          
    .crc_clr         (w_crc_clr    ),                         
    .crc_data        (w_crc_data   ),                        
    .crc_next        (w_crc_next   )                         
);
endmodule 
