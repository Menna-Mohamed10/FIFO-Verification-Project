import shared_pkg::*;
import FIFO_transaction_pkg::*;
module FIFO_tb(FIFO_if.tb f);
FIFO_transaction txn;
initial begin
    txn = new();
    //reset
    f.rst_n = 0;
    f.wr_en = 0;
    f.rd_en = 0;
    f.data_in = 0;
    @(negedge f.clk);
    -> sample_event;
    f.rst_n = 1;

    repeat(9000) begin
        assert(txn.randomize());
        f.wr_en = txn.wr_en;
        f.rd_en = txn.rd_en;
        f.data_in = txn.data_in;
        f.rst_n = txn.rst_n;
        @(negedge f.clk);
        -> sample_event;
    end

    test_finished =1;
    
end
endmodule