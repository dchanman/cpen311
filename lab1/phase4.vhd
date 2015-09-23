--------------------------------------------------------
--	CPEN 311 - Lab 1
--	Graeme Rennie	23071137
--	Derek Chan 		33184128
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase4 is
   port (KEY: in std_logic_vector(3 downto 0);  -- push-button switches
         SW : in std_logic_vector(17 downto 0);  -- slider switches
         CLOCK_50: in std_logic;                 -- 50MHz clock input
         CLOCK_27 : in std_logic;
         LEDR : out std_logic_vector(17 downto 0);
	 HEX0 : out std_logic_vector(6 downto 0); -- output to drive digit 0
	 HEX1 : out std_logic_vector(6 downto 0)
   );     
end phase4;

architecture structural of phase4 is

   component state_machine
      port (clk : in std_logic;   -- clock input
         resetb : in std_logic;   -- active-low reset input
         dir : in std_logic;      -- dir switch value
         hex0 : out std_logic_vector(6 downto 0)  -- drive digit 0
      );
   end component;

   -- These following signals are used in the clock dividers (see below).
	-- slow_clock and fast_clock are the outputs of the clock dividers.
	-- count50 and count27 count the clocks cycles from CLOCK50 and CLOCK27 respectively
	-- count50_limit and count27_limit are values determined by the switches
	-- speed1 and speed2 are translations from the SW inputs
	-- speed27 and speed50 are non-zero speeds that modify the rate at which the LEDs change
	
   signal slow_clock : std_logic := '0';
   signal fast_clock : std_logic := '0';
   signal count50 : unsigned(34 downto 0) := (others => '0');
   signal count27 : unsigned(34 downto 0) := (others => '0');
   
   signal count50_limit : unsigned(31 downto 0) := (others => '0');
	signal count27_limit : unsigned(31 downto 0) := (others => '0');
   
   signal speed1 : unsigned(7 downto 0);
   signal speed2 : unsigned(7 downto 0);
   signal speed27 : unsigned(7 downto 0);
   signal speed50 : unsigned(7 downto 0);

   -- Note: the above syntax (others=>'0') is a short cut for initializing
   -- all bits in this 26 bit wide bus to 0. 

begin
    speed1 <= unsigned(SW(17 downto 10));
    speed2 <= unsigned(SW(9 downto 2));

	 -- These are the linear functions that map SW inputs to variable speeds
    count50_limit <= to_unsigned(((-952148)*to_integer(speed50)+250952148), 32);
    count27_limit <= to_unsigned(((-514160)*to_integer(speed27)+135514160), 32);
    
	 -- The following processes ensure that the clock still runs with a SW input of 0
	PROCESS(all) begin
		if(speed1 = "00000000") then
		speed50 <= "00000001";
	else
		speed50 <= speed1;
	end if;
	end process;
	
	PROCESS(all) begin
		if(speed2 = "00000000") then
		speed27 <= "00000001";
	else
		speed27 <= speed2;
	end if;
	end process;

	-- This is the clock divider process. It converts the physical clocks to variable speeds
    PROCESS (CLOCK_27)	
    BEGIN
		if rising_edge (CLOCK_27) THEN 
			count27 <= count27 + 1;
			-- Once the count exceeds the limit set by the switches,
			-- toggle our output and create our clock signal
			if(count27 > count27_limit) then
				slow_clock <= not slow_clock;
            count27 <= (others => '0');
			end if;
		end if;
    END process;

	PROCESS (CLOCK_50)	
	BEGIN
		if rising_edge (CLOCK_50) THEN 
			count50 <= count50 + 1;
			-- Once the count exceeds the limit set by the switches,
			-- toggle our output and create our clock signal
			if(count50 > count50_limit) then
				fast_clock <= not fast_clock;
				count50 <= (others => '0');
			end if;
		end if;
	END process;

	-- For debugging, blink the LEDs with the clock produced by the clock divider process
    LEDR(8) <= fast_clock;
    LEDR(6) <= slow_clock;

    -- instantiate the state machine component, which is defined in 
    -- state_machine.vhd (which you will write).    
    
    u0: state_machine port map(slow_clock,  -- the clock input to the state machine
                                            -- is the slow clock
                               KEY(0),  -- the reset input to the state machine is
                                        -- pushbutton # 0
                               SW(0),   -- the dir input to the state machine is
                                        -- slider switch # 0,
                               HEX1);	-- the output of the state machine is connected
                                        -- to hex digit 1
                                        
    u1: state_machine port map(fast_clock,  -- the clock input to the state machine
                                            -- is the slow clock
                               KEY(0),  -- the reset input to the state machine is
                                        -- pushbutton # 0
                               SW(1),   -- the dir input to the state machine is
                                        -- slider switch # 1,
                               HEX0);	-- the output of the state machine is connected
                                        -- to hex digit 0
end structural;
