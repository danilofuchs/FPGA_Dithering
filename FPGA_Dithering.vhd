library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.VgaUtils.all;

use work.Pixel.all;

entity FPGA_Dithering is
    port (
        clk : in STD_LOGIC; -- Pin 23, 50MHz from the onboard oscillator.
        rgb : out STD_LOGIC_VECTOR (2 downto 0); -- Pins 106, 105 and 104
        hsync : out STD_LOGIC; -- Pin 101
        vsync : out STD_LOGIC; -- Pin 103
        led : out STD_LOGIC_VECTOR(3 downto 0) -- Pin 87, 86, 85, 84
    );
end entity FPGA_Dithering;

architecture rtl of FPGA_Dithering is
    -- VGA Clock - 25 MHz clock derived from the 50MHz built-in clock
    signal vga_clk : STD_LOGIC;

    signal vga_hsync, vga_vsync : STD_LOGIC;
    signal display_enable : STD_LOGIC;
    signal dithered_red_pixel, dithered_green_pixel, dithered_blue_pixel : STD_LOGIC;
    signal rgb_output : STD_LOGIC_VECTOR (2 downto 0);
    signal column, row : INTEGER;

    signal pixel : pixel_type;

    signal q : STD_LOGIC_VECTOR(7 downto 0);

    component ImageLoader is
        generic (
            init_file : in STRING;
            image_width : in INTEGER;
            image_height : in INTEGER;
            memory_size : INTEGER;
            address_width : INTEGER
        );
        port (
            clk : in STD_LOGIC;
            column : in INTEGER;
            row : in INTEGER;
            pixel : out pixel_type
        );
    end component;

    component RgbImageLoader is
        generic (
            init_file : in STRING;
            image_width : in INTEGER;
            image_height : in INTEGER;
            memory_size : INTEGER;
            address_width : INTEGER
        );
        port (
            clk : in STD_LOGIC;
            column : in INTEGER;
            row : in INTEGER;
            pixel : out pixel_type
        );
    end component;

    component SevenSegmentsDecoder is
        port (
            input : in STD_LOGIC_VECTOR (3 downto 0);
            output : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    component VgaController is
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
    end component;

    component OrderedDitherer is
        port (
            pixel : in STD_LOGIC_VECTOR(7 downto 0);
            row : in INTEGER;
            column : in INTEGER;

            dithered_pixel : out STD_LOGIC
        );
    end component;
begin
    -- img_gray : ImageLoader
    -- generic map(
    --     init_file => "./images/jardim_botanico_gray.mif",
    --     image_height => 136,
    --     image_width => 202,
    --     memory_size => 27472,
    --     address_width => 15
    -- )
    -- port map(
    --     clk => clk,
    --     column => column,
    --     row => row,
    --     pixel => pixel
    -- );

    img_color : RgbImageLoader
    generic map(
        init_file => "./images/jardim_botanico.mif",
        image_height => 78,
        image_width => 116,
        memory_size => 9048,
        address_width => 14
    )
    port map(
        clk => clk,
        column => column,
        row => row,
        pixel => pixel
    );

    vga_controller : VgaController generic map(
        h_pulse => H_SYNC_PULSE,
        h_bp => H_BACK_PORCH,
        h_pixels => H_PIXELS,
        h_fp => H_FRONT_PORCH,
        h_pol => H_SYNC_POLARITY,
        v_pulse => V_SYNC_PULSE,
        v_bp => V_BACK_PORCH,
        v_pixels => V_PIXELS,
        v_fp => V_FRONT_PORCH,
        v_pol => V_SYNC_POLARITY
    )
    port map(
        pixel_clk => vga_clk,
        reset_n => '1',
        h_sync => vga_hsync,
        v_sync => vga_vsync,
        disp_ena => display_enable,
        column => column,
        row => row
    );
    red_ditherer : OrderedDitherer port map(
        pixel => pixel.red,
        row => row,
        column => column,
        dithered_pixel => dithered_red_pixel
    );
    green_ditherer : OrderedDitherer port map(
        pixel => pixel.green,
        row => row,
        column => column,
        dithered_pixel => dithered_green_pixel
    );
    blue_ditherer : OrderedDitherer port map(
        pixel => pixel.blue,
        row => row,
        column => column,
        dithered_pixel => dithered_blue_pixel
    );

    rgb_output(0) <= dithered_red_pixel;
    rgb_output(1) <= dithered_green_pixel;
    rgb_output(2) <= dithered_blue_pixel;

    rgb <=
        rgb_output when display_enable = '1' else
        "000";

    hsync <= vga_hsync;
    vsync <= vga_vsync;

    -- We need 25MHz for the VGA so we divide the input clock by 2
    process (clk)
    begin
        if (rising_edge(clk)) then
            vga_clk <= not vga_clk;
        end if;
    end process;
end architecture;