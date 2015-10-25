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
	
	type STATES is (STATE_1_CLEAR_SCREEN, STATE_COMPLETE);
	signal state : STATES := STATE_1_CLEAR_SCREEN;
	signal next_state : STATES := STATE_1_CLEAR_SCREEN;
	
	type WAIT_1_SECOND_STATE is (WAIT_1_SECOND_STATE_READY, WAIT_1_SECOND_STATE_RUNNING, WAIT_1_SECOND_STATE_DONE);
	signal wait_1_second_state : WAIT_1_SECOND_STATE := WAIT_1_SECOND_STATE_READY;
	signal wait_1_second_next_state : WAIT_1_SECOND_STATE := WAIT_1_SECOND_STATE_READY;

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
			
	wait_1_second : process(ALL)
	BEGIN
	END PROCESS;
	

	state_machine : process(ALL)
	BEGIN
		-- default values
		next_state <= state;
		LEDG <= "0000";
		
		if (KEY(0) = '0') then
			next_state <= STATE_1_CLEAR_SCREEN;
		else
			case next_state is
			when STATE_1_CLEAR_SCREEN =>
				LEDG <= "0001";
				x <= clear_x;
				y <= clear_y;
				plot <= clear_plot;
				clear_start <= '0';
				
				if (clear_done = '1') then
					next_state <= STATE_COMPLETE;
				end if;
			when others =>
				LEDG <= "1111";
				x <= "00000000";
				y <= "0000000";
				plot <= '0';
				clear_start <= '1';
			end case;
		end if;
	END PROCESS;
	
	state <= next_state;
end RTL;


