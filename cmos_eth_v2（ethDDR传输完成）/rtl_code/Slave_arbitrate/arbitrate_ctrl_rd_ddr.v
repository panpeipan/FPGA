module arbitrate_ctrl_rd_ddr 
#(
    parameter slave_num = 4'd6
)
(
    input wire            ddr_clk           ,
    input wire            sys_rstn          ,
    output reg  [5: 0]    slave_valid       ,
//slave0
    input  wire           Rslave0_req       ,
    input  wire [24: 0]   Rslave0_Raddr     ,
    input  wire [9 : 0]   Rslave0_Rlen      ,
    output wire [31: 0]   Rslave0_data      ,
    output wire           Rslave0_wen       ,
//slave1
    input  wire           Rslave1_req       ,
    input  wire [24: 0]   Rslave1_Raddr     ,
    input  wire [9 : 0]   Rslave1_Rlen      ,
    output wire [31: 0]   Rslave1_data      ,
    output wire           Rslave1_wen       ,
//slave2
    input  wire           Rslave2_req       ,
    input  wire [24: 0]   Rslave2_Raddr     ,
    input  wire [9 : 0]   Rslave2_Rlen      ,
    output wire [31: 0]   Rslave2_data      ,
    output wire           Rslave2_wen       ,
//slave3
    input  wire           Rslave3_req       ,
    input  wire [24: 0]   Rslave3_Raddr     ,
    input  wire [9 : 0]   Rslave3_Rlen      ,
    output wire [31: 0]   Rslave3_data      ,
    output wire           Rslave3_wen       ,
//slave4
    input  wire           Rslave4_req       ,
    input  wire [24: 0]   Rslave4_Raddr     ,
    input  wire [9 : 0]   Rslave4_Rlen      ,
    output wire [31: 0]   Rslave4_data      ,
    output wire           Rslave4_wen       ,
//slave5
    input  wire           Rslave5_req       ,
    input  wire [24: 0]   Rslave5_Raddr     ,
    input  wire [9 : 0]   Rslave5_Rlen      ,
    output wire [31: 0]   Rslave5_data      ,
    output wire           Rslave5_wen       ,
//from ddr_wr_crtl
    input  wire           ready             ,
    input  wire           ddr_read_finish   ,
//to ddr_wrctrl
    output reg  [24: 0]   arb_rddr_addr     ,
    output reg  [9 : 0]   arb_rddr_len      ,
    input  wire           ddr_Wfifo_en      ,
    input  wire [31: 0]   ddr_Wfifo_data    ,      
    output reg            mem_ren           ,
    input  wire           mem_ren_valid     
);
    
reg  [5:0]    sellect_num    ;
reg           arbitrate_ready;                           //arbitrate is ready for request from slave 0-3
reg           mem_ren_exact  ; 
wire [5:0]    primary_num    ;
wire          slave_req_flag ; 

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        sellect_num <= 6'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        sellect_num <= primary_num ;
    end
end 

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arbitrate_ready <= 1'b1;
    end 
    else if (ddr_read_finish) begin
        arbitrate_ready <= 1'b1;
    end 
    else if (slave_req_flag) begin
        arbitrate_ready <= 1'b0;
    end 
    else begin
        arbitrate_ready <= arbitrate_ready ;
    end
end 

always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        slave_valid <= 6'd0 ;
    end 
    else if (ddr_read_finish) begin
        slave_valid <= 6'd0 ;
    end
    else if (slave_req_flag && arbitrate_ready) begin
        slave_valid <= primary_num ;
    end 
end 
// arb_rddr_addr
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arb_rddr_addr <= 25'd0;
    end 
    else if (ddr_read_finish) begin
        arb_rddr_addr <= 25'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        case (primary_num)
            6'd1: begin
                arb_rddr_addr <= Rslave0_Raddr[24:0] ;
            end 
            6'd2:begin 
                arb_rddr_addr <= Rslave1_Raddr[24:0] ;
            end 
            6'd4:begin 
                arb_rddr_addr <= Rslave2_Raddr[24:0] ;
            end 
            6'd8:begin 
                arb_rddr_addr <= Rslave3_Raddr[24:0] ;
            end 
            6'd16:begin 
                arb_rddr_addr <= Rslave4_Raddr[24:0] ;
            end 
            6'd32:begin 
                arb_rddr_addr <= Rslave5_Raddr[24:0] ;
            end 
            default: begin
                arb_rddr_addr <= 25'd0;
            end
        endcase
    end
end 
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn ) begin
        arb_rddr_len <= 10'd0;
    end 
    else if (ddr_read_finish) begin
        arb_rddr_len <= 10'd0;
    end 
    else if (slave_req_flag && arbitrate_ready) begin
        case (primary_num)
            6'd1: begin
                arb_rddr_len <= Rslave0_Rlen ;
            end 
            6'd2:begin 
                arb_rddr_len <= Rslave1_Rlen ;
            end 
            6'd4:begin 
                arb_rddr_len <= Rslave2_Rlen ;
            end 
            6'd8:begin 
                arb_rddr_len <= Rslave3_Rlen ;
            end 
            6'd16:begin 
                arb_rddr_len <= Rslave4_Rlen ;
            end 
            6'd32:begin 
                arb_rddr_len <= Rslave5_Rlen ;
            end 
            default: begin
                arb_rddr_len <= 10'd0;
            end
        endcase
    end
end 
//w_ddr unity
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        mem_ren_exact <= 1'b0;
    end 
    else if (slave_req_flag&&arbitrate_ready) begin
        mem_ren_exact <= 1'b1;
    end 
    else if(mem_ren)begin
        mem_ren_exact <= 1'b0;
    end 
    else begin 
        mem_ren_exact <= mem_ren_exact ;
    end
end
always @(posedge ddr_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
        mem_ren <= 1'b0;
    end 
    else if (mem_ren_exact && ready) begin
        mem_ren <= 1'b1;
    end 
    else if (mem_ren_valid)begin 
        mem_ren <= 1'b0 ;
    end
    else begin 
        mem_ren <= mem_ren ;
    end 
end
assign slave_req_flag = Rslave0_req || Rslave1_req || Rslave2_req || Rslave3_req || Rslave4_req || Rslave5_req;
//assign primary_num = Rslave0_req ? 4'd1:(Rslave1_req ? 4'd2:(Rslave2_req ? 4'd4 : (Rslave3_req ? 4'd8:4'd0)));
assign primary_num = Rslave5_req ? 6'd32:(Rslave0_req ? 6'd1:(Rslave1_req ? 6'd2 : (Rslave2_req ? 6'd4:(Rslave3_req ? 6'd8:(Rslave4_req ? 6'd16:6'd0)))));


assign Rslave0_wen  = (sellect_num == 6'd1 ) ? ddr_Wfifo_en   : 1'b0;
assign Rslave1_wen  = (sellect_num == 6'd2 ) ? ddr_Wfifo_en   : 1'b0;
assign Rslave2_wen  = (sellect_num == 6'd4 ) ? ddr_Wfifo_en   : 1'b0;
assign Rslave3_wen  = (sellect_num == 6'd8 ) ? ddr_Wfifo_en   : 1'b0;
assign Rslave4_wen  = (sellect_num == 6'd16) ? ddr_Wfifo_en   : 1'b0;
assign Rslave5_wen  = (sellect_num == 6'd32) ? ddr_Wfifo_en   : 1'b0;

assign Rslave0_data = (sellect_num == 6'd1 ) ? ddr_Wfifo_data :32'b0;
assign Rslave1_data = (sellect_num == 6'd2 ) ? ddr_Wfifo_data :32'b0;
assign Rslave2_data = (sellect_num == 6'd4 ) ? ddr_Wfifo_data :32'b0;
assign Rslave3_data = (sellect_num == 6'd8 ) ? ddr_Wfifo_data :32'b0;
assign Rslave4_data = (sellect_num == 6'd16) ? ddr_Wfifo_data :32'b0;
assign Rslave5_data = (sellect_num == 6'd32) ? ddr_Wfifo_data :32'b0;

endmodule
