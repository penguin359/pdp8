---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
entity state is
    Port( clk : in  STD_LOGIC;
    	  run : in  STD_LOGIC;
    	  fi1  : out STD_LOGIC;
    	  halted : out STD_LOGIC
    );
end state;
---------------------------------------------------------------------
architecture behavioral of state is
-- 13 inputs + IR
-- 33 outputs
-- 22 states
type cpu_state is (Sread_instr, 
--type word is std_logic_vector(11 downto 0);
--signal ac : word := (others => '0');
--signal ir : word := (others => '0');
--signal ea : word := (others => '0');
signal ac : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ir : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ea : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal pc : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

constant z_bit : INTEGER := 7;
constant i_bit : INTEGER := 8;
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
		end case;
	end process;
end behavioral;
