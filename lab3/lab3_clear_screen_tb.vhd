LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;


ENTITY lab3_clear_screen_tb IS
  -- no inputs or outputs
END lab3_clear_screen_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF lab3_clear_screen_tb IS        

  -- Define the lab3_clear_screen subblock, which is the component we are testing
  component lab3_clear_screen is
    port(
     CLOCK  : in  std_logic;
     RESET  : in  std_logic;
     START : in  std_logic;
     X : out std_logic_vector(7 downto 0);
     Y : out std_logic_vector(6 downto 0);
     PLOT  : out std_logic;
     DONE  : out std_logic;
     STATE  : out std_logic_vector(1 downto 0));
  end component;

   -- local signals we will use in the testbench
  SIGNAL CLOCK  : std_logic;
  SIGNAL RESET  : std_logic;
  SIGNAL START : std_logic;
  SIGNAL X : std_logic_vector(7 downto 0);
  SIGNAL Y : std_logic_vector(6 downto 0);
  SIGNAL PLOT  : std_logic;
  SIGNAL DONE  : std_logic;
begin

   -- instantiate the design-under-test

   dut : lab3_clear_screen PORT MAP(
    CLOCK => CLOCK,
    RESET => RESET,
	  START => START,
	  X => X,
	  Y => Y,
	  PLOT => PLOT,
	  DONE => DONE,
	  STATE => open
   );


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
     variable x_expected : unsigned(7 downto 0) := to_unsigned(0,8);
     variable y_expected : unsigned(6 downto 0) := to_unsigned(0,7);
   begin   
       
      -- starting values for simulation

      clock <= '0';
      reset <= '0';
      start <= '1';
      
      wait for 1 ns;
      
      -- validate reset
      assert (DONE = '0')
        report "FAILED INITIAL RESET - DONE WAS NOT 0"
        severity failure;
        
      assert (X = "00000000")
        report "FAILED INITIAL RESET - X WAS NOT 0"
        severity failure;
        
      assert (Y = "0000000")
        report "FAILED INITIAL RESET - Y WAS NOT 0"
        severity failure;
        
      assert (PLOT = '0')
        report "FAILED INITIAL RESET - PLOT WAS NOT 0"
        severity failure;
        
      -- reset should be asynchronous
      clock <= '0';
      reset <= '0';
      start <= '0';
      
      wait for 1 ns;      
      clock <= '1';
      wait for 1 ns;      
      clock <= '0';
      wait for 1 ns;      
      clock <= '1';
      wait for 1 ns;      
      clock <= '0';
      
      -- validate reset
      assert(DONE = '0')
        report "FAILED ASYNC RESET - DONE WAS NOT 0"
        severity failure;
        
      assert(X = "00000000")
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = "0000000")
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;
      
    
      -- test that we iterate through the entire VGA output
      clock <= '0';
      reset <= '1';
      start <= '0';
      wait for 1 ns;

      -- clock once to kick it into CLEARING state      
      --clock <= '1';
      --wait for 1 ns;
      
      for y_index in 0 to 120 loop
      for x_index in 0 to 160 loop
   
        report "Validating (x,y): (" & integer'image(x_index) & "," & integer'image(y_index) & ")";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(X = std_logic_vector(to_unsigned(x_index,X'length)))
          report "FAILED LOOP, X WAS NOT " & integer'image(x_index)
          severity failure;
        
        assert(Y = std_logic_vector(to_unsigned(y_index,Y'length)))
          report "FAILED LOOP, Y WAS NOT " & integer'image(y_index)
          severity failure;
        
        assert(PLOT = '1')
          report "FAILED LOOP - PLOT WAS NOT 1"
          severity warning;
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
        
      end loop;
      end loop;
      
                     
      -- validate done
      report "Validating done state";
      
      assert(DONE = '1')
        report "FAILED ASYNC RESET - DONE WAS NOT 1"
        severity failure;
        
      assert(X = "00000000")
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = "0000000")
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;
      
      -- done should be independent of clock cycles
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      
      assert(DONE = '1')
        report "FAILED ASYNC RESET - DONE WAS NOT 1"
        severity failure;
        
      assert(X = "00000000")
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = "0000000")
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;
        
      -- validate not resetting state when start goes high
      report "Validating releasing start";
      start <= '1';
      reset <= '1';
      wait for 1 ns;
      
      -- done should be independent of clock cycles
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
      
      assert(DONE = '1')
        report "FAILED ASYNC RESET - DONE WAS NOT 1"
        severity failure;
        
      assert(X = "00000000")
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = "0000000")
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;
        
      report "================== TEST PART 2 =============================";
        
      -- reset should be asynchronous
      clock <= '0';
      reset <= '0';
      start <= '1';
      
      wait for 1 ns;      
      clock <= '1';
      wait for 1 ns;      
      clock <= '0';
      wait for 1 ns;      
      clock <= '1';
      wait for 1 ns;      
      clock <= '0';
      
      -- validate reset
      assert(DONE = '0')
        report "FAILED ASYNC RESET - DONE WAS NOT 0"
        severity failure;
        
      assert(X = "00000000")
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = "0000000")
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;

        
      -- test that we iterate through the entire VGA output
      clock <= '0';
      reset <= '1';
      start <= '0';
      wait for 1 ns;

      -- clock once to kick it into CLEARING state      
      --clock <= '1';
      --wait for 1 ns;
      
      for y_index in 0 to 120 loop
      for x_index in 0 to 160 loop
   
        report "Validating (x,y): (" & integer'image(x_index) & "," & integer'image(y_index) & ")";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(X = std_logic_vector(to_unsigned(x_index,X'length)))
          report "FAILED LOOP, X WAS NOT " & integer'image(x_index)
          severity failure;
        
        assert(Y = std_logic_vector(to_unsigned(y_index,Y'length)))
          report "FAILED LOOP, Y WAS NOT " & integer'image(y_index)
          severity failure;
        
        assert(PLOT = '1')
          report "FAILED LOOP - PLOT WAS NOT 1"
          severity failure;
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
        
      end loop;
      end loop;    
      
        
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;
