////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT f);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge f.clk or negedge f.rst_n) begin
	if (!f.rst_n) begin
		wr_ptr <= 0;
		f.overflow <= 0; //reseting overflow
		f.underflow <= 0; //reseting underflow
		f.wr_ack <= 0; //reseting wr_ack
	end
	else if (f.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= f.data_in;
		f.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		f.wr_ack <= 0; 
		if (f.full & f.wr_en)
			f.overflow <= 1;
		else
			f.overflow <= 0;
	end
end

always @(posedge f.clk or negedge f.rst_n) begin
	if (!f.rst_n) begin
		rd_ptr <= 0;
	end
	else if (f.rd_en && count != 0) begin
		f.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin  
		if (f.empty & f.rd_en)
			f.underflow <= 1;
		else
			f.underflow <= 0;
	end
end

always @(posedge f.clk or negedge f.rst_n) begin
	if (!f.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({f.wr_en, f.rd_en} == 2'b10) && !f.full) 
			count <= count + 1;
		else if ( ({f.wr_en, f.rd_en} == 2'b01) && !f.empty)
			count <= count - 1;
		else if ( ({f.wr_en, f.rd_en} == 2'b11) && f.empty) //handling not reading when empty and writing only
			count <= count + 1;
		else if ( ({f.wr_en, f.rd_en} == 2'b11) && f.full) //hndling not writinf when full and reading only
		count <= count - 1;
	end
end

assign f.full = (count == FIFO_DEPTH)? 1 : 0;
assign f.empty = (count == 0)? 1 : 0;
assign f.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;  //FIFO_DEPTH-1 is 7 so almost full updates
assign f.almostempty = (count == 1)? 1 : 0;

// Assertions
`ifdef SIM
	property p_reset;
		@(posedge f.clk) (!f.rst_n) |-> (wr_ptr == 0 && rd_ptr == 0 && count == 0);
	endproperty
	a_reset : assert property(p_reset)
	else $error("Reset behavior fail");
	c_reset : cover property(p_reset);

	property p_wr_ack;
		@(posedge f.clk) disable iff(!f.rst_n) (f.wr_en && !f.full) |=> (f.wr_ack == 1);
	endproperty
	a_wr_ack : assert property(p_wr_ack)
	else $error("wr_ack behavior fail");
	c_wr_ack : cover property(p_wr_ack);

	property p_overflow;
		@(posedge f.clk) disable iff(!f.rst_n) (f.wr_en && f.full) |=> (f.overflow == 1);
	endproperty
	a_overflow : assert property(p_overflow)
	else $error("overflow behavior fail");
	c_overflow : cover property(p_overflow);

	property p_underflow;
		@(posedge f.clk) disable iff(!f.rst_n) (f.rd_en && f.empty) |=> (f.underflow == 1);
	endproperty
	a_underflow : assert property(p_underflow)
	else $error("underflow behavior fail");
	c_underflow : cover property(p_underflow);

	property p_empty;
		@(posedge f.clk) (count == 0) |-> (f.empty == 1);
	endproperty
	a_empty : assert property(p_empty)
	else $error("empty behavior fail");
	c_empty : cover property(p_empty);

	property p_full;
		@(posedge f.clk) (count == FIFO_DEPTH) |-> (f.full == 1);
	endproperty
	a_full : assert property(p_full)
	else $error("full behavior fail");
	c_full : cover property(p_full);

	property p_almostempty;
		@(posedge f.clk) (count == 1) |-> (f.almostempty == 1);
	endproperty
	a_almostempty : assert property(p_almostempty)
	else $error("almostempty behavior fail");
	c_almostempty : cover property(p_almostempty);

	property p_almostfull;
		@(posedge f.clk) (count == FIFO_DEPTH-1) |-> (f.almostfull == 1);
	endproperty
	a_almostfull : assert property(p_almostfull)
	else $error("almostfull behavior fail");
	c_almostfull : cover property(p_almostfull);

	property p_wr_pointer_wraparound;
		@(posedge f.clk) (wr_ptr == FIFO_DEPTH - 1 && f.wr_en && !f.full) |-> ##1 (wr_ptr == 0);
	endproperty
	a_wr_pointer_wraparound : assert property(p_wr_pointer_wraparound)
	else $error("pointer_wr_wraparound behavior fail");
	c_wr_pointer_wraparound : cover property(p_wr_pointer_wraparound);

	property p_rd_pointer_wraparound;
		@(posedge f.clk) (rd_ptr == FIFO_DEPTH - 1 && f.rd_en && !f.empty) |-> ##1 (rd_ptr == 0);
	endproperty
	a_rd_pointer_wraparound : assert property(p_rd_pointer_wraparound)
	else $error("pointer_rd_wraparound behavior fail");
	c_rd_pointer_wraparound : cover property(p_rd_pointer_wraparound);

	property p_pointer_threshold;
		@(posedge f.clk) (wr_ptr < FIFO_DEPTH && rd_ptr < FIFO_DEPTH && count <= FIFO_DEPTH);
	endproperty
	a_pointer_threshold : assert property(p_pointer_threshold)
	else $error("almostfull behavior fail");
	c_pointer_threshold : cover property(p_pointer_threshold);

`endif

endmodule