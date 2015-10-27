LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;


ENTITY lab3_draw_line_tb IS
  -- no inputs or outputs
END lab3_draw_line_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF lab3_draw_line_tb IS        

  -- Define the lab3_draw_line subblock, which is the component we are testing
  component lab3_draw_line is
    port(
      CLOCK  : in  std_logic;
      RESET : in  std_logic;
      START : in  std_logic;
      X0  : in  unsigned(7 downto 0);
      X1  : in  unsigned(7 downto 0);
      Y0  : in  unsigned(7 downto 0);
      Y1  : in  unsigned(7 downto 0);
      X : out unsigned(7 downto 0);
      Y : out unsigned(7 downto 0);
      PLOT  : out std_logic;
      DONE  : out std_logic);
  end component;

   -- local signals we will use in the testbench
  SIGNAL CLOCK  : std_logic;
  SIGNAL RESET  : std_logic;
  SIGNAL START : std_logic;
  SIGNAL X0 : unsigned(7 downto 0);
  SIGNAL Y0 : unsigned(7 downto 0);
  SIGNAL X1 : unsigned(7 downto 0);
  SIGNAL Y1 : unsigned(7 downto 0);
  SIGNAL X : unsigned(7 downto 0);
  SIGNAL Y : unsigned(7 downto 0);
  SIGNAL PLOT  : std_logic;
  SIGNAL DONE  : std_logic;
begin

   -- instantiate the design-under-test

   dut : lab3_draw_line PORT MAP(
    CLOCK => CLOCK,
    RESET => RESET,
	  START => START,   
	  X0 => X0,
	  Y0 => Y0,
		X1 => X1,
	  Y1 => Y1,
	  X => X,
	  Y => Y,
	  PLOT => PLOT,
	  DONE => DONE
   );


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
     variable x_expected : unsigned(7 downto 0) := to_unsigned(0,8);
     variable y_expected : unsigned(7 downto 0) := to_unsigned(0,8);
   begin   
       
      -- starting values for simulation
      report "================== STARTING TESTS =============================";

      clock <= '0';
      reset <= '0';
      start <= '1';
      X0 <= to_unsigned(0,8);
      X1 <= to_unsigned(0,8);
      Y0 <= to_unsigned(0,8);
      Y1 <= to_unsigned(0,8);
      
      wait for 1 ns;
      
      -- validate reset
      report "================== VALIDATING RESET =============================";
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
      
    
      -- test that we can draw a straight line
      report "================== VALIDATING HORIZONTAL LINE 0 =============================";
      clock <= '0';
      reset <= '1';
      start <= '0';
      X0 <= to_unsigned(0,8);
      X1 <= to_unsigned(160,8);
      Y0 <= to_unsigned(0,8);
      Y1 <= to_unsigned(0,8);
      wait for 1 ns;
      
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
          
      
      for x_index in to_integer(X0) to to_integer(X1) loop
        report "Validating straight line: (" & integer'image(x_index) & ",0)";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(X = to_unsigned(x_index,X'length))
          report "FAILED LOOP, X expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(X)) & ">"
          severity failure;
        
        assert(Y = Y0 and Y = Y1)
          report "FAILED LOOP, Y expected: <" & integer'image(to_integer(Y0))  & "> instead of <" & integer'image(to_integer(Y)) & ">"

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
      
      -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
                     
      -- validate done
      report "Validating done state";
      
      assert(DONE = '1')
        report "FAILED DONE - DONE WAS NOT 1"
        severity failure;
        
      assert(X = X1)
        report "FAILED DONE - X WAS NOT X1"
        severity failure;
        
      assert(Y = Y1)
        report "FAILED DONE - Y WAS NOT Y1"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED DONE - PLOT WAS NOT 0"
        severity failure;
      
      -- done should be independent of clock cycles
      report "================== VALIDATING ASYNC RESET =============================";
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
        report "FAILED DONE - DONE WAS NOT 1"
        severity failure;
        
      assert(X = X1)
        report "FAILED DONE - X WAS NOT X1"
        severity failure;
        
      assert(Y = Y1)
        report "FAILED DONE - Y WAS NOT Y1"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED DONE - PLOT WAS NOT 0"
        severity failure;
                       
        
      -- validate resetting state when reset goes low
      report "Validating reset";
      reset <= '0';
      start <= '1';
      wait for 1 ns;
      
      assert(DONE = '0')
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
        
        
      report "================== VALIDATING HORIZONTAL LINE 1 =============================";
      clock <= '0';
      reset <= '1';
      start <= '0';
      X0 <= to_unsigned(160,8);
      X1 <= to_unsigned(0,8);
      Y0 <= to_unsigned(0,8);
      Y1 <= to_unsigned(0,8);
      wait for 1 ns;
      
      -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
      for x_index in to_integer(X0) downto to_integer(X1) loop
        report "Validating straight line: (" & integer'image(x_index) & ",0)";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(X = to_unsigned(x_index,X'length))
          report "FAILED LOOP, X expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(X)) & ">"
          severity failure;
        
        assert(Y = Y0 and Y = Y1)
          report "FAILED LOOP, Y expected: <" & integer'image(to_integer(Y0))  & "> instead of <" & integer'image(to_integer(Y)) & ">"

          severity failure;
        
        assert(PLOT = '1')
          report "FAILED LOOP - PLOT WAS NOT 0"
          severity failure;        
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
  
      end loop;
      
      -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
                     
      -- validate done
      report "Validating done state";
      
      assert(DONE = '1')
        report "FAILED DONE - DONE WAS NOT 1"
        severity failure;
        
      assert(X = X1)
        report "FAILED DONE - X WAS NOT X1"
        severity failure;
        
      assert(Y = Y1)
        report "FAILED DONE - Y WAS NOT Y1"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED DONE - PLOT WAS NOT 0"
        severity failure;
      
      -- validate resetting state when reset goes low
      report "Validating reset";
      reset <= '0';
      start <= '1';
      wait for 1 ns;
      
      assert(DONE = '0')
        report "FAILED ASYNC RESET - DONE WAS NOT 1"
        severity failure;
        
      assert(X = X0)
        report "FAILED ASYNC RESET - X WAS NOT 0"
        severity failure;
        
      assert(Y = Y0)
        report "FAILED ASYNC RESET - Y WAS NOT 0"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED ASYNC RESET - PLOT WAS NOT 0"
        severity failure;
               

      report "================== VALIDATING DIAGONAL LINE 0 =============================";
      -- reset
      start <= '1';
      wait for 1 ns;

      clock <= '0';
      reset <= '1';
      start <= '0';
      X0 <= to_unsigned(0,8);
      X1 <= to_unsigned(5,8);
      Y0 <= to_unsigned(0,8);
      Y1 <= to_unsigned(5,8);
      wait for 1 ns;
      
          -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
      
      
      for x_index in to_integer(X0) to to_integer(X1)-1 loop
        report "Validating straight line: (0," & integer'image(x_index) & ")";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(Y = to_unsigned(x_index,Y'length))
          report "FAILED LOOP, Y expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(Y)) & ">"
          severity warning;
          
        assert(X = to_unsigned(x_index,X'length))
          report "FAILED LOOP, X expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(X)) & ">"
          severity warning;
        
        assert(PLOT = '1')
          report "FAILED LOOP - PLOT WAS NOT 1"
          severity failure;        
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
  
      end loop;
      
      -- validate resetting state when reset goes low
      report "Validating reset";
      reset <= '0';
      start <= '1';
      wait for 1 ns;
      
      assert(DONE = '0')
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
      
      report "================== VALIDATING DIAGONAL LINE 1 =============================";
      -- reset
      start <= '1';
      wait for 1 ns;

      clock <= '0';
      reset <= '1';
      start <= '0';
      X0 <= to_unsigned(0,8);
      X1 <= to_unsigned(50,8);
      Y0 <= to_unsigned(0,8);
      Y1 <= to_unsigned(50,8);
      wait for 1 ns;
      
          -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
      
      
      for x_index in to_integer(X0) to to_integer(X1)-1 loop
        report "Validating straight line: (0," & integer'image(x_index) & ")";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
        
        assert(PLOT = '1')
          report "FAILED LOOP - PLOT WAS NOT 1"
          severity failure;
          
        assert(Y = to_unsigned(x_index,Y'length))
          report "FAILED LOOP, Y expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(Y)) & ">"
          severity warning;
          
        assert(X = to_unsigned(x_index,X'length))
          report "FAILED LOOP, X expected: <" & integer'image(x_index)  & "> actual <" & integer'image(to_integer(X)) & ">"
          severity warning;      
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
        
               
      end loop;
      
      -- Manually clock once
      clock <= '0';
      wait for 1 ns;
      clock <= '1';
      wait for 1 ns;
    
                     
      -- validate done
      report "Validating done state";
      
      assert(DONE = '1')
        report "FAILED DONE - DONE WAS NOT 1"
        severity failure;
        
      assert(X = X1)
        report "FAILED DONE - X WAS NOT X1"
        severity failure;
        
      assert(Y = Y1)
        report "FAILED DONE - Y WAS NOT Y1"
        severity failure;
        
      assert(PLOT = '0')
        report "FAILED DONE - PLOT WAS NOT 0"
        severity failure;

      report "================== ALL TESTS PASSED =============================";
      -- validate resetting state when reset goes low
      report "Validating reset";
      reset <= '0';
      start <= '1';
      wait for 1 ns;
      
      assert(DONE = '0')
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
      
      
      -- reset
      start <= '1';
      wait for 1 ns;

      clock <= '0';
      reset <= '1';
      start <= '0';
      X0 <= to_unsigned(0,8);
      X1 <= to_unsigned(159,8);
      Y0 <= to_unsigned(16,8);
      Y1 <= to_unsigned(104,8);
      wait for 1 ns;
      
          -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      
      
      for a_index in to_integer(X0) to to_integer(X1)-1 loop
      for x_index in to_integer(X0) to to_integer(X1)-1 loop
        report "Validating straight line: (0," & integer'image(x_index) & ")";
        
        -- validate reset
        assert(DONE = '0')
          report "FAILED LOOP, DONE WAS NOT '0'"
          severity failure;
          
        -- Manually clock once
        clock <= '0';
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
  
      end loop;
    end loop;
      
                                                                       
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;
