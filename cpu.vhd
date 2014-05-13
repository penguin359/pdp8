---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------
entity cpu is
    Port( clk : in  STD_LOGIC;
	  --data : inout STD_LOGIC_VECTOR(11 downto 0);
	  --addr : out STD_LOGIC_VECTOR(11 downto 0);
	  en_cla : in  STD_LOGIC;
	  en_cll : in  STD_LOGIC;
	  en_cma : in  STD_LOGIC;
	  en_cml : in  STD_LOGIC;
	  en_iac : in  STD_LOGIC;
	  en_ral : in  STD_LOGIC;
	  en_rar : in  STD_LOGIC;
	  en_rtl : in  STD_LOGIC;
	  en_rtr : in  STD_LOGIC;
	  en_bsw : in  STD_LOGIC;
	  en_sma : in  STD_LOGIC;
	  en_sza : in  STD_LOGIC;
	  en_snl : in  STD_LOGIC;
	  en_and : in  STD_LOGIC;
	  skip   : out STD_LOGIC
    );
end cpu;
---------------------------------------------------------------------
architecture behavioral of cpu is
component state
    Port( clk : in  STD_LOGIC;
    	  run : in  STD_LOGIC;
    	  fi1  : out STD_LOGIC;
    	  halted : out STD_LOGIC
    );
end component;

--type word is std_logic_vector(11 downto 0);
--signal ac : word := (others => '0');
--signal ir : word := (others => '0');
--signal ea : word := (others => '0');
signal ac : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal link : STD_LOGIC := '0';
signal ir : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ea : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal pc : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

constant z_bit : INTEGER := 7;
constant i_bit : INTEGER := 8;

signal uc_stage1 : STD_LOGIC_VECTOR(12 downto 0);
signal uc_stage2 : STD_LOGIC_VECTOR(12 downto 0);
signal uc_stage3 : STD_LOGIC_VECTOR(12 downto 0);
signal uc_stage4 : STD_LOGIC_VECTOR(12 downto 0);
begin
	inst_state: state Port Map(
		clk => clk,
		run => '0',
		fi1 => open,
		halted => open
	);

	-- Address calculation
	process(clk)
	variable page : std_logic_vector(11 downto 7);
	begin
		if rising_edge(clk) then
			if ir(z_bit) = '1' then
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

	uc_stage1(11 downto 0) <= (others => '0')  when en_cla = '1' else ac;
	uc_stage1(12)          <= '0'              when en_cll = '1' else link;
	uc_stage2(11 downto 0) <= not uc_stage1(11 downto 0) when en_cma = '1' else uc_stage1(11 downto 0);
	uc_stage2(12)          <= not uc_stage1(12) when en_cml = '1' else uc_stage1(12);
	uc_stage3 <= uc_stage2 + 1 when en_iac = '1' else uc_stage2;
	uc_stage4 <= uc_stage3(11 downto 00) & uc_stage3(12 downto 12) when en_ral = '1' else
		     uc_stage3(10 downto 00) & uc_stage3(12 downto 11) when en_rtl = '1' else
		     uc_stage3(00 downto 00) & uc_stage3(12 downto 01) when en_rar = '1' else
		     uc_stage3(01 downto 00) & uc_stage3(12 downto 02) when en_rtr = '1' else
		     uc_stage3(12) & uc_stage3(5 downto 0) & uc_stage3(11 downto 6) when en_bsw = '1' else
		     uc_stage3;

	skip <= '1' when ((en_sma = '1' and ac(11) = '1') or (en_sza = '1' and ac = "000000000000") or (en_snl = '1' and link = '1')) xor en_and = '1' else '0';
end behavioral;

--10 ... 02 01 00 12 11 RTL
--11 10 ... 02 01 00 12 RAL
--12 11 10 ... 02 01 00
--00 12 11 10 ... 02 01 RAR
--01 00 12 11 10 ... 02 RTR
