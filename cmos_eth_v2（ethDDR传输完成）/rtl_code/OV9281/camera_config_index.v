module camera_config_index 
(
    input wire [8:0]   reg_index        ,
    output reg [23:0]  LUT_DATA         
);

//iic需要配置的寄存器值  			
always@(reg_index)   
 begin
    case(reg_index)
		0 : LUT_DATA <= 24'h0100_00;
		1 : LUT_DATA <= 24'h0103_01;
		//--- PLL setting ---//
		2 : LUT_DATA <= 24'h030a_00;//pll1_predivp
		3 : LUT_DATA <= 24'h0300_01;//pll1_prediv
		4 : LUT_DATA <= 24'h0301_00;//pll1_divp_h
		5 : LUT_DATA <= 24'h0302_30;//pll1_divp_l
		6 : LUT_DATA <= 24'h0303_03;////pll1_divm
		7 : LUT_DATA <= 24'h0304_03;//pll1_div_mipi
		8 : LUT_DATA <= 24'h0305_02;//pll1_divsp
		9 : LUT_DATA <= 24'h0306_01;//pll1_divs
		10: LUT_DATA <= 24'h0314_00;//pll2_predivp
		11: LUT_DATA <= 24'h030b_04;//pll2_prediv
		12: LUT_DATA <= 24'h030c_00;//pll2_divp_h
		13: LUT_DATA <= 24'h030d_60;//pll2_divp_l
		14: LUT_DATA <= 24'h030f_05;//pll2_divsp
		15: LUT_DATA <= 24'h030e_06;//pll2_divs
		16: LUT_DATA <= 24'h0312_07;//pll2_div_sa1
		17: LUT_DATA <= 24'h0313_01;//pll2_div_dac
		18: LUT_DATA <= 24'h3001_62;
		19: LUT_DATA <= 24'h3004_01;//io_pad_out_en[17:16]
		20: LUT_DATA <= 24'h3005_ff;//io_pad_out_en[15:8]
		21: LUT_DATA <= 24'h3006_e2;//io_pad_out_en[7:0]
		22: LUT_DATA <= 24'h3011_0a;
		23: LUT_DATA <= 24'h3013_18;
		24: LUT_DATA <= 24'h301c_f0;
		25: LUT_DATA <= 24'h3022_07;
		26: LUT_DATA <= 24'h3030_10;
		27: LUT_DATA <= 24'h3039_2e;
		28: LUT_DATA <= 24'h303a_f0;
		//manula AEC/AGC
		29: LUT_DATA <= 24'h3500_00;
		30: LUT_DATA <= 24'h3501_02;
		31: LUT_DATA <= 24'h3502_00;
		32: LUT_DATA <= 24'h3503_08;
		33: LUT_DATA <= 24'h3505_00;
		34: LUT_DATA <= 24'h3507_00;
		35: LUT_DATA <= 24'h3508_00;
		36: LUT_DATA <= 24'h3509_3f;
		//analog control
		37: LUT_DATA <= 24'h3610_80;
		38: LUT_DATA <= 24'h3611_a0;
		39: LUT_DATA <= 24'h3620_6e;
		40: LUT_DATA <= 24'h3632_56;
		41: LUT_DATA <= 24'h3633_78;
		42: LUT_DATA <= 24'h3662_05;
		43: LUT_DATA <= 24'h3666_5a;
		44: LUT_DATA <= 24'h366f_7e;
		45: LUT_DATA <= 24'h3680_84;
		//sensor control
		46: LUT_DATA <= 24'h3712_80;
		47: LUT_DATA <= 24'h372d_22;
		48: LUT_DATA <= 24'h3731_80;
		49: LUT_DATA <= 24'h3732_30;
		50: LUT_DATA <= 24'h3778_00;
		51: LUT_DATA <= 24'h377d_22;
		52: LUT_DATA <= 24'h3788_02;
		53: LUT_DATA <= 24'h3789_a4;
		54: LUT_DATA <= 24'h378a_00;
		55: LUT_DATA <= 24'h378b_4a;
		56: LUT_DATA <= 24'h3799_20;
		//timing control
		57: LUT_DATA <= 24'h3800_00;
		58: LUT_DATA <= 24'h3801_00;
		59: LUT_DATA <= 24'h3802_00;
		60: LUT_DATA <= 24'h3803_00;
		61: LUT_DATA <= 24'h3804_05;
		62: LUT_DATA <= 24'h3805_0f;
		63: LUT_DATA <= 24'h3806_03;
		64: LUT_DATA <= 24'h3807_2f;
		65: LUT_DATA <= 24'h3808_05;//1280  180
		66: LUT_DATA <= 24'h3809_00;
		67: LUT_DATA <= 24'h380a_03;//768
		68: LUT_DATA <= 24'h380b_20;
		69: LUT_DATA <= 24'h380c_07;//1892
		70: LUT_DATA <= 24'h380d_64;
		71: LUT_DATA <= 24'h380e_03;//816
		72: LUT_DATA <= 24'h380f_50;//VTS
		73: LUT_DATA <= 24'h3810_00;
		74: LUT_DATA <= 24'h3811_08;
		75: LUT_DATA <= 24'h3812_00;
		76: LUT_DATA <= 24'h3813_08;
		77: LUT_DATA <= 24'h3814_11;
		78: LUT_DATA <= 24'h3815_11;
		79: LUT_DATA <= 24'h3820_00;//Bit[2]:Vflip;vertical image flip
		80: LUT_DATA <= 24'h3821_04;//Bit[2] mirror
		81: LUT_DATA <= 24'h382c_05;
		82: LUT_DATA <= 24'h382d_b0;
		83: LUT_DATA <= 24'h389d_00;
		84: LUT_DATA <= 24'h3881_42;
		85: LUT_DATA <= 24'h3882_01;
		86: LUT_DATA <= 24'h3883_00;
		87: LUT_DATA <= 24'h3885_02;
		88: LUT_DATA <= 24'h38a8_02;
		89: LUT_DATA <= 24'h38a9_80;
		90: LUT_DATA <= 24'h38b1_00;
		91: LUT_DATA <= 24'h38b3_02;
		92: LUT_DATA <= 24'h38c4_00;
		93: LUT_DATA <= 24'h38c5_c0;
		94: LUT_DATA <= 24'h38c6_04;
		95: LUT_DATA <= 24'h38c7_80;
		96: LUT_DATA <= 24'h3920_ff;//strobe_pattern[7;0]
		//BLC control
		97: LUT_DATA <= 24'h4003_40;
		98: LUT_DATA <= 24'h4008_04;
		99: LUT_DATA <= 24'h4009_0b;
		100: LUT_DATA <= 24'h400c_00;
		101: LUT_DATA <= 24'h400d_07;
		102: LUT_DATA <= 24'h4010_40;
		103: LUT_DATA <= 24'h4043_40;
		//format control
		104: LUT_DATA <= 24'h4307_30;
		105: LUT_DATA <= 24'h4317_01;//Bit[0] DVP enable
		106: LUT_DATA <= 24'h4501_00;
		107: LUT_DATA <= 24'h4507_00;
		108: LUT_DATA <= 24'h4509_00;
		109: LUT_DATA <= 24'h450a_08;
		110: LUT_DATA <= 24'h4601_04;//VFIFO read start point low byte
		111: LUT_DATA <= 24'h470f_e0;
		112: LUT_DATA <= 24'h4708_01;//bit[2] HREF polarity;bit[1] VSYNC polarity; bit[0]-PCLK polarity
		113: LUT_DATA <= 24'h4f07_00;
		114: LUT_DATA <= 24'h4800_00;//MIPI top control
		//ISP top registers BLC(black level calibration)
		115: LUT_DATA <= 24'h5000_9f;//Bit[0] - 1:BLC Enable
		116: LUT_DATA <= 24'h5001_00;
		117: LUT_DATA <= 24'h5e00_00;//Bit[7] - test pattern disable
		118: LUT_DATA <= 24'h5d00_0b;
		119: LUT_DATA <= 24'h5d01_02;
		//low power modes
		120: LUT_DATA <= 24'h4f00_04;
		121: LUT_DATA <= 24'h4f10_00;
		122: LUT_DATA <= 24'h4f11_98;
		123: LUT_DATA <= 24'h4f12_0f;
		124: LUT_DATA <= 24'h4f13_c4;
		//125: LUT_DATA <= 24'h5e00_80;
		//126: LUT_DATA <= 24'h4320_80;
		125: LUT_DATA <= 24'h0100_01;//Bit[0] - 1:streaming
		default:LUT_DATA<=24'h000000;
    endcase            
end	      



endmodule 