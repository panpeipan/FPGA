module slave_arbitrate_interface 
#(
    parameter SLAVE_NUMBER = 2'b00 ,
    parameter MAXADDR      = 21'd245_760
)
(   
    input wire          ddr_clk         ,
    input wire          sys_rstn        ,
    //fifo flag
    input wire          fifo_full_flag  ,
    input wire          fifo_empty_flag ,
    input  wire [10: 0] fifo_len        ,
    //req & valid
    output reg          slave_req       ,
    input wire          arbitrate_valid ,
    input wire          slave_wr_load   ,             //暂时未用
    input wire  [1 : 0] slave_wrbank    ,
    
    output wire [22: 0] slave_waddr     ,
    output reg  [9 : 0] slave_wburst_len 
    );
    

reg [20:0] slave_waddr_reg ;

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        slave_req <= 1'b0;
    end 
    else if (arbitrate_valid) begin //keepping until ddr finishes read comd
        slave_req <= 1'b0;
    end 
    else if(fifo_len >= 256||fifo_full_flag) begin
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
        slave_waddr_reg <= 21'b0;
    end 
    else if (valid_neg) begin
        slave_waddr_reg <= slave_waddr_reg + 21'd256;
    end 
    else if (slave_waddr_reg == MAXADDR) begin
        slave_waddr_reg <= 21'b0;
    end
    else begin
        slave_waddr_reg <= slave_waddr_reg;
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

assign slave_waddr  = {SLAVE_NUMBER,slave_waddr_reg};
endmodule
