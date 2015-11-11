library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- This is a package that provides useful constants and types for Lab 5.
-- 

package lab5_pkg is
  constant POS_AMPL  : integer := 32768;
  constant NEG_AMPL : integer := -32768;
  
  -- the following are sample rates for the notes A-G they are represented 
  -- as half a period such that they can be shifted before use instead of devided
  -- these numbers were obtained by: 48000 / note freq / 2
  constant C : integer := 92; --262Hz
  constant D : integer := 82; --294Hz
  constant E : integer := 73; --330HZ
  constant F : integer := 69; --349Hz
  constant G : integer := 61; --392Hz
  constant A : integer := 55; --440Hz
  constant B : integer := 49; --494Hz

  
  --type point is record
  --  x : unsigned(7 downto 0);
  --  y : unsigned(7 downto 0);
  --end record;
  
  -- List of states that the state machine can be in.
  type state_type is (INIT, WAITSTATE, 
                           WRITE);
end;

package body lab5_pkg is
end package body;
