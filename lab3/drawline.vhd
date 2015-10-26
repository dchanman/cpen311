
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity line_drawer is
  port(clk                 : in  std_logic;
       reset               : in  std_logic;
       x0                  : in signed(15 downto 0);
       x1                  : in signed(15 downto 0);
       y0                  : in signed(13 downto 0);
       y1                  : in signed(13 downto 0);
       xout                : out std_logic_vector(7 downto 0);
       yout                : out std_logic_vector(6 downto 0);
       line_done           : out std_logic;
       plot                : out std_logic);
end line_drawer;

architecture impl of line_drawer is


--  signal x      : std_logic_vector(7 downto 0);
--  signal y      : std_logic_vector(6 downto 0);
 -- signal colour : std_logic_vector(2 downto 0);
 -- signal plot   : std_logic;
  
--  signal x_counter : unsigned(7 downto 0) := (others => '0');
--  signal y_counter : unsigned(6 downto 0) := (others => '0');
  
--  signal x_done : std_logic := '0';
--  signal y_done : std_logic := '0';
--  signal x_init : std_logic := '0';
--  signal y_init : std_logic := '0';
--  signal load_y : std_logic; 
  signal dy : signed(13 downto 0);
  signal dx : signed(15 downto 0);
  signal x0_internal : signed(15 downto 0);
  signal y0_internal : signed(13 downto 0);
  
  signal sx : signed(15 downto 0);
  signal sy : signed(13 downto 0);
  signal err : signed(15 downto 0);
  
  signal load_dxy_sxy : std_logic;
  signal load_err : std_logic;
  signal loop_done : std_logic;
  
  signal current_state : std_logic_vector(2 downto 0) := "000";
  signal next_state : std_logic_vector(2 downto 0);
  
begin

  -- includes the vga adapter, which should be in your project 
  
  --FSM
  process(all) begin
    case current_state is
      when "000" =>
        load_dxy_sxy <= '1';
        load_err <= '0';
        plot <= '0';
        next_state <= "001";
        line_done <= '0';
      when "001" =>
        load_err <= '1';
        load_dxy_sxy <= '1';
        plot <= '0';
        next_state <= "010";
        line_done <= '0';
      when "010" => -------working line
        --loopin
        load_dxy_sxy <= '0';
        load_err <= '0';
        plot <= '1';
        line_done <= '0';
        if(loop_done = '1') then
          next_state <= "011";
        else
          next_state <= "010";
        end if;
      when "011" =>
        load_err <= '0';
        load_dxy_sxy <= '0';
        plot <= '0';
        next_state <= "011";
        line_done <= '1';
      when others => 
        load_err <= '0';
        load_dxy_sxy <= '0';
        plot <= '0';
        next_state <= "000";
        line_done <= '0';
    end case;
    
 if (reset = '0') then
      next_state <= "000";
    end if; 
  end process;
      
  process(clk) begin
    if(rising_edge(clk)) then
      current_state <= next_state;
    end if;
  end process;
        
  --DATAPATH
  process(clk) begin
    if(rising_edge(clk)) then
     if(load_dxy_sxy <= '1') then
        if(x0 > x1) then
          dx <= x0 - x1;
        else
          dx <= x1 - x0;
        end if;
      else
        dx <= dx;
      end if;
      if(load_dxy_sxy <= '1') then
        if(y0 > y1) then
          dy <= y0 - y1;
        else
          dy <= y1 - y0;
        end if;
      else
        dy <= dy;
      end if;
    end if;
  end process;
  
  process(clk) 
  variable e2 : signed(31 downto 0);
  begin
    e2 := 2 * err;
    if(rising_edge(clk)) then
     if(load_dxy_sxy <= '1') then
        x0_internal <= x0;
      else
        if( e2 > (0 - dy)) then
          x0_internal <= x0_internal + sx;
        else
         x0_internal <= x0_internal;
       end if;
      end if;
     if(load_dxy_sxy <= '1') then
        y0_internal <= y0;
      else
        if(e2 < dx) then
          y0_internal <= y0_internal + sy;
        else
          y0_internal <= y0_internal;
        end if;
      end if;
    end if;
    
    if(rising_edge(clk)) then
      if(load_err = '1') then
        err <= dx - dy;
       else 
         if(e2 > (0 - dy)) then
            err <= err - dy;
          elsif(e2 < dx) then
            err <= err +dx;
          else
            err <= err;
          end if;
       end if;
     end if;
   end process;
    
  process(clk) begin
    if(rising_edge(clk)) then
      if (load_dxy_sxy = '1') then
        if(x0 < x1) then
          sx <= "0000000000000001";
        else
          sx <= "1111111111111110";
        end if;
        if(y0 < y1) then
          sy <= "00000000000001";
        else 
          sy <= "11111111111110";
        end if;
      else
        sx <= sx;
        sy <= sy;
      end if;
    end if;
  end process;
    

      
    process(clk)begin
      if(rising_edge(clk))then
        if((x0_internal = x1) and (y0_internal = y1)) then
          loop_done <= '1';
        else
          loop_done <= '0';
        end if;
      end if;
    end process;
    
    
    xout <= std_logic_vector(unsigned(x0_internal(7 downto 0)));
    yout <= std_logic_vector(unsigned(y0_internal(6 downto 0)));
     
   end impl;