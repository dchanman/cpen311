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

       
  process(all) begin
  blanking <= '0';
  --next_state <= "000";
  
    case current_state is
      when "000" =>
        rest_blanker <= '0';
        next_state <= "001";
        blanking <= '0';
      when "001" => 
        rest_blanker <= '1';
        blanking <= '1';
        if(blanker_done = '1') then
          next_state <= "010";
        else
          next_state <= "001";
        end if;
      when "010" => 
        rest_blanker <= '0';
        next_state <= "010";
      when "011" => 
        rest_blanker <= '0';
        next_state <= "001";
      when "100" =>   
        rest_blanker <= '0';
        next_state <= "001";
      when others =>
        rest_blanker <= '0';
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
      plot_tovga <= plot;
    end if;
  end process;
 
 LEDR(17) <= blanker_done;
 LEDR(15) <= plotb;
 LEDR(14) <= rest_blanker;
 LEDR(13 downto 11) <= current_state;
 LEDR(2) <= blanking;

end RTL;


