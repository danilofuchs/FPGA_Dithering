# FPGA Dithering

Implementation of [Ordered Dithering](https://en.wikipedia.org/wiki/Ordered_dithering)
algorithm for Cyclone IV FPGA.

| Original image                 | No dithering (rounding pixels)   | Dithering                     |
| ------------------------------ | -------------------------------- | ----------------------------- |
| ![](./docs/color_original.jpg) | ![](./docs/color_no_dither.jpeg) | ![](./docs/color_dither.jpeg) |
| ![](./docs/bw_original.jpg)    | ![](./docs/bw_no_dither.jpeg)    | ![](./docs/bw_dither.jpeg)    |

> Photos taken from my cellphone camera, pointed at a LCD screen with VGA input

- ✔️ 2x2 Bayer Dithering
- ✔️ 8-bit grayscale dithering to 1-bit BW
- ✔️ 24-bit RGB dithering to 3-bit RGB
- ✔️ 640x480@60Hz VGA output
- ✔️ Images up to 34Kb in size (uncompressed)

Built for _RZ-EasyFPGA A2.2_, a simple board built with the **Altera Cyclone IV EP4CE6E22C8N**
chip, easily found on AliExpress for cheap. The datasheet is non-existent, and the pinage is in the [docs folder](./docs/RZ-EasyFPGA.jpg).

![Board picture](./docs/board.png)

Although it suits most hobbyist needs, this board is pretty limited.

The builtin VGA port only has a single output bit per channel (R, G, B). It
is not possible to display a full 24-bit pixel to a display without a daughter board.

## Inspiration

This project was inspired by 2 awesome videos:

[![](./docs/dithering_http203.png)](https://www.youtube.com/watch?v=wS0Gck00nDw)

> [HTTP 203 - Dithering](https://www.youtube.com/watch?v=wS0Gck00nDw)

I really recommend watching this video to understand the algorithm:

[![](./docs/dithering_computerphile.png)](https://www.youtube.com/watch?v=IviNO7iICTM&ab_channel=Computerphile)

> [Computerphile - Ordered Dithering](https://www.youtube.com/watch?v=IviNO7iICTM&ab_channel=Computerphile)

## Dithering

The naïve approach to convert an 8-bit channel to 1-bit would be to simply round
the pixels to their nearest value (1 or 0). However, this limits ourselves to just
basic colors and tends to saturate colors too much, it does not look good on the eyes.
(check the initial table)

Dithering performs some clever mathematics so it looks OK to the human eye.

### Ordered Dithering (Bayer 2x2 method)

Given an 8-bit pixel, calculate the dithered color of the pixel (1-bit), using
the following 2x2 dithering matrix:

```
 ___________
| 64  | 128 |
|-----------|
| 192 |  0  |
 ‾‾‾‾‾‾‾‾‾‾‾
```

For each 2x2 block of the original image, we apply the matrix according to the
following rule: If the pixel value is greater than the matrix entry for that
matrix entry, the pixel is dithered to white; otherwise it is dithered to black.

For colored images, we simply apply this process on each channel
individually and combine them in the end.

## Initial setup

This project uses [Intel Quartus Prime **Lite**](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html) version 20.1 or later.

You will need to have an USB Blaster. To install the drivers on Windows, follow
[terasIC guide](https://www.terasic.com.tw/wiki/Altera_USB_Blaster_Driver_Installation_Instructions).

With everything set up, do the following:

1. Open the project in Quartus Prime
1. Compile
1. Program to the FPGA using the _Program device_ tool.
1. Connect the VGA connector to a screen
1. See the dithered image!

### MATLAB script to generate image input

If you want to display a custom image, you first need to prepare it so the FPGA
can understand it.

The `scripts/generate_mif_file.m` script takes an input image and resizes it
to fit inside the FPGA's maximum memory size (34Kb). It also can transform an image
to grayscale and outputs a `.mif` file to be referenced inside the VHDL code.

> The script does not work on Octave, as it lacks the `imread` function.

And the generated file will be a `.mif` with the following content:

```mif
DEPTH=9048;
WIDTH=24;
ADDRESS_RADIX = UNS;
DATA_RADIX = HEX;
CONTENT	BEGIN
	0	:	425485;
	1	:	425485;
	2	:	435686;
	3	:	445588;
	4	:	435487;
	5	:	425487;
	6	:	435588;
	7	:	445689;
	8	:	43578a;
    ...
END;
```

The command output will look like this:

```
[jardim_botanico.mif]
	Height: 78
	Width: 116
	Memory size: 9048
	Pixel depth: 24b
	Address Width: 14
	RAM usage: 217152 bits (78.54%)
```

Take this information and place it inside the [FPGA_Dithering.vhd](./FPGA_Dithering.vhd)
file, commenting or replacing other images (the FPGA only has memory capacity for
one at a time).

## VGA displays

For more reference on VGA displays on this board, check this repo:

https://github.com/fsmiamoto/EasyFPGA-VGA

For this project, we are going to use DigiKey's implementation of a VGA
controller in VHDL.

https://forum.digikey.com/t/vga-controller-vhdl/12794

The controller should follow the VGA spec, needing to display pixels in the
correct timing according to this sheet:

![VGA Timings Sheet](./docs/vga_timings.jpeg)

The provided `VgaController` is generic and can be configured with any timing specification.

As the RZ-EasyFPGA A2.2 only supports a fixed 50MHz clock, we can only output
640x480@60Hz (25Mhz Pixel Frequency) or 800x600@72Hz (50Mhz pixel freq).

![VGA 640x480 60 Timings](./docs/vga_640x480_60_timings.png)

> http://tinyvga.com/vga-timing/640x480@60Hz

For connecting with the actual board, we are going to use the following ports
from the VgaController:

![VGAController Documentation](./docs/vga_controller_ports.jpeg)

These are configured to connect to the Pins 101-106 on the board.
