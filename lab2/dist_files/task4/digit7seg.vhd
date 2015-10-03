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

ENTITY digit7seg IS
	PORT(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
	);
END;


ARCHITECTURE behavioral OF digit7seg IS
BEGIN

digit_lookup : PROCESS(ALL)
BEGIN
  if digit = 0 then
    seg7 <= "1000000";
  elsif digit = 1 then
    seg7 <= "1111001";
  elsif digit = 2 then
    seg7 <= "0100100";
  elsif digit = 3 then
    seg7 <= "0110000";
  elsif digit = 4 then
    seg7 <= "0011001";
  elsif digit = 5 then
    seg7 <= "0010010";
  elsif digit = 6 then
    seg7 <= "0000010";
  elsif digit = 7 then
    seg7 <= "1111000";
  elsif digit = 8 then
    seg7 <= "0000000";
  elsif digit = 9 then
    seg7 <= "0010000";
  elsif digit = 10 then
    seg7 <= "0001000";
  elsif digit = 11 then
    seg7 <= "0000011";
  elsif digit = 12 then
    seg7 <= "0100111";
  elsif digit = 13 then
    seg7 <= "0100001";
  elsif digit = 14 then
    seg7 <= "0000110";
  elsif digit = 15 then
    seg7 <= "0001110";
  else
    seg7 <= "0111111";
  end if;
END PROCESS;

END;
