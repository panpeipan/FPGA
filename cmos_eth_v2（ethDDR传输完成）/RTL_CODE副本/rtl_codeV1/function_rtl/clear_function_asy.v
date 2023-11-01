module clear_function_asy 
(
input  wire  clock_source  ,
input  wire  clock_target  ,
input  wire  rst_n     ,
input  wire  camera_vsync_neg,
output wire  clear_req_source,
output wire  clear_req_target
);
//(camera_href==1'b1) & (camera_vsync==1'b0)

reg  clear_d0,clear_d1;

always@(posedge clock_target or negedge rst_n)begin
    if(!rst_n) begin 
        clear_d0 <= 1'b0;
        clear_d1 <= 1'b0;
    end 
    else begin 
        clear_d0 <= camera_vsync_neg;
        clear_d1 <= clear_d0;
    end 
end 

assign clear_req_source = camera_vsync_neg;
assign clear_req_target = clear_d0 & !clear_d1;




endmodule 