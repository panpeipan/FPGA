fifo_32w8r	fifo_32w8r_inst (
	.aclr ( aclr_sig ),
	.data ( data_sig ),
	.rdclk ( rdclk_sig ),
	.rdreq ( rdreq_sig ),
	.wrclk ( wrclk_sig ),
	.wrreq ( wrreq_sig ),
	.q ( q_sig ),
	.wrempty ( wrempty_sig ),
	.wrfull ( wrfull_sig ),
	.wrusedw ( wrusedw_sig )
	);
