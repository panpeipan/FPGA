module debounce           //bottom done = GND
#(
parameter hold_time = 50_000 //50MHZ hold_time = 0.001s
)
(
input wire            clk ,
input wire            rst_n ,

input wire            signal_i ,
output wire           signal_o 
);
wire temp_wire;
reg  [31: 0]  cnt_num ;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_num <= 32'd0; 
    end 
    else if (signal_i == 1'b0) begin
        if (cnt_num == hold_time) begin
            cnt_num <= cnt_num ;
        end 
        else begin
            cnt_num <= cnt_num +32'd1;
        end
    end 
    else begin
        cnt_num <= 32'd0;
    end
end
assign temp_wire = (cnt_num == hold_time ) ? 1'b1:1'b0;
reg pos_d0,pos_d1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pos_d0 <= 1'b0;
        pos_d1 <= 1'b0;
    end 
    else begin
        pos_d0 <= temp_wire;
        pos_d1 <= pos_d0  ;
    end
end
assign signal_o = pos_d0 & ~pos_d1;


endmodule
