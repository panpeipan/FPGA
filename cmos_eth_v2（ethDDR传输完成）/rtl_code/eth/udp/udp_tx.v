`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns
module udp_tx 
#(
	parameter   BOARD_MAC = 48'h001122334455,
	parameter   BOARD_IP  = {8'd192,8'd168,8'd1,8'd10},
	parameter   DES_MAC   = 48'hffffffffffff,
	parameter   DES_IP    = {8'd192,8'd168,8'd1,8'd102},
	parameter   BOARD_PORTNUM = 16'd1010 ,
	parameter   PC_PORTNUM = 16'd2020
)
(
   input  wire            i_sys_rstn       ,
   input  wire            i_gmii_tx_clk    ,
   input  wire            i_udp_tx_start_en, //以太网开始发送信号
   input  wire [31:0]     i_fifo_tx_data   , //以太网待发送数据  
   output reg             o_fifo_data_req  , //以太网数据请求
   input  wire [15:0]     i_udp_tx_byte_num, //以太网发送的有效字节数
   input  wire [47:0]     i_des_mac        , //发送的目标MAC地址
   input  wire [31:0]     i_des_ip         , //发送的目标IP地址    
   input  wire [31:0]     i_crc_data       , //CRC校验数据
   input  wire [7:0]      i_crc_next       , //CRC下次校验完成数据
   output  reg            o_udp_tx_done    , //以太网发送完成信号
   output  reg            o_gmii_tx_dv     , //GMII输出数据有效信号
   output  reg  [7:0]     o_gmii_tx_data   , //GMII输出数据 
   output  reg            o_gmii_tx_error  , //GMII输出错误
   
   output  reg            o_crc_en         , //CRC开始校验使能
   output  reg            o_crc_clr          //CRC数据复位信号 
);
//----------------------------------------------------//
// reg
//----------------------------------------------------//
reg  [2: 0]               state                ;
reg  [2: 0]               nextstate            ;
reg                       r_skip_en            ;
reg  [4: 0]               r_cnt                ;
reg  [15: 0]              r_data_cnt           ;
reg  [4: 0]               r_real_add_cnt       ;
reg  [47:0]               r_des_mac_addr       ;
reg  [47:0]               r_des_ip_addr        ;
reg  [15:0]               r_udp_length         ;
reg  [31:0]               r_check_buff         ;
reg  [7:0]                preamble [7:0]       ; //前导码 
reg  [7:0]                eth_head [13:0]      ; //以太网协议首部
reg  [31:0]               ip_head  [6:0]       ; //IP首部 + UDP首部 
reg  [15: 0]              r_data_len           ; //数据长度
reg  [15: 0]              r_udp_len            ; //UDP长度 = UDP首部长度 + 有效数据段长 
reg  [15: 0]              r_total_num          ; //IP长度 = IP首部长度 + UDP首部长度 + 有效数据段长度 
reg                       r_udp_tx_start_d0    ;
reg                       r_udp_tx_start_d1    ;
reg  [1: 0]               r_tx_byte_sel        ;
reg                       r_tx_done_t          ;
//----------------------------------------------------//
// wire
//----------------------------------------------------//
wire                      w_pos_udp_start_en     ;
wire [15: 0]              w_real_tx_data_len     ;

//----------------------------------------------------//
// local parameter
//----------------------------------------------------//
localparam       ST_IDLE     = 3'd0;
localparam       ST_CHECK_SUM= 3'd1;
localparam       ST_PREAMBLE = 3'd2;
localparam       ST_ETH_HEAD = 3'd3;
localparam       ST_IP_HEAD  = 3'd4;
localparam       ST_TX_DATA  = 3'd5;
localparam       ST_CRC      = 3'd6;

localparam       PREAMBLE_BYTE = 8'h55   ;
localparam       SFD_BYTE      = 8'hd5   ;
localparam       ETH_TYPE      = 16'h0800;
localparam       MIN_DATA_NUM  = 16'd18  ;          //以太网数据最小46个字节，IP首部20个字节+UDP首部8个字节
                                                    //所以数据至少46-20-8=18个字节
localparam       IP_VERSION    = 4'b0100 ;
localparam       TYPE_SERVICE  = 8'd0    ;
localparam       IP_FLAG       = 3'b010  ;          //可改 
localparam       IP_OFFSET     = 13'd0   ;          //可改
localparam       SURVIVE_TIME  = 16'd64  ;
localparam       UDP_TYPE      = 8'd17   ;

//----------------------------------------------------//
// state mechine
//----------------------------------------------------//
always @(posedge i_gmii_tx_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn) begin
        state <= ST_IDLE ;
    end 
    else begin
        state <= nextstate ;
    end
end 

always @(*) begin
    nextstate = ST_IDLE ;
    case (state)
        ST_IDLE: begin
            if (r_skip_en) begin
                nextstate = ST_CHECK_SUM ;
            end 
            else begin
                nextstate = ST_IDLE ;
            end
        end 
        ST_CHECK_SUM :begin 
            if (r_skip_en) begin
                nextstate = ST_PREAMBLE ;
            end 
            else begin
                nextstate = ST_CHECK_SUM ;
            end
        end  
        ST_PREAMBLE : begin 
            if (r_skip_en ) begin
                nextstate = ST_ETH_HEAD ;
            end 
            else begin
                nextstate = ST_PREAMBLE ;
            end
        end 
        ST_ETH_HEAD :begin 
            if (r_skip_en) begin
                nextstate = ST_IP_HEAD ;
            end 
            else begin
                nextstate = ST_ETH_HEAD ;
            end
        end  
        ST_IP_HEAD :begin 
            if (r_skip_en) begin
                nextstate = ST_TX_DATA ; 
            end 
            else begin
                nextstate = ST_IP_HEAD ;
            end
        end 
        ST_TX_DATA:begin 
            if (r_skip_en) begin
                nextstate = ST_CRC ;
            end 
            else begin
                nextstate = ST_TX_DATA ;
            end
        end  
        ST_CRC :begin 
            if (r_skip_en) begin
                nextstate = ST_IDLE;
            end 
            else begin
                nextstate = ST_CRC ;
            end
        end 
        default: begin
            nextstate = ST_IDLE ;
        end
    endcase
end
always @(posedge i_gmii_tx_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn) begin
        r_skip_en    <= 1'b0 ;
        r_cnt        <= 'd0  ;
        r_check_buff <= 'd0  ;
        r_real_add_cnt  <= 'd0;
        r_tx_done_t  <= 1'b0 ;
        r_data_cnt   <= 'd0  ;
        r_check_buff <= 'd0  ; 
        r_tx_byte_sel <= 2'b0;
        o_fifo_data_req <= 1'b0;
        ip_head[1][31:16] <= 16'd0;
        o_gmii_tx_data <= 'd0;
        o_gmii_tx_dv   <= 'd0;
        o_crc_en       <= 'd0;
        o_gmii_tx_error <= 1'b0;
        preamble[0] <= PREAMBLE_BYTE;                 
        preamble[1] <= PREAMBLE_BYTE;
        preamble[2] <= PREAMBLE_BYTE;
        preamble[3] <= PREAMBLE_BYTE;
        preamble[4] <= PREAMBLE_BYTE;
        preamble[5] <= PREAMBLE_BYTE;
        preamble[6] <= PREAMBLE_BYTE;
        preamble[7] <= SFD_BYTE;
        preamble[7] <= 8'hd5;
        //目的MAC地址
        eth_head[0] <= DES_MAC[47:40];
        eth_head[1] <= DES_MAC[39:32];
        eth_head[2] <= DES_MAC[31:24];
        eth_head[3] <= DES_MAC[23:16];
        eth_head[4] <= DES_MAC[15:8];
        eth_head[5] <= DES_MAC[7:0];
        //源MAC地址
        eth_head[6] <= BOARD_MAC[47:40];
        eth_head[7] <= BOARD_MAC[39:32];
        eth_head[8] <= BOARD_MAC[31:24];
        eth_head[9] <= BOARD_MAC[23:16];
        eth_head[10] <= BOARD_MAC[15:8];
        eth_head[11] <= BOARD_MAC[7:0];
        //以太网类型
        eth_head[12] <= ETH_TYPE[15:8];
        eth_head[13] <= ETH_TYPE[7:0];  
    end 
    else begin 
        o_gmii_tx_error <= 1'b0 ;
        r_skip_en <= 1'b0;
        r_tx_done_t <= 1'b0;
        o_gmii_tx_dv <= 1'b0 ;
        o_crc_en  <= 1'b0;
        o_fifo_data_req <= 1'b0 ;
        case (nextstate)
            ST_IDLE: begin
                if (w_pos_udp_start_en) begin
                    r_skip_en    <= 1'b1 ;
                    r_cnt        <= 'd0  ;
                    ip_head[0]   <= {IP_VERSION,4'd5,TYPE_SERVICE,r_total_num};
                    ip_head[1][31:16] <= ip_head[1][31:16] + 16'd1 ;
                    ip_head[1][15: 0] <= {IP_FLAG,IP_OFFSET};
                    ip_head[2]   <= {8'h40,UDP_TYPE,16'h0};
                    ip_head[3]   <= BOARD_IP ;
                    if (i_des_ip != 32'd0) begin
                        ip_head[4] <= i_des_ip ; 
                    end 
                    else begin
                        ip_head[4] <= DES_IP ;
                    end
                    ip_head[5] <= {BOARD_PORTNUM,PC_PORTNUM};
                    ip_head[6] <= {r_udp_len,16'h0000};
                    if (i_des_mac != 48'd0) begin
                        eth_head[0] <= i_des_mac[47:40];
                        eth_head[1] <= i_des_mac[39:32];
                        eth_head[2] <= i_des_mac[31:24];
                        eth_head[3] <= i_des_mac[23:16];
                        eth_head[4] <= i_des_mac[15:8];
                        eth_head[5] <= i_des_mac[7:0] ;
                    end 
                end
            end 
            ST_CHECK_SUM :begin 
                r_cnt <= r_cnt + 5'd1 ;
                if (r_cnt == 5'd0) begin
                    r_check_buff <= ip_head[0][31:16] + ip_head[0][15:0]
                                  + ip_head[1][31:16] + ip_head[1][15:0]
                                  + ip_head[2][31:16] + ip_head[2][15:0]
                                  + ip_head[3][31:16] + ip_head[3][15:0]
                                  + ip_head[4][31:16] + ip_head[4][15:0];
                end 
                else if (r_cnt == 5'd1) begin
                    r_check_buff <= r_check_buff[31:16] + r_check_buff[15:0] ;
                end 
                else if (r_cnt == 5'd2) begin
                    r_check_buff <= r_check_buff[31:16] + r_check_buff[15:0] ;
                end 
                else if (r_cnt == 5'd3) begin
                    r_skip_en <= 1'b1 ;
                    r_cnt <= 'd0 ;
                    ip_head[2][15:0] <= ~r_check_buff[15:0] ;
                end 
                else begin
                    o_gmii_tx_error <= 1'b1;
                end
            end  
            ST_PREAMBLE :begin 
                o_gmii_tx_dv   <= 1'b1 ;
                o_gmii_tx_data <= preamble[r_cnt];
                if (r_cnt == 5'd7) begin
                    r_skip_en <= 1'b1 ;
                    r_cnt <= 'd0;
                end 
                else begin
                    r_cnt <= r_cnt + 5'd1 ;
                end
            end  
            ST_ETH_HEAD:begin 
                o_gmii_tx_dv <= 1'b1 ;
                o_crc_en     <= 1'b1 ;
                o_gmii_tx_data <= eth_head[r_cnt];
                if (r_cnt == 5'd13) begin
                    r_skip_en <= 1'b1 ;
                    r_cnt     <= 'd0 ;
                end 
                else begin
                    r_cnt <= r_cnt + 5'd1 ;
                end
            end 
            ST_IP_HEAD :begin 
                o_crc_en     <= 1'b1 ;
                o_gmii_tx_dv <= 1'b1 ;
                r_tx_byte_sel <= r_tx_byte_sel + 2'b1 ;
                if (r_tx_byte_sel == 2'd0) begin
                    o_gmii_tx_data <= ip_head[r_cnt][31:24];
                end 
                else if (r_tx_byte_sel == 2'd1) begin
                    o_gmii_tx_data <= ip_head[r_cnt][23:16];
                end 
                else if (r_tx_byte_sel == 2'd2) begin
                    o_gmii_tx_data <= ip_head[r_cnt][15:8];
                    if (r_cnt == 5'd6) begin
                        o_fifo_data_req <= 1'b1 ;
                    end
                end 
                else if (r_tx_byte_sel == 2'd3) begin
                    o_gmii_tx_data <= ip_head[r_cnt][7:0];
                    if (r_cnt == 5'd6) begin
                        r_skip_en <= 1'b1 ;
                        r_cnt     <= 1'b0 ;
                    end 
                    else begin
                        r_cnt <= r_cnt + 5'd1 ;
                    end
                end
            end 
            ST_TX_DATA :begin 
                o_crc_en <= 1'b1 ;
                o_gmii_tx_dv <= 1'b1 ;
                r_tx_byte_sel <= r_tx_byte_sel + 2'd1 ;
                if (r_tx_byte_sel == 2'd0 ) begin
                    o_gmii_tx_data <= i_fifo_tx_data [31:24] ;
                end 
                else if (r_tx_byte_sel == 2'd1) begin
                    o_gmii_tx_data <= i_fifo_tx_data [23:16] ;
                end 
                else if (r_tx_byte_sel == 2'd2) begin
                    o_gmii_tx_data <= i_fifo_tx_data [15:8] ;
                    if (r_data_cnt != r_data_len -16'd2) begin
                        o_fifo_data_req <= 1'b1 ;
                    end
                end 
                else if (r_tx_byte_sel == 2'd3) begin
                    o_gmii_tx_data <= i_fifo_tx_data [7:0] ;
                end  
                if (r_data_cnt < r_data_len - 16'd1) begin
                    r_data_cnt <= r_data_cnt + 16'd1 ;
                end 
                else if (r_data_cnt == r_data_len - 16'd1) begin
                    o_fifo_data_req <= 1'b0 ;
                    if (r_data_cnt + r_real_add_cnt < w_real_tx_data_len - 16'd1) begin
                        r_real_add_cnt <= r_real_add_cnt + 5'd1 ;
                    end 
                    else begin
                        r_skip_en      <= 1'b1 ;
                        r_data_cnt     <=  'd0 ;
                        r_real_add_cnt <=  'd0 ;
                        r_tx_byte_sel  <=  'd0 ;
                    end 
                    if (r_real_add_cnt > 0) begin
                        o_gmii_tx_data <= 8'd0 ;
                    end
                end
            end  
            ST_CRC :begin 
                o_gmii_tx_dv <= 1'b1 ;
                r_tx_byte_sel <= r_tx_byte_sel + 2'd1 ;
                if (r_tx_byte_sel == 2'd0) begin
                    o_gmii_tx_data <= {~i_crc_next[0],~i_crc_next[1],~i_crc_next[2]
                                      ,~i_crc_next[3],~i_crc_next[4],~i_crc_next[5]
                                      ,~i_crc_next[6],~i_crc_next[7]};
                end 
                else if (r_tx_byte_sel == 2'd1)begin 
                    o_gmii_tx_data <= {~i_crc_data[16],~i_crc_data[17],~i_crc_data[18]
                                      ,~i_crc_data[19],~i_crc_data[20],~i_crc_data[21]
                                      ,~i_crc_data[22],~i_crc_data[23]};
                end 
                else if (r_tx_byte_sel == 2'd2) begin
                    o_gmii_tx_data <= {~i_crc_data[8],~i_crc_data[9],~i_crc_data[10]
                                      ,~i_crc_data[11],~i_crc_data[12],~i_crc_data[13]
                                      ,~i_crc_data[14],~i_crc_data[15]};
                end 
                else if (r_tx_byte_sel == 2'd3) begin
                    o_gmii_tx_data <= {~i_crc_data[0] ,~i_crc_data[1] ,~i_crc_data[2] 
                                      ,~i_crc_data[3] ,~i_crc_data[4] ,~i_crc_data[5]
                                      ,~i_crc_data[6] ,~i_crc_data[7] };
                    r_skip_en <= 1'b1 ;
                    r_tx_done_t <= 1'b1 ;
                end  
                else begin
                    o_gmii_tx_error <= 1'b1 ;
                end
            end 
            default: begin
                o_gmii_tx_error <= 1'b1;
            end
        endcase
    end
end
    
//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_gmii_tx_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn) begin
        r_data_len  <= 16'd0 ;
        r_udp_len   <= 16'd0 ;
        r_total_num <= 16'd0 ;
    end 
    else if (state == ST_IDLE && i_udp_tx_start_en) begin
        r_data_len  <= i_udp_tx_byte_num ;
        r_udp_len   <= i_udp_tx_byte_num + 16'd8 ;
        r_total_num <= i_udp_tx_byte_num + 16'd8 + 16'd20 ;
    end
end

always @(posedge i_gmii_tx_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn) begin
        r_udp_tx_start_d0 <= 1'b0;
        r_udp_tx_start_d1 <= 1'b0;
    end 
    else begin
        r_udp_tx_start_d0 <= i_udp_tx_start_en ;
        r_udp_tx_start_d1 <= r_udp_tx_start_d0 ;
    end
end 

always @(posedge i_gmii_tx_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn ) begin
        o_udp_tx_done <= 1'b0;
        o_crc_clr     <= 1'b0;
    end 
    else begin
        o_udp_tx_done <= r_tx_done_t ;
        o_crc_clr     <= r_tx_done_t ;
    end
end
//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign w_pos_udp_start_en = r_udp_tx_start_d0 && !r_udp_tx_start_d1 ;
assign w_real_tx_data_len = (r_data_len >= MIN_DATA_NUM) ? r_data_len : MIN_DATA_NUM ;
endmodule 
