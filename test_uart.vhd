--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:40:52 05/08/2014
-- Design Name:   
-- Module Name:   /home/lorenl/Dropbox/School/EE432/pdp8-vhdl/test_uart.vhd
-- Project Name:  pdp8
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_uart IS
END test_uart;
 
ARCHITECTURE behavior OF test_uart IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart
    PORT(
         clk : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         txload : IN  std_logic;
         txload2 : IN  std_logic;
         tx : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal txload : std_logic := '0';
   signal txload2 : std_logic := '0';

 	--Outputs
   signal tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart PORT MAP (
          clk => clk,
          data => data,
          txload => txload,
          txload2 => txload2,
          tx => tx
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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      txload2 <= '1';
      wait for clk_period*10;
      txload2 <= '0';
      wait for 1.2 ms;
      txload2 <= '1';
      wait for clk_period*10;
      txload2 <= '0';
      wait for 700 us;
      txload2 <= '1';
      wait for 500 us;
      txload2 <= '0';
      wait for clk_period*10;

      wait;
   end process;

END;
