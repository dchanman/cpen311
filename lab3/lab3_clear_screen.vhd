library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_clear_screen is
  port(
    CLOCK  : in  std_logic;
    RESET : in  std_logic;
    START : in  std_logic;
    COLOUR : out std_logic_vector(2 downto 0);
    X : out std_logic_vector(7 downto 0);
    Y : out std_logic_vector(6 downto 0);
    PLOT  : out std_logic;
    DONE  : out std_logic);
end lab3_clear_screen;

architecture behavioural of lab3_clear_screen is
  type STATES is (STATE_READY,STATE_CLEARING,STATE_DONE);
    
  signal state : STATES := STATE_READY;
  signal next_state : STATES := STATE_READY;
  
  signal x_y_looper_reset : std_logic;
  signal x_y_looper_done : std_logic;
  signal x_out : unsigned(7 downto 0) := "00000000";
  signal y_out : unsigned(6 downto 0) := "0000000";
begin

  state_machine : process(ALL)
  begin
    if RESET = '0' then
      -- asyncronous reset
      next_state <= STATE_READY;
      DONE <= '0';
      PLOT <= '0';
      x_y_looper_reset <= '1';
    else
      next_state <= state;
      
      case state is
      when STATE_READY =>
        -- State Outputs
        DONE <= '0';
        PLOT <= '0';
        x_y_looper_reset <= '1';
        
        -- State Transition
        if START = '0' then
          next_state <= STATE_CLEARING;
        end if;
        
      when STATE_CLEARING =>
        -- State Outputs
        DONE <= '0';
        PLOT <= '1';
        x_y_looper_reset <= '0';
        
        -- State Transition
        if (x_y_looper_done = '1') then 
          next_state <= STATE_DONE;
        end if;
        
      when STATE_DONE =>
        -- State Outputs
        DONE <= '1';
        PLOT <= '0';
        
        -- State Transition
        if START = '1' then
          next_state <= STATE_READY;
        end if;
        
      end case;
    end if;
  end process;
  
  x_y_looper : process(CLOCK, x_y_looper_reset)
    variable x_inc : unsigned(7 downto 0);
    variable y_inc : unsigned(6 downto 0);
  begin
    if x_y_looper_reset = '1' then
      -- asyncronous reset
      x_out <= "00000000";
      y_out <= "0000000";
      x_y_looper_done <= '0';
      
    elsif rising_edge(CLOCK) then
      if (x_y_looper_done = '0') then
        -- on clock, increment x
        y_inc := y_out;
        x_inc := x_out + 1;
        
        -- if X overflows the VGA, increment Y
        if (x_inc > 160) then
          x_inc := "00000000";
          y_inc := y_out + 1;
          
          -- if Y overflows the VGA, we are done
          if (y_inc > 120) then
              y_inc := "0000000";
              x_y_looper_done <= '1';
          end if;
        end if;
        
        x_out <= x_inc;
        y_out <= y_inc;
      end if;      
    end if;  
  end process;
  
  state <= next_state;
  COLOUR <= "111";
  X <= std_logic_vector(x_out);
  Y <= std_logic_vector(y_out);
    
  
end behavioural;