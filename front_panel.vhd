---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.control.ALL;
---------------------------------------------------------------------
entity front_panel is
    Port( clk : in  STD_LOGIC;
	  -- Panel to CPU
	  swreg : out STD_LOGIC_VECTOR(11 downto 0);
	  dispsel : out STD_LOGIC_VECTOR(1 downto 0);
	  run : out STD_LOGIC;
	  loadpc : out STD_LOGIC;
	  step : out STD_LOGIC;
	  deposit : out STD_LOGIC;
	  -- CPU to Panel
	  dispout : in STD_LOGIC_VECTOR(11 downto 0);
	  linkout : in STD_LOGIC;
	  halt : in STD_LOGIC
    );
end front_panel;
---------------------------------------------------------------------
architecture behavioral of front_panel is
begin
end behavioral;
