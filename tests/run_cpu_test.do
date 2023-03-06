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

#vcom -93 -work work {../control.vhd}
#vcom -93 -work work {../state.vhd}
#vcom -93 -work work {../cpu.vhd}
#vlog -work work -sv {../control.v}
vlog -work work -sv {+incdir+..} {../state.v}
vlog -work work -sv {+incdir+..} {../cpu.v}
vlog -work work {+incdir+..} {../IOT_Distributor.v}

vlog -work uvm +define+UVM_HDL_NO_DPI +incdir+../../uvm-1.2/src -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}

vlog -L uvm {+incdir+..} {+incdir+../../uvm-1.2/src} -sv {cpu_tb_top.sv}

vsim -classdebug -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH cpu_tb_top

add wave *
#add wave /uarttx_if/driver_cb/*
add wave /vif/*
#add wave /dut/*

run -all

wave zoom full
