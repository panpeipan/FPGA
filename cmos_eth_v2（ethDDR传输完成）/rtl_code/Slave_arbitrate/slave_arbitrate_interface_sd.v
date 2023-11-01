module slave_arbitrate_interface_sd               //写入DDR
#(
    parameter SLAVE_NUMBER = 4'b0000 ,  //4bit 
    parameter PARAM_BIT    = 1'b0    ,
    parameter MAXADDR      = 18'd245_760
)
(   
    input wire          ddr_clk               ,
    input wire          sys_rstn              , 
    //fifo flag                               
    input wire          camera_vsync_neg      ,
    input wire          fifo_full_flag        ,
    input wire          fifo_empty_flag       ,
    input  wire [10: 0] fifo_len              ,
    //req & valid                             
    output reg          slave_req             ,
    input wire          arbitrate_valid       ,
    input wire          slave_wr_load         ,             //暂时未用
    input wire  [1 : 0] slave_wrbank          ,
    output wire [24: 0] slave_waddr           ,
    output reg  [9 : 0] slave_wburst_len      ,
    output reg          slave_frame_finished     
);
    
localparam               reg_slave_sel_wr_bank = 2'b00 ;

reg [17:0] slave_waddr_reg ;  //19bit - 18bit [17: 0] ------- 原21位

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        slave_req <= 1'b0;
    end 
    else if (arbitrate_valid) begin //keepping until ddr finishes read comd
        slave_req <= 1'b0;
    end 
    else if(~slave_frame_finished&&fifo_len >= 256||fifo_full_flag) begin
        slave_req <= 1'b1;
    end
    else begin
        slave_req <= slave_req ;
    end
end
reg arbitrate_valid_d0,arbitrate_valid_d1;
wire valid_neg ;
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        arbitrate_valid_d0 <= 1'b0;
        arbitrate_valid_d1 <= 1'b0;
    end 
    else begin
        arbitrate_valid_d0 <= arbitrate_valid;
        arbitrate_valid_d1 <= arbitrate_valid_d0;
    end
end
assign valid_neg = ~arbitrate_valid_d0&arbitrate_valid_d1;
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (~sys_rstn) begin
        slave_waddr_reg <= 18'b0;
        slave_frame_finished <= 1'b0;
    end 
    else if (valid_neg) begin
        slave_waddr_reg <= slave_waddr_reg + 18'd256;
    end 
    else if (slave_waddr_reg == MAXADDR) begin
        slave_waddr_reg <= 18'b0;
        slave_frame_finished <= 1'b1;
    end
    else if (camera_vsync_neg) begin
        slave_waddr_reg <= 18'b0;
        slave_frame_finished <= 1'b0;
    end
    else begin
        slave_waddr_reg <= slave_waddr_reg;
        slave_frame_finished <= slave_frame_finished;
    end
end
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        slave_wburst_len <= 10'd0;
    end 
    else begin
        slave_wburst_len <= 10'd256;
    end
end

assign slave_waddr = {reg_slave_sel_wr_bank,PARAM_BIT,SLAVE_NUMBER,slave_waddr_reg};   //反转BNAK + SD卡读取

endmodule
