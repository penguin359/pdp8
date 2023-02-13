transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/loren/Documents/devel/fpga/pdp8/alu.vhd}
vcom -93 -work work {C:/Users/loren/Documents/devel/fpga/pdp8/test_alu.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc"  test_alu

add wave *
view structure
view signals
run -all
