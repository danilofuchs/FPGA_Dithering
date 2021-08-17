library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package VgaUtils is
  constant COLOR_WHITE : STD_LOGIC_VECTOR := "111";
  constant COLOR_YELLOW : STD_LOGIC_VECTOR := "110";
  constant COLOR_PURPLE : STD_LOGIC_VECTOR := "101";
  constant COLOR_RED : STD_LOGIC_VECTOR := "100";
  constant COLOR_WATER : STD_LOGIC_VECTOR := "011";
  constant COLOR_GREEN : STD_LOGIC_VECTOR := "010";
  constant COLOR_BLUE : STD_LOGIC_VECTOR := "001";
  constant COLOR_BLACK : STD_LOGIC_VECTOR := "000";

  -- Timing values for 640x480@60Hz resolution
  -- http://tinyvga.com/vga-timing/640x480@60Hz
  constant H_SYNC_PULSE : INTEGER := 96;
  constant H_BACK_PORCH : INTEGER := 48;
  constant H_PIXELS : INTEGER := 640;
  constant H_FRONT_PORCH : INTEGER := 16;
  constant H_SYNC_POLARITY : STD_LOGIC := '0';

  constant V_SYNC_PULSE : INTEGER := 2;
  constant V_BACK_PORCH : INTEGER := 33;
  constant V_PIXELS : INTEGER := 480;
  constant V_FRONT_PORCH : INTEGER := 10;
  constant V_SYNC_POLARITY : STD_LOGIC := '0';

  -- Timing values for 800x600@72Hz resolution
  -- http://tinyvga.com/vga-timing/800x600@72Hz
  -- If using these timings, use the 50MHz clock directly instead of dividing by 2
  -- CONSTANT H_SYNC_PULSE : INTEGER := 120;
  -- CONSTANT H_BACK_PORCH : INTEGER := 64;
  -- CONSTANT H_PIXELS : INTEGER := 800;
  -- CONSTANT H_FRONT_PORCH : INTEGER := 56;
  -- CONSTANT H_SYNC_POLARITY : STD_LOGIC := '1';

  -- CONSTANT V_SYNC_PULSE : INTEGER := 6;
  -- CONSTANT V_BACK_PORCH : INTEGER := 23;
  -- CONSTANT V_PIXELS : INTEGER := 600;
  -- CONSTANT V_FRONT_PORCH : INTEGER := 37;
  -- CONSTANT V_SYNC_POLARITY : STD_LOGIC := '1';
end package;

package body VgaUtils is
end VgaUtils;