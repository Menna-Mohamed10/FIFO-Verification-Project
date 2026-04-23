vlib work
vlog -f src_files.list +cover +define+SIM -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover
coverage save fifo.ucdb -onexit
add wave sim:/top/f/*
add wave -position insertpoint  \
sim:/top/mon/sb.data_out_ref
run -all