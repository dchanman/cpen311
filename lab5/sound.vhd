LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab5_pkg.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
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

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);


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
    --variables
    begin
      if(reset = '1') then
        --reset
        state := INIT;
      elsif rising_edge(CLOCK_50) then
        --statemachine
        case state is
          when INIT =>
            --amplitude initially zero
            out_ampl := 0;
            --add C
            if(SW(6) = '1') then
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
          if(SW(5) = '1') then
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
          if(SW(4) = '1') then
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
          if(SW(3) = '1') then
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
          if(SW(2) = '1') then
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
          if(SW(1) = '1') then
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
          if(SW(0) = '1') then
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
