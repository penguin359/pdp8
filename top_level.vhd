---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
entity top_level is
    Port( clk : in  STD_LOGIC
    );
end top_level;
---------------------------------------------------------------------
architecture behavioral of top_level is
component cpu
    Port( clk : in  STD_LOGIC;
	  --data : inout STD_LOGIC_VECTOR(11 downto 0);
	  --addr : out STD_LOGIC_VECTOR(11 downto 0);
	  din : in STD_LOGIC_VECTOR(11 downto 0);
	  dout : out STD_LOGIC_VECTOR(11 downto 0);
	  addr : out STD_LOGIC_VECTOR(11 downto 0);
	  mem_read : out STD_LOGIC;
	  mem_write : out STD_LOGIC;
	  mem_valid : in STD_LOGIC
	  --en_and : in  STD_LOGIC;
	  --skip   : out STD_LOGIC
    );
end component;

component mem
    Port( clk : in  STD_LOGIC;
	  din : in STD_LOGIC_VECTOR(11 downto 0);
	  dout : out STD_LOGIC_VECTOR(11 downto 0);
	  addr : in STD_LOGIC_VECTOR(11 downto 0);
	  mem_read : in  STD_LOGIC;
	  mem_write : in  STD_LOGIC;
	  mem_valid : out  STD_LOGIC
    );
end component;

signal data_mem_to_cpu, data_cpu_to_mem, addr : STD_LOGIC_VECTOR(11 downto 0);
signal mem_read, mem_write, mem_valid : STD_LOGIC;
begin
	inst_cpu: cpu Port Map(
		clk => clk,
		din => data_mem_to_cpu,
		dout => data_cpu_to_mem,
		addr => addr,
		mem_read => mem_read,
		mem_write => mem_write,
		mem_valid => mem_valid
		--en_and => '0',
		--skip => open
	);

	inst_mem: mem Port Map(
		clk => clk,
		din => data_cpu_to_mem,
		dout => data_mem_to_cpu,
		addr => addr,
		mem_read => mem_read,
		mem_write => mem_write,
		mem_valid => mem_valid
	);
end behavioral;
