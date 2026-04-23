import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import shared_pkg::*;

module FIFO_monitor(FIFO_if.mon f);
FIFO_coverage cvr;
FIFO_transaction txn;
FIFO_scoreboard sb;
initial begin
  txn = new();
  sb  = new();
  cvr = new();
  forever begin
    @(negedge f.clk);
    wait(sample_event.triggered);
    txn.rst_n         = f.rst_n;
    txn.wr_en         = f.wr_en;
    txn.rd_en         = f.rd_en;
    txn.data_in       = f.data_in;
    txn.data_out      = f.data_out;
    txn.wr_ack        = f.wr_ack;
    txn.overflow      = f.overflow;
    txn.underflow     = f.underflow;
    txn.full          = f.full;
    txn.empty         = f.empty;
    txn.almostfull    = f.almostfull;
    txn.almostempty   = f.almostempty;

    fork
      begin
        cvr.sample_data(txn);
      end
      begin
        #2;
        sb.check_data(txn);
      end
    join

    if (test_finished) begin
      $display("TEST FINISHED");
      $display("Correct count = %0d", correct_count);
      $display("Error count   = %0d", error_count);
      $finish;
    end
  end

end
endmodule