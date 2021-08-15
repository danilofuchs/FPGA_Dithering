LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY std;

USE work.Pixel.ALL;

ENTITY ImageLoader IS
    GENERIC (
        file_name : IN STRING
    );
    PORT (
        x : IN INTEGER;
        y : IN INTEGER;
        pixel : OUT pixel_type
    );
END ENTITY ImageLoader;

ARCHITECTURE rtl OF ImageLoader IS
    CONSTANT HEADER_LENGTH : INTEGER := 2;

    TYPE mem_t IS ARRAY(0 TO 126002) OF unsigned(7 DOWNTO 0);
    SIGNAL ram : mem_t;
    ATTRIBUTE ram_init_file : STRING;
    ATTRIBUTE ram_init_file OF ram : SIGNAL IS file_name;

    SIGNAL image_width, image_height : INTEGER;
    SIGNAL pixel_index : INTEGER;
BEGIN
    image_width <= to_integer(ram(0));
    image_height <= to_integer(ram(1));

    pixel_index <= HEADER_LENGTH + (y * image_height) + x;

    pixel.red <= STD_LOGIC_VECTOR(ram(pixel_index))
    WHEN (x <= image_width AND y <= image_height) ELSE
    "00000000";

    pixel.green <= STD_LOGIC_VECTOR(ram(pixel_index))
    WHEN (x <= image_width AND y <= image_height) ELSE
    "00000000";

    pixel.blue <= STD_LOGIC_VECTOR(ram(pixel_index))
    WHEN (x <= image_width AND y <= image_height) ELSE
    "00000000";
END ARCHITECTURE;