---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.control.ALL;
use std.textio.ALL;
---------------------------------------------------------------------
entity uarttx is
    Port( clk : in  STD_LOGIC;
	  ready : out STD_LOGIC;
	  clear : in STD_LOGIC;
	  clearacc : out STD_LOGIC;
	  dataout : in STD_LOGIC_VECTOR(7 downto 0);
	  datain : out STD_LOGIC_VECTOR(7 downto 0);
	  load : in STD_LOGIC
    );
end uarttx;
---------------------------------------------------------------------
architecture behavioral of uarttx is
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
begin
	process
	file log : text is out "out.log";
	variable outline : line;
	begin
		wait on clear, load;
		if rising_edge(clear) then
			flag <= '0';
		end if;
		if rising_edge(load) then
			--write(outline, Conv_bitvector(dataout), right, 8);
			--write(L => outline, VALUE => "00");
			--write(outline, "00");
			--write(outline, Conv_Integer(dataout));
			--write(outline, Conv_Integer(dataout));
			--write(outline, character'val(Conv_Integer(dataout)));
			--write(outline, string'("Goodbye"));
			--writeline(log, outline);
			write(log, "" & character'val(Conv_Integer(dataout)));
			wait for 10 ns;
			flag <= '1';
		end if;
	end process;

	ready <= flag;
	clearacc <= '0';
	datain <= (others => '0');
end behavioral;
