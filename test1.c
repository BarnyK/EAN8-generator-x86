#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    __uint32_t file_size;
    __uint16_t reserved1;
    __uint16_t reserved2;
    __uint32_t  start;
    __uint32_t header_size;
    __int32_t width;
    __int32_t height;
    __uint16_t planes;
    __uint16_t bits_per_pixel;
    __uint32_t compression;;
    __uint32_t image_size;
    __int32_t vertical_resolution;
    __int32_t horizontal_resolution;
    __uint32_t colors;
    __uint32_t imporant_colors;
}bmpHeaderData;

void writeHeader(FILE *fptr, __uint32_t file_size, __int32_t height, __int32_t width){
    bmpHeaderData head;
    __uint16_t type = 0x4d42;
    head.file_size = file_size;
    head.reserved1 = 0;
    head.reserved2 = 0;
    head.start = 0x0436;
    head.header_size = 40;
    head.width = width;
    head.height = height;
    head.planes = 1;
    head.bits_per_pixel = 8;
    head.compression = 0;
    head.image_size = 0;
    head.vertical_resolution = 2835;     // 72 DPI
    head.horizontal_resolution = 2835;   
    head.colors = 0;
    head.imporant_colors = 0;
    fwrite(&type, sizeof(__uint16_t), 1, fptr);
    fwrite(&head, sizeof(head), 1, fptr);
}

int main(int argc, char* argv[]){
    printf("Hi\n");

    // FILE* fptr;
    // fptr = fopen("asdf.bmp","wb");
    // if(!fptr){
    //     printf("ERROR\n");
    //     return 1;
    // }
    // writeHeader(fptr, 88*510+62, 510, 680);
    // for(__uint32_t c = 0; c <= 0x00FFFFFF; c+= 0x00010101){
    //     printf("%d\n", c);
    //     fwrite(&c, sizeof(__uint32_t), 1, fptr);
    // }
    // fclose(fptr);

    int width = atoi(argv[1]);
    int stride = (((8 * width) + 31)/32) * 4;
    printf("%d",stride);
    return 0;
}