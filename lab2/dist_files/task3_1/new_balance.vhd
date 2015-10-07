-----------------------------------------------------
--  CPEN 311 - Lab 2
--  Graeme Rennie   23071137
--  Derek Chan      33184128
-----------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
-- Skeleton file for new_balance subblock.  This block is purely
-- combinational (think Pattern 1 in the slides) and calculates the
-- new balance after adding winning bets and subtracting losing bets.
--
---------------------------------------------------------------


ENTITY new_balance IS
  PORT(money : in unsigned(11 downto 0);  -- Current balance before this spin
       value1 : in unsigned(2 downto 0);  -- Value of bet 1
       value2 : in unsigned(2 downto 0);  -- Value of bet 2
       value3 : in unsigned(2 downto 0);  -- Value of bet 3
       bet1_wins : in std_logic;  -- True if bet 1 is a winner
       bet2_wins : in std_logic;  -- True if bet 2 is a winner
       bet3_wins : in std_logic;  -- True if bet 3 is a winner
       new_money : out unsigned(11 downto 0));  -- balance after adding winning
                                                -- bets and subtracting losing bets
END new_balance;


ARCHITECTURE behavioural OF new_balance IS
BEGIN
new_balance_calculator : PROCESS(ALL)
  variable new_balance : unsigned(11 downto 0);
BEGIN
  new_balance := money;
  
  if (bet1_wins = '1') then
    new_balance := new_balance + to_unsigned(35,9)*value1;
  else
    new_balance := new_balance - to_unsigned(1,9)*value1;
  end if;
  
  if (bet2_wins = '1') then
    new_balance := new_balance + to_unsigned(1,9)*value2;
  else
    new_balance := new_balance - to_unsigned(1,9)*value2;
  end if;
  
  if (bet3_wins = '1') then
    new_balance := new_balance + to_unsigned(2,9)*value3;
  else
    new_balance := new_balance - to_unsigned(1,9)*value3;
  end if;
  
  new_money <= new_balance;
  
END PROCESS;
END;
