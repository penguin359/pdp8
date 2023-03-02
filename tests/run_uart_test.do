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

vlog -L uvm {+incdir+../../uvm-1.2/src} -sv {uart_test.sv}

vsim -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH top

add wave *
add wave /uarttx_if/driver_cb/*
add wave /serial_if/*

#run -all
run 1100 us

wave zoom full
