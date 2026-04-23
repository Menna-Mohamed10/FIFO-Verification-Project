package FIFO_coverage_pkg;
import FIFO_transaction_pkg::*;
class FIFO_coverage;
    FIFO_transaction F_cvg_txn;
    covergroup CovFIFO;
    c_full : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.full;
    c_empty : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.empty;
    c_almost_full : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostfull;
    c_almost_empty : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostempty;
    c_overflow : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.overflow;
    c_underflow : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.underflow;
    c_wr_ack : cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.wr_ack;
  endgroup

  function new();
    CovFIFO = new();
  endfunction

  function void sample_data(input FIFO_transaction F_txn);
    F_cvg_txn = F_txn;
    CovFIFO.sample();
  endfunction

endclass
    
endpackage