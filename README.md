# ecoar project 2
usage:  draw_ean8 width height code filename

code can be of length 7 or 8
filename can be provided but it can also save to code.bmp, ex. 12345670.bmp

Task:
void draw_ean8(void *img, unsigned int stride, unsigned int height,unsigned int modwidth, char *digits);
Draw EAN-8 barcode corresponding to a string of digits and save it as a .BMP image file (bars only, equal height).  Choose the .BMP color representation according to your preferences.

Divided in 32bit, 64bit and version with floating points that I don't need for the project