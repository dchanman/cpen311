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
  
  component spinwheel IS
	PORT(
		fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock  component spinwheel IS
	PORT(
		fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
		resetb : IN  STD_LOGIC;      -- asynchronous reset
		spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
  END component;

component win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win component;
		resetb : IN  STD_LOGIC;      -- asynchronous reset
		spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
  END component;

component win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win component;
  
  signal spin_result : unsigned(5 downto 0);
  signal slow_clock : std_logic := '0';
 	signal spin_result_latched : unsigned(5 downto 0);  -- result of the spin (the winning number)
  signal bet1_value : unsigned(5 downto 0); -- value for bet 1
  signal bet2_colour : std_logic;  -- colour for bet 2
  signal bet3_dozen : unsigned(1 downto 0);  -- dozen for bet 3
  signal bet1_wins : std_logic;  -- whether bet 1 is a winner
  signal bet2_wins : std_logic;  -- whether bet 2 is a winner
  signal bet3_wins :  std_logic; -- whether bet 3 is a winner
 --- Your code goes here
 begin
  spinner : spinwheel port map(fast_clock => CLOCK_27, resetb => key(1), spin_result => spin_result);
   
  process(slow_clock) begin
     if(rising_edge(slow_clock)) then
      spin_result_latched <= spin_result;
    end if;
  end process;
  
    process(slow_clock) begin
     if(rising_edge(slow_clock)) then
      bet1_value <= unsigned(SW(8 downto 3));
    end if;
  end process;
  
  process(slow_clock) begin
     if(rising_edge(slow_clock)) then
      bet2_colour <= SW(12);
    end if;
  end process;
  
  process(slow_clock) begin
     if(rising_edge(slow_clock)) then
      bet3_dozen <= unsigned(SW(17 downto 16));
    end if;
  end process;
  
  win_block : win port map (spin_result_latched => spin_result_latched,
             bet1_value => bet1_value,
             bet2_colour => bet2_colour,
             bet3_dozen => bet3_dozen,
             bet1_wins => bet1_wins,
             bet2_wins => bet2_wins,
             bet3_wins => bet3_wins);
    
    
    
END;
