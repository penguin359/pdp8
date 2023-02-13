library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port(
		acc : in std_logic_vector(11 downto 0);
		link : in std_logic;

		clear_acc : in std_logic;
		clear_link : in std_logic;
		comp_acc : in std_logic;
		comp_link : in std_logic;
		increment : in std_logic;
		rot_left : in std_logic;
		rot_right : in std_logic;
		rot_twice : in std_logic;

		result_acc : out std_logic_vector(11 downto 0);
		result_link : out std_logic
	);
end entity alu;

architecture implementation of alu is
begin
	result_acc <= "000000000001" when increment = '1' else "000000000000";
	result_link <= '0';
end architecture implementation;
