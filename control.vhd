---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
package control is
	type sel_ac is (ac_none, ac_and_md, ac_add_md, ac_zero, ac_uc);
	type sel_pc is (pc_none, pc_data, pc_ma, pc_ma1, pc_incr);
	type sel_skip is (skip_none, skip_md_clear, skip_uc);
	type sel_addr is (addr_none, addr_ma, addr_pc, addr_ea);
	type sel_data is (data_none, data_ac, data_md, data_pc, data_pc1);
	type sel_ir is (ir_none, ir_data);
	type sel_ma is (ma_none, ma_data, ma_ea);
	type sel_md is (md_none, md_data, md_data1);
end control;

package body control is
end control;
