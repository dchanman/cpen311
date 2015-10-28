
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blanker is
  port(CLOCK_50            : in  std_logic;
       reset               : in  std_logic;
       xout                : out std_logic_vector(7 downto 0);
       yout                : out std_logic_vector(6 downto 0);
       colour              : out std_logic_vector(2 downto 0);
       blanker_done        : out std_logic;
       plot                : out std_logic);
end blanker;

architecture impl of blanker is


--  signal x      : std_logic_vector(7 downto 0);
--  signal y      : std_logic_vector(6 downto 0);
 -- signal colour : std_logic_vector(2 downto 0);
 -- signal plot   : std_logic;
  
  signal x_counter : unsigned(7 downto 0) := (others => '0');
  signal y_counter : unsigned(6 downto 0) := (others => '0');
  
  signal x_done : std_logic := '0';
  signal y_done : std_logic := '0';
  signal x_init : std_logic := '0';
  signal y_init : std_logic := '0';
  signal load_y : std_logic; 
  
  signal cblankstate : std_logic_vector(1 downto 0) := "00";
  signal nblank_state : std_logic_vector(1 downto 0);
  
begin

  -- includes the vga adapter, which should be in your project 
  
  --FSM
  process(all) begin
    case cblankstate is
      when "00" =>
        x_init <= '1';
        y_init <= '1';
        plot <= '0';
        load_y <= '1';
        nblank_state <= "01";
        blanker_done <= '0';
      when "01" =>
        x_init <= '0';
        y_init <= '0';
        load_y <= '0';
        if(x_done = '1') then
          nblank_state <= "10";
        else
          nblank_state <= "01";
        end if;
        plot <= '1';
        blanker_done <= '0';
      when "10" =>
        x_init <= '1';
        load_y <= '1';
        y_init <= '0';
        plot <= '0';
        if(y_done = '1') then
          nblank_state <= "11";
        else
          nblank_state <= "01";
        end if;
        blanker_done <= '0';
      when "11" =>
        x_init <= '0';
        plot <= '0';
        load_y <= '0';
        y_init <= '0';
        nblank_state <= "00";
        blanker_done <= '1';
      when others => 
        x_init <= '0';
        plot <= '0';
        y_init <= '0';
        load_y <= '0';
        nblank_state <= "00";
        blanker_done <= '0';
    end case;
    
 if (reset = '0') then
      nblank_state <= "00";
    end if; 
  end process;
      
  process(CLOCK_50) begin
    if(rising_edge(CLOCK_50)) then
      cblankstate <= nblank_state;
    end if;
  end process;
        
  --DATAPATH
  process(CLOCK_50) begin
    if(rising_edge(CLOCK_50)) then
      x_counter <= x_counter + 1;
      if((x_counter > 159)) then
        x_counter <= (others => '0');
        x_done <= '1';
      end if;
      
      if(x_init = '1') then
        x_done <= '0';
        x_counter <= (others => '0');
      end if;
    end if;
  end process;
  
   process(CLOCK_50) begin
    if(rising_edge(CLOCK_50)) then
      if((y_counter > 119)) then
        y_counter <= (others => '0');
        y_done <= '1';
      elsif (load_y = '0') then
        y_counter <= y_counter;
      else
        y_counter <= y_counter + 1;
      end if;
      
      if(y_init = '1') then
        y_done <= '0';
        y_counter <= (others => '0');
      end if;
    end if;
  end process;
     

     xout <= std_logic_vector(x_counter);
     yout <= std_logic_vector(y_counter);
     colour <= "000";
     
   end impl;