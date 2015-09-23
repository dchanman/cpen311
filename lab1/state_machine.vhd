--------------------------------------------------------
--	CPEN 311 - Lab 1
--	Graeme Rennie	23071137
--	Derek Chan 		33184128
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------
--
--  This is the entity part of the top level file for Phase 3.
--  The entity part declares the inputs and outputs of the
--  module as well as their types.  For now, a signal of
--  “std_logic” type can take on the value ‘0’ or ‘1’ (it
--  can actually do more than this).  A signal of type
--  std_logic_vector can be thought of as an array of 
--  std_logic, and is used to describe a bus (a parallel 
--  collection of wires).
--
--  Note: you don't have to change the entity part.
--  
----------------------------------------------------------

entity state_machine is
   port (clk : in std_logic;  -- clock input to state machine
         resetb : in std_logic;  -- active-low reset input
         dir : in std_logic;     -- dir input
         hex0 : out std_logic_vector(6 downto 0)  -- output of state machine
            -- Note that in the above, hex0 is a 7-bit wide bus
            -- indexed using indices 6, 5, 4 ... down to 0.  The
            -- most-significant bit is hex(6) and the least significant
            -- bit is hex(0)
   );
end state_machine;

----------------------------------------------------------------
--
-- The following is the architecture part of the state machine.  It 
-- describes the behaviour of the state machine using synthesizable
-- VHDL.  
--
----------------------------------------------------------------- 

architecture behavioural of state_machine is


-- Declare 2 internal signals (2-bit)
-- First signal is the next_state
-- Second signal is the current_state
signal next_state,current_state:std_logic_vector(2 downto 0);
begin

	-- State Machine process
	process(all)
	begin
		if (DIR = '0') then
			case current_state is
				when "000" =>
					next_state <= "001";
				when "001" =>
					next_state <= "010";
				when "010" =>
					next_state <= "011";
				when "011" =>
					next_state <= "100";
				when "100" =>
					next_state <= "000";
				when others =>
				  next_state <= "000";
			end case;
		else
		  case current_state is
				when "000" =>
					next_state <= "100";
				when "001" =>
					next_state <= "000";
				when "010" =>
					next_state <= "001";
				when "011" =>
					next_state <= "010";
				when "100" =>
					next_state <= "011";
				when others =>
				  next_state <= "000";
			end case;
		end if;
		
		-- if the reset signal is high, then the next state is 00
		if (resetb = '0') then
			next_state <= "000";
		end if;
	end process;
	
	-- Output process
	process(all)
	begin
		if (current_state = "000") then
			hex0 <= "0100001"; -- D
		elsif (current_state = "001") then
			hex0 <= "0000110"; -- E
		elsif (current_state = "010") then
			hex0 <= "0101111"; -- R
		elsif (current_state = "011") then
			hex0 <= "0000110"; -- E
		elsif(current_state = "100") then
			hex0 <= "0001001"; -- K
		else
		  hex0 <= "1111111";
		end if;
	end process;
	
	-- Current/Next State Updater Process
	process(clk)
	begin
		if rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;
	

end behavioural;
