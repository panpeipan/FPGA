module switch_show
#(  parameter hold_time =500000 //50MHZ hold_time = 0.001s
)(
    input wire clk ,
    input wire rstn,
    input wire key_input,
    output wire show_state 
);
wire    key_output ;
reg     close_reg  ;
always@(posedge clk or negedge rstn)begin 
    if(!rstn) 
        close_reg <= 1'b1;
    else if (key_output) 
        close_reg <= ~close_reg;
    else 
        close_reg <= close_reg;
end 

debounce           //bottom done = GND
#(
    .hold_time (hold_time) //50MHZ hold_time = 0.001s
)deboune_sw_show
(
.clk       (clk),
.rst_n     (rstn),
.signal_i  (key_input),
.signal_o  (key_output)
);

assign show_state = close_reg ;
endmodule 

