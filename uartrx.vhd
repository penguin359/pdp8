---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.control.ALL;
use std.textio.ALL;
---------------------------------------------------------------------
entity uartrx is
    Port( clk : in  STD_LOGIC;
	  ready : out STD_LOGIC;
	  clear : in STD_LOGIC;
	  clearacc : out STD_LOGIC;
	  dataout : in STD_LOGIC_VECTOR(7 downto 0);
	  datain : out STD_LOGIC_VECTOR(7 downto 0);
	  load : in STD_LOGIC
    );
end uartrx;
---------------------------------------------------------------------
architecture behavioral of uartrx is
-- 0 TFL T Flag set (non-portable)
-- 1 TSF Skip if T set
-- 2 TCF T Flag clear
-- 3 ---
-- 4 TPC Print AC(7:0)
-- 5 TSK Skip if K or T set (non-portable)
-- 6 TLS TCF + TPC
-- 7 ---

-- 0 KCF K Flag clear (non-portable)
-- 1 KSF Skip if K set
-- 2 KCC K Flag clear, AC clear, execute read
-- 3 ---
-- 4 KRS AC <= AC OR buffer
-- 5 KIE Load control from AC (non-portable)
-- 6 KRB KCC + KRS

signal flag : STD_LOGIC := '0';
signal data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
	process
	file log : text is in "in.log";
	variable outline : line;
	variable chr : string(1 to 1);
	variable good : integer;
	begin
		wait on clear, load;
		if rising_edge(clear) then
			flag <= '0';
		end if;
		if rising_edge(load) then
			if not endfile(log) then
				wait for 10 ns;
				read(log, chr, good);
				data <= Conv_STD_LOGIC_VECTOR(CHARACTER'POS(chr(1)), 8);
				flag <= '1';
			end if;
		end if;
	end process;

	ready <= flag;
	clearacc <= '0';
	datain <= data;
end behavioral;
