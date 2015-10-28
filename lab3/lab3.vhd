library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDR                : out  std_logic_vector(17 downto 0);
     --  LEDG                : out std_logic
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3;

architecture rtl of lab3 is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;
  
component blanker is
  port(CLOCK_50            : in  std_logic;
       reset               : in  std_logic;
       xout                   : out std_logic_vector(7 downto 0);
       yout                  : out std_logic_vector(6 downto 0);
       colour              : out std_logic_vector(2 downto 0);
       blanker_done                : out std_logic;
       plot                : out std_logic);
end component blanker;

component line_drawer is
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
end component line_drawer;

  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal x_tovga      : std_logic_vector(7 downto 0);
  signal y_tovga      : std_logic_vector(6 downto 0);
  signal colour_tovga : std_logic_vector(2 downto 0);
  signal plot_tovga   : std_logic;
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  
  signal x_counter : unsigned(7 downto 0) := (others => '0');
  signal y_counter : unsigned(6 downto 0) := (others => '0');
  
  signal x_done : std_logic := '0';
  signal y_done : std_logic := '0';
  signal x_init : std_logic := '0';
  signal y_init : std_logic := '0';
  signal load_y : std_logic; 
  
  signal cblankstate : std_logic_vector(1 downto 0) := "00";
  signal nblank_state : std_logic_vector(1 downto 0);
  
  signal current_state : std_logic_vector(2 downto 0) := "000";
  signal next_state : std_logic_vector(2 downto 0);
  
  signal colourb : std_logic_vector(2 downto 0);
  signal rest_blanker : std_logic;
  signal blanker_done : std_logic;
  signal xb : std_logic_vector(7 downto 0);
  signal yb : std_logic_vector(6 downto 0);
  signal plotb : std_logic;
  signal blanking : std_logic;

  signal x0 : signed(15 downto 0);
  signal x1 : signed(15 downto 0);
  signal y0 : signed(13 downto 0);
  signal y1 : signed(13 downto 0);
  
  signal reset_liner : std_logic;
  signal reset_line_counter : std_logic;
  signal line_counter : unsigned(4 downto 0);
  signal count_i : std_logic;
  signal done_14 : std_logic;
  signal lineing : std_logic;
  signal line_done : std_logic;
  signal plotl : std_logic;
  signal xl : std_logic_vector(7 downto 0);
  signal yl : std_logic_vector(6 downto 0);
  
  signal second_counter : unsigned(32 downto 0);
  signal second_done : std_logic;
  signal zero_second : std_logic;
  signal bonus_started : std_logic;
begin

  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour_tovga,
             x         => x_tovga,
             y         => y_tovga,
             plot      => plot_tovga,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);

  blank : blanker port map (
       CLOCK_50        => CLOCK_50,
       reset           => rest_blanker,
       xout               => xb,
       yout               => yb,
       colour          => colourb,
       plot            => plotb,
       blanker_done    => blanker_done);

  liner : line_drawer port map (clk  => CLOCK_50,
       reset             => reset_liner,
       x0                => x0,
       x1                => x1,
       y0                => y0,
       y1                => y1,
       xout              => x,
       yout              => y,
       line_done         => line_done,
       plot              => plotl);
       
  process(all) begin
  blanking <= '0';
  plot <= '0';
  --next_state <= "000";
  
    case current_state is
      when "000" =>
        reset_liner <= '0';
        rest_blanker <= '0';
        blanking <= '0';
        plot <= '0';
        count_i <= '0';
        zero_second <= '0';
        reset_line_counter <= '1';
        bonus_started <= '0';
        
        next_state <= "001";     
      when "001" => 
        reset_liner <= '0';
        rest_blanker <= '1';
        blanking <= '1';
        plot <= '0';
        count_i <= '0';
        zero_second <= '0';
      if(bonus_started = '1') then
        reset_line_counter <= '0';
       else
         reset_line_counter <= '1';
       end if;
       bonus_started <= '1';
        if(blanker_done = '1') then
          next_state <= "010";
        else
          next_state <= "001";
        end if;
      when "010" => 
        --Done blanking the screen time for i=1
        reset_liner <= '0';
        bonus_started <= '1';
        count_i <= '1';
        rest_blanker <= '0';
        blanking <= '0';
        plot <= '0';
        reset_line_counter <= '0';
        zero_second <= '0';
        
        if(done_14 = '1') then
          next_state <= "100";
        else
          next_state <= "011";
        end if;
      when "011" => 
        --Drawing a line
        reset_liner <= '1';
        count_i <= '0';
        rest_blanker <= '0';
        bonus_started <= '1';
        blanking <= '0';
        plot <= '1';
        reset_line_counter <= '0';
        zero_second <= '1';
        
        if(line_done = '1') then
         -- next_state <= "010";
         next_state <= "101";
        else
          next_state <= "011";
        end if;
      when "100" =>   
        reset_liner <= '0';
        count_i <= '0';
        rest_blanker <= '0';
        blanking <= '0';
        bonus_started <= '1';
        plot <= '0';
        count_i <= '0';
        zero_second <= '0';
        reset_line_counter <= '0';
        
        next_state <= "000";
      when "101" =>
        reset_liner <= '0';
        count_i <= '0';
        rest_blanker <= '0';
        blanking <= '0';
        plot <= '0';
        count_i <= '0';
        bonus_started <= '1';
        zero_second <= '0';
        reset_line_counter <= '0';
        
        if(second_done = '1') then
          next_state <= "001";
        else
          next_state <= "101";
        end if;
        
      when others =>
        reset_liner <= '0';
        count_i <= '0';
        reset_line_counter <= '0';
        rest_blanker <= '0';
        zero_second <= '1';
        bonus_started <= '1';
        next_state <= "001";
    end case;
    
    if (KEY(3) = '0') then
      next_state <= "000";
    end if; 
  end process;  
  
  process(CLOCK_50) begin
    if(rising_edge(CLOCK_50)) then
      current_state <= next_state;
    end if;
  end process;
        
  process(all)begin
    if(blanking = '1') then
      x_tovga <= xb;
      y_tovga <= yb;
      colour_tovga <= colourb;
      plot_tovga <= plotb;
    else
      x_tovga <= x;
      y_tovga <= y;
      colour_tovga <= colour;
      plot_tovga <= plotl;
    end if;
  end process;
 
  process(CLOCK_50)begin
    if(rising_edge(CLOCK_50))then
      if(count_i = '1') then
        line_counter <= line_counter + 1;
      else
        line_counter <= line_counter;
      end if;
      if(reset_line_counter = '1') then
        line_counter <= "00000";
      end if;
      if(line_counter >= 13) then
        done_14 <= '1';
        --line_conuter
      else
        done_14 <= '0';
      end if;
      if(KEY(3) = '0') then
        done_14 <= '0';
      end if;
    end if;
  end process;
  
  process(CLOCK_50)begin
    if(rising_edge(CLOCK_50)) then
      second_counter <= second_counter + 1;
      
    if((second_counter) > to_unsigned(50000000, second_counter'length)) then
      second_done <= '1';
      second_counter <= (others => '0');
    else
      second_done <= '0';
    end if;
    
      if(zero_second = '1') then
        second_counter <= (others => '0');
      end if;
      
    
      
    end if;
  end process;
  
  
  process(all)begin
  --  if(rising_edge(CLOCK_50)) then
      x0 <= (others => '0');
      y0 <= to_signed((to_integer(line_counter) * 8), y0'length); --WORK HERE
   --  x1 <= (line_counter sll 8);
      x1 <= to_signed(159, x1'length);
      y1 <= to_signed(120, y1'length) - to_signed((to_integer(line_counter) * 8), y1'length);
     -- colour <= gray(to_integer(line_counter) mod 8);
 --   end if;
  end process;
  
  process(all)begin
    case (to_integer(line_counter) mod 8) is
        when 0 => colour <= "000";
        when 1 => colour <= "001";
        when 2 => colour <= "010";
        when 3 => colour <= "011";
        when 4 => colour <= "100";
        when 5 => colour <= "101";
        when 6 => colour <= "110";
        when 7 => colour <= "111";
        when others => colour <= "111";
      end case;
 --colour <= "100";
    end process;

 LEDR(17) <= line_done;
 LEDR(16) <= plot;
 LEDR(15) <= reset_liner;
 LEDR(14 downto 12) <= current_state;
-- LEDR(0) <= blanking;
 LEDR(11 downto 10) <= std_logic_vector(line_counter(1 downto 0));
 --LEDR(9 downto 5) <= std_logic_vector(line_counter);
 --LEDR(3 downto 1) <= colour;
--LEDR(9 downto 0) <= std_logic_vector(second_counter(9 downto 0));
LEDR(4) <= reset_line_counter;
LEDR(3) <= done_14;
LEDR(2) <= bonus_started;
LEDR(1) <= zero_second;
LEDR(0) <= second_done;

end RTL;


