module sd_rdaddr_slave1
#(
    parameter MAXADDR  = 18'd245_760                  //1280*768      64*48/4=768
)  
(    
    //ddr_wr_ctrl                                        
    input wire               ddr_clk                         ,
    input wire               ddr_rstn                        ,
    input wire               rd_burst_data_valid             ,
    input wire  [31 :0]      rd_burst_data                   ,
    //w_fifo                                                
    output wire              w_fifo_clk                      ,
    output wire              w_fifo_en                       ,
    output wire [31 :0]      w_fifo_data                     ,
    //arbitrate _ port 
    output reg               slave_req                       ,
    input  wire              slave_valid                     ,
    output reg  [24 :0]      slave_raddr                     ,
    output wire [9 : 0]      rd_len                          ,
    //fifo_32w16r 状态                                           
    input  wire [8 : 0]      fifo_len                        ,
    input  wire              fifo_full_flag                  ,
    input  wire [3 :0 ]      read_channal                    ,  //表征当前存储与显示的图像通道
    input  wire              wr_sd_sec_done                  ,
    output reg  [19:0 ]      w_fifo_en_cnt                   ,
    output reg               rd_addr_error       
); 


reg arbitrate_valid_d0,arbitrate_valid_d1;
wire valid_pos ;
reg wr_sd_sec_done_d0,wr_sd_sec_done_d1;
wire wr_sd_sec_done_pos ;
localparam               rd_byte_number = 9'd128       ;         //SD卡的写入 是8 * 512  所以对于DDR的32位宽，是32*128 
localparam               initial_addr   = 18'd0        ;
localparam               reg_slave_sel_rd_bank = 2'b00 ;
wire [24:0]             rd_addr_sample                ;
wire                    ready_rd_flag                 ; 
reg                     frame_wr_done_reg             ;          //表征当前存储的图像，完后从DDR中读取出来了
reg                     frame_sd_read_start_flag      ;
assign                  rd_len         = 10'd256      ;

//-----------------------------------------------
//   valid_pos
//-----------------------------------------------
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
//-----------------------------------------------
//   wr_sd_sec_done_pos
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        wr_sd_sec_done_d0 <= 1'b0;
        wr_sd_sec_done_d1 <= 1'b0;
    end 
    else begin
        wr_sd_sec_done_d0 <= wr_sd_sec_done;
        wr_sd_sec_done_d1 <= wr_sd_sec_done_d0;
    end
end
assign wr_sd_sec_done_pos = wr_sd_sec_done_d0&~wr_sd_sec_done_d1;

//-----------------------------------------------
//   frame_rd_done
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        slave_raddr <= 25'd0;
    end 
    else if (valid_pos&&(slave_raddr[17:0]<MAXADDR)) begin
        slave_raddr <= slave_raddr + 25'd256;
    end 
    else if (wr_sd_sec_done_pos) begin 
        slave_raddr <= rd_addr_sample ;
    end
    //else if (slave_raddr[17:0]==MAXADDR&&wr_sd_sec_done) begin 
    //    slave_raddr <= rd_addr_sample ;
    //end
    else begin
        slave_raddr <= slave_raddr;
    end
end 
//-----------------------------------------------
//  bank_switch --- slave_req
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        slave_req <= 1'b0;
    end 
    else if(slave_valid)begin
        slave_req <= 1'b0;
    end 
    else if(ready_rd_flag&&(slave_raddr[17:0]<MAXADDR))begin
        slave_req <= 1'b1;
    end 
    else begin
        slave_req <= slave_req;
    end
end  
//-----------------------------------------------
//  frame_wr_done_reg 
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        frame_wr_done_reg <= 1'b0;
    end 
    else if(wr_sd_sec_done)begin
        frame_wr_done_reg <= 1'b0;
    end 
    else if (slave_raddr[17:0]==MAXADDR) begin 
        frame_wr_done_reg <= 1'b1;
    end
    else begin
        frame_wr_done_reg <= frame_wr_done_reg;
    end
end 

//-----------------------------------------------
//  frame_wr_done_reg 
//-----------------------------------------------
always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        frame_sd_read_start_flag <= 1'b0;
    end 
    else if(wr_sd_sec_done)begin
        frame_sd_read_start_flag <= 1'b1;
    end 
    else if (frame_wr_done_reg) begin 
        frame_sd_read_start_flag <= 1'b0;
    end
    else begin
        frame_sd_read_start_flag <= frame_sd_read_start_flag;
    end
end 

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        w_fifo_en_cnt <= 20'b0;
    end 
    else if(w_fifo_en)begin
        w_fifo_en_cnt <= w_fifo_en_cnt + 20'b1;
    end 
    //else if (frame_wr_done_reg) begin 
    //    w_fifo_en_cnt <= 20'b0;
    //end
    else begin
        w_fifo_en_cnt <= w_fifo_en_cnt;
    end
end 

////-----------test   debug-error   //

reg [24:0]reg_slave_raddr_t   ;

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        reg_slave_raddr_t <= 25'b0;
    end 
    else if(slave_req&slave_valid)begin
        reg_slave_raddr_t <= slave_raddr ;
    end 
    else begin
        reg_slave_raddr_t <= reg_slave_raddr_t;
    end
end 

always @(posedge ddr_clk or negedge ddr_rstn) begin
    if (!ddr_rstn) begin
        rd_addr_error <= 1'b0;
    end 
    else if(slave_req&&slave_valid&&(slave_raddr == reg_slave_raddr_t))begin
        rd_addr_error <= 1'b1 ;
    end 
    else begin
        rd_addr_error <= 1'b0;
    end
end 

////-----------test   debug-error   //



assign ready_rd_flag  = (frame_sd_read_start_flag&&(!fifo_full_flag)&&(fifo_len<rd_byte_number))?1'b1:1'b0;
assign w_fifo_clk     = ddr_clk            ;
assign w_fifo_en      = rd_burst_data_valid;
assign w_fifo_data    = rd_burst_data      ;
assign rd_addr_sample = {reg_slave_sel_rd_bank,1'b1,read_channal,initial_addr};             //initial read_address
//-----------------------------------------------------------------------------
//对于DDR的读取SD卡所暂存的数据，BANK不做划分，只使用3‘b001最为该图像存储的地址


endmodule