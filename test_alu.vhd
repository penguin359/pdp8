library ieee;
use ieee.std_logic_1164.all;

entity test_alu is
end entity test_alu;

architecture test_bench of test_alu is
COMPONENT alu
	PORT
	(
		acc		:	 IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		link		:	 IN STD_LOGIC;
		clear_acc		:	 IN STD_LOGIC;
		clear_link		:	 IN STD_LOGIC;
		comp_acc		:	 IN STD_LOGIC;
		comp_link		:	 IN STD_LOGIC;
		increment		:	 IN STD_LOGIC;
		rot_left		:	 IN STD_LOGIC;
		rot_right		:	 IN STD_LOGIC;
		rot_twice		:	 IN STD_LOGIC;
		result_acc		:	 OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		result_link		:	 OUT STD_LOGIC
	);
END COMPONENT;

signal acc		:	 STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
signal link		:	 STD_LOGIC := '0';
signal clear_acc	:	 STD_LOGIC := '0';
signal clear_link	:	 STD_LOGIC := '0';
signal comp_acc		:	 STD_LOGIC := '0';
signal comp_link	:	 STD_LOGIC := '0';
signal increment	:	 STD_LOGIC := '0';
signal rot_left		:	 STD_LOGIC := '0';
signal rot_right	:	 STD_LOGIC := '0';
signal rot_twice	:	 STD_LOGIC := '0';

signal result_acc	:	 STD_LOGIC_VECTOR(11 DOWNTO 0);
signal result_link	:	 STD_LOGIC;

begin
	uut : alu port map(
		acc => acc,
		link => link,
		clear_acc => clear_acc,
		clear_link => clear_link,
		comp_acc => comp_acc,
		comp_link => comp_link,
		increment => increment,
		rot_left => rot_left,
		rot_right => rot_right,
		rot_twice => rot_twice,
		result_acc => result_acc,
		result_link => result_link
	);

	stimuli: process
	begin
		wait for 10 ns;
		assert result_acc = "000000000000" report "Bad ACC" severity failure;
		assert result_link = '0' report "Bad Link" severity failure;

		increment <= '1';
		wait for 10 ns;
		assert result_acc = "000000000001" report "Bad ACC" severity failure;
		assert result_link = '0' report "Bad Link" severity failure;
		wait;
	end process stimuli;
end architecture test_bench;
