
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

-----------------------------------------------------
--
--  This block will contain a decoder to decode a 4-bit number
--  to a 7-bit vector suitable to drive a HEX dispaly
--
--  It is a purely combinational block (think Pattern 1) and
--  is similar to a block you designed in Lab 1.
--
--------------------------------------------------------

ENTITY smallDecimalConverter IS
	PORT(
	        number : in unsigned(5 downto 0);
          digit0 : OUT  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          digit1 : OUT  UNSIGNED(3 DOWNTO 0)  -- number 0 to 0xF
	);
END;


ARCHITECTURE behavioral OF smallDecimalConverter IS
BEGIN
-- Your code goes here
  process(all) 
  variable tempNum : integer := 0;
  begin
    tempNum := to_integer(number) /10;
    digit1 <= to_unsigned(tempNum, 4);
    
    tempNum := (to_integer(number) - (tempNum * 10)) / 1;
    digit0 <= to_unsigned(tempNum, 4);
end process;

END;