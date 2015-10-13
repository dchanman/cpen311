library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3_draw_line is
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
  
  signal dx : unsigned(7 downto 0);
  signal dy : unsigned(7 downto 0);
  signal err : integer;
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
        
        -- State Transition
        if START = '1' then
          next_state <= STATE_READY;
        end if;
        
      end case;
    end if;
  end process;
  
  x_y_looper : process(CLOCK, x_y_looper_reset)
    variable e2 : integer;
    variable x_inc : unsigned(7 downto 0);
    variable y_inc : unsigned(7 downto 0);
    variable err_inc  : integer;
    variable dx_inc : unsigned(7 downto 0);
    variable dy_inc : unsigned(7 downto 0);
  begin
    if x_y_looper_reset = '1' then
      -- asyncronous reset
      x_out <= X0;
      y_out <= Y0;
      x_y_looper_done <= '0';
      
      -- calculate dx
      if (X0 > X1) then
        dx_inc := X0 - X1;
        sx <= SLOPE_NEGATIVE;
      else
        dx_inc := X1 - X0;
        sx <= SLOPE_POSITIVE;
      end if;
          
      -- calculate dy
      if (Y0 > Y1) then
        dy_inc := Y0 - Y1;
        sy <= SLOPE_NEGATIVE;
      else
        dy_inc := Y1 - Y0;
        sy <= SLOPE_POSITIVE;
      end if;
      
      -- calculate err
      err_inc := to_integer(dx_inc) - to_integer(dy_inc);
          report "CALCULATING | err_inc : " & integer'image(err_inc) &
          " | dx_inc : " & integer'image(to_integer(dx_inc)) & 
          " | dy_inc : " & integer'image(to_integer(dy_inc)) &
          " | X0 : " & integer'image(to_integer(X0)) & 
          " | X1 : " & integer'image(to_integer(X1)) & 
          " | Y0 : " & integer'image(to_integer(Y0)) & 
          " | Y1 : " & integer'image(to_integer(Y1)) ;
      
    elsif rising_edge(CLOCK) then
      if (x_y_looper_done = '0') then
        
        -- check if we are finished
        if (x_out = X1) and (y_out = Y1) then
          x_y_looper_done <= '1';
        else
          
          err_inc := err;
          x_inc := x_out;
          y_inc := y_out;
                
          -- e2 := 2* err
          e2 := 2*err_inc;
          report "e2 : " & integer'image(e2) &
          " | err : " & integer'image(err) &
          " | dx : " & integer'image(to_integer(dx)) & 
          " | dy : " & integer'image(to_integer(dy));
          
          -- if e2 > -dy
          if (e2 > (0 - to_integer(dy))) then
            err_inc := err - to_integer(dy);
            case sx is
            when SLOPE_POSITIVE =>
              x_inc := x_out + 1;
            when SLOPE_NEGATIVE =>
              x_inc := x_out - 1;
            end case;
          end if;
          
          -- if e2 < dx
          if (e2 < dx) then
            err_inc := err + to_integer(dx);
            case sy is
            when SLOPE_POSITIVE =>
              y_inc := y_out + 1;
            when SLOPE_NEGATIVE =>
              y_inc := y_out - 1;
            end case;
          end if;
                    
          x_out <= x_inc;
          y_out <= y_inc;
          err <= err_inc;
          
        end if;      
      end if;
    end if;
    err <= err_inc; 
    dx <= dx_inc; 
    dy <= dy_inc; 
  end process;
  
  state <= next_state;
  X <= x_out;
  Y <= y_out;
      
end behavioural;