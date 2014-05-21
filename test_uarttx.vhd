------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
------------------------------------------------------------------------
entity test_uarttx is
end test_uarttx;
------------------------------------------------------------------------
architecture behavioral of test_uarttx is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uarttx
    PORT(
         clk : IN  std_logic;
         ready : OUT  std_logic;
         clear : IN  std_logic;
         clearacc : OUT  std_logic;
         dataout : IN  std_logic_vector(7 downto 0);
         datain : OUT  std_logic_vector(7 downto 0);
         load : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clear : std_logic := '0';
   signal dataout : std_logic_vector(7 downto 0) := (others => '0');
   signal load : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal clearacc : std_logic;
   signal datain : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uarttx PORT MAP (
          clk => clk,
          ready => ready,
          clear => clear,
          clearacc => clearacc,
          dataout => dataout,
          datain => datain,
          load => load
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   variable idx : integer := 0;
   constant str : string := ("Hello, World!" & cr & lf & nul);
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      for idx in str'range loop
	      assert ready = '0' report "Ready!" severity failure;
	      --dataout <= std_logic_vector'value("H");
	      dataout <= conv_std_logic_vector(character'pos(str(idx)), 8);
	      load <= '1';
	      wait for clk_period;
	      load <= '0';
	      wait for clk_period;
	      assert ready = '1' report "Not ready!" severity failure;
	      clear <= '1';
	      wait for clk_period;
	      clear <= '0';
      end loop;

      wait;
   end process;

END;
