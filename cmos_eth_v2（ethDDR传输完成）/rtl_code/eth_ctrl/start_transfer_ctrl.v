module start_transfer_ctrl(
    input                 clk                        ,   //ʱ���ź�
    input                 rst_n                      ,   //��λ�źţ��͵�ƽ��Ч
    input                 udp_rec_pkt_done           ,   //UDP�������ݽ�������ź�
    input                 udp_rec_en                 ,   //UDP���յ�����ʹ���ź� 
    input        [7:0]    udp_rec_data               ,   //UDP���յ�����
    input        [15:0]   udp_rec_byte_num           ,   //UDP���յ����ֽ���
    output  wire          transfer_all_frame_flag    ,    //ͼ��ʼ�����־,1:��ʼ���� 0:ֹͣ����
    output  reg           transfer_signle_frame_flag ,    //ͼ��ʼ�����־,1:��ʼ���� 0:ֹͣ����
    output  reg [3:0]     transfer_cmos_sel          , 
    input   wire          frame_transfer_done
    );    
    
//parameter define
localparam  start_all_frame   = 8'h10;  //��������֡ͼ��
//parameter  channal = 8'h81;  //��ʼ����ͨ��1����
//parameter  channa2 = 8'h82;  //��ʼ����ͨ��2����
//parameter  channa3 = 8'h83;  //��ʼ����ͨ��3����
//parameter  channa4 = 8'h84;  //��ʼ����ͨ��4����
//parameter  channa5 = 8'h85;  //��ʼ����ͨ��5����
//parameter  channa6 = 8'h86;  //��ʼ����ͨ��6����
//parameter  channa7 = 8'h87;  //��ʼ����ͨ��7����
//parameter  channa8 = 8'h88;  //��ʼ����ͨ��7����
//*****************************************************
//**                    main code
//*****************************************************
reg transfer_all_frame_flag_d0 ;
reg transfer_all_frame_flag_d1 ;
reg transfer_all_frame_flag_d2 ;
reg transfer_all_frame_flag_d3 ;
//�������յ�������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        transfer_all_frame_flag_d0     <= 1'b0 ;
        transfer_cmos_sel           <= 4'd1 ;
        transfer_signle_frame_flag  <= 1'b0 ;
    end 
    else if(udp_rec_pkt_done && udp_rec_byte_num == 16'd1) begin
        if(udp_rec_data == start_all_frame) begin                           //ֹͣ���� 
            transfer_all_frame_flag_d0 <= 1'b1; 
        end 
        else if(udp_rec_data[7:4] == 4'h8)   begin                //��ʼ����
            transfer_signle_frame_flag <= 1'b1;
            transfer_cmos_sel          <= udp_rec_data[3:0];      //������Χ�������Ĭ������ͷ1
        end 
    end
    else begin 
        transfer_signle_frame_flag <= 1'b0 ;
        transfer_all_frame_flag_d0 <= 1'b0 ;
    end 
end 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        transfer_all_frame_flag_d1  <= 1'b0 ;
        transfer_all_frame_flag_d2  <= 1'b0 ;
        transfer_all_frame_flag_d3  <= 1'b0 ;
    end 
    else begin 
        transfer_all_frame_flag_d1  <= transfer_all_frame_flag_d0 ;
        transfer_all_frame_flag_d2  <= transfer_all_frame_flag_d1 ;
        transfer_all_frame_flag_d3  <= transfer_all_frame_flag_d2 ;
    end 
end 

assign transfer_all_frame_flag =    transfer_all_frame_flag_d0 | transfer_all_frame_flag_d1 | 
                                    transfer_all_frame_flag_d2 | transfer_all_frame_flag_d3 ;


endmodule