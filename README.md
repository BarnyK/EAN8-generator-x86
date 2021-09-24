# EAN8 Generator
## Directories explanation
32bit - Contains 32bit version of the code
32bit_FPU - 32bit version using the Floating Point Unit
64bit - Contains 64bit version of the code
64bit_SSE - 64bit version using the Streaming SIMD Extensions

## Compilation
Each directory contains Makefile which sets up linking between C and assembly code
`make` in a directory will create the `draw_ean8` file.
## Usage
`$draw_ean8 <width> <height> <code> <filename>`

width, height are paramters for the output image

code - ascii string of integers with length of 7 or 8

filename - Path to save file. Optional. Default saves to `<code>.bmp` 

## Task description:
Project made for the Computer Architecture course at university
void draw_ean8(void *img, unsigned int stride, unsigned int height,unsigned int modwidth, char *digits);
Draw EAN-8 barcode corresponding to a string of digits and save it as a .BMP image file (bars only, equal height).  Choose the .BMP color representation according to your preferences.
