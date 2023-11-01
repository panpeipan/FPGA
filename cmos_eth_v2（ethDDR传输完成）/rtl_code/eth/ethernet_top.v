`timescale 1ns / 1ps

module ethernet_top
#(
    parameter BOARD_MAC  = (48'h00_11_22_33_44_55       ),
    parameter BOARD_IP   = ({8'd192,8'd168,8'd1,8'd10}  ),
    parameter DES_MAC    = (48'hff_ff_ff_ff_ff_ff       ),
    parameter DES_IP     = ({8'd192,8'd168,8'd1,8'd102} )
)( 
	input                  reset_n                        ,    
    input                  i_touch_key                    ,  //arp_key
	input                  fpga_gclk                      ,  //NULL 
	output                 e_reset                        ,
//output CLK_25_ASIC,                          
    output                 e_mdc                          ,  //NULL
	inout                  e_mdio                         ,  //NULL
//rec                         
	input                  e_rxc                          ,  //125Mhz ethernet gmii rx clock
	input                  e_rxdv                         ,	
	input                  e_rxer                         ,	//NULL					
	input  [7:0]           e_rxd                          ,        
//tx                                   
	input                  e_txc                          ,  //NULL 25Mhz ethernet mii tx clock       
	output                 e_gtxc                         ,  //25Mhz ethernet gmii tx clock  
	output                 e_txen                         , 
	output                 e_txer                         , 					
	output [7:0]           e_txd	                      ,
//-------------------------------------
//udp
    //rec
    output wire            o_gmii_rec_clk                 ,
    output wire            o_udp_rec_pkt_done             ,   
    output wire            o_udp_rec_data_valid           ,   
    output wire [ 7: 0]    o_udp_rec_data                 ,   
    output wire [15: 0]    o_udp_rec_byte_num             ,   
    //tx 
    output wire            o_gmii_tx_clk                  ,
    output wire            o_udp_tx_pkt_done              ,
    input  wire            i_tx_start_en                  ,   
    output wire            o_fifo_data_req                ,   
    input  wire [31: 0]    i_tx_data                      ,   
    input  wire [15: 0]    i_tx_byte_num                  ,
    output wire            o_gmii_tx_busy
);
// req - valid 
wire            w_arp_tx_req         ;
wire            w_arp_tx_valid       ;
wire            w_udp_req            ;
wire            w_udp_tx_valid       ;

wire [47:0]     w_arp_desmac_addr    ;
wire [31:0]     w_arp_desip_addr     ;
wire            w_arp_tx_en          ;
wire [7: 0]     w_arp_tx_data        ;

wire            w_gmii_udp_dv        ;
wire [7: 0]     w_gmii_udp_data      ;
wire            w_gmii_tx_busy       ;


wire [5 : 0]    w_rdfifo_depth       ;

assign e_gtxc = e_rxc ;	    //gtxc输出125Mhz的时钟
assign o_gmii_rec_clk = e_rxc ;
assign o_gmii_tx_clk  = e_rxc ;
arp_top 
#(
    .BOARD_MAC    (BOARD_MAC),
    .BOARD_IP     (BOARD_IP ),
    .DES_MAC      (DES_MAC  ),
    .DES_IP       (DES_IP   )
)arp_m0
(
    .i_rst_n               (reset_n          ), //复位信号，低电平有效 
    .i_touch_key           (i_touch_key      ),
    //GMII接口                               
    .i_gmii_rx_clk         (e_rxc            ), //GMII接收数据时钟
    .i_gmii_rx_dv          (e_rxdv           ), //GMII输入数据有效信号
    .i_gmii_rx_data        (e_rxd            ),  //GMII输入数据
    .i_gmii_tx_clk         (e_gtxc           ), //GMII发送数据时钟
    .o_gmii_tx_en          (w_arp_tx_en      ), //GMII输出数据有效信号
    .o_gmii_tx_error       (                 ),
    .o_gmii_tx_data        (w_arp_tx_data    ), //GMII输出数据  
    .o_phy_rsetn           (                 ), //phy芯片复位，低电平有效
    .o_arp_tx_req          (w_arp_tx_req     ),
    .i_arp_tx_valid        (w_arp_tx_valid   ),    
    .o_arp_desmac_addr     (w_arp_desmac_addr),
    .o_arp_desip_addr      (w_arp_desip_addr )
);

udp  
#(
	.BOARD_MAC    (BOARD_MAC),
	.BOARD_IP     (BOARD_IP ),
	.DES_MAC      (DES_MAC  ),
	.DES_IP       (DES_IP   )
)udp_m1
(
    .i_sys_rstn          ( reset_n            ),
    .i_gmii_rx_clk       ( e_rxc              ),
    .i_gmii_rx_dv        ( e_rxdv             ),
    .i_gmii_rx_data      ( e_rxd              ),
    .i_gmii_tx_clk       ( e_gtxc             ),
    .o_gmii_tx_dv        ( w_gmii_udp_dv      ),
    .o_gmii_tx_data      ( w_gmii_udp_data    ),
    //rec
    .o_rec_pkt_done      (o_udp_rec_pkt_done  ),   // FIFO LOOP
    .o_rec_data_valid    (o_udp_rec_data_valid),   // FIFO LOOP
    .o_rec_data          (o_udp_rec_data      ),   // FIFO LOOP
    .o_rec_byte_num      (o_udp_rec_byte_num  ),   // FIFO LOOP
    //tx
    .i_tx_start_en       (i_tx_start_en       ),   // FIFO LOOP
    .o_fifo_data_req     (o_fifo_data_req     ),   // FIFO LOOP
    .i_tx_data           (i_tx_data           ),   // FIFO LOOP
    .i_tx_byte_num       (i_tx_byte_num       ),   // FIFO LOOP
    .i_des_mac           (w_arp_desmac_addr   ),
    .i_des_ip            (w_arp_desip_addr    ),
    .o_tx_done           (o_udp_tx_pkt_done   ),
    .o_tx_udp_req        (w_udp_req           ),
    .i_tx_udp_valid      (w_udp_tx_valid      ),
    .i_gmii_tx_busy      (w_gmii_tx_busy      )
);

gmii_tx_ctrl gmii_tx_ctrlm2
(
    .i_sys_rstn          (reset_n         ),
    .i_gmii_clk          (e_gtxc          ),
    //arp    
    .i_arp_req           (w_arp_tx_req    ),
    .o_arp_valid         (w_arp_tx_valid  ),
    .i_gmii_arp_dv       (w_arp_tx_en     ),
    .i_gmii_arp_data     (w_arp_tx_data   ),
    //udp                       
    .i_udp_req           (w_udp_req       ),
    .o_udp_tx_valid      (w_udp_tx_valid  ),
    .i_gmii_udp_dv       (w_gmii_udp_dv   ),
    .i_gmii_udp_data     (w_gmii_udp_data ),
    //状态                      
    .o_tx_arpp_udpn      (),
    .o_tx_busy           (w_gmii_tx_busy  ),
    //output gmii               
    .o_gmii_tx_en        (e_txen          ), //GMII输出数据有效信号
    .o_gmii_tx_error     (e_txer          ),
    .o_gmii_tx_data      (e_txd           ), //GMII输出数据  
    .o_phy_rsetn         (e_reset         )  //phy芯片复位，低电平有效
);

assign o_gmii_tx_busy = w_gmii_tx_busy ;

endmodule
