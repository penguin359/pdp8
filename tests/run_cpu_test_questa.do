transcript on

# Questa Sim
set args {-vopt}

# ModelSim
#set args {}

if {[file exists uvm_questa]} {
    vdel -lib uvm_questa -all
}
vlib uvm_questa

if {[file exists rtl_work_questa]} {
    vdel -lib rtl_work_questa -all
}
vlib rtl_work_questa
vmap work rtl_work_questa

#vcom $args -93 -work work {../control.vhd}
#vcom $args -93 -work work {../state.vhd}
#vcom $args -93 -work work {../cpu.vhd}
#vcom $args -93 -work work {../IOT_Distributor.vhd}
#vlog $args -vlog01compat -work work {../control.v}
vlog $args -vlog01compat -work work {+incdir+..} {../state.v}
vlog $args -vlog01compat -work work {+incdir+..} {../cpu.v}
vlog $args -vlog01compat -work work {+incdir+..} {../IOT_Distributor.v}

#vlog $args -sv -work uvm_questa {+define+UVM_HDL_NO_DPI} {+incdir+../../uvm-1.2/src} -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}
vlog $args -sv -work uvm_questa {+define+UVM_NO_DPI} {+incdir+../../uvm-1.2/src} -dpiheader dpi_export.h {../../uvm-1.2/src/uvm_pkg.sv}

vlog $args -sv -L uvm_questa {+incdir+..} {+incdir+../../uvm-1.2/src} {cpu_tb_top.sv}

#vsim $args -L uvm_questa -classdebug -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH cpu_tb_top
#vsim $args -L uvm_questa -classdebug -sv_lib uvm_dpi64 +UVM_VERBOSITY=UVM_HIGH cpu_tb_top
vsim $args -L uvm_questa -classdebug +UVM_VERBOSITY=UVM_HIGH cpu_tb_top

# Questa Sim
add wave /cpu_tb_top/*
add wave /cpu_tb_top/vif/*

run -all

wave zoom full
