library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

library std;

use work.Pixel.all;

entity ImageLoader is
    generic (
        init_file : STRING;
        image_width : INTEGER;
        image_height : INTEGER;
        memory_size : INTEGER;
        address_width : INTEGER
    );
    port (
        clk : in STD_LOGIC;
        x : in INTEGER;
        y : in INTEGER;
        pixel : out pixel_type
    );
end entity ImageLoader;

architecture rtl of ImageLoader is
    component ROM
        generic (
            init_file : STRING;
            data_width : INTEGER;
            address_width : INTEGER;
            memory_size : INTEGER
        );
        port (
            address : in STD_LOGIC_VECTOR (address_width - 1 downto 0);
            clock : in STD_LOGIC := '1';
            q : out STD_LOGIC_VECTOR (data_width - 1 downto 0)
        );
    end component;

    signal pixel_index : INTEGER;
    signal pixel_address : STD_LOGIC_VECTOR(address_width - 1 downto 0);
    signal pixel_data : STD_LOGIC_VECTOR(7 downto 0);

    signal should_draw : BOOLEAN;
begin
    image : ROM
    generic map(
        init_file => init_file,
        data_width => 8,
        address_width => address_width,
        memory_size => memory_size
    )
    port map(
        clock => clk,
        address => pixel_address,
        q => pixel_data
    );

    pixel_index <= (y * image_width) + x;
    pixel_address <= conv_std_logic_vector(pixel_index, pixel_address'length);

    should_draw <= (x <= image_width and y <= image_height and pixel_index <= memory_size);

    pixel.red <= pixel_data when (should_draw) else
    "00000000";
    pixel.green <= pixel_data when (should_draw) else
    "00000000";
    pixel.blue <= pixel_data when (should_draw) else
    "00000000";

end architecture;