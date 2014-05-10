------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------
entity uart is
    Port( clk : in STD_LOGIC;
	  data : in STD_LOGIC_VECTOR(7 downto 0);
	  txload : in STD_LOGIC;
	  txload2 : in STD_LOGIC;
	  tx : out STD_LOGIC
    );
end uart;
------------------------------------------------------------------------
architecture behavioral of uart is
constant baud : INTEGER := 9600;
constant divider : INTEGER := 100000000 / (baud*16);

constant hello : STRING(1 to 15) := ("Hello, world!" & cr & lf);

signal count : INTEGER := 0;
signal en_count : STD_LOGIC;

constant txcount_max : STD_LOGIC_VECTOR(7 downto 0) := "10011111"; --16*10-1
signal txcount : STD_LOGIC_VECTOR(7 downto 0) := txcount_max;
signal tx_start, txbit, txdone : STD_LOGIC;
signal txack2 : STD_LOGIC := '0';
signal tx_shift_req : STD_LOGIC_VECTOR(8 downto 0) := (others => '1');
signal data_req : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if en_count = '1' then
				count <= 0;
			else
				count <= count + 1;
			end if;
		end if;
	end process;
	en_count <= '1' when count = divider else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if tx_start = '1' then
				txcount <= (others => '0');
			elsif txdone = '0' and en_count = '1' then -- 16*10-1
				txcount <= txcount + 1;
			end if;
		end if;
	end process;
	txdone <= '1' when txcount = txcount_max else '0'; -- 16*10-1
	txbit <= '1' when txcount(3 downto 0) = "0000" else '0';

	-- Transmit data register
	process(clk)
	begin
		if rising_edge(clk) then
			--if txload2 = '1' then
			--	if txack2 = '1' then
			--		txload2 <= '0';
			--	end if;
			--elsif txload = '1' then
			if txack2 = '1' then
				--txload2 <= '0';
			end if;
			if txload = '1' then
				data_req <= data;
				--busy <= '1';
				--ack <= '1';
				--txload2 <= '1';
			end if;
		end if;
	end process;

	tx_start <= '1' when txdone = '1' and txload2 = '1' else '0';

	-- Transmit shift register
	process(clk)
	begin
		if rising_edge(clk) then
			txack2 <= '0';
			if tx_start = '1' then
				-- Stop, MSB-LSB, Start
				tx_shift_req <= "01001000" & "0";
				txack2 <= '1';
			elsif txdone = '0' and txbit = '1' then
				tx_shift_req <= "1" & tx_shift_req(8 downto 1);
			end if;
		end if;
	end process;

	tx <= tx_shift_req(0);
end behavioral;
