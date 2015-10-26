library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_clear_screen is
  port(
    CLOCK  : in  std_logic;
    RESET : in  std_logic;
    START : in  std_logic;
    X : out std_logic_vector(7 downto 0);
    Y : out std_logic_vector(6 downto 0);
    PLOT  : out std_logic;
    DONE  : out std_logic);
end lab3_clear_screen;

architecture behavioural of lab3_clear_screen is
  type STATES is (STATE_READY,STATE_CLEARING,STATE_DONE);
  begin

  state_machine : process(ALL)
  variable state : STATES := STATE_READY;
  variable x_out : unsigned(7 downto 0) := "00000000";
  variable y_out : unsigned(7 downto 0) := "00000000";
  begin
    if RESET = '0' then
      -- asyncronous reset
      state := STATE_READY;
      DONE <= '0';
      PLOT <= '0';
    else      
      case state is
      when STATE_READY =>
        -- State Outputs
        DONE <= '0';
        PLOT <= '0';
		  
		  -- State Action
		  -- Nothing. Wait for Start
        
        -- State Transition
        if START = '0' then
          state := STATE_CLEARING;
          PLOT <= '1';
        else
          state := STATE_READY;
        end if;
        
      when STATE_CLEARING =>
        -- State Outputs
        DONE <= '0';
        PLOT <= '1';
		  
		  -- State Action
		  if (rising_edge(CLOCK)) then
			x_out := x_out + 1;
			if (x_out > 160) then
				x_out := "00000000";
				y_out := y_out + 1;
			end if;
		  end if;
			
			-- State Transition
			if (y_out > 120) then
          state := STATE_DONE;
          y_out := "00000000";
          DONE <= '1';
          PLOT <= '0';
      else
          state := STATE_CLEARING;
      end if;
        
      when STATE_DONE =>
        -- State Outputs
        DONE <= '1';
        PLOT <= '0';
		  
		  -- State Action
		  -- Nothing. Wait for Start
        
        -- State Transition
        if START = '1' then
          state := STATE_READY;
          DONE <= '0';
        else
          state := STATE_DONE;
        end if;
        
      end case;
    end if;
  X <= std_logic_vector(x_out);
  Y <= std_logic_vector(y_out(6 downto 0));
  end process;
  
end behavioural;