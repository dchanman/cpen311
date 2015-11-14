LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab5_pkg.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
			LEDR                           : OUT std_logic_vector(17 downto 0);
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC);
END sound;

ARCHITECTURE Behavior OF sound IS

	   -- CODEC Cores
	
	COMPONENT clock_generator
		PORT(	CLOCK_27														:IN STD_LOGIC;
		    	reset															:IN STD_LOGIC;
				AUD_XCK														:OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT(	CLOCK_50,reset												:IN STD_LOGIC;
		    	I2C_SDAT														:INOUT STD_LOGIC;
				I2C_SCLK														:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT audio_codec
		PORT(	CLOCK_50,reset,read_s,write_s							:IN STD_LOGIC;
				writedata_left, writedata_right						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK		:IN STD_LOGIC;
				read_ready, write_ready									:OUT STD_LOGIC;
				readdata_left, readdata_right							:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_DACDAT													:OUT STD_LOGIC);
	END COMPONENT;
	
COMPONENT rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;
	signal address_sig : std_logic_vector(4 downto 0) := "00000";
	signal q_sig : std_logic_vector(7 DOWNTO 0);
	signal clock_sig : std_logic;

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);

  clock_sig <= CLOCK_50;

  rom_inst : rom PORT MAP (
		address	 => address_sig,
		clock	 => clock_sig,
		q	 => q_sig
	);

  --prints which adress of the file we are reading to the leds for fun
  LEDR(4 downto 0) <= address_sig; 
  
       --- rest of your code goes here
  process(CLOCK_50, reset)
    variable state : state_type := INIT;
    variable freq_C : natural := 0;
    variable freq_D : natural := 0;
    variable freq_E : natural := 0;
    variable freq_F : natural := 0;
    variable freq_G : natural := 0;
    variable freq_A : natural := 0;
    variable freq_B : natural := 0;
    variable out_ampl : integer := 0;
    
    variable add_C : std_logic := '0';
    variable add_D : std_logic := '0';
    variable add_E : std_logic := '0';    
    variable add_F : std_logic := '0';    
    variable add_G : std_logic := '0';
    variable add_A : std_logic := '0';
    variable add_B : std_logic := '0';
    
    variable note_counter : natural := 0;
    variable timer : natural := 0;
    
    --variables
    begin
      if(reset = '1') then
        --reset
        state := INIT;
      elsif rising_edge(CLOCK_50) then
        
        --timer for half second notes
        timer := timer + 1;
        
        --statemachine
        case state is
          when INIT =>
            --if its been half a second update the notes we want added based on the contents
            -- read from memory and update the address to read the next note
            if(timer >= 25000000) then
              add_C := '0';
              add_D := '0';  
              add_E := '0';
              add_F := '0';             
              add_G := '0';
              add_A := '0';  
              add_B := '0';
            case to_integer(signed(q_sig)) is
              when 1 => add_C := '1';
              when 2 => add_D := '1';  
              when 3 => add_E := '1';
              when 4 => add_F := '1';
              when 5 => add_G := '1';
              when 6 => add_A := '1';  
              when 7 => add_B := '1';
              when others => add_C := '1';
            end case;
            timer := 0;
             address_sig <= std_logic_vector(unsigned(address_sig) + "00001");
            if(address_sig = "11111") then
             address_sig <= "00000";
           end if;
          end if;
            --amplitude initially zero
            out_ampl := 0;
            --add C
            if(SW(6) = '1' or add_C = '1') then
             if freq_C <= C then
              out_ampl := out_ampl + POS_AMPL;
              freq_C := freq_C + 1;
            elsif freq_C <= 2*C then
              out_ampl := out_ampl + NEG_AMPL;
              freq_C := freq_C + 1;
            else
              freq_C := 0;
            end if;
          end if;   
          --add D        
          if(SW(5) = '1' or add_D = '1') then
             if freq_D <= D then
              out_ampl := out_ampl + POS_AMPL;
              freq_D := freq_D + 1;
            elsif freq_D <= 2*D then
              out_ampl := out_ampl + NEG_AMPL;
              freq_D := freq_D + 1;
            else
              freq_D := 0;
            end if;
          end if;
          --add E         
          if(SW(4) = '1' or add_E = '1') then
             if freq_E <= E then
              out_ampl := out_ampl + POS_AMPL;
              freq_E := freq_E + 1;
            elsif freq_E <= 2*E then
              out_ampl := out_ampl + NEG_AMPL;
              freq_E := freq_E + 1;
            else
              freq_E := 0;
            end if;
          end if;
          --add F      
          if(SW(3) = '1' or add_F = '1') then
             if freq_F <= F then
              out_ampl := out_ampl + POS_AMPL;
              freq_F := freq_F + 1;
            elsif freq_F <= 2*F then
              out_ampl := out_ampl + NEG_AMPL;
              freq_F := freq_F + 1;
            else
              freq_F := 0;
            end if;
          end if;
          --add G      
          if(SW(2) = '1' or add_G = '1') then
             if freq_G <= G then
              out_ampl := out_ampl + POS_AMPL;
              freq_G := freq_G + 1;
            elsif freq_G <= 2*G then
              out_ampl := out_ampl + NEG_AMPL;
              freq_G := freq_G + 1;
            else
              freq_G := 0;
            end if;
          end if;
          --add A      
          if((SW(1) = '1') or (add_A = '1')) then
             if freq_A <= A then
              out_ampl := out_ampl + POS_AMPL;
              freq_A := freq_A + 1;
            elsif freq_A <= 2*A then
              out_ampl := out_ampl + NEG_AMPL;
              freq_A := freq_A + 1;
            else
              freq_A := 0;
            end if;
          end if;
          --add B    
          if(SW(0) = '1' or add_B = '1') then
             if freq_B <= B then
              out_ampl := out_ampl + POS_AMPL;
              freq_B := freq_B + 1;
            elsif freq_B <= 2*B then
              out_ampl := out_ampl + NEG_AMPL;
              freq_B := freq_B + 1;
            else
              freq_B := 0;
            end if;
          end if;
             write_s <= '0';
             writedata_left <= std_logic_vector(to_signed(out_ampl, writedata_left'length));
             writedata_right <= std_logic_vector(to_signed(out_ampl, writedata_right'length));
            state := WAITSTATE;
          when WAITSTATE =>
            if(write_ready = '1') then
              state := WRITE;
            end if;
          when WRITE =>
            write_s <= '1';
            if(write_ready = '0') then
              state := INIT;
            end if;
        end case;
      end if;
    end process;


END Behavior;
