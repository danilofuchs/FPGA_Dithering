LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.VgaUtils.ALL;

ENTITY FPGA_Dithering IS
    PORT (
        clk : IN STD_LOGIC; -- Pin 23, 50MHz from the onboard oscilator.
        rgb : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Pins 106, 105 and 104
        hsync : OUT STD_LOGIC; -- Pin 101
        vsync : OUT STD_LOGIC; -- Pin 103
        up : IN STD_LOGIC;
        down : IN STD_LOGIC;
        left : IN STD_LOGIC;
        right : IN STD_LOGIC
    );
END ENTITY FPGA_Dithering;

ARCHITECTURE rtl OF FPGA_Dithering IS
    CONSTANT SQUARE_SIZE : INTEGER := 30; -- In pixels
    CONSTANT SQUARE_SPEED : INTEGER := 100_000;

    -- VGA Clock - 25 MHz clock derived from the 50MHz built-in clock
    SIGNAL vga_clk : STD_LOGIC;

    SIGNAL rgb_input, rgb_output : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL vga_hsync, vga_vsync : STD_LOGIC;
    SIGNAL hpos, vpos : INTEGER;

    SIGNAL square_x : INTEGER RANGE HDATA_BEGIN TO HDATA_END := HDATA_BEGIN + H_HALF - SQUARE_SIZE/2;
    SIGNAL square_y : INTEGER RANGE VDATA_BEGIN TO VDATA_END := VDATA_BEGIN + V_HALF - SQUARE_SIZE/2;
    SIGNAL square_speed_count : INTEGER RANGE 0 TO SQUARE_SPEED := 0;

    SIGNAL up_debounced : STD_LOGIC;
    SIGNAL down_debounced : STD_LOGIC;
    SIGNAL left_debounced : STD_LOGIC;
    SIGNAL right_debounced : STD_LOGIC;

    SIGNAL move_square_en : STD_LOGIC;
    SIGNAL should_move_square : BOOLEAN;

    SIGNAL should_draw_square : BOOLEAN;

    COMPONENT VgaController IS
        PORT (
            clk : IN STD_LOGIC;
            rgb_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            rgb_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            hpos : OUT INTEGER;
            vpos : OUT INTEGER
        );
    END COMPONENT;

    COMPONENT Debounce IS
        PORT (
            i_Clk : IN STD_LOGIC;
            i_Switch : IN STD_LOGIC;
            o_Switch : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    controller : VgaController PORT MAP(
        clk => vga_clk,
        rgb_in => rgb_input,
        rgb_out => rgb_output,
        hsync => vga_hsync,
        vsync => vga_vsync,
        hpos => hpos,
        vpos => vpos
    );

    debounce_up_switch : Debounce PORT MAP(
        i_Clk => vga_clk,
        i_Switch => up,
        o_Switch => up_debounced
    );

    debounce_down_switch : Debounce PORT MAP(
        i_Clk => vga_clk,
        i_Switch => down,
        o_Switch => down_debounced
    );

    debounce_left_switch : Debounce PORT MAP(
        i_Clk => vga_clk,
        i_Switch => left,
        o_Switch => left_debounced
    );

    debounce_right_switch : Debounce PORT MAP(
        i_Clk => vga_clk,
        i_Switch => right,
        o_Switch => right_debounced
    );

    rgb <= rgb_output;
    hsync <= vga_hsync;
    vsync <= vga_vsync;

    move_square_en <= up_debounced XOR down_debounced XOR left_debounced XOR right_debounced;
    should_move_square <= square_speed_count = SQUARE_SPEED;

    Square(hpos, vpos, square_x, square_y, SQUARE_SIZE, should_draw_square);

    -- We need 25MHz for the VGA so we divide the input clock by 2
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            vga_clk <= NOT vga_clk;
        END IF;
    END PROCESS;

    PROCESS (vga_clk)
    BEGIN
        IF (rising_edge(vga_clk)) THEN
            IF (should_draw_square) THEN
                rgb_input <= COLOR_GREEN;
            ELSE
                rgb_input <= COLOR_BLACK;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (vga_clk)
    BEGIN
        IF (rising_edge(vga_clk)) THEN
            IF (move_square_en = '1') THEN
                IF should_move_square THEN
                    square_speed_count <= 0;
                ELSE
                    square_speed_count <= square_speed_count + 1;
                END IF;
            ELSE
                square_speed_count <= 0;
            END IF;

            IF (should_move_square) THEN
                IF (up_debounced = '0') THEN
                    IF (square_y <= VDATA_BEGIN) THEN
                        square_y <= VDATA_BEGIN;
                    ELSE
                        square_y <= square_y - 1;
                    END IF;
                END IF;

                IF (down_debounced = '0') THEN
                    IF (square_y >= VDATA_END - SQUARE_SIZE) THEN
                        square_y <= VDATA_END - SQUARE_SIZE;
                    ELSE
                        square_y <= square_y + 1;
                    END IF;
                END IF;

                IF (left_debounced = '0') THEN
                    IF (square_x <= HDATA_BEGIN) THEN
                        square_x <= HDATA_BEGIN;
                    ELSE
                        square_x <= square_x - 1;
                    END IF;
                END IF;

                IF (right_debounced = '0') THEN
                    IF (square_x >= HDATA_END - SQUARE_SIZE) THEN
                        square_x <= HDATA_END - SQUARE_SIZE;
                    ELSE
                        square_x <= square_x + 1;
                    END IF;
                END IF;
            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE;