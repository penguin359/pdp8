---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------
entity mem is
    Port( clk : in  STD_LOGIC;
	  din : in STD_LOGIC_VECTOR(11 downto 0);
	  dout : out STD_LOGIC_VECTOR(11 downto 0);
	  addr : in STD_LOGIC_VECTOR(11 downto 0);
	  mem_read : in  STD_LOGIC;
	  mem_write : in  STD_LOGIC;
	  mem_valid : out  STD_LOGIC
    );
end mem;
---------------------------------------------------------------------
architecture behavioral of mem is
--component ram
--    Port( clka : in  STD_LOGIC;
--    	  wea : in  STD_LOGIC_VECTOR(0 downto 0);
--    	  addra : in  STD_LOGIC_VECTOR(11 downto 0);
--    	  dina : in  STD_LOGIC_VECTOR(11 downto 0);
--    	  douta : out  STD_LOGIC_VECTOR(11 downto 0)
--    );
--end component;
component ram is
	Port(
		onchip_memory2_0_clk1_clk         : in  std_logic                     := 'X';             -- clk
		onchip_memory2_0_s1_address       : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address
		onchip_memory2_0_s1_clken         : in  std_logic                     := 'X';             -- clken
		onchip_memory2_0_s1_chipselect    : in  std_logic                     := 'X';             -- chipselect
		onchip_memory2_0_s1_write         : in  std_logic                     := 'X';             -- write
		onchip_memory2_0_s1_readdata      : out std_logic_vector(15 downto 0);                    -- readdata
		onchip_memory2_0_s1_writedata     : in  std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
		onchip_memory2_0_s1_byteenable    : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
		onchip_memory2_0_reset1_reset     : in  std_logic                     := 'X';             -- reset
		onchip_memory2_0_reset1_reset_req : in  std_logic                     := 'X'              -- reset_req
	);
end component ram;

signal dout_full : STD_LOGIC_VECTOR(15 downto 0);
type state is (Sidle, Sread, Swrite);
signal current_state : state := Sidle;
signal next_state : state;
signal wea : STD_LOGIC_VECTOR(0 downto 0);
begin
	--inst_ram: ram Port Map(
	--	clka => clk,
	--	wea => wea,
	--	addra => addr,
	--	dina => din,
	--	douta => dout
	--);
	inst_ram : component ram Port Map(
		onchip_memory2_0_clk1_clk => clk,
		onchip_memory2_0_s1_address => addr,
		onchip_memory2_0_s1_clken => open,
		onchip_memory2_0_s1_chipselect => open,
		onchip_memory2_0_s1_write => wea(0),
		onchip_memory2_0_s1_readdata => dout_full,
		onchip_memory2_0_s1_writedata => "0000" & din,
		onchip_memory2_0_s1_byteenable => open,
		onchip_memory2_0_reset1_reset => open,
		onchip_memory2_0_reset1_reset_req => open
	);

	process(clk)
	begin
		if rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

	process(current_state, mem_read, mem_write)
	begin
		mem_valid <= '0';
		wea(0) <= '0';
		next_state <= current_state;
		case current_state is
			when Sidle =>
				if mem_read = '1' then
					next_state <= Sread;
				elsif mem_write = '1' then
					wea(0) <= '1';
					next_state <= Swrite;
				end if;
			when Sread =>
				mem_valid <= '1';
				next_state <= Sidle;
			when Swrite =>
				mem_valid <= '1';
				next_state <= Sidle;
		end case;
	end process;

	dout <= dout_full(11 downto 0);
end behavioral;
