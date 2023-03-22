transcript on

# Questa Sim
set args {-vopt}

if {[file exists uvm_questa]} {
    vdel -lib uvm_questa -all
}
vlib uvm_questa

if {[file exists rtl_work_questa]} {
    vdel -lib rtl_work_questa -all
}
vlib rtl_work_questa
vmap work rtl_work_questa

vlog $args -vlog01compat {../uarttx.v}

#vlog $args -work uvm_questa +define+UVM_HDL_NO_DPI +incdir+../../uvm-1.2/src -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}
vlog $args -work uvm_questa +define+UVM_NO_DEPRECATED +incdir+../../uvm-1.2/src -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}

vlog $args -L uvm_questa {+incdir+../../uvm-1.2/src} -sv +define+UART_TX_TEST {uart_tb_top.sv}
#vlog $args -L uvm_questa {+incdir+../../uvm-1.2/src} -sv {uart_tb_top.sv}

vsim $args -L uvm_questa -classdebug -voptargs="+acc" -sv_lib uvm_dpi64 +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_HIGH uart_tb_top
#vsim $args -L uvm_questa -classdebug -voptargs="+acc" +UVM_VERBOSITY=UVM_HIGH uart_tb_top

add wave /uart_tb_top/*
add wave /uart_tb_top/uarttx_if/driver_cb/*
add wave /uart_tb_top/serial_if/*

# TODO Simulation does not currently finish at end of sequence
#run -all
run 1100 us

wave zoom full
