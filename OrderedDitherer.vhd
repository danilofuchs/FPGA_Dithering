library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Given an 8-bit pixel located in row and column position,
-- return the dithered color of the pixel (1-bit).
--
-- Uses the following 2x2 dithering matrix:
--
--   64  128
--   192 0
--
-- The dithering is done by comparing the pixel value with the
-- dithering matrix entry. If the pixel value is greater than the
-- matrix entry, the pixel is dithered to white; otherwise it is
-- dithered to black.
--
entity OrderedDitherer is
    port (
        pixel : in STD_LOGIC_VECTOR(7 downto 0);
        row : in INTEGER;
        column : in INTEGER;

        dithered_pixel : out STD_LOGIC
    );
end entity OrderedDitherer;

architecture rtl of OrderedDitherer is

    signal pixel_value : INTEGER;

begin
    pixel_value <= to_integer(unsigned(pixel));

    dithered_pixel <=
        '1' when (row mod 2 = 0) and (column mod 2 = 0) and pixel_value > 0 else
        '1' when (row mod 2 = 1) and (column mod 2 = 1) and pixel_value > 64 else
        '1' when (row mod 2 = 1) and (column mod 2 = 0) and pixel_value > 128 else
        '1' when (row mod 2 = 0) and (column mod 2 = 1) and pixel_value > 192 else
        '0';

end architecture;