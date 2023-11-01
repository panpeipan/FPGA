module gmii_tx_ctrl 
(
    input    wire                i_sys_rstn          ,
    input    wire                i_gmii_clk          ,
    //arp    
    input    wire                i_arp_req           ,
    output   reg                 o_arp_valid         , //表征此时ARP发送有效
    input    wire                i_gmii_arp_dv       ,
    input    wire  [7:0]         i_gmii_arp_data     ,
    //udp                       
    input    wire                i_udp_req           ,
    output   reg                 o_udp_tx_valid      , //表征此时UDP发送有效
    input    wire                i_gmii_udp_dv       ,
    input    wire  [7:0]         i_gmii_udp_data     ,
    //状态                      
    output   reg                 o_tx_arpp_udpn      ,
    output   reg                 o_tx_busy           ,
    //控制端口此时属于ARP还是UDP - output gmii               
    output   wire                o_gmii_tx_en        , //GMII输出数据有效信号
    output   wire                o_gmii_tx_error     ,
    output   wire   [7:0]        o_gmii_tx_data      , //GMII输出数据  
    output   wire                o_phy_rsetn           //phy芯片复位，低电平有效
);

always@(posedge i_gmii_clk or negedge i_sys_rstn )begin 
    if(!i_sys_rstn)begin 
        o_arp_valid    <= 1'b0 ;
        o_udp_tx_valid <= 1'b0 ;
        o_tx_arpp_udpn <= 1'b0 ;
    end 
    else if (i_arp_req && !o_tx_busy) begin 
        o_arp_valid    <= 1'b1 ;
        o_udp_tx_valid <= 1'b0 ;
        o_tx_arpp_udpn <= 1'b1 ;
    end 
    else if (i_udp_req && !o_tx_busy) begin 
        o_arp_valid    <= 1'b0 ;
        o_udp_tx_valid <= 1'b1 ;
        o_tx_arpp_udpn <= 1'b0 ;
    end 
    else begin 
        o_arp_valid    <= 1'b0 ;
        o_udp_tx_valid <= 1'b0 ;
        o_tx_arpp_udpn <= o_tx_arpp_udpn ;
    end 
end 

always@(posedge i_gmii_clk or negedge i_sys_rstn )begin 
    if(!i_sys_rstn)begin 
        o_tx_busy <= 1'b0 ;
    end 
    else if (i_arp_req && !o_tx_busy) begin 
        o_tx_busy <= 1'b1 ;
    end 
    else if (i_udp_req && !o_tx_busy) begin 
        o_tx_busy <= 1'b1 ;
    end 
    else if (!i_gmii_arp_dv && !i_gmii_udp_dv) begin 
        o_tx_busy <= 1'b0 ;
    end 
    else begin 
        o_tx_busy <= o_tx_busy ;
    end 
end 


//assign 
assign o_phy_rsetn     = i_sys_rstn ; 
assign o_gmii_tx_error = 1'b0       ;
assign o_gmii_tx_data  = o_tx_arpp_udpn ? i_gmii_arp_data : i_gmii_udp_data ;
assign o_gmii_tx_en    = o_tx_arpp_udpn ? i_gmii_arp_dv   : i_gmii_udp_dv   ;


endmodule 