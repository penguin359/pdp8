------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
------------------------------------------------------------------------
entity test_uartcp is
end test_uartcp;
------------------------------------------------------------------------
architecture behavioral of test_uartcp is 
 
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
    
    COMPONENT uartrx
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
   signal clear2 : std_logic := '0';
   signal dataout : std_logic_vector(7 downto 0) := (others => '0');
   signal load : std_logic := '0';
   signal load2 : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal ready2 : std_logic;
   signal clearacc : std_logic;
   signal datain : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
   signal str : string(1 to 256) := (others => nul);
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut2: uarttx PORT MAP (
          clk => clk,
          ready => ready2,
          clear => clear2,
          clearacc => open,
          dataout => dataout,
          datain => open,
          load => load2
        );

   uut: uartrx PORT MAP (
          clk => clk,
          ready => ready,
          clear => clear,
          clearacc => clearacc,
          dataout => "00000000",
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
   variable d : STD_LOGIC_VECTOR(7 downto 0);
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      for idx in str'range loop
	      assert ready = '0' report "Ready!" severity failure;
	      load <= '1';
	      wait for clk_period;
	      load <= '0';
	      clear2 <= '0';
	      wait for clk_period;
	      assert ready = '1' report "Not ready!" severity failure;
	      --d := datain;
	      --d := not d;
	      --str(idx) <= character'val(conv_integer(d));
	      str(idx) <= character'val(conv_integer(not datain));

	      assert ready2 = '0' report "Ready2!" severity failure;
	      --dataout <= conv_std_logic_vector(character'pos(str(idx)), 8);
	      --dataout <= conv_std_logic_vector(idx-1, 8);
	      dataout <= not datain;
	      load2 <= '1';
	      clear <= '1';
	      wait for clk_period;
	      load2 <= '0';
	      clear <= '0';
	      wait for clk_period;
	      assert ready2 = '1' report "Not ready2!" severity failure;
	      clear2 <= '1';
      end loop;

      wait;
   end process;

END;
