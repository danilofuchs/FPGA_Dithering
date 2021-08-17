LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_arith.ALL;

LIBRARY std;

USE work.Pixel.ALL;

ENTITY ImageLoader IS
    GENERIC (
        init_file : STRING;
        image_width : INTEGER;
        image_height : INTEGER;
        memory_size : INTEGER;
        address_width : INTEGER
    );
    PORT (
        clk : IN STD_LOGIC;
        x : IN INTEGER;
        y : IN INTEGER;
        pixel : OUT pixel_type
    );
END ENTITY ImageLoader;

ARCHITECTURE rtl OF ImageLoader IS
    COMPONENT ROM
        GENERIC (
            init_file : STRING;
            data_width : INTEGER;
            address_width : INTEGER;
            memory_size : INTEGER
        );
        PORT (
            address : IN STD_LOGIC_VECTOR (address_width - 1 DOWNTO 0);
            clock : IN STD_LOGIC := '1';
            q : OUT STD_LOGIC_VECTOR (data_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL pixel_index : INTEGER;
    SIGNAL pixel_address : STD_LOGIC_VECTOR(address_width - 1 DOWNTO 0);
    SIGNAL pixel_data : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL should_draw : BOOLEAN;
BEGIN
    image : ROM
    GENERIC MAP(
        init_file => init_file,
        data_width => 8,
        address_width => address_width,
        memory_size => memory_size
    )
    PORT MAP(
        clock => clk,
        address => pixel_address,
        q => pixel_data
    );

    pixel_index <= (y * image_width) + x;
    pixel_address <= conv_std_logic_vector(pixel_index, pixel_address'length);

    should_draw <= (x <= image_width AND y <= image_height AND pixel_index <= memory_size);

    pixel.red <= pixel_data WHEN (should_draw) ELSE
    "00000000";
    pixel.green <= pixel_data WHEN (should_draw) ELSE
    "00000000";
    pixel.blue <= pixel_data WHEN (should_draw) ELSE
    "00000000";

END ARCHITECTURE;