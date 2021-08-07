LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

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
ENTITY OrderedDitherer IS
    PORT (
        pixel : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        row : IN INTEGER;
        column : IN INTEGER;

        dithered_pixel : OUT STD_LOGIC
    );
END ENTITY OrderedDitherer;

ARCHITECTURE rtl OF OrderedDitherer IS

    SIGNAL pixel_value : INTEGER;

BEGIN
    pixel_value <= to_integer(unsigned(pixel));

    dithered_pixel <=
        '1' WHEN (row MOD 2 = 0) AND (column MOD 2 = 0) AND pixel_value > 0 ELSE
        '1' WHEN (row MOD 2 = 1) AND (column MOD 2 = 1) AND pixel_value > 64 ELSE
        '1' WHEN (row MOD 2 = 1) AND (column MOD 2 = 0) AND pixel_value > 128 ELSE
        '1' WHEN (row MOD 2 = 0) AND (column MOD 2 = 1) AND pixel_value > 192 ELSE
        '0';

END ARCHITECTURE;