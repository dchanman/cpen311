library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDR                : out  std_logic_vector(17 downto 0);
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

  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  
  signal x_counter : unsigned(7 downto 0) := (others => '0');
  signal y_counter : unsigned(6 downto 0) := (others => '0');
  
  signal x_done : std_logic := '0';
  signal y_done : std_logic := '0';
  signal x_init : std_logic := '0';
  signal y_init : std_logic := '0';
  signal load_y : std_logic; 
  
  signal current_state : std_logic_vector(1 downto 0) := "00";
  signal next_state : std_logic_vector(1 downto 0);
  signal colour_signal : std_logic_vector(7 downto 0);

begin

  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);


  -- rest of your code goes here, as well as possibly additional files
  --FSM
  process(all) begin
    case current_state is
      when "00" =>
        x_init <= '1';
        y_init <= '1';
        plot <= '0';
        load_y <= '1';
        next_state <= "01";
      when "01" =>
        x_init <= '0';
        y_init <= '0';
        load_y <= '0';
        if(x_done = '1') then
          next_state <= "10";
        else
          next_state <= "01";
        end if;
        plot <= '1';
      when "10" =>
        x_init <= '1';
        load_y <= '1';
        y_init <= '0';
        plot <= '0';
        if(y_done = '1') then
          next_state <= "11";
        else
          next_state <= "01";
        end if;
      when "11" =>
        x_init <= '0';
        plot <= '0';
        load_y <= '0';
        y_init <= '0';
        next_state <= "11";
      when others => 
        x_init <= '0';
        plot <= '0';
        y_init <= '0';
        load_y <= '0';
        next_state <= "11";
    end case;
    
    if (KEY(3) = '0') then
      next_state <= "00";
    end if; 
  end process;
      
  process(CLOCK_50) begin
    if(rising_edge(CLOCK_50)) then
      current_state <= next_state;
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
     
     LEDR(17 downto 11) <= x(6 downto 0);
     LEDR(6 downto 0) <= y;
     LEDR(10) <= x_done;
     LEDR(9) <= y_done;
     LEDR(8 downto 7) <= current_state;
    -- LEDR(7) <= plot;
     
     x <= std_logic_vector(x_counter);
     y <= std_logic_vector(y_counter);
     colour_signal <= std_logic_vector((x_counter mod 8)); -- will i need to worry about the bits on this?
     colour <= colour_signal(2 downto 0);
     
  --process(all) begin
    
       
  --process (all) begin
    --for Xl in 159 downto 0 loop
      --for Yl in 119 downto 0 loop 
        --x <= 

end RTL;


