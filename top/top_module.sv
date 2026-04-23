module top();
bit clk;
initial begin
  forever begin
    #1 clk = ~clk;
  end
end

FIFO_if f(clk);
FIFO DUT(f.DUT);
FIFO_tb tb(f.tb);
FIFO_monitor mon(f.mon);

property async_reset;
  @(negedge f.rst_n) (!f.rst_n) |-> (!f.overflow && !f.underflow && !f.wr_ack);
endproperty
a_async_reset : assert property(async_reset)
else $error("Async reset assertion failed");

endmodule