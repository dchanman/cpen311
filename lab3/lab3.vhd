library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
	port(CLOCK_50						: in	std_logic;
			 KEY								 : in	std_logic_vector(3 downto 0);
			 SW									: in	std_logic_vector(17 downto 0);
			 LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
			 VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);	-- The outs go to VGA controller
			 VGA_HS							: out std_logic;
			 VGA_VS							: out std_logic;
			 VGA_BLANK					 : out std_logic;
			 VGA_SYNC						: out std_logic;
			 VGA_CLK						 : out std_logic);
end lab3;

architecture rtl of lab3 is

 --Component from the Verilog file: vga_adapter.v

	component vga_adapter
		generic(RESOLUTION : string);
		port (resetn																			 : in	std_logic;
					clock																				: in	std_logic;
					colour																			 : in	std_logic_vector(2 downto 0);
					x																						: in	std_logic_vector(7 downto 0);
					y																						: in	std_logic_vector(6 downto 0);
					plot																				 : in	std_logic;
					VGA_R, VGA_G, VGA_B													: out std_logic_vector(9 downto 0);
					VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	end component;
	
	component lab3_clear_screen is
	port(
		CLOCK	: in	std_logic;
		RESET : in	std_logic;
		START : in	std_logic;
		COLOUR : out std_logic_vector(2 downto 0);
		X : out std_logic_vector(7 downto 0);
		Y : out std_logic_vector(6 downto 0);
		PLOT	: out std_logic;
		DONE	: out std_logic);
	end component;
	
	type STATES is (STATE_0_INITIALIZE, STATE_1_CLEAR_SCREEN, STATE_COMPLETE);

	signal x			: std_logic_vector(7 downto 0);
	signal y			: std_logic_vector(6 downto 0);
	signal plot	 : std_logic;
	
	signal clear_x			: std_logic_vector(7 downto 0);
	signal clear_y			: std_logic_vector(6 downto 0);
	signal clear_plot	 : std_logic;
	signal clear_start	 : std_logic;
	signal clear_done	 : std_logic;

begin

	-- includes the vga adapter, which should be in your project 

	vga_u0 : vga_adapter
		generic map(RESOLUTION => "160x120") 
		port map(resetn		=> KEY(3),
						 clock		 => CLOCK_50,
						 colour		=> SW(17 downto 15),
						 x				 => x,
						 y				 => y,
						 plot			=> plot,
						 VGA_R		 => VGA_R,
						 VGA_G		 => VGA_G,
						 VGA_B		 => VGA_B,
						 VGA_HS		=> VGA_HS,
						 VGA_VS		=> VGA_VS,
						 VGA_BLANK => VGA_BLANK,
						 VGA_SYNC	=> VGA_SYNC,
						 VGA_CLK	 => VGA_CLK);
						 
	lab3_clear_screen_u1 : lab3_clear_screen
		port map(
			CLOCK	=> CLOCK_50,
			RESET => KEY(0),
			START => clear_start,
			COLOUR => open,
			X => clear_x,
			Y => clear_y,
			PLOT => clear_plot,
			DONE => clear_done);

	state_machine : process(KEY(0), CLOCK_50)
	variable current_state : STATES := STATE_0_INITIALIZE;
	BEGIN
		if (KEY(0) = '0') then
			LEDG <= "0000";
			x <= "00000000";
			y <= "0000000";
			plot <= '0';
			clear_start <= '0';
			
			current_state := STATE_0_INITIALIZE;
		else
			if rising_edge(CLOCK_50) then
			case current_state is
			when STATE_0_INITIALIZE =>
				LEDG <= "0000";
				x <= "00000000";
				y <= "0000000";
				plot <= '0';
				clear_start <= '0';
				
				current_state := STATE_1_CLEAR_SCREEN;
			
			when STATE_1_CLEAR_SCREEN =>
				-- State Outputs
				LEDG <= "0001";
				x <= clear_x;
				y <= clear_y;
				plot <= clear_plot;
				clear_start <= '0';
				
				-- Next State
				if (clear_done = '1') then
					current_state := STATE_COMPLETE;
				else
					current_state := STATE_1_CLEAR_SCREEN;
				end if;
				
			when STATE_COMPLETE =>
				LEDG <= "1111";
				x <= "00000000";
				y <= "0000000";
				plot <= '0';
				clear_start <= '1';
				
				current_state := STATE_COMPLETE;
			end case;
		end if;
		end if;
	END PROCESS;
end RTL;


