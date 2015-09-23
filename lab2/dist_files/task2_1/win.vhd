LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a skeleton you can use for the win subblock.  This block determines
--  whether each of the 3 bets is a winner.  As described in the lab
--  handout, the first bet is a "straight-up" bet, teh second bet is 
--  a colour bet, and the third bet is a "dozen" bet.
--
--  This should be a purely combinational block.  There is no clock.
--  Remember the rules associated with Pattern 1 in the lectures.
--
---------------------------------------------------------------

ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win;


ARCHITECTURE behavioural OF win IS
BEGIN

-- process for checking if bet1 wins
-- bet1 is a single bet.
bet1_checker : PROCESS(ALL)
BEGIN
	if (spin_result_latched = bet1_value) then
		bet1_wins <= '1';
	else
		bet1_wins <= '0';
	end if;
END PROCESS;

-- process for checking if bet2 wins
-- bet2 is a color bet
-- '1' is red, '0' is black
bet2_checker : PROCESS(ALL)
	variable spin_result_unsigned : unsigned(5 downto 0);
BEGIN
	spin_result_unsigned := unsigned(spin_result_latched);
	
	-- Default value, bet2_wins is false
	bet2_wins <= '0';
	
	if (spin_result_unsigned = 0) then
		-- [0] has no color
		bet2_wins <= '0';
	elsif(spin_result_unsigned < 19) then
		-- for values [1,18], odd numbers are RED, even are BLACK
		if (spin_result_latched(0) = bet2_colour) then
			bet2_wins <= '1';
		end if;
	else
		-- for values [19,36], even numbers are RED, odd are BLACK
		if (spin_result_latched(0) = not bet2_colour) then
			bet2_wins <= '1';
		end if;
	end if;
END PROCESS;

-- process for checking if bet3 wins
-- bet3 is a dozen bet for ranges [1,12], [13,24], [25,36]
bet3_checker : PROCESS(ALL)
	variable spin_result_unsigned : unsigned(5 downto 0);
BEGIN
	spin_result_unsigned := unsigned(spin_result_latched);
	
	bet3_wins <= '0';
	
	case bet3_dozen is
		when "00" =>
		  if ((spin_result_unsigned >= 1) and (spin_result_unsigned <= 12)) then
				bet3_wins <= '1';
			end if;
		when "01" =>
			if ((spin_result_unsigned >= 13) and (spin_result_unsigned <= 24)) then
				bet3_wins <= '1';
			end if;
		when "10" =>
			if ((spin_result_unsigned >= 25) and (spin_result_unsigned <= 36)) then
				bet3_wins <= '1';
			end if;
		when others =>
			bet3_wins <= '0';
	end case;
END PROCESS;

END;
