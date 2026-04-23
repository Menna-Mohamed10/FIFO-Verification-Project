package FIFO_scoreboard_pkg;
import FIFO_transaction_pkg::*;
import shared_pkg::*;
class FIFO_scoreboard;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
    bit [FIFO_WIDTH-1:0] mem[$];

    function void check_data(input FIFO_transaction txn);
        if ((data_out_ref != txn.data_out)) begin
            error_count++;
            $display("ERROR @ %0t, data_out_Ref = %h, data_out = %h", $time, data_out_ref, txn.data_out);
            end
        else begin
            correct_count++;
        end  
        reference_model(txn);

    endfunction

    function void reference_model(input FIFO_transaction txn);
        wr_ack_ref =0;
        overflow_ref =0;
        underflow_ref =0;
        if(!txn.rst_n) begin
            mem.delete();
        end
        else if(({txn.wr_en, txn.rd_en} == 2'b11) && empty_ref)begin
            mem.push_back(txn.data_in);
            empty_ref = 0;
        end
        else begin
            //write
            if(txn.wr_en) begin
                if(mem.size() < FIFO_DEPTH) begin
                    mem.push_back(txn.data_in);
                    wr_ack_ref =1;
                end
                else begin
                    overflow_ref =1;
                end
            end

            //read
            if(txn.rd_en) begin
                if(mem.size() > 0) begin
                    data_out_ref = mem.pop_front();
                    wr_ack_ref =1;
                end
                else begin
                    underflow_ref =1;
                end
            end
        end

        full_ref = (mem.size() == FIFO_DEPTH)? 1:0;
        empty_ref = (mem.size() == 0)? 1:0;
        almostfull_ref = (mem.size() == FIFO_DEPTH -1)? 1:0;
        almostempty_ref = (mem.size() == 1)? 1:0;
    endfunction
endclass
    
endpackage