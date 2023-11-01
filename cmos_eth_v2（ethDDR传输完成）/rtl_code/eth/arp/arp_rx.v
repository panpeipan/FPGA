module arp_rx 
#(
    parameter       BOARD_MAC = 48'h00_11_22_33_44_55,
    parameter       BOARD_IP  = {8'd192,8'd168,8'd1,8'd10}
)
(
    input  wire         i_rst_n             ,
    input  wire         i_gmii_rxc          ,
    input  wire         i_gmii_rx_dv        ,
    input  wire [7:0]   i_gmii_rxd          ,
    output reg          o_arp_rx_done       ,
    output reg          o_arp_rx_type       ,
    output reg  [47:0]  o_arp_srcmac_addr   ,
    output reg  [31:0]  o_arp_srcip_addr 
);
     
//----------------------------------------------------//
// local parameter
//----------------------------------------------------//
//状态机
localparam    ST_IDLE       =    3'd0;
localparam    ST_PREAMBLE   =    3'd1;
localparam    ST_ETH_HEAD   =    3'd2;
localparam    ST_ARP_DATA   =    3'd3;
localparam    ST_RX_END     =    3'd4;
//localparam 
localparam    ETH_ARP_TYPE  =    16'h0806;
localparam    PREAMBLE_BYTE =    8'h55;
localparam    SFD_BYTE      =    8'b10101011;
//----------------------------------------------------//
// reg
//----------------------------------------------------//
reg           r_skip_en         ;
//reg           r_error_en        ;
reg  [5: 0]   r_cnt             ;
reg  [15: 0]  r_eth_type        ;
reg  [47: 0]  r_des_mac_t       ;
reg  [31: 0]  r_des_ip_t        ;
reg  [15: 0]  r_op_data         ;
reg  [47: 0]  r_src_mac_t       ;
reg  [31: 0]  r_src_ip_t        ;
//----------------------------------------------------//
// wire
//----------------------------------------------------//

//----------------------------------------------------//
// state mechine
//----------------------------------------------------//
reg  [2: 0]  state            ;
// reg  [2: 0]  nextstate        ;
// always @(posedge i_gmii_rxc or negedge i_rst_n) begin
    // if (!i_rst_n) begin
        // state <= ST_IDLE ;       
    // end 
    // else begin
        // state <= nextstate ;
    // end
// end 

// always @(posedge i_gmii_rxc or negedge i_rst_n) begin
    // if (!i_rst_n) begin
        // nextstate <= ST_IDLE ;
    // end 
    // else begin
        // case (state)
            // ST_IDLE: begin
                // if (r_skip_en) begin
                    // nextstate <= ST_PREAMBLE ;
                // end 
                // else begin
                    // nextstate <= nextstate;
                // end
            // end 
            // ST_PREAMBLE:begin 
                // if (r_skip_en) begin
                    // nextstate <= ST_ETH_HEAD ;
                // end 
                // else if (r_error_en) begin
                    // nextstate <= ST_RX_END ;
                // end
                // else begin
                    // nextstate <= nextstate ;
                // end 
            // end 
            // ST_ETH_HEAD:begin 
                // if (r_skip_en) begin
                    // nextstate <= ST_ARP_DATA ;
                // end 
                // else if (r_error_en) begin
                    // nextstate <= ST_RX_END ;
                // end
                // else begin
                    // nextstate <= nextstate ;
                // end                 
            // end 
            // ST_ARP_DATA:begin 
                // if (r_skip_en) begin
                    // nextstate <= ST_RX_END ;
                // end 
                // else if (r_error_en) begin
                    // nextstate <= ST_RX_END ;
                // end
                // else begin
                    // nextstate <= nextstate  ;
                // end    
            // end 
            // ST_RX_END :begin 
                // if (r_skip_en) begin
                    // nextstate <= ST_ARP_DATA ;
                // end 
                // else begin
                    // nextstate <= nextstate  ;
                // end               end 
            // default: begin
                // nextstate <= ST_IDLE ;
            // end
        // endcase
    // end
// end

//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_gmii_rxc or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_op_data <= 'd0;
        o_arp_srcip_addr <= 'd0;
        r_eth_type <= 'd0;
        r_des_mac_t <= 'd0;
        r_op_data <= 'd0;
        o_arp_rx_type <= 'd0;
        o_arp_srcmac_addr <= 'd0;
        r_src_mac_t <= 48'd0;
        r_src_ip_t <= 32'd0;
        r_des_ip_t <= 32'd0;
        state <= ST_IDLE;
        o_arp_rx_done <= 1'b0   ;
    end 
    else begin 
        o_arp_rx_done <= 1'b0   ;
        o_arp_rx_type <= 'd0;
        case (state) 
            ST_IDLE: begin
                if ((i_gmii_rxd==PREAMBLE_BYTE)&&(i_gmii_rx_dv)) begin
                    state <= ST_PREAMBLE;
                end 
                else begin
                    state <= ST_IDLE;
                end
            end 
            ST_PREAMBLE :begin 
                if (i_gmii_rx_dv) begin
                    if ((r_cnt<5'd6)&&(i_gmii_rxd != PREAMBLE_BYTE)) begin
                        state <= ST_RX_END;
                    end 
                    else if (r_cnt == 5'd6 && i_gmii_rxd == 8'hd5) begin
                        state <= ST_ETH_HEAD;
                    end 
                    else if (r_cnt == 5'd6 && i_gmii_rxd != 8'hd5) begin
                        state <= ST_RX_END;
                    end
                end
            end 
            ST_ETH_HEAD :begin 
                if (i_gmii_rx_dv) begin
                    if (r_cnt < 5'd6) begin
                        r_des_mac_t <= {r_des_mac_t[39:0],i_gmii_rxd};
                    end 
                    else if (r_cnt == 5'd6) begin        //对于ARP不需要在这里存下源MAC地址，可以在ARP数据段中解析SRCMAC
                        if (r_des_mac_t != BOARD_MAC&&r_des_mac_t != 48'hff_ff_ff_ff_ff_ff) begin
                            //r_error_en <= 1'b1 ;
                            state <= ST_RX_END;
                        end 
                    end 
                    else if (r_cnt == 5'd12 ) begin
                        r_eth_type [15:8] <= i_gmii_rxd;
                    end 
                    else if (r_cnt == 5'd13) begin
                        r_eth_type [7:0] <= i_gmii_rxd ;
                        if (r_eth_type [15:8]==ETH_ARP_TYPE[15:8]&& i_gmii_rxd == ETH_ARP_TYPE[7:0]) begin
                            state <= ST_ARP_DATA;
                        end 
                        else begin
                            state <= ST_RX_END ;
                        end
                    end
                end 
            end  
            ST_ARP_DATA :begin 
                if (i_gmii_rx_dv) begin
                    if (r_cnt == 5'd6) begin
                        r_op_data [15:8] <= i_gmii_rxd ;
                    end 
                    else if (r_cnt == 5'd7) begin
                        r_op_data [7:0] <= i_gmii_rxd ;
                    end 
                    else if (r_cnt >= 5'd8 && r_cnt < 5'd14) begin
                        r_src_mac_t <= {r_src_mac_t[39:0],i_gmii_rxd};
                    end 
                    else if (r_cnt >= 5'd14 && r_cnt < 5'd18) begin
                        r_src_ip_t <= {r_src_ip_t[23:0],i_gmii_rxd};
                    end 
                    else if (r_cnt >= 5'd24 && r_cnt < 5'd28) begin
                        r_des_ip_t <= {r_des_ip_t[23:0],i_gmii_rxd};
                    end 
                    else if (r_cnt == 5'd28) begin
                        if (r_des_ip_t == BOARD_IP) begin
                            if ((r_op_data == 16'd1)||(r_op_data == 16'd2)) begin   //操作码1：请求ARP，2：相应ARP 
                                o_arp_rx_done <= 1'b1 ;
                                state <= ST_RX_END ;
                                o_arp_srcmac_addr <= r_src_mac_t ;
                                o_arp_srcip_addr <= r_src_ip_t ;
                                r_src_mac_t <= 'd0;
                                r_src_ip_t <= 'd0;
                                r_des_mac_t <= 'd0;
                                r_des_ip_t <= 'd0;
                                if (r_op_data==16'd1) begin      // 1请求 2 
                                    o_arp_rx_type <= 1'b0;
                                end 
                                else begin
                                    o_arp_rx_type <= 1'b1;
                                end
                            end 
                            else begin
                                state <= ST_RX_END ;
                            end
                        end 
                        else begin
                            state <= ST_RX_END ;
                        end
                    end
                end 
            end 
            ST_RX_END :begin 
                if (i_gmii_rx_dv == 1'b0 ) begin    
                    state <= ST_IDLE;
                end
            end 
            default: begin
                o_arp_srcip_addr <= 'd0;
                o_arp_rx_type <= 'd0;
                o_arp_srcmac_addr <= 'd0;
                r_src_mac_t <= 48'd0;
                r_src_ip_t <= 32'd0;
                r_des_ip_t <= 32'd0;
            end
        endcase
    end
end


always @(posedge i_gmii_rxc or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_cnt  <= 'd0 ;
    end 
    //ST_IDLE
    else if ((state == ST_IDLE)&&(i_gmii_rxd==PREAMBLE_BYTE)&&(i_gmii_rx_dv))  begin
        r_cnt  <= 'd0 ;
    end 
    //ST_PREAMBLE
    else if ((state == ST_PREAMBLE)&&(r_cnt < 5'd6)) begin 
        r_cnt <= r_cnt + 5'd1;
    end 
    else if ((state == ST_PREAMBLE)&&(r_cnt == 5'd6)) begin 
        r_cnt <= 'd0;
    end 
    //ST_ETH_HEAD
    else if ((state == ST_ETH_HEAD)&&(r_cnt < 5'd13)) begin 
        r_cnt <= r_cnt + 5'd1;
    end 
    else if ((state == ST_ETH_HEAD)&&(r_cnt == 5'd13)) begin 
        r_cnt <= 'd0;
    end 
    //ST_ARP_DATA
    else if ((state == ST_ARP_DATA)&&(r_cnt < 5'd28)) begin 
        r_cnt <= r_cnt + 5'd1;
    end 
    else if ((state == ST_ARP_DATA)&&(r_cnt == 5'd28)) begin 
        r_cnt <= 'd0;
    end 
    else if (state == ST_RX_END) begin 
        r_cnt <= 'd0;
    end 
end


endmodule 
