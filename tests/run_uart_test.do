transcript on

if {[file exists uvm]} {
    vdel -lib uvm -all
}
vlib uvm

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat {../uarttx.v}

vlog -work uvm +define+UVM_HDL_NO_DPI +incdir+../../uvm-1.2/src -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}

vlog -L uvm {+incdir+../../uvm-1.2/src} -sv +define+UART_TX_TEST {uart_tb_top.sv}
#vlog -L uvm {+incdir+../../uvm-1.2/src} -sv {uart_tb_top.sv}

vsim -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH uart_tb_top

add wave *
add wave /uarttx_if/driver_cb/*
add wave /serial_if/*

#run -all
run 1100 us

wave zoom full
