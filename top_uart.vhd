----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:08:00 05/08/2014 
-- Design Name: 
-- Module Name:    top_uart - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_uart is
    Port ( clk : in  STD_LOGIC;
           RsTx : out  STD_LOGIC);
end top_uart;

architecture Behavioral of top_uart is
	COMPONENT uart
	PORT(
		clk : IN std_logic;
		data : IN std_logic_vector(7 downto 0);
		txload : IN std_logic;
		txload2 : IN std_logic;          
		tx : OUT std_logic
		);
	END COMPONENT;

begin

	Inst_uart: uart PORT MAP(
		clk => clk,
		data => "00000000",
		txload => '0',
		txload2 => '1',
		tx => RsTx
	);
end Behavioral;

