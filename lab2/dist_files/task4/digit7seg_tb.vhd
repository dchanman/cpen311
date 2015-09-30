LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a testbench you can use to test the digit7seg subblock in Modelsim.
--  The testbench repeatedly applies test vectors and checks the output to
--  make sure they match the expected values.  You can use this without
--  modification (unless you want to add more test vectors, which is not a
--  bad idea).  However, please be sure you understand it before trying to
--  use it in Modelsim.
--
---------------------------------------------------------------

ENTITY digit7seg_tb IS
  -- no inputs or outputs
END digit7seg_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF digit7seg_tb IS

   -- We will use an array of records to hold a list of test vectors and expected outputs.
   -- This simplifies adding more tests; we just have to add another line in the array.
   -- Each element of the array is a record that corresponds to one test vector.
   
   -- Define the record that describes one test vector
   
   TYPE test_case_record IS RECORD
      digit : UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
      seg7 : STD_LOGIC_VECTOR(6 DOWNTO 0);  -- one per segment
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 15) OF test_case_record;
     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 8 numbers in each
   -- line correspond to the 8 entries in the record.  Seven of these entries 
   -- represent inputs to apply, and one represents the expected output.
    
   signal test_case_array : test_case_array_type := (
	(to_unsigned(0,4), "1000000"),
	(to_unsigned(1,4), "1111001"),
	(to_unsigned(2,4), "0100100"),
	(to_unsigned(3,4), "0110000"),
	(to_unsigned(4,4), "0011001"),
	(to_unsigned(5,4), "0010010"),
	(to_unsigned(6,4), "0000010"),
	(to_unsigned(7,4), "1111000"),
	(to_unsigned(8,4), "0000000"),
	(to_unsigned(9,4), "0010000"),
	(to_unsigned(10,4), "0001000"),
	(to_unsigned(11,4), "0000011"),
	(to_unsigned(12,4), "0100111"),
	(to_unsigned(13,4), "0100001"),
	(to_unsigned(14,4), "0000100"),
	(to_unsigned(15,4), "0001110"));             

  -- Define the new_balance subblock, which is the component we are testing

  COMPONENT digit7seg IS
    PORT(
      digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
      seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
    );
   END COMPONENT;

   -- local signals we will use in the testbench 
   SIGNAL digit : UNSIGNED(3 DOWNTO 0);
   SIGNAL seg7 : STD_LOGIC_VECTOR(6 DOWNTO 0);  
begin

   -- instantiate the design-under-test

   dut : digit7seg PORT MAP(
      digit => digit,
	   seg7 => seg7   
   );


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin   
       
      -- starting values for simulation.  Not really necessary, since we initialize
      -- them above anyway

      digit <= to_unsigned(0,4);
      --seg7 <= "0000000"; 
      
      wait for 1 ns;
    
      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
        
        -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " digit=" & integer'image(to_integer(test_case_array(i).digit));

        -- assign the values to the inputs of the DUT (design under test)

	      digit <= test_case_array(i).digit;

        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 1 ns;
        
        -- now print the results along with the expected results

        for j in 0 to test_case_array(i).seg7'length - 1 loop
          report "[" & integer'image(j) & "]:" & 
                 "Expected: " & std_logic'image(test_case_array(i).seg7(j)) &
                 "Got: " & std_logic'image(seg7(j));
        end loop;

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (test_case_array(i).seg7 = seg7 )
            report "FAILED WITH INTEGER " & integer'image(i)
            severity failure;
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;
