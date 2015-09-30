LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

----------------------------------------------------------------------
--
--  This is the top level template for Lab 2.  Use the schematic on Page 3
--  of the lab handout to guide you in creating this structural description.
--  The combinational blocks have already been designed in previous tasks,
--  and the spinwheel block is given to you.  Your task is to combine these
--  blocks, as well as add the various registers shown on the schemetic, and
--  wire them up properly.  The result will be a roulette game you can play
--  on your DE2.
--
-----------------------------------------------------------------------

ENTITY roulette IS
	PORT(   CLOCK_27 : IN STD_LOGIC; -- the fast clock for spinning wheel
		KEY : IN STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : IN STD_LOGIC_VECTOR(17 downto 0);
		LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
		HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
END roulette;


ARCHITECTURE structural OF roulette IS
	-- Component definitions
	COMPONENT spinwheel IS
	PORT(
		fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
		resetb : IN  STD_LOGIC;      -- asynchronous reset
		spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
	END COMPONENT;
	
	COMPONENT digit7seg IS
	PORT(
          digit : IN  UNSIGNED(3 downto 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 downto 0)  -- one per segment
	);
	END COMPONENT;
	
	COMPONENT new_balance IS
	PORT(money : in unsigned(11 downto 0);  -- Current balance before this spin
		value1 : in unsigned(2 downto 0);  -- Value of bet 1
		value2 : in unsigned(2 downto 0);  -- Value of bet 2
		value3 : in unsigned(2 downto 0);  -- Value of bet 3
		bet1_wins : in std_logic;  -- True if bet 1 is a winner
		bet2_wins : in std_logic;  -- True if bet 2 is a winner
		bet3_wins : in std_logic;  -- True if bet 3 is a winner
		new_money : out unsigned(11 downto 0));  -- balance after adding winning
                                                -- bets and subtracting losing bets
	END COMPONENT;
	
	COMPONENT win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
		bet1_value : in unsigned(5 downto 0); -- value for bet 1
		bet2_colour : in std_logic;  -- colour for bet 2
		bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
		bet1_wins : out std_logic;  -- whether bet 1 is a winner
		bet2_wins : out std_logic;  -- whether bet 2 is a winner
		bet3_wins : out std_logic); -- whether bet 3 is a winner
	END COMPONENT;
	
	-- Signal definitions
	SIGNAL spin_result : UNSIGNED(5 downto 0);
	SIGNAL spin_result_latched : UNSIGNED(5 downto 0);
	SIGNAL bet1_value : UNSIGNED(5 downto 0);
	SIGNAL bet2_colour : STD_LOGIC;
	SIGNAL bet3_dozen : UNSIGNED(1 downto 0);
	SIGNAL bet1_wins : STD_LOGIC;
	SIGNAL bet2_wins : STD_LOGIC;
	SIGNAL bet3_wins : STD_LOGIC;
	SIGNAL money : UNSIGNED(11 downto 0);
	SIGNAL new_money : UNSIGNED(11 downto 0);
	SIGNAL bet1_amount : UNSIGNED(2 downto 0);
	SIGNAL bet2_amount : UNSIGNED(2 downto 0);
	SIGNAL bet3_amount : UNSIGNED(2 downto 0);
	SIGNAL resetb : STD_LOGIC;
	SIGNAL slow_clock : STD_LOGIC;
	SIGNAL fast_clock : STD_LOGIC;
	
BEGIN
	-- Hardware signal mappings
	resetb <= KEY(1);
	slow_clock <= KEY(0);
	fast_clock <= CLOCK_27;
	LEDG(0) <= bet1_wins;
	LEDG(1) <= bet2_wins;
	LEDG(2) <= bet3_wins;
	HEX3 <= "1111111";
	HEX4 <= "1111111";
	HEX5 <= "1111111";

	-- Instantiate components
	spinwheel_1 : spinwheel port map(
		fast_clock, -- fast_clock
		resetb, -- resetb
		spin_result -- spin_result
	);
	
	win_6 : win port map(
		spin_result_latched,
		bet1_value,
		bet2_colour,
		bet3_dozen,
		bet1_wins,
		bet2_wins,
		bet3_wins
	);
	
	new_balance_11 : new_balance port map(
		money,
		bet1_amount, -- value 1
		bet2_amount, -- value 2
		bet3_amount, -- value 3
		bet1_wins,
		bet2_wins,
		bet3_wins,
		new_money
	);
	
	digit7seg_12 : digit7seg port map(
		new_money(11 downto 8),
		HEX2
	);
	
	digit7seg_13 : digit7seg port map(
		new_money(7 downto 4),
		HEX1
	);
	
	digit7seg_14 : digit7seg port map(
		new_money(3 downto 0),
		HEX0
	);
	
	digit7seg_15 : digit7seg port map(
		spin_result_latched(3 downto 0),
		HEX6
	);
	
	digit7seg_16 : digit7seg port map(
		"00" & spin_result_latched(5 downto 4),
		HEX7
	);
	
	-- Processes defined below as latches
	six_bit_register_2 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				spin_result_latched <= to_unsigned(0, spin_result_latched'length);
			else
				spin_result_latched <= spin_result;
			end if;
		end if;	
	END PROCESS;
	
	six_bit_register_3 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet1_value <= to_unsigned(0, bet1_value'length);
			else
				bet1_value <= unsigned(SW(8 downto 3));
			end if;
		end if;		
	END PROCESS;
	
	one_bit_dff_4 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet2_colour <= '0';
			else
				bet2_colour <= std_logic(SW(12));
			end if;
		end if;		
	END PROCESS;

	two_bit_register_5 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet3_dozen <= to_unsigned(0, bet3_dozen'length);
			else
				bet3_dozen <= unsigned(SW(17 downto 16));
			end if;
		end if;		
	END PROCESS;
	
	three_bit_register_7 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet1_amount <= to_unsigned(0, bet1_amount'length);
			else
				bet1_amount <= unsigned(SW(2 downto 0));
			end if;
		end if;	
	END PROCESS;
	
	three_bit_register_8 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet2_amount <= to_unsigned(0, bet2_amount'length);
			else
				bet2_amount <= unsigned(SW(11 downto 9));
			end if;
		end if;	
	END PROCESS;
	
	three_bit_register_9 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				bet3_amount <= to_unsigned(0, bet3_amount'length);
			else
				bet3_amount <= unsigned(SW(15 downto 13));
			end if;
		end if;	
	END PROCESS;
	
	twelve_bit_register_10 : PROCESS(slow_clock)
	BEGIN
		if rising_edge(slow_clock) then
			if resetb = '0' then
				money <= to_unsigned(32, money'length);
			else
				money <= new_money;
			end if;
		end if;	
	END PROCESS;
	
END;
