library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_draw_line is
  port(
    CLOCK  : in  std_logic;
    RESET : in  std_logic;
    START : in  std_logic;
    X0  : in  unsigned(7 downto 0);
    Y0  : in  unsigned(7 downto 0);
	 X1  : in  unsigned(7 downto 0);
    Y1  : in  unsigned(7 downto 0);
    X : out unsigned(7 downto 0);
    Y : out unsigned(7 downto 0);
    PLOT  : out std_logic;
    DONE  : out std_logic);
end lab3_draw_line;

architecture behavioural of lab3_draw_line is
  type STATES is (STATE_READY,STATE_DRAWING,STATE_DONE);
  type SLOPE is (SLOPE_POSITIVE,SLOPE_NEGATIVE);
    
  signal state : STATES := STATE_READY;
  signal next_state : STATES := STATE_READY;
  
  signal x_y_looper_reset : std_logic;
  signal x_y_looper_done : std_logic;
  signal x_out : unsigned(7 downto 0);
  signal y_out : unsigned(7 downto 0);
  
  signal dx : signed(7 downto 0);
  signal dy : signed(7 downto 0);
  signal err : signed(8 downto 0);
  signal sx : slope;
  signal sy : slope;
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
          next_state <= STATE_DRAWING;
        end if;
        
      when STATE_DRAWING =>
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
        x_y_looper_reset <= '0';
        
        -- State Transition
        if START = '1' then
          next_state <= STATE_READY;
        end if;
      end case;
    end if;
  end process;
 
 x_y_param_calculator : process(ALL)
 BEGIN
	  -- calculate dx
	if (X0 > X1) then
	  dx <= to_signed(to_integer(X0 - X1),8);
	  sx <= SLOPE_NEGATIVE;
	else
	  dx <= to_signed(to_integer(X1 - X0),8);
	  sx <= SLOPE_POSITIVE;
	end if;
		 
	-- calculate dy
	if (Y0 > Y1) then
	  dy <= to_signed(to_integer(Y0 - Y1),8);
	  sy <= SLOPE_NEGATIVE;
	else
	  dy <= to_signed(to_integer(Y1 - Y0),8);
	  sy <= SLOPE_POSITIVE;
	end if;
END PROCESS;
  
x_y_looper : process(ALL)
	variable err : signed(8 downto 0);
	variable x_inc : unsigned(7 downto 0);
	variable y_inc : unsigned(7 downto 0);  
   variable e2 : signed(9 downto 0);
  begin
	 e2 := err & "0";
	 
    if x_y_looper_reset = '1' then
      -- asyncronous reset
      x_out <= X0;
      y_out <= Y0;
      x_y_looper_done <= '0';
      
      -- calculate err
      err := "0" & (dx - dy);
    elsif rising_edge(CLOCK) then
      if (x_y_looper_done = '0') then
        
        -- check if we are finished
        if (x_out = X1) and (y_out = Y1) then
          x_y_looper_done <= '1';
        else    
          -- if e2 > -dy
          if (e2 > (to_signed(0,10) - "00" & dy)) then
            err := err - to_integer(dy);
            case sx is
            when SLOPE_POSITIVE =>
              x_out <= x_out + 1;
            when SLOPE_NEGATIVE =>
              x_out <= x_out - 1;
            end case;
          end if;
          
          -- if e2 < dx
          if (e2 < dx) then
            err := err + dx;
            case sy is
            when SLOPE_POSITIVE =>
              y_out <= y_out + 1;
            when SLOPE_NEGATIVE =>
              y_out <= y_out - 1;
            end case;
          end if;     
        end if;      
      end if;
    end if;
  end process;
  
  state <= next_state;
  X <= x_out;
  Y <= y_out;
      
end behavioural;