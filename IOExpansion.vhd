----------------------------------------------------------------------------------
-- Company: Digilent RO
-- Engineer: Mircea Dabacan
-- 
-- Create Date:    20:46:18 04/06/2009 
-- Design Name: Adept IO Expansion Reference Component
-- Module Name:    IOExpansion - Behavioral 
-- Project Name: Adept 2
-- Target Devices: 
-- Tool versions: WP10.1.03
-- Description: 
--
-- The component implements EPP byte registers for virtual IOs on a FPGA target: 

--   Name              Epp     Dir Explain
--                     Address 
-- regVer(7 downto 0)  0x00    I/O returns the complement of written value
-- Led(7 downto 0)     0x01    In  8 virtual LEDs on the PC I/O Ex GUI
-- LBar(7 downto 0)    0x02    In  8 right lights on the PC I/O Ex GUI light bar
-- LBar(15 downto 8)   0x03    In  8 middle lights on the PC I/O Ex GUI light bar
-- LBar(23 downto 16)  0x04    In  8 left lights on the PC I/O Ex GUI light bar
-- Sw(7 downto 0)      0x05    In  8 switches, bottom row on the PC I/O Ex GUI
-- Sw(15 downto 8)     0x06    In  8 switches, top row on the PC I/O Ex GUI
-- Btn(7 downto 0)     0x07    In  8 Buttons, bottom row on the PC I/O Ex GUI
-- Btn(15 downto 8)    0x08    In  8 Buttons, top row on the PC I/O Ex GUI
-- dwOut(7 downto 0)   0x09    Out 8 Bits in an output double word
-- dwOut(15 downto 8)  0x0a    Out 8 Bits in an output double word
-- dwOut(23 downto 16) 0x0b    Out 8 Bits in an output double word
-- dwOut(31 downto 24) 0x0c    Out 8 Bits in an output double word
-- dwIn(7 downto 0)    0x0d    In  8 Bits in an input double word
-- dwIn(15 downto 8)   0x0e    In  8 Bits in an input double word
-- dwIn(23 downto 16)  0x0f    In  8 Bits in an input double word
-- dwIn(31 downto 24)  0x10    In  8 Bits in an input double word

-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IOExpansion is

    Port (
-- Epp-like bus signals
      EppAstb: in std_logic;        -- Address strobe
      EppDstb: in std_logic;        -- Data strobe
      EppWr  : in std_logic;        -- Port write signal
      EppDB  : inout std_logic_vector(7 downto 0); -- port data bus
      EppWait: out std_logic;        -- Port wait signal
-- user extended signals 
      Led  : in std_logic_vector(7 downto 0);   -- 0x01     8 virtual LEDs on the PC I/O Ex GUI
      LBar : in std_logic_vector(23 downto 0);  -- 0x02..4  24 lights on the PC I/O Ex GUI light bar
      Sw   : out std_logic_vector(15 downto 0);  -- 0x05..6  16 switches, bottom row on the PC I/O Ex GUI
      Btn  : out std_logic_vector(15 downto 0);  -- 0x07..8  16 Buttons, bottom row on the PC I/O Ex GUI
      dwOut: out std_logic_vector(31 downto 0); -- 0x09..b  32 Bits user output
      dwIn : in std_logic_vector(31 downto 0)   -- 0x0d..10 32 Bits user input
         );

end IOExpansion;

architecture Behavioral of IOExpansion is

  signal regEppAdr: std_logic_vector (7 downto 0); -- Epp address 
  signal regVer: std_logic_vector(7 downto 0); --  0x00    I/O returns the complement of written value
  signal busEppInternal: std_logic_vector(7 downto 0);  -- internal bus (before tristate)

begin

-- Epp signals
   -- Port signals
   EppWait <= '1' when EppAstb = '0' or EppDstb = '0' else '0';
             -- asynchronous Wait assering (maximal Epp speed)

   EppDB <= busEppInternal when (EppWr = '1') else "ZZZZZZZZ";

   busEppInternal <= 
       regEppAdr when (EppAstb = '0') else
       regVer when (regEppAdr = x"00") else
       Led when (regEppAdr = x"01") else
       LBar(7 downto 0) when (regEppAdr = x"02") else
       LBar(15 downto 8) when (regEppAdr = x"03") else
       LBar(23 downto 16) when (regEppAdr = x"04") else
       dwIn(7 downto 0) when (regEppAdr = x"0d") else
       dwIn(15 downto 8) when (regEppAdr = x"0e") else
       dwIn(23 downto 16) when (regEppAdr = x"0f") else
       dwIn(31 downto 24);-- when (regEppAdr = x"10") else

  -- EPP Address register
  process (EppAstb)
    begin
      if rising_edge(EppAstb) then  -- Astb end edge
        if EppWr = '0' then -- Epp Addr write cycle
  		    regEppAdr <= EppDB;          -- Epp Address register update
        end if;
      end if;
    end process;

  -- EPP Write registers register
  process (EppDstb)
    begin
      if rising_edge(EppDstb) then  -- Astb end edge
        if EppWr = '0' then -- Epp Addr write cycle
          if regEppAdr = X"00" then 
  		      regVer <= not EppDB;          -- register update (complemented)
          elsif regEppAdr = X"05" then 
  		      Sw(7 downto 0) <= EppDB;      -- register update
          elsif regEppAdr = X"06" then 
            Sw(15 downto 8) <= EppDB;     -- register update
          elsif regEppAdr = X"07" then 
  		      Btn(7 downto 0) <= EppDB;     -- register update
          elsif regEppAdr = X"08" then 
  		      Btn(15 downto 8) <= EppDB;    -- register update
          elsif regEppAdr = X"09" then 
  		      dwOut(7 downto 0) <= EppDB;   -- register update
          elsif regEppAdr = X"0a" then 
  		      dwOut(15 downto 8) <= EppDB;  -- register update
          elsif regEppAdr = X"0b" then 
  		      dwOut(23 downto 16) <= EppDB; -- register update
          elsif regEppAdr = X"0c" then 
  		      dwOut(31 downto 24) <= EppDB; -- register update
          end if;
        end if;
      end if;
    end process;

end Behavioral;
