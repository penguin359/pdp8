---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
---------------------------------------------------------------------
entity top_level is
    Port( clk1 : in  STD_LOGIC;
    	  clk2 : in  STD_LOGIC;
    	  fi1  : out STD_LOGIC;
    	  fi2  : out STD_LOGIC
    );
end top_level;
---------------------------------------------------------------------
architecture Behavioral of top_level is
component sm
    Port( clk  : in  STD_LOGIC;
    	  trig : in  STD_LOGIC;
    	  fi   : out STD_LOGIC
    );
end component;

signal trig1,     trig2     : STD_LOGIC := '0';
signal trig1_mid, trig2_mid : STD_LOGIC := '0';
signal fi1_int,   fi2_int   : STD_LOGIC;
begin
	sm1 : sm Port Map(
		clk => clk1,
		trig => trig1,
		fi => fi1_int
	);

	sm2 : sm Port Map(
		clk => clk2,
		trig => trig2,
		fi => fi2_int
	);

	sync1_proc: process(clk1)
	begin
		if rising_edge(clk1) then
			trig1_mid <= not fi2_int;
			trig1 <= trig1_mid;
		end if;
	end process;

	sync2_proc: process(clk2)
	begin
		if rising_edge(clk2) then
			trig2_mid <= fi1_int;
			trig2 <= trig2_mid;
		end if;
	end process;

	fi1 <= fi1_int;
	fi2 <= fi2_int;
end Behavioral;
