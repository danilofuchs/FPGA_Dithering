LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.VgaUtils.ALL;

ENTITY FPGA_Dithering IS
    PORT (
        clk : IN STD_LOGIC; -- Pin 23, 50MHz from the onboard oscillator.
        rgb : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Pins 106, 105 and 104
        hsync : OUT STD_LOGIC; -- Pin 101
        vsync : OUT STD_LOGIC -- Pin 103
    );
END ENTITY FPGA_Dithering;

ARCHITECTURE rtl OF FPGA_Dithering IS

    CONSTANT COLOR_WHITE : STD_LOGIC_VECTOR := "111";
    CONSTANT COLOR_YELLOW : STD_LOGIC_VECTOR := "110";
    CONSTANT COLOR_PURPLE : STD_LOGIC_VECTOR := "101";
    CONSTANT COLOR_RED : STD_LOGIC_VECTOR := "100";
    CONSTANT COLOR_WATER : STD_LOGIC_VECTOR := "011";
    CONSTANT COLOR_GREEN : STD_LOGIC_VECTOR := "010";
    CONSTANT COLOR_BLUE : STD_LOGIC_VECTOR := "001";
    CONSTANT COLOR_BLACK : STD_LOGIC_VECTOR := "000";

    -- VGA Clock - 25 MHz clock derived from the 50MHz built-in clock
    SIGNAL vga_clk : STD_LOGIC;

    SIGNAL vga_hsync, vga_vsync : STD_LOGIC;
    SIGNAL display_enable : STD_LOGIC;
    SIGNAL dithered_pixel : STD_LOGIC;
    SIGNAL rgb_output : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL column, row : INTEGER;

    COMPONENT VgaController IS
        GENERIC (
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
        PORT (
            pixel_clk : IN STD_LOGIC; --pixel clock at frequency of VGA mode being used
            reset_n : IN STD_LOGIC; --active low asynchronous reset
            h_sync : OUT STD_LOGIC; --horizontal sync pulse
            v_sync : OUT STD_LOGIC; --vertical sync pulse
            disp_ena : OUT STD_LOGIC; --display enable ('1' = display time, '0' = blanking time)
            column : OUT INTEGER; --horizontal pixel coordinate
            row : OUT INTEGER; --vertical pixel coordinate
            n_blank : OUT STD_LOGIC; --direct blacking output to DAC
            n_sync : OUT STD_LOGIC); --sync-on-green output to DAC
    END COMPONENT;

    COMPONENT OrderedDitherer IS
        PORT (
            pixel : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            row : IN INTEGER;
            column : IN INTEGER;

            dithered_pixel : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    controller : VgaController GENERIC MAP(
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
    PORT MAP(
        pixel_clk => vga_clk,
        reset_n => '1',
        h_sync => vga_hsync,
        v_sync => vga_vsync,
        disp_ena => display_enable,
        column => column,
        row => row
    );

    ordered_ditherer : OrderedDitherer PORT MAP(
        pixel => "10000000",
        row => row,
        column => column,
        dithered_pixel => dithered_pixel
    );

    -- Displays White
    rgb_output <= (OTHERS => dithered_pixel);

    rgb <=
        rgb_output WHEN display_enable = '1' ELSE
        "000";

    hsync <= vga_hsync;
    vsync <= vga_vsync;

    -- We need 25MHz for the VGA so we divide the input clock by 2
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            vga_clk <= NOT vga_clk;
        END IF;
    END PROCESS;
END ARCHITECTURE;