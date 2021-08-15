LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY std;

USE work.Pixel.ALL;

ENTITY ImageLoader IS
    GENERIC (
        file_name : IN STRING;
        image_width : IN INTEGER;
        image_height : IN INTEGER
    );
    PORT (
        clk : IN STD_LOGIC;
        x : IN INTEGER;
        y : IN INTEGER;
        pixel : OUT pixel_type
    );
END ENTITY ImageLoader;

ARCHITECTURE rtl OF ImageLoader IS

    TYPE mem_t IS ARRAY(0 TO 126000) OF unsigned(7 DOWNTO 0);
    SIGNAL ram : mem_t;
    ATTRIBUTE ram_init_file : STRING;
    ATTRIBUTE ram_init_file OF ram : SIGNAL IS file_name;

    SIGNAL pixel_index : INTEGER;
BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            pixel_index <= (y * image_width) + x;

            IF (x <= image_width AND y <= image_height) THEN
                pixel.green <= STD_LOGIC_VECTOR(ram(pixel_index));
            ELSE
                pixel.green <= "00000000";
            END IF;

            IF (x <= image_width AND y <= image_height) THEN
                pixel.blue <= STD_LOGIC_VECTOR(ram(pixel_index));
            ELSE
                pixel.blue <= "00000000";
            END IF;

            IF (x <= image_width AND y <= image_height) THEN
                pixel.red <= STD_LOGIC_VECTOR(ram(pixel_index));
            ELSE
                pixel.red <= "00000000";
            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE;