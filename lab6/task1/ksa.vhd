library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
component lcd_driver is
	port( 
	     clk : in std_logic;
		  resetb : in std_logic;
		  displ_char : in std_logic_vector(7 downto 0);
		  displ_write : in std_logic;
		  displ_ready : out std_logic;
        lcd_rw : out std_logic;
        lcd_en : out std_logic;
        lcd_rs : out std_logic;
        lcd_on : out std_logic;
        lcd_blon : out std_logic;
        lcd_data : out std_logic_vector(7 downto 0));
end component ;
	
	component core is
  port(clk : in  std_logic;  -- Clock 
       reset : in  std_logic;  -- reset
       MIN_KEY : in  integer;  -- slider switches
       MAX_KEY : in  integer;
		   DONE : out std_logic;  
		   address_in : in std_logic_vector(4 downto 0);
		   q_out      : out std_logic_vector(7 downto 0); 
		   found : out std_logic);  -- red lights
  end component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, state_print, write, state_done_printing, next_char,				
   	 					  state_done);
								
    -- These are signals that are used to connect to the memory													 

	 signal address_d : STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal data_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren_d: STD_LOGIC;	
	 signal q_d1 : STD_LOGIC_VECTOR (7 DOWNTO 0);	
	 signal q_d2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal q_d3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal q_d4 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 signal q_d  : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 signal clk : std_logic;
	 signal reset : std_logic;
	 
	 signal secret_key : unsigned(23 downto 0) := (others => '0');
	 
	 signal c1_done : std_logic := '0';
	 signal c1_found : std_logic := '0';
	 signal c2_done : std_logic := '0';
	 signal c2_found : std_logic := '0';
	 signal c3_done : std_logic := '0';
	 signal c3_found : std_logic := '0';
	 signal c4_done : std_logic := '0';
	 signal c4_found : std_logic := '0';
	 
	 	signal	 displ_char :  std_logic_vector(7 downto 0);
		signal displ_write :  std_logic;
		signal  displ_ready :  std_logic;
    signal    lcd_rw :  std_logic;
    signal   lcd_en :  std_logic;
    signal    lcd_rs :  std_logic;
    signal   lcd_on :  std_logic;
    signal   lcd_blon :  std_logic;
    signal   lcd_data :  std_logic_vector(7 downto 0);
	 
	 begin
	   	clk <= CLOCK_50;
	   	--clk <= KEY(1);
	   	reset <= not(KEY(0));
	  -- 	secret_key <= "000000" & SW(17 downto 0);
	  
	    -- Include the S memory structurally
	    c1: core port map (
	      clk => clk,  -- Clock 
       reset => reset,  -- reset
       MIN_KEY => 0,  
       MAX_KEY => 4194303,
		   DONE => c1_done,  
		   found => c1_found,
		   address_in => address_d,
		   q_out => q_d1); 
		   
      c2: core port map (
	      clk => clk,  -- Clock 
       reset => reset,  -- reset
       MIN_KEY => 4194304,  
       MAX_KEY => 8388607,
		   DONE => c2_done,  
		   found => c2_found,
		   address_in => address_d,
		   q_out => q_d2); 

      c3: core port map (
	      clk => clk,  -- Clock 
       reset => reset,  -- reset
       MIN_KEY => 8388608,  
       MAX_KEY => 12582911,
		   DONE => c3_done,  
		   found => c3_found,
		   address_in => address_d,
		   q_out => q_d3); 
		  
		  c4: core port map (
	      clk => clk,  -- Clock 
       reset => reset,  -- reset
       MIN_KEY => 12582912,  
       MAX_KEY => 16777216,
		   DONE => c4_done,  
		   found => c4_found,
		   address_in => address_d,
		   q_out => q_d4); 
		   
		 lcd: lcd_driver	port map ( 
	     clk => clk,
		  resetb => reset,
		  displ_char => displ_char,
		  displ_write => displ_write,
		  displ_ready => displ_ready,
        lcd_rw => lcd_rw,
        lcd_en => lcd_en,
        lcd_rs => lcd_rs,
        lcd_on  =>   lcd_on,
        lcd_blon => lcd_blon,
        lcd_data  =>   lcd_data);
       -- write your code here.  As described in Slide Set 14, this 
       -- code will drive the address, data, and wren signals to
       -- fill the memory with the values 0...255
         
       -- You will be likely writing this is a state machine. Ensure
       -- that after the memory is filled, you enter a DONE state which
       -- does nothing but loop back to itself.  
       
       LEDR(17) <= c1_done;
       LEDR(16) <= c1_found;
       LEDR(14) <= c2_done;
       LEDR(13) <= c2_found;
       LEDR(11) <= c3_done;
       LEDR(10) <= c3_found;
       LEDR(8) <= c4_done;
       LEDR(7) <= c4_found;
       
       process(all) begin
         if(c1_found = '1') then
           q_d <= q_d1;
         elsif(c2_found = '1') then
           q_d <= q_d2;
         elsif(c3_found = '1') then
           q_d <= q_d3;
        elsif(c4_found = '1') then
           q_d <= q_d4;
         else
           q_d <= q_d1;
         end if;
       end process;
       
       process(clk, reset)
         variable state : state_type := state_init;
         variable i : natural := 0;
         
         begin
          if(reset = '1') then
           --reset
           LEDG <= (others => '0');
--           LEDR <= (others => '0');
           state := state_init;
          elsif rising_edge(clk) then
           case state is
           when state_init =>
             if(c1_done = '1') or (c2_done = '1') or (c3_done = '1') or (c4_done = '1') then
             state := state_done;
           else 
             state := state_init;
           end if;
           LEDG <= (others => '0');
     --      LEDR <= (others => '0');
         when state_done =>
           state := state_done;
           if(c1_found = '1') then
             LEDG(4) <= '1';
             state := state_print;
           end if;          
           if(c2_found = '1') then
             LEDG(5) <= '1';
              state := state_print;
           end if;
           if(c3_found = '1') then
             LEDG(6) <= '1';
              state := state_print;
           end if;
           if(c4_found = '1') then
            LEDG(7) <= '1';
             state := state_print;
           end if;
           
           address_d <= std_logic_vector(to_unsigned(i, address_d'length));
           
           if((c1_found = '0') and (c2_found = '0')  and (c3_found = '0')  and (c4_found = '0')) then
              LEDG(0) <= '1';
           end if;
           
          when state_print =>
            address_d <= std_logic_vector(to_unsigned(i, address_d'length));
            if(displ_ready = '1') then
              state := write;
            else
              state := state_print;
            end if;
          when write =>
            displ_char <= q_d;
            if(displ_ready = '0') then
            state := next_char;
            i := i + 1;
          else
            state := write;
          end if;
       when next_char =>
         if(i > 31) then
         state := state_done_printing;
       else
         address_d <= std_logic_vector(to_unsigned(i, address_d'length));
         state := state_print;
       end if;
     when state_done_printing =>
       state := state_done_printing;
           when others =>
             --nothing
           end case;
          end if;
         end process;
         
  

end RTL;


