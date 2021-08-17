library ieee;
use ieee.std_logic_1164.all;

package Pixel is
    type pixel_type is record
        red : STD_LOGIC_VECTOR(7 downto 0);
        green : STD_LOGIC_VECTOR(7 downto 0);
        blue : STD_LOGIC_VECTOR(7 downto 0);
    end record;
end package;