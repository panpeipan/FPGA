module key_bank_switch 
#(
    parameter hold_time = 2_000_000
)(
input wire        clk               ,
input wire        rstn              ,
input wire        key_bottom        ,
output reg  [1:0] read_channal      
);
wire key_debounce;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_channal <= 2'b00;
    end 
    else if (key_debounce) begin
        read_channal <= read_channal + 2'd1;
    end 
    else begin
        read_channal <= read_channal ;
    end
end

debounce 
#( .hold_time (hold_time))
debounce_key1
(
    .clk        (clk),
    .rst_n      (rstn),
    .signal_i   (key_bottom),
    .signal_o   (key_debounce)
);

endmodule
