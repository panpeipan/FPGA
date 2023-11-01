module arp_ctrl 
(
    input  wire            i_rst_n              ,
    input  wire            i_crtl_clk           ,
    input  wire            i_touch_key          ,
    input  wire            i_arp_rx_done        ,
    input  wire            i_arp_rx_type        ,              //0：请求 1：应答
    input  wire [47: 0]    i_arp_rx_srcmac_addr ,
    input  wire [31: 0]    i_arp_rx_srcip_addr  ,
    output reg             o_arp_tx_en          ,
    output reg             o_arp_tx_type        ,
    output reg  [47: 0]    o_arp_tx_desmac_addr ,
    output reg  [31: 0]    o_arp_tx_desip_addr  ,
    input  wire            i_arp_tx_done        ,
    output reg             o_arp_tx_req         ,
    input  wire            i_arp_tx_valid      
);
//----------------------------------------------------//
// reg
//----------------------------------------------------//
reg  [47: 0]  r_rx_srcmac_addr        ;
reg  [31: 0]  r_rx_srcip_addr         ; 

reg           r_touch_key_d0  , r_touch_key_d1 ;
//----------------------------------------------------//
// wire
//----------------------------------------------------//
wire          pos_touch_key;
//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_crtl_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_touch_key_d0 <= 1'b0;
        r_touch_key_d1 <= 1'b0;
    end 
    else begin
        r_touch_key_d0 <= i_touch_key ;
        r_touch_key_d1 <= r_touch_key_d0 ;
    end
end

always @(posedge i_crtl_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_arp_tx_req         <= 1'b0                 ;
        o_arp_tx_type        <= 1'b0                 ;
        o_arp_tx_desip_addr  <= 'd0                  ;
        o_arp_tx_desmac_addr <= 'd0                  ;
        r_rx_srcmac_addr     <= 'd0                  ;
        r_rx_srcip_addr      <= 'd0                  ; 
    end 
    else if (pos_touch_key) begin
        o_arp_tx_req         <= 1'b1                 ;
        o_arp_tx_type        <= 1'b0                 ;     //请求PC-IP，获取MAC地址
        o_arp_tx_desip_addr  <= r_rx_srcip_addr      ; 
        o_arp_tx_desmac_addr <= r_rx_srcmac_addr     ; 
        
    end 
    else if (i_arp_rx_done == 1'b1 && i_arp_rx_type == 1'b1) begin   // 0 请求 1 应答
        o_arp_tx_req         <= 1'b0                 ;
        o_arp_tx_type        <= 1'b0                 ;
        r_rx_srcmac_addr     <= i_arp_rx_srcmac_addr ;
        r_rx_srcip_addr      <= i_arp_rx_srcip_addr  ; 
    end 
    else if (i_arp_rx_done == 1'b1 && i_arp_rx_type == 1'b0) begin  
        o_arp_tx_req         <= 1'b1                 ;
        o_arp_tx_type        <= 1'b1                 ;
        o_arp_tx_desip_addr  <= i_arp_rx_srcip_addr  ;
        o_arp_tx_desmac_addr <= i_arp_rx_srcmac_addr ;  
    end 
    else if (i_arp_tx_valid) begin 
        o_arp_tx_req <= 1'b0 ;
    end 
    else begin
        o_arp_tx_req <= o_arp_tx_req ;
    end 
    
end 

always @(posedge i_crtl_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_arp_tx_en    <= 1'b0 ;
    end 
    else if (o_arp_tx_req && i_arp_tx_valid) begin
        o_arp_tx_en    <= 1'b1 ;
    end 
    else begin 
        o_arp_tx_en    <= 1'b0 ;
    end 
end


//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign pos_touch_key = r_touch_key_d0 && ~r_touch_key_d1 ;
endmodule 
