vlog -work work -sv {+incdir+..} -vlog01compat {../state.v}
vlog -work work -sv {+incdir+..} -vlog01compat {../cpu.v}
vlog -work work {+incdir+..} -vlog01compat {../IOT_Distributor.v}

vlog -L uvm {+incdir+..} {+incdir+../../uvm-1.2/src} -sv {cpu_tb_top.sv}

#vsim -sv_lib uvm_dpi +UVM_VERBOSITY=UVM_HIGH cpu_tb_top

#add wave *
##add wave /uarttx_if/driver_cb/*
#add wave /vif/*
##add wave /dut/*

restart -force

run -all

wave zoom full
