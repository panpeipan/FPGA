module arp_top 
#(
    //parameter define
    //开发板MAC地址 00-11-22-33-44-55
    parameter  BOARD_MAC = 48'h00_11_22_33_44_55,     
    //开发板IP地址 192.168.1.10
    parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
    //目的MAC地址 ff_ff_ff_ff_ff_ff
    parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff,   
    //目的IP地址 192.168.1.102     
    parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102}    
)
(
    input                       i_rst_n              , //复位信号，低电平有效 
    input                       i_touch_key          ,
    //GMII接口                  
    input                       i_gmii_rx_clk        , //GMII接收数据时钟
    input                       i_gmii_rx_dv         , //GMII输入数据有效信号
    input        [7:0]          i_gmii_rx_data       , //GMII输入数据
    input                       i_gmii_tx_clk        , //GMII发送数据时钟
    output                      o_gmii_tx_en         , //GMII输出数据有效信号
    output                      o_gmii_tx_error      ,
    output       [7:0]          o_gmii_tx_data       , //GMII输出数据  
    output                      o_phy_rsetn          , //phy芯片复位，低电平有效
    output                      o_arp_tx_req         ,
    input                       i_arp_tx_valid       ,
    output       [47:0]         o_arp_desmac_addr    ,
    output       [31:0]         o_arp_desip_addr     
);
//----------------------------------------------------//
// wire
//----------------------------------------------------//
wire               w_arp_rx_done        ; //ARP接收完成信号
wire               w_arp_rx_type        ; //ARP接收类型 0:请求  1:应答
wire       [47:0]  w_arp_srcmac_addr    ; //接收到目的MAC地址
wire       [31:0]  w_arp_srcip_addr     ; //接收到目的IP地址    
wire               w_arp_tx_en          ; //ARP发送使能信号
wire               w_arp_tx_type        ; //ARP发送类型 0:请求  1:应答
wire       [47:0]  w_arp_desmac_addr    ; //发送的目标MAC地址
wire       [31:0]  w_arp_desip_addr     ; //发送的目标IP地址
wire               w_arp_tx_done        ; //以太网发送完成信号    
//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign o_phy_rsetn      = i_rst_n ; 
assign o_gmii_tx_error  = 1'b0    ;

arp #(
    .BOARD_MAC ( 48'h00_11_22_33_44_55       ),    
    .BOARD_IP  ( {8'd192,8'd168,8'd1,8'd10}  ),
    .DES_MAC   ( 48'hff_ff_ff_ff_ff_ff       ),
    .DES_IP    ( {8'd192,8'd168,8'd1,8'd102} )
)arp_m0(
    .i_rst_n            (i_rst_n ), //复位信号，低电平有效
    //GMII接口
    .i_gmii_rx_clk      (i_gmii_rx_clk     ), //GMII接收数据时钟
    .i_gmii_rx_dv       (i_gmii_rx_dv      ), //GMII输入数据有效信号
    .i_gmii_rx_data     (i_gmii_rx_data    ), //GMII输入数据
    .i_gmii_tx_clk      (i_gmii_tx_clk     ), //GMII发送数据时钟
    .o_gmii_tx_en       (o_gmii_tx_en      ), //GMII输出数据有效信号
    .o_gmii_tx_data     (o_gmii_tx_data    ), //GMII输出数据          
    //用户接口
    .o_arp_rx_done      (w_arp_rx_done     ), //ARP接收完成信号
    .o_arp_rx_type      (w_arp_rx_type     ), //ARP接收类型 0:请求  1:应答
    .o_arp_srcmac_addr  (w_arp_srcmac_addr ), //接收到目的MAC地址
    .o_arp_srcip_addr   (w_arp_srcip_addr  ), //接收到目的IP地址    
    .i_arp_tx_en        (w_arp_tx_en       ), //ARP发送使能信号
    .i_arp_tx_type      (w_arp_tx_type     ), //ARP发送类型 0:请求  1:应答
    .i_arp_desmac_addr  (w_arp_desmac_addr ), //发送的目标MAC地址
    .i_arp_desip_addr   (w_arp_desip_addr  ), //发送的目标IP地址
    .o_arp_tx_done      (w_arp_tx_done     ) //以太网发送完成信号    
);
arp_ctrl arp_ctrl_m1    
(
    .i_rst_n              (i_rst_n           ),
    .i_crtl_clk           (i_gmii_rx_clk     ),
    .i_touch_key          (i_touch_key       ),
    .i_arp_rx_done        (w_arp_rx_done     ),
    .i_arp_rx_type        (w_arp_rx_type     ),              //0：请求 1：应答
    .i_arp_rx_srcmac_addr (w_arp_srcmac_addr ),
    .i_arp_rx_srcip_addr  (w_arp_srcip_addr  ),
    .o_arp_tx_en          (w_arp_tx_en       ),
    .o_arp_tx_type        (w_arp_tx_type     ),
    .o_arp_tx_desmac_addr (w_arp_desmac_addr ),
    .o_arp_tx_desip_addr  (w_arp_desip_addr  ),
    .i_arp_tx_done        (w_arp_tx_done     ),
    .o_arp_tx_req         (o_arp_tx_req  ),
    .i_arp_tx_valid       (i_arp_tx_valid)
);

assign o_arp_desmac_addr =  w_arp_desmac_addr;
assign o_arp_desip_addr  =  w_arp_desip_addr ;


endmodule 
