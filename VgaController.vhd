--------------------------------------------------------------------------------
--
--   FileName:         vga_controller.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--   Version 1.1 03/07/2018 Scott Larson
--     Corrected two minor "off-by-one" errors
--    
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity VgaController is
  generic (
    h_pulse : INTEGER := 208; --horizontal sync pulse width in pixels
    h_bp : INTEGER := 336; --horizontal back porch width in pixels
    h_pixels : INTEGER := 1920; --horizontal display width in pixels
    h_fp : INTEGER := 128; --horizontal front porch width in pixels
    h_pol : STD_LOGIC := '0'; --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse : INTEGER := 3; --vertical sync pulse width in rows
    v_bp : INTEGER := 38; --vertical back porch width in rows
    v_pixels : INTEGER := 1200; --vertical display width in rows
    v_fp : INTEGER := 1; --vertical front porch width in rows
    v_pol : STD_LOGIC := '1'); --vertical sync pulse polarity (1 = positive, 0 = negative)
  port (
    pixel_clk : in STD_LOGIC; --pixel clock at frequency of VGA mode being used
    reset_n : in STD_LOGIC; --active low asynchronous reset
    h_sync : out STD_LOGIC; --horizontal sync pulse
    v_sync : out STD_LOGIC; --vertical sync pulse
    disp_ena : out STD_LOGIC; --display enable ('1' = display time, '0' = blanking time)
    column : out INTEGER; --horizontal pixel coordinate
    row : out INTEGER; --vertical pixel coordinate
    n_blank : out STD_LOGIC; --direct blacking output to DAC
    n_sync : out STD_LOGIC); --sync-on-green output to DAC
end VgaController;

architecture behavior of VgaController is
  constant h_period : INTEGER := h_pulse + h_bp + h_pixels + h_fp; --total number of pixel clocks in a row
  constant v_period : INTEGER := v_pulse + v_bp + v_pixels + v_fp; --total number of rows in column
begin

  n_blank <= '1'; --no direct blanking
  n_sync <= '0'; --no sync on green

  process (pixel_clk, reset_n)
    variable h_count : INTEGER range 0 to h_period - 1 := 0; --horizontal counter (counts the columns)
    variable v_count : INTEGER range 0 to v_period - 1 := 0; --vertical counter (counts the rows)
  begin

    if (reset_n = '0') then --reset asserted
      h_count := 0; --reset horizontal counter
      v_count := 0; --reset vertical counter
      h_sync <= not h_pol; --deassert horizontal sync
      v_sync <= not v_pol; --deassert vertical sync
      disp_ena <= '0'; --disable display
      column <= 0; --reset column pixel coordinate
      row <= 0; --reset row pixel coordinate

    elsif (pixel_clk'EVENT and pixel_clk = '1') then

      --counters
      if (h_count < h_period - 1) then --horizontal counter (pixels)
        h_count := h_count + 1;
      else
        h_count := 0;
        if (v_count < v_period - 1) then --vertical counter (rows)
          v_count := v_count + 1;
        else
          v_count := 0;
        end if;
      end if;

      --horizontal sync signal
      if (h_count < h_pixels + h_fp or h_count >= h_pixels + h_fp + h_pulse) then
        h_sync <= not h_pol; --deassert horizontal sync pulse
      else
        h_sync <= h_pol; --assert horizontal sync pulse
      end if;

      --vertical sync signal
      if (v_count < v_pixels + v_fp or v_count >= v_pixels + v_fp + v_pulse) then
        v_sync <= not v_pol; --deassert vertical sync pulse
      else
        v_sync <= v_pol; --assert vertical sync pulse
      end if;

      --set pixel coordinates
      if (h_count < h_pixels) then --horizontal display time
        column <= h_count; --set horizontal pixel coordinate
      end if;
      if (v_count < v_pixels) then --vertical display time
        row <= v_count; --set vertical pixel coordinate
      end if;

      --set display enable output
      if (h_count < h_pixels and v_count < v_pixels) then --display time
        disp_ena <= '1'; --enable display
      else --blanking time
        disp_ena <= '0'; --disable display
      end if;

    end if;
  end process;

end behavior;