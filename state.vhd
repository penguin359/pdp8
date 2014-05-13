---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
entity state is
    Port( clk : in  STD_LOGIC;
    	  run : in  STD_LOGIC;
    	  opcode : in  STD_LOGIC_VECTOR(2 downto 0);
    	  indirect : in  STD_LOGIC;
    	  load_addr_pc  : out STD_LOGIC;
    	  load_ir_data  : out STD_LOGIC;
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
type cpu_state is (Shalt, Sread_instr, Sdecode_instr, Sexec_instr, Sexec_opr, Sexec_iot);
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

	process(current_state)
	begin
		halted <= '0';
		next_state <= current_state;
		case current_state is
			when Shalt =>
				halted <= '1';
				if run = '1' then
					next_state <= Sread_instr;
				end if;
			when Sread_instr =>
				-- Read memory at address PC and load into IR
				load_addr_pc <= '1';
				load_ir_data <= '1';
				mem_read <= '1';
				if mem_valid = '1' then
					next_state <= Sexec_instr;
				end if;
			when Sdecode_instr =>
				if opcode = opcode_opr then
					next_state <= Sexec_opr;
				elsif opcode = opcode_iot then
					next_state <= Sexec_opr;
				elsif indirect = '1' then
				end if;
			when Sexec_instr =>
			when others =>
				next_state <= Shalt;
		end case;
	end process;
end behavioral;
