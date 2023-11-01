module eth_trans_slave 
#(
    parameter MAXADDR  = 18'd245_760                  //1280*768      64*48/4=768
)  
(    
    // eth-- 
    //transfer_all_frame_flag         , //表征以太网传输DDR图像 NULL 
    input wire              transfer_all_frame_flag         ,  
    //eth_single_frame_eth_done       ,
    input wire              eth_single_frame_eth_done       ,   
    input wire              all_frame_eth_done              , //表针一帧图像传输完成  NULL  --可有打包模块传输  
    output reg              ddr_write_pre_first_flag_valid  ,
    input wire              ddr_write_pre_first_flag_ready  ,
    output wire             ddr_single_transfer_done        ,
    //ddr_wr_ctrl                                        
    input wire              ddr_clk                         ,
    input wire              ddr_rstn                        ,
    input wire              rd_burst_data_valid             ,  //eth rd ddr 
    input wire  [31 : 0]    rd_burst_data                   ,  //eth rd ddr 
    //w_fifo                                                
    output wire             w_fifo_clk                      ,
    output wire             w_fifo_en                       ,
    output wire [31 :0 ]    w_fifo_data                     ,
    //arbitrate _ port 
    output reg              slave_req                       ,  //仲裁--请求与回应
    input  wire             slave_valid                     ,  //仲裁--请求与回应
    output reg  [24:0]      slave_raddr                     ,
    output wire [9 :0]      rd_len                          ,
    //fifo_32w8r 状态                                           
    input wire  [10: 0]     fifo_len                        ,
    input wire              fifo_full_flag                  ,  
//--------------------------------------------------------------
    output wire             slave_raddr_judge_d2  ,
    output wire             slave_raddr_judge_d1  ,
    output wire             slave_raddr_judge     ,
    output wire             ready_rd_flag         ,
    output reg              slave_change          ,
//--------------------------------------------------------------
    //fifo_32w8r 状态  
    input wire  [1 :0]      slave_sel_rd_bank               ,
    output reg  [3 :0]      eth_read_channal                     //后续可加入按键消抖，进行摄像头的跳转
//    input wire              camera_vsync                    , //for debug                             
); 
reg slave_raddr_judge_d1_t0,slave_raddr_judge_d1_t1 ;
wire slave_raddr_judge_d1_pos ;
reg       arbitrate_valid_d0,arbitrate_valid_d1;
wire      valid_pos ;
reg       eth_trans_flag ;
assign    rd_len = 10'd256;
//---------------------------------------------//
localparam rd_byte_number = 11'd1400;
//localparam wr_byte_number = 256   ; 
localparam initial_addr   = 18'd0 ;
wire [24:0]             rd_addr_sample        ;
//wire                    ready_rd_flag         ; 
//wire                    slave_raddr_judge     ;
//wire                    slave_raddr_judge_d1  ;
reg  [ 1:0]             reg_slave_sel_rd_bank ;

reg                     slave_req_t0          ;
reg                     slave_req_t1          ;
reg                     slave_req_t2          ;
reg                     eth_single_frame_eth_done_d0  ;
reg                     eth_single_frame_eth_done_d1  ;
wire                    eth_single_frame_eth_done_pos ;
reg                     ddr_single_transfer_done_d0   ;
reg                     ddr_single_transfer_done_d1   ;
reg                     ddr_single_transfer_done_d2   ;

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        eth_single_frame_eth_done_d0 <= 1'b0 ; 
        eth_single_frame_eth_done_d1 <= 1'b0 ;
    end 
    else begin 
        eth_single_frame_eth_done_d0 <= eth_single_frame_eth_done ; 
        eth_single_frame_eth_done_d1 <= eth_single_frame_eth_done_d0 ;
    end 
end

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        eth_trans_flag <= 1'b0;
    end 
    else if (transfer_all_frame_flag ) begin
        eth_trans_flag <= 1'b1 ;
    end 
    else if (all_frame_eth_done)begin 
        eth_trans_flag <= 1'b0 ;
    end 
    else begin 
        eth_trans_flag <= eth_trans_flag ;
    end 
end
 

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        eth_read_channal <= 4'b0 ;
    end 
    else if(~eth_trans_flag)begin 
        eth_read_channal <= 4'b0 ;
    end 
    else if (eth_single_frame_eth_done_pos) begin //keepping until ddr finishes read comd
        eth_read_channal <= eth_read_channal + 4'b1 ;
    end 
    else if (eth_read_channal[3]&eth_single_frame_eth_done_pos) begin    // eth_read_channal == 4'd8 
        eth_read_channal <= 4'd0 ;
    end 
    else begin
        eth_read_channal <= eth_read_channal ;
    end
end


always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        arbitrate_valid_d0 <= 1'b0;
        arbitrate_valid_d1 <= 1'b0;
    end 
    else begin
        arbitrate_valid_d0 <= slave_valid;
        arbitrate_valid_d1 <= arbitrate_valid_d0;
    end
end
assign valid_pos = arbitrate_valid_d0&~arbitrate_valid_d1;

always @(eth_read_channal[0] or eth_trans_flag) begin         //
    reg_slave_sel_rd_bank <= slave_sel_rd_bank ;              //
end                                                           //

//-----------------------------------------------
//   frame_rd_done
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        slave_raddr <= 25'd0;
        slave_change <= 1'b0 ; 
    end 
    else if (valid_pos&&slave_raddr_judge) begin
        slave_raddr <= slave_raddr + 25'd256;
    end 
    else if (slave_raddr[17:0]==MAXADDR&&eth_single_frame_eth_done_pos) begin 
        slave_raddr <= rd_addr_sample;
        slave_change <= 1'b1 ;
    end
    else begin
        slave_raddr <= slave_raddr; 
        slave_change <= 1'b0 ;
    end
end 

//-----------------------------------------------
//   ddr_single_transfer_done
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        ddr_single_transfer_done_d0 <= 1'b0;
        ddr_single_transfer_done_d1 <= 1'b0;
        ddr_single_transfer_done_d2 <= 1'b0;
    end 
    else if (slave_raddr_judge_d1_pos) begin
        ddr_single_transfer_done_d0 <= 1'b1;
        ddr_single_transfer_done_d1 <= 1'b0;
        ddr_single_transfer_done_d2 <= 1'b0;
    end 
    else begin
        ddr_single_transfer_done_d0 <= 1'b0;
        ddr_single_transfer_done_d1 <= ddr_single_transfer_done_d0;
        ddr_single_transfer_done_d2 <= ddr_single_transfer_done_d1;
    end
end 

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        slave_raddr_judge_d1_t0 <= 1'b0;
        slave_raddr_judge_d1_t1 <= 1'b0;
    end 
    else begin
        slave_raddr_judge_d1_t0 <= slave_raddr_judge_d1;
        slave_raddr_judge_d1_t1 <= slave_raddr_judge_d1_t0;
    end
end 

assign slave_raddr_judge_d1_pos = slave_raddr_judge_d1_t0 & ~slave_raddr_judge_d1_t1;
//-----------------------------------------------
//  bank_switch --- slave_req/mem_wen
//-----------------------------------------------
reg    r_first_info_done ;
reg    r_rd_cyc_flag     ;
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        r_first_info_done <= 1'b0 ;
        r_rd_cyc_flag     <= 1'b0 ;
        slave_req    <= 1'b0;
        slave_req_t0 <= 1'b0;
        slave_req_t1 <= 1'b0;
        slave_req_t2 <= 1'b0;
        ddr_write_pre_first_flag_valid <= 1'b0;
    end 
    else if(slave_valid)begin 
        r_rd_cyc_flag     <= 1'b0 ;
        r_first_info_done <= 1'b0 ; 
        slave_req    <= 1'b0;
        slave_req_t0 <= 1'b0;
        slave_req_t1 <= 1'b0;
        slave_req_t2 <= 1'b0;
        ddr_write_pre_first_flag_valid <= 1'b0;
    end 
    else if(ready_rd_flag&&slave_raddr_judge&& ~r_rd_cyc_flag)begin 
        if (ddr_write_pre_first_flag_valid )begin 
            if(ddr_write_pre_first_flag_ready)begin 
                ddr_write_pre_first_flag_valid <= 1'b0 ;
                r_rd_cyc_flag <= 1'b1 ;
                slave_req    <= 1'b0;
                slave_req_t0 <= 1'b1;
                slave_req_t1 <= 1'b0;
                slave_req_t2 <= 1'b0;
            end 
        end 
        else if(slave_raddr[17:0]==18'd0 && ~r_first_info_done)begin 
            ddr_write_pre_first_flag_valid <= 1'b1 ;
            r_first_info_done <= 1'b1 ; 
            slave_req    <= 1'b0;
            slave_req_t0 <= 1'b0;
            slave_req_t1 <= 1'b0;
            slave_req_t2 <= 1'b0;
        end 
        else begin 
            r_rd_cyc_flag <= 1'b1 ;
            ddr_write_pre_first_flag_valid <= ddr_write_pre_first_flag_valid ;
            slave_req    <= slave_req_t2;
            slave_req_t0 <= 1'b1;
            slave_req_t1 <= slave_req_t0;
            slave_req_t2 <= slave_req_t1;
        end 
    end 
    else begin 
        r_rd_cyc_flag <= r_rd_cyc_flag ;
        slave_req    <= slave_req_t2 | slave_req;
        slave_req_t0 <= 1'b0;
        slave_req_t1 <= slave_req_t0;
        slave_req_t2 <= slave_req_t1;
        ddr_write_pre_first_flag_valid <= ddr_write_pre_first_flag_valid ;
    end
end  

//always @(posedge ddr_clk or negedge ddr_rstn) begin
//    if (!ddr_rstn) begin
//        r_rd_cyc_flag <= 1'b0;
//        slave_req     <= 1'b0;
//        slave_req_t0  <= 1'b0;
//        slave_req_t1  <= 1'b0;
//        slave_req_t2  <= 1'b0;
//    end 
//    else if(valid_pos)begin 
//        r_rd_cyc_flag <= 1'b0;
//        slave_req     <= 1'b0;
//        slave_req_t0  <= 1'b0;
//        slave_req_t1  <= 1'b0;
//        slave_req_t2  <= 1'b0;
//    end 
//    else if(ready_rd_flag&&slave_raddr_judge&& ~r_rd_cyc_flag)begin 
//        if (slave_raddr[17:0]==18'd0 ) begin 
//            if(ddr_write_pre_first_flag_ready)begin 
//                r_rd_cyc_flag <= 1'b1;
//                slave_req     <= 1'b0;
//                slave_req_t0  <= 1'b1;
//                slave_req_t1  <= 1'b0;
//                slave_req_t2  <= 1'b0;
//            end 
//            else if(~r_first_info_done)begin 
//                slave_req    <= 1'b0;
//                slave_req_t0 <= 1'b0;
//                slave_req_t1 <= 1'b0;
//                slave_req_t2 <= 1'b0;
//            end 
//            else begin 
//                r_rd_cyc_flag <= 1'b1 ;
//                slave_req    <= slave_req_t2;
//                slave_req_t0 <= 1'b1;
//                slave_req_t1 <= slave_req_t0;
//                slave_req_t2 <= slave_req_t1;
//            end 
//        end 
//        else begin 
//            r_rd_cyc_flag <= 1'b1 ;
//            slave_req     <= 1'b0 ;
//            slave_req_t0  <= 1'b1 ;
//            slave_req_t1  <= 1'b0 ;
//            slave_req_t2  <= 1'b0 ;
//        end 
//    end 
//    else begin 
//        r_rd_cyc_flag <= r_rd_cyc_flag ;
//        slave_req    <= slave_req_t2 | slave_req;
//        slave_req_t0 <= 1'b0;
//        slave_req_t1 <= slave_req_t0;
//        slave_req_t2 <= slave_req_t1;
//    end
//end 
//
//
//
//
//always @(posedge ddr_clk or negedge ddr_rstn) begin
//    if (!ddr_rstn) begin
//        ddr_write_pre_first_flag_valid <= 1'b0;
//    end 
//    else if(ddr_write_pre_first_flag_ready)begin 
//        ddr_write_pre_first_flag_valid <= 1'b0;
//    end 
//    else if(valid_pos)begin 
//        ddr_write_pre_first_flag_valid <= 1'b0;
//    end 
//    else if(ready_rd_flag&&slave_raddr_judge&&(slave_raddr[17:0]==18'd0 && ~r_first_info_done))begin 
//        ddr_write_pre_first_flag_valid <= 1'b1 ;
//    end 
//    else begin 
//        ddr_write_pre_first_flag_valid <= ddr_write_pre_first_flag_valid ;
//    end
//end  
//
//always @(posedge ddr_clk or negedge ddr_rstn) begin
//    if (!ddr_rstn) begin
//        r_first_info_done <= 1'b0 ;
//    end 
//    else if(valid_pos)begin 
//        r_first_info_done <= 1'b0 ; 
//    end 
//    else if(ready_rd_flag&&slave_raddr_judge&&(slave_raddr[17:0]==18'd0 && ~r_first_info_done))begin 
//        r_first_info_done <= 1'b1 ; 
//    end 
//    else begin 
//        r_first_info_done <= r_first_info_done ;
//    end
//end  

assign slave_raddr_judge_d2 = slave_raddr[17:0]== 18'd0 ;
assign slave_raddr_judge_d1 = slave_raddr[17:0]==MAXADDR ;
assign slave_raddr_judge    = (slave_raddr[17:0]<MAXADDR);
assign ready_rd_flag        = (eth_trans_flag)&&(!fifo_full_flag)&&(fifo_len<rd_byte_number)?1'b1:1'b0; 
assign rd_addr_sample = {reg_slave_sel_rd_bank,1'b0,eth_read_channal,initial_addr};             //initial read_address
//---------------------------------------------//  
assign w_fifo_clk   = ddr_clk            ;
assign w_fifo_en    = rd_burst_data_valid;
assign w_fifo_data  = rd_burst_data      ;
assign eth_single_frame_eth_done_pos = eth_single_frame_eth_done_d0 & ~eth_single_frame_eth_done_d1;
assign ddr_single_transfer_done = ddr_single_transfer_done_d0 | ddr_single_transfer_done_d1|ddr_single_transfer_done_d2;
endmodule 