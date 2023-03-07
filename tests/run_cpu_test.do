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
#vcom -93 -work work {../IOT_Distributor.vhd}
#vlog -vlog01compat -work work {../control.v}
vlog -vlog01compat -work work {+incdir+..} {../state.v}
vlog -vlog01compat -work work {+incdir+..} {../cpu.v}
vlog -vlog01compat -work work {+incdir+..} {../IOT_Distributor.v}

vlog -sv -work uvm {+define+UVM_HDL_NO_DPI} {+incdir+../../uvm-1.2/src} -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}

vlog -sv -L uvm {+incdir+..} {+incdir+../../uvm-1.2/src} {cpu_tb_top.sv}

vsim -classdebug -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH cpu_tb_top

add wave *
#add wave /uarttx_if/driver_cb/*
add wave /vif/*
#add wave /dut/*

run -all

wave zoom full
