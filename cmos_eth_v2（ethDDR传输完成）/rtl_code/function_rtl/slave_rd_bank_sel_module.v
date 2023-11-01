module slave_rd_bank_sel_module 
(    
    input  wire [3: 0]       read_channal                ,

    input  wire              slave0_rd_load              ,
    input  wire [1: 0]       slave0_rd_bank              ,
    input  wire              slave1_rd_load              ,
    input  wire [1: 0]       slave1_rd_bank              ,
    input  wire              slave2_rd_load              ,
    input  wire [1: 0]       slave2_rd_bank              ,
    input  wire              slave3_rd_load              ,
    input  wire [1: 0]       slave3_rd_bank              ,
    input  wire              slave4_rd_load              ,
    input  wire [1: 0]       slave4_rd_bank              ,
    input  wire              slave5_rd_load              ,
    input  wire [1: 0]       slave5_rd_bank              ,
    input  wire              slave6_rd_load              ,
    input  wire [1: 0]       slave6_rd_bank              ,
    input  wire              slave7_rd_load              ,
    input  wire [1: 0]       slave7_rd_bank              ,
    input  wire              slave8_rd_load              ,
    input  wire [1: 0]       slave8_rd_bank              ,
    //---sel_bank
    output wire              slave_sel_rd_load           ,
    output wire [1: 0]       slave_sel_rd_bank                             
); 

assign slave_sel_rd_load = (read_channal == 4'd0) ? (slave0_rd_load):(
                           (read_channal == 4'd1) ? (slave1_rd_load):(
                           (read_channal == 4'd2) ? (slave2_rd_load):(
                           (read_channal == 4'd3) ? (slave3_rd_load):(
                           (read_channal == 4'd4) ? (slave4_rd_load):(
                           (read_channal == 4'd5) ? (slave5_rd_load):(
                           (read_channal == 4'd6) ? (slave6_rd_load):(
                           (read_channal == 4'd7) ? (slave7_rd_load):(
                           (read_channal == 4'd8) ? (slave8_rd_load):
                           slave0_rd_load ))))))));
assign slave_sel_rd_bank = (read_channal == 4'd0) ? (slave0_rd_bank):(
                           (read_channal == 4'd1) ? (slave1_rd_bank):(
                           (read_channal == 4'd2) ? (slave2_rd_bank):(
                           (read_channal == 4'd3) ? (slave3_rd_bank):(
                           (read_channal == 4'd4) ? (slave4_rd_bank):(
                           (read_channal == 4'd5) ? (slave5_rd_bank):(
                           (read_channal == 4'd6) ? (slave6_rd_bank):(
                           (read_channal == 4'd7) ? (slave7_rd_bank):(
                           (read_channal == 4'd8) ? (slave8_rd_bank):
                           slave0_rd_bank))))))));
endmodule 