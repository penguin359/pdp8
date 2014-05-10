---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
entity cpu is
    Port( clk1 : in  STD_LOGIC;
    	  clk2 : in  STD_LOGIC;
    	  fi1  : out STD_LOGIC;
    	  fi2  : out STD_LOGIC
	  data : inout STD_LOGIC_VECTOR(11 downto 0);
	  addr : out STD_LOGIC_VECTOR(11 downto 0);
    );
end cpu;
---------------------------------------------------------------------
architecture behavioral of cpu is
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
	-- Address calculation
	process(clk)
	variable page : std_logic_vector(11 downto 7);
	begin
		if rising_edge(clk) then
			if ir(z_bit) then
				page := pc(11 downto 7);
			else
				page := (others => '0');
			end if;
			ea <= page & ir(6 downto 0);
		end if;
	end process;

	-- Program Counter
	process(clk)
	begin
		if rising_edge(clk) then
			--if load_pc_ea = '1' then
		end if;
	end process;
end behavioral;
