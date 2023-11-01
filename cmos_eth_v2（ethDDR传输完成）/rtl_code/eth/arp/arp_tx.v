module arp_tx 
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
    input  wire            i_rst_n            ,
    input  wire            i_gmii_tx_clk      ,
    output reg [7:0]       o_gmii_tx_data     ,
    output reg             o_gmii_tx_en       ,
    input  wire            i_arp_tx_req       ,
    output reg             o_arp_tx_done      ,
    input  wire            i_arp_tx_type      , // ARP发送类型 0：请求 1：应答
    input  wire [47: 0]    i_arp_desmac_addr  ,
    input  wire [31: 0]    i_arp_desip_addr   ,
    input  wire [31: 0]    i_crc_data         ,
    input  wire [7 : 0]    i_crc_next         ,
    output reg             o_crc_en           ,
    output reg             o_crc_clr          
);
     
//----------------------------------------------------//
// local parameter
//----------------------------------------------------//
//状态机
localparam     ST_IDLE        =    3'd0;
localparam     ST_PREADMBLE   =    3'd1;
localparam     ST_ETH_HEAD    =    3'd2;
localparam     ST_ARP_DATA    =    3'd3;
localparam     ST_CRC         =    3'd4; 
//localparam 
localparam     ETH_ARP_TYPE   =    16'h0806 ;
localparam     PREAMBLE_BYTE  =    8'h55;
localparam     SFD_BYTE       =    8'hd5; //以太网协议下的SFD
localparam     HD_TYPE        =    16'h0001; //ARP协议下的硬件类型
localparam     PROTOCOL_TYPE  =    16'h0800; //ARP协议下的协议类型
localparam     MIN_DATA_NUM   =    16'd46  ; //以太网数据最小为46字节，不足补充数据
//----------------------------------------------------//
// reg
//----------------------------------------------------//
reg  [5:0]  r_cnt                  ;
reg  [7:0]  preamble [7 :0]        ;
reg  [7:0]  eth_head [13:0]        ;
reg  [7:0]  arp_data [27:0]        ;
reg         r_skip_en              ;
reg         r_arp_tx_done_t        ;
reg  [4:0]  r_data_cnt             ;

//----------------------------------------------------//
// wire
//----------------------------------------------------//

//----------------------------------------------------//
// state mechine
//----------------------------------------------------//
reg  [2: 0]  state            ;
reg  [2: 0]  nextstate        ;
always @(posedge i_gmii_tx_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= ST_IDLE ;       
    end 
    else begin
        state <= nextstate ;
    end
end 
always @(posedge i_gmii_tx_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        nextstate <= ST_IDLE ;       
    end 
    else begin
        case (state)
            ST_IDLE: begin
                if (i_arp_tx_req) begin
                    nextstate <= ST_PREADMBLE ;        
                end 
                else begin
                    nextstate <= nextstate  ;
                end
            end 
            ST_PREADMBLE:begin 
                if (r_skip_en) begin
                    nextstate <= ST_ETH_HEAD ;
                end 
                else begin
                    nextstate <= nextstate ;
                end 
            end 
            ST_ETH_HEAD :begin 
                if (r_skip_en) begin
                    nextstate <= ST_ARP_DATA ;
                end 
                else begin
                    nextstate <= nextstate ;
                end 
            end  
            ST_ARP_DATA :begin 
                if (r_skip_en) begin
                    nextstate <= ST_CRC ;
                end 
                else begin
                    nextstate <= nextstate  ;
                end 
            end  
            ST_CRC :begin 
                if (r_skip_en) begin
                    nextstate <= ST_IDLE ;
                end 
                else begin
                    nextstate <= nextstate ;
                end 
            end 
            default: begin
                nextstate <= ST_IDLE ;
            end
        endcase
    end
end 


    
//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_gmii_tx_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_cnt <= 6'd0;
        r_skip_en <= 1'b0;
        o_gmii_tx_data <= 8'd0;
        o_gmii_tx_en <= 1'b0;
        r_arp_tx_done_t <= 1'b0;
        o_crc_en <= 1'b0;
        r_data_cnt <= 5'd0;
        preamble[0] <= PREAMBLE_BYTE;
        preamble[1] <= PREAMBLE_BYTE;
        preamble[2] <= PREAMBLE_BYTE;
        preamble[3] <= PREAMBLE_BYTE;
        preamble[4] <= PREAMBLE_BYTE;
        preamble[5] <= PREAMBLE_BYTE;
        preamble[6] <= PREAMBLE_BYTE;
        preamble[7] <= SFD_BYTE;
        eth_head[0] <= DES_MAC[47:40];      //目的MAC地址
        eth_head[1] <= DES_MAC[39:32];
        eth_head[2] <= DES_MAC[31:24];
        eth_head[3] <= DES_MAC[23:16];
        eth_head[4] <= DES_MAC[15:8];
        eth_head[5] <= DES_MAC[7:0];        
        eth_head[6] <= BOARD_MAC[47:40];    //源MAC地址
        eth_head[7] <= BOARD_MAC[39:32];    
        eth_head[8] <= BOARD_MAC[31:24];    
        eth_head[9] <= BOARD_MAC[23:16];    
        eth_head[10] <= BOARD_MAC[15:8];    
        eth_head[11] <= BOARD_MAC[7:0];     
        eth_head[12] <= ETH_ARP_TYPE[15:8];     //以太网帧类型
        eth_head[13] <= ETH_ARP_TYPE[7:0]; 
        arp_data[0] <= HD_TYPE[15:8];       //硬件类型
        arp_data[1] <= HD_TYPE[7:0];
        arp_data[2] <= PROTOCOL_TYPE[15:8]; //上层协议类型
        arp_data[3] <= PROTOCOL_TYPE[7:0];
        arp_data[4] <= 8'h06;               //硬件地址长度,6
        arp_data[5] <= 8'h04;               //协议地址长度,4
        arp_data[6] <= 8'h00;               //OP,操作码 8'h01：ARP请求 8'h02:ARP应答
        arp_data[7] <= 8'h01;
        arp_data[8] <= BOARD_MAC[47:40];    //发送端(源)MAC地址
        arp_data[9] <= BOARD_MAC[39:32];
        arp_data[10] <= BOARD_MAC[31:24];
        arp_data[11] <= BOARD_MAC[23:16];
        arp_data[12] <= BOARD_MAC[15:8];
        arp_data[13] <= BOARD_MAC[7:0];
        arp_data[14] <= BOARD_IP[31:24];    //发送端(源)IP地址
        arp_data[15] <= BOARD_IP[23:16];
        arp_data[16] <= BOARD_IP[15:8];
        arp_data[17] <= BOARD_IP[7:0];
        arp_data[18] <= DES_MAC[47:40];     //接收端(目的)MAC地址
        arp_data[19] <= DES_MAC[39:32];
        arp_data[20] <= DES_MAC[31:24];
        arp_data[21] <= DES_MAC[23:16];
        arp_data[22] <= DES_MAC[15:8];
        arp_data[23] <= DES_MAC[7:0];  
        arp_data[24] <= DES_IP[31:24];      //接收端(目的)IP地址
        arp_data[25] <= DES_IP[23:16];
        arp_data[26] <= DES_IP[15:8];
        arp_data[27] <= DES_IP[7:0];
    end 
    else begin
        o_crc_en <= 1'b0;
        r_skip_en <= 1'b0;
        o_gmii_tx_en <= 1'b0;
        o_gmii_tx_data <= 8'd0;
        r_arp_tx_done_t <= 1'b0;
        case (nextstate )
            ST_IDLE: begin
                if (i_arp_tx_req) begin
                    r_skip_en <= 1'b1;
                    if ((i_arp_desmac_addr != 'd0) || (i_arp_desip_addr != 'd0))begin
                        eth_head[0] <= i_arp_desmac_addr[47:40];
                        eth_head[1] <= i_arp_desmac_addr[39:32];
                        eth_head[2] <= i_arp_desmac_addr[31:24];
                        eth_head[3] <= i_arp_desmac_addr[23:16];
                        eth_head[4] <= i_arp_desmac_addr[15:8];
                        eth_head[5] <= i_arp_desmac_addr[7:0];  
                        arp_data[18] <= i_arp_desmac_addr[47:40];
                        arp_data[19] <= i_arp_desmac_addr[39:32];
                        arp_data[20] <= i_arp_desmac_addr[31:24];
                        arp_data[21] <= i_arp_desmac_addr[23:16];
                        arp_data[22] <= i_arp_desmac_addr[15:8];
                        arp_data[23] <= i_arp_desmac_addr[7:0];  
                        arp_data[24] <= i_arp_desip_addr[31:24];
                        arp_data[25] <= i_arp_desip_addr[23:16];
                        arp_data[26] <= i_arp_desip_addr[15:8];
                        arp_data[27] <= i_arp_desip_addr[7:0];
                    end 
                    if (!i_arp_tx_type) begin
                        arp_data[7] <= 8'h01;       //请求
                    end 
                    else begin
                        arp_data[7] <= 8'h02;       //响应
                    end
                end
            end 
            ST_PREADMBLE:begin 
                o_gmii_tx_en <= 1'b1;
                o_gmii_tx_data <= preamble[r_cnt];
                if (r_cnt == 6'd6) begin
                    r_skip_en <= 1'b1 ;
                    r_cnt <= r_cnt + 6'd1;
                end 
                else if (r_cnt == 6'd7) begin
                    r_cnt <= 6'd0;
                end
                else begin
                    r_cnt <= r_cnt + 6'd1;
                end
            end 
            ST_ETH_HEAD :begin 
                o_gmii_tx_en <= 1'b1 ;
                o_crc_en <= 1'b1;
                o_gmii_tx_data <= eth_head[r_cnt];
                if (r_cnt == 6'd12) begin
                    r_skip_en <= 1'b1; 
                    r_cnt <= r_cnt + 6'd1;
                end 
                else if (r_cnt == 6'd13) begin
                    r_cnt <= 6'd0;
                end
                else begin
                    r_cnt <= r_cnt + 6'd1;
                end
            end 
            ST_ARP_DATA :begin 
                o_gmii_tx_en <= 1'b1 ;
                o_crc_en <= 1'b1;
                //r_cnt
                if (r_cnt == MIN_DATA_NUM - 1'b1) begin
                    r_cnt <= 6'd0;
                    r_data_cnt <= 5'd0;
                end 
                else if (r_cnt == MIN_DATA_NUM - 6'd2) begin
                    r_skip_en <= 1'b1; 
                    r_cnt <= r_cnt + 6'd1;
                end
                else begin
                    r_cnt <= r_cnt + 6'd1;
                end 
                //
                if (r_data_cnt <= 5'd27) begin
                    r_data_cnt <= r_data_cnt + 1'b1 ;
                    o_gmii_tx_data <= arp_data[r_data_cnt];
                end 
                else begin
                    o_gmii_tx_data <= 8'd0; 
                end 
            end  
            ST_CRC :begin 
                o_gmii_tx_en <= 1'b1;
                r_cnt <= r_cnt + 1'b1;
                if(r_cnt == 6'd0)
                    o_gmii_tx_data <= {~i_crc_next[0], ~i_crc_next[1], 
                                       ~i_crc_next[2], ~i_crc_next[3],
                                       ~i_crc_next[4], ~i_crc_next[5], 
                                       ~i_crc_next[6],~i_crc_next[7]};
                else if(r_cnt == 6'd1)
                    o_gmii_tx_data <= {~i_crc_data[16], ~i_crc_data[17],
                                       ~i_crc_data[18], ~i_crc_data[19], 
                                       ~i_crc_data[20], ~i_crc_data[21], 
                                       ~i_crc_data[22], ~i_crc_data[23]};
                else if(r_cnt == 6'd2) begin
                    o_gmii_tx_data <= {~i_crc_data[8] ,  ~i_crc_data[9], 
                                       ~i_crc_data[10], ~i_crc_data[11],
                                       ~i_crc_data[12], ~i_crc_data[13], 
                                       ~i_crc_data[14], ~i_crc_data[15]};                              
                    r_skip_en <= 1'b1;
                end
                else if(r_cnt == 6'd3) begin
                    o_gmii_tx_data <= {~i_crc_data[0], ~i_crc_data[1], 
                                       ~i_crc_data[2], ~i_crc_data[3],
                                       ~i_crc_data[4], ~i_crc_data[5], 
                                       ~i_crc_data[6], ~i_crc_data[7]};  
                    r_arp_tx_done_t <= 1'b1;
                    r_cnt <= 1'b0;
                end 
            end 
            default: begin
                r_skip_en <= 1'b0;
                o_gmii_tx_en <= 1'b0;
                o_gmii_tx_data <= 8'd0;
            end
        endcase
    end 
end 

always @(posedge i_gmii_tx_clk or negedge i_rst_n ) begin
    if (!i_rst_n) begin
        o_crc_clr <= 1'b0;
        o_arp_tx_done <= 1'b0;
    end 
    else begin
        o_crc_clr <= r_arp_tx_done_t ;
        o_arp_tx_done <= r_arp_tx_done_t;
    end
end
endmodule 
