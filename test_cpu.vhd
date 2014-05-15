------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
------------------------------------------------------------------------
entity test_cpu is
end test_cpu;
------------------------------------------------------------------------
architecture behavioral of test_cpu is 
 
-- Component Declaration for the Unit Under Test (UUT)
 
component cpu
    Port( clk : in  STD_LOGIC;
	  din : in STD_LOGIC_VECTOR(11 downto 0);
	  dout : out STD_LOGIC_VECTOR(11 downto 0);
	  addr : out STD_LOGIC_VECTOR(11 downto 0);
	  mem_read : out STD_LOGIC;
	  mem_write : out STD_LOGIC;
	  mem_valid : in STD_LOGIC;
	  en_and : in  STD_LOGIC;
	  skip   : out STD_LOGIC
    );
end component;


--Inputs
signal clk : STD_LOGIC := '0';
signal din : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal mem_valid : STD_LOGIC := '0';
signal en_and : STD_LOGIC := '0';

--Outputs
signal dout : STD_LOGIC_VECTOR(11 downto 0);
signal addr : STD_LOGIC_VECTOR(11 downto 0);
signal mem_read : STD_LOGIC;
signal mem_write : STD_LOGIC;
signal skip : STD_LOGIC;

-- Clock period definitions
constant clk_period : TIME := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
	uut: cpu Port Map (
		clk => clk,
		din => din,
		dout => dout,
		addr => addr,
		mem_read => mem_read,
		mem_write => mem_write,
		mem_valid => mem_valid,
		en_and => en_and,
		skip => skip
        );

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	-- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	

		wait for clk_period*10;

		-- Read instruction
		assert mem_read = '1'
		report "(1)CPU Not reading instruction"
		severity failure;
		assert addr = "000000000000"
		report "(1a)Incorrect address"
		severity failure;

		-- TAD Z 101 0000
		din <= "001001010000";
		mem_valid <= '1';
		wait for clk_period;
		mem_valid <= '0';
		assert mem_read = '0'
		report "(1)Read not finished"
		severity failure;

		-- Operand read 26
		--wait until rising_edge(clk) and mem_read = '1'
		wait for clk_period*4;
		assert mem_read = '1'
		report "(1)Not reading operand"
		severity failure;
		assert addr = "000001010000"
		report "(1b)Incorrect address"
		severity failure;
		din <= "000000011010";
		mem_valid <= '1';
		wait for clk_period;
		mem_valid <= '0';

		-- Read instruction
		wait for clk_period*4;
		assert mem_read = '1'
		report "(2)CPU Not reading instruction"
		severity failure;
		assert addr = "000000000001"
		report "(2a)Incorrect address"
		severity failure;

		-- JMP IZ 101 0001
		din <= "101101010001";
		mem_valid <= '1';
		wait for clk_period;
		mem_valid <= '0';
		assert mem_read = '0'
		report "(2)Read not finished"
		severity failure;

		-- Operand read 07000
		wait for clk_period*4;
		assert mem_read = '1'
		report "(2)Not reading operand"
		severity failure;
		assert addr = "000001010001"
		report "(2b)Incorrect address"
		severity failure;
		din <= "111000000000";
		mem_valid <= '1';
		wait for clk_period;
		mem_valid <= '0';

		wait;
	end process;

end behavioral;
