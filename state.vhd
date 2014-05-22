---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.control.ALL;
---------------------------------------------------------------------
entity state is
    Port( clk : in  STD_LOGIC;
    	  run : in  STD_LOGIC;
    	  opcode : in  STD_LOGIC_VECTOR(2 downto 0);
    	  indirect : in  STD_LOGIC;
	  sel_ac : out sel_ac;
	  sel_pc : out sel_pc;
	  sel_skip : out sel_skip;
	  sel_addr : out sel_addr;
	  sel_data : out sel_data;
	  sel_iot : out sel_iot;
	  sel_ir : out sel_ir;
	  sel_ma : out sel_ma;
	  sel_md : out sel_md;
    	  mem_read  : out STD_LOGIC;
    	  mem_write  : out STD_LOGIC;
    	  mem_valid  : in  STD_LOGIC;
    	  halted : out STD_LOGIC
    );
end state;
---------------------------------------------------------------------
architecture behavioral of state is
-- 13 inputs + IR
-- 33 outputs
-- 22 states
type cpu_state is (Shalt, Sread_instr, Sdecode_instr, Sread_indirect, Sexec_instr, Sexec_instr2);
signal current_state : cpu_state := Shalt;
signal next_state : cpu_state;
--type word is std_logic_vector(11 downto 0);
--signal ac : word := (others => '0');
--signal ir : word := (others => '0');
--signal ea : word := (others => '0');
signal ac : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ir : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ea : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal pc : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

constant opcode_and : STD_LOGIC_VECTOR(2 downto 0) := "000";
constant opcode_tad : STD_LOGIC_VECTOR(2 downto 0) := "001";
constant opcode_isz : STD_LOGIC_VECTOR(2 downto 0) := "010";
constant opcode_dca : STD_LOGIC_VECTOR(2 downto 0) := "011";
constant opcode_jms : STD_LOGIC_VECTOR(2 downto 0) := "100";
constant opcode_jmp : STD_LOGIC_VECTOR(2 downto 0) := "101";
constant opcode_iot : STD_LOGIC_VECTOR(2 downto 0) := "110";
constant opcode_opr : STD_LOGIC_VECTOR(2 downto 0) := "111";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

	process(current_state, run, mem_valid, opcode, indirect)
	begin
		halted <= '0';
		mem_read <= '0';
		mem_write <= '0';
		sel_ac <= ac_none;
		sel_pc <= pc_none;
		sel_skip <= skip_none;
		sel_addr <= addr_none;
		sel_data <= data_none;
		sel_iot <= iot_none;
		sel_ir <= ir_none;
		sel_ma <= ma_none;
		sel_md <= md_none;
		next_state <= current_state;
		case current_state is
			when Shalt =>
				halted <= '1';
				if run = '1' then
					next_state <= Sread_instr;
				end if;
			when Sread_instr =>
				-- Read memory at address PC and load into IR
				sel_addr <= addr_pc;
				sel_ir <= ir_data;
				mem_read <= '1';
				if mem_valid = '1' then
					next_state <= Sdecode_instr;
				end if;
			when Sdecode_instr =>
				if opcode = opcode_opr then
					next_state <= Sexec_instr;
				elsif opcode = opcode_iot then
					next_state <= Sexec_instr;
				elsif indirect = '1' then
					-- Let mem_read drop to '0'
					next_state <= Sread_indirect;
				else
					sel_ma <= ma_ea;
					next_state <= Sexec_instr;
				end if;
			when Sread_indirect =>
				sel_addr <= addr_ea;
				sel_ma <= ma_data;
				mem_read <= '1';
				if mem_valid = '1' then
					next_state <= Sexec_instr;
				end if;
			when Sexec_instr =>
				case opcode is
					when opcode_and =>
						sel_addr <= addr_ma;
						sel_md <= md_data;
						mem_read <= '1';
						if mem_valid = '1' then
							next_state <= Sexec_instr2;
						end if;
					when opcode_tad =>
						sel_addr <= addr_ma;
						sel_md <= md_data;
						mem_read <= '1';
						if mem_valid = '1' then
							next_state <= Sexec_instr2;
						end if;
					when opcode_isz =>
						sel_addr <= addr_ma;
						sel_md <= md_data1;
						mem_read <= '1';
						if mem_valid = '1' then
							next_state <= Sexec_instr2;
						end if;
					when opcode_dca =>
						sel_addr <= addr_ma;
						sel_data <= data_ac;
						mem_write <= '1';
						if mem_valid = '1' then
							next_state <= Sexec_instr2;
						end if;
					when opcode_jms =>
						sel_addr <= addr_ma;
						sel_data <= data_pc1;
						mem_write <= '1';
						if mem_valid = '1' then
							next_state <= Sexec_instr2;
						end if;
					when opcode_jmp =>
						sel_pc <= pc_ma;
						next_state <= Sread_instr;
					when opcode_iot =>
						sel_ac <= ac_iot;
						sel_pc <= pc_incr;
						sel_skip <= skip_iot;
						sel_iot <= iot_en;
						next_state <= Sread_instr;
					when opcode_opr =>
						sel_ac <= ac_uc;
						sel_pc <= pc_incr;
						sel_skip <= skip_uc;
						next_state <= Sread_instr;
					when others =>
				end case;
			when Sexec_instr2 =>
				sel_pc <= pc_incr;
				next_state <= Sread_instr;
				case opcode is
					when opcode_and =>
						sel_ac <= ac_and_md;
					when opcode_tad =>
						sel_ac <= ac_add_md;
					when opcode_isz =>
						sel_pc <= pc_none;
						next_state <= current_state;
						sel_addr <= addr_ma;
						sel_data <= data_md;
						mem_write <= '1';
						if mem_valid = '1' then
							sel_pc <= pc_incr;
							sel_skip <= skip_md_clear;
							next_state <= Sread_instr;
						end if;
					when opcode_dca =>
						sel_ac <= ac_zero;
					when opcode_jms =>
						sel_pc <= pc_ma1;
					when others =>
				end case;
			when others =>
				next_state <= Shalt;
		end case;
	end process;
end behavioral;
