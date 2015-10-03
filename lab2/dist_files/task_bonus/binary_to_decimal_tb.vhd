LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a testbench you can use to test the binary_to_decimal subblock in Modelsim.
--  The testbench repeatedly applies test vectors and checks the output to
--  make sure they match the expected values.  You can use this without
--  modification (unless you want to add more test vectors, which is not a
--  bad idea).  However, please be sure you understand it before trying to
--  use it in Modelsim.
--
---------------------------------------------------------------

ENTITY binary_to_decimal_tb IS
  -- no inputs or outputs
END binary_to_decimal_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF binary_to_decimal_tb IS        

  -- Define the binary_to_decimal subblock, which is the component we are testing
  COMPONENT binary_to_decimal IS
	PORT(
          binary : IN  UNSIGNED(11 downto 0);  -- number 0 to 4096
          digit_1 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_10 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_100 : OUT UNSIGNED(3 downto 0);  -- one per segment
          digit_1000 : OUT UNSIGNED(3 downto 0)  -- one per segment
	 );
  END COMPONENT;

   -- local signals we will use in the testbench 
   SIGNAL binary : UNSIGNED(11 DOWNTO 0);
   SIGNAL digit_1 : UNSIGNED(3 DOWNTO 0);  
   SIGNAL digit_10 : UNSIGNED(3 DOWNTO 0);  
   SIGNAL digit_100 : UNSIGNED(3 DOWNTO 0);  
   SIGNAL digit_1000 : UNSIGNED(3 DOWNTO 0);  
begin

   -- instantiate the design-under-test

   dut : binary_to_decimal PORT MAP(
    binary => binary,
	  digit_1 => digit_1,   
	  digit_10 => digit_10,
	  digit_100 => digit_100,
	  digit_1000 => digit_1000
   );


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
     variable result : unsigned(11 downto 0);
     variable next_result : unsigned(11 downto 0);
     variable next_result_1000 : unsigned(13 downto 0);
   begin   
       
      -- starting values for simulation.  Not really necessary, since we initialize
      -- them above anyway

      binary <= to_unsigned(0,12);
      result := to_unsigned(0,12);
      
      wait for 1 ns;
    
      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in 0 to 4095 loop
        
        -- assign the values to the inputs of the DUT (design under test)

	      binary <= to_unsigned(i, 12);

        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 1 ns;
        
        -- calculate the result
        result := to_unsigned(0,12);
        
        next_result := result + to_unsigned(1,8)*digit_1;
        result := next_result;
        
        next_result := result + to_unsigned(10,8)*digit_10;
        result := next_result;

        next_result := result + to_unsigned(100,8)*digit_100;
        result := next_result;

        -- with the 1000 value, we need to use a larger temporary variable
        -- to hold the result. Otherwise the simulator will truncate it
        -- and we'll receive incorrect values
        next_result_1000 := to_unsigned(1000,10)*digit_1000;
        next_result := result + next_result_1000(11 downto 0);
        result := next_result;
        
        -- now print the results along with the expected results
        report "Expected: <" & integer'image(i) & ">, got: <" & integer'image(to_integer(result)) & ">.";

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (to_unsigned(i,12) = result )
            report "FAILED WITH VALUE " & integer'image(i)
            severity failure;
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;
