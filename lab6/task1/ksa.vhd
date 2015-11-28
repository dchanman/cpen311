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
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, 
                       state_fill,	read_Si, waitState1, compute_j, waitState2, write_Si, write_Sj,					
   	 					  state_done);
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	
	 signal clk : std_logic;
	 signal reset : std_logic;
	 signal secret_key : std_logic_vector(23 downto 0);

	 begin
	   	clk <= CLOCK_50;
	   	--clk <= KEY(1);
	   	reset <= not(KEY(0));
	   	secret_key <= "000000" & SW(17 downto 0);
	    -- Include the S memory structurally
       u0: s_memory port map (
	        address, clk, data, wren, q);
			  
       -- write your code here.  As described in Slide Set 14, this 
       -- code will drive the address, data, and wren signals to
       -- fill the memory with the values 0...255
         
       -- You will be likely writing this is a state machine. Ensure
       -- that after the memory is filled, you enter a DONE state which
       -- does nothing but loop back to itself.  
       process(clk, reset)
         variable state : state_type := state_init;
         variable i : natural := 0;
         variable j : natural := 0;
         variable Si : natural := 0;
         variable Sj : natural := 0;
         begin
          if(reset = '1') then
           --reset
           i := 0;
           LEDG(7) <= '0';
           state := state_init;
          elsif rising_edge(clk) then
           case state is
           when state_init =>
             i := 0;
             state := state_fill;
             --do stuff
           when state_fill =>
             if(i > 255) then 
              state := read_Si;
              i := 0;
              j := 0;
              wren <= '0';
            else
              state := state_fill;
              address <= std_logic_vector(to_unsigned(i, address'length));
              data <= std_logic_vector(to_unsigned(i, address'length));
              wren <= '1';
              i := i + 1;
            end if;
             --more stuff
           when read_Si =>
             if(i > 255) then
              state := state_done;
              wren <= '0';
            else
             address <= std_logic_vector(to_unsigned(i, address'length));
             wren <= '0';
             state := waitState1;
            end if;
           when waitState1 =>
             wren <= '0';
             state := compute_j;
             Si := to_integer(unsigned(q));
           when compute_j =>
             wren <= '0';
             Si := to_integer(unsigned(q));
             j := j + Si;
             case (i mod 3) is
              when 0 => j := j + to_integer(unsigned(secret_key(23 downto 16)));
              when 1 => j := j + to_integer(unsigned(secret_key(15 downto 8)));
              when 2 => j := j + to_integer(unsigned(secret_key(7 downto 0)));
              when others => j := j;
            end case;
           --j := j + to_integer(((unsigned(secret_key))(i mod 3)));
             j := j mod 256;
             address <= std_logic_vector(to_unsigned(j, address'length));
             state := waitState2;
           when waitState2 =>
             state := write_Si;
              Sj := to_integer(unsigned(q));
           when write_Si =>
               wren <= '1';
              Sj := to_integer(unsigned(q));
              address <= std_logic_vector(to_unsigned(j, address'length));
              data <= std_logic_vector(to_unsigned(Si, address'length));
              state := write_Sj;
            when write_Sj =>
              wren <= '1';
              address <= std_logic_vector(to_unsigned(i, address'length));
              data <= std_logic_vector(to_unsigned(Sj, address'length));
              state := read_Si;
              i := i + 1;
           when state_done =>
             state := state_done;
             wren <= '0';
             LEDG(7) <= '1';
             --over
           when others =>
             --nothing
           end case;
          end if;
          
          LEDR(7 downto 0) <= std_logic_vector(to_unsigned(i, 8));
          LEDR(17 downto 10) <= std_logic_vector(to_unsigned(j, 8));
         end process;
         
  

end RTL;


