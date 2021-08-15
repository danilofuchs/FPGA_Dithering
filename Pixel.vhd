LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE Pixel IS
    TYPE pixel_type IS RECORD
        red : STD_LOGIC_VECTOR(7 DOWNTO 0);
        green : STD_LOGIC_VECTOR(7 DOWNTO 0);
        blue : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
END PACKAGE;