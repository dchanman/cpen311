-----------------------------------------------------
--	CPEN 311 - Lab 2
--	Graeme Rennie	23071137
--	Derek Chan 		33184128
-----------------------------------------------------

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

ENTITY binary_to_decimal IS
	PORT(
          binary : IN  UNSIGNED(11 downto 0);  -- number 0 to 4096
          digit_1 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_10 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_100 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_1000 : OUT UNSIGNED(3 downto 0)  -- one per segment
	);
END;


ARCHITECTURE behavioral OF binary_to_decimal IS
BEGIN
  conversion : PROCESS(ALL)
    variable input_value : unsigned(11 downto 0);
    variable output_value : unsigned(11 downto 0);
  BEGIN
    input_value := binary;
    output_value := input_value mod 10;
    digit_1 <= output_value(3 downto 0);
    
    input_value := binary / 10;
    output_value := input_value mod 10;
    digit_10 <= output_value(3 downto 0);
    
    input_value := binary / 100;
    output_value := input_value mod 10;
    digit_100 <= output_value(3 downto 0);
    
    input_value := binary / 1000;
    output_value := input_value mod 10;
    digit_1000 <= output_value(3 downto 0); 
    
  END PROCESS;
END;
