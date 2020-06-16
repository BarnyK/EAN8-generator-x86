#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//void draw_ean8(void *img, unsigned int stride, unsigned int height,unsigned int modwidth, char *digits);
extern void draw_ean8(char *img, unsigned int stride, unsigned int height, unsigned int width, char *digits, char *buffer);

// Writes header data and 2 color pallette
void writeHeader(FILE *fptr, unsigned int file_size, unsigned int height, unsigned int width){
    unsigned short type = 0x4d42;
    unsigned short reserved1 = 0;
    unsigned short reserved2 = 0;
    unsigned int start = 0x3e;
    unsigned int header_size = 40;
    unsigned short planes = 1;
    unsigned short bits_per_pixel = 8;
    unsigned int compression = 0;
    unsigned int image_size = 0;
    int vertical_resolution = 2835;     // 72 DPI
    int horizontal_resolution = 2835;   
    unsigned int colors = 2;
    unsigned int imporant_colors = 0;
    unsigned int color1 = 0x00FFFFFF;
    unsigned int color2 = 0x00000000;
    fwrite(&type, sizeof(__uint16_t), 1, fptr);
    fwrite(&file_size, sizeof(__uint32_t), 1, fptr);
    fwrite(&reserved1, sizeof(__uint16_t), 1, fptr);
    fwrite(&reserved2, sizeof(__uint16_t), 1, fptr);
    fwrite(&start, sizeof(__uint32_t), 1, fptr);
    fwrite(&header_size, sizeof(__uint32_t), 1, fptr);
    fwrite(&width, sizeof(__int32_t), 1, fptr);
    fwrite(&height, sizeof(__int32_t), 1, fptr);
    fwrite(&planes, sizeof(__uint16_t), 1, fptr);
    fwrite(&bits_per_pixel, sizeof(__uint16_t), 1, fptr);
    fwrite(&compression, sizeof(__uint32_t), 1, fptr);
    fwrite(&image_size, sizeof(__uint32_t), 1, fptr);
    fwrite(&vertical_resolution, sizeof(__int32_t), 1, fptr);
    fwrite(&horizontal_resolution, sizeof(__int32_t), 1, fptr);
    fwrite(&colors, sizeof(__uint32_t), 1, fptr);
    fwrite(&imporant_colors, sizeof(__uint32_t), 1, fptr);
    fwrite(&color1, sizeof(__uint32_t), 1, fptr);
    fwrite(&color2, sizeof(__uint32_t), 1, fptr);
}

// Image data stored in unsigner char

int main(int argc, char *argv[]){
    unsigned int width, height, checksum=0, codecheck = 1, digits_len, stride, file_size;
    char digits[9] = {0}, filename[256] = {0}, tmp;
    char *pictureData, *buffer;
    
    if(argc < 4){
        printf("Not enough arguments\n");
        return 1;
    }

    // Read and validate width
    width = atoi(argv[1]);
    if(width < 67){
        printf("Invalid width");
        return 2;
    }

    // Read and validate height
    height = atoi(argv[2]);
    if(height <= 0){
        printf("Invalid height");
        return 3;
    }
    
    // Read, validate and check ean8 code
    strncpy(digits, argv[3],9);
    digits_len = strlen(digits);
    if(digits_len == 8 || digits_len == 7){
        for(int i = 0; i < digits_len; i++){
            if((digits[i] >= '0') && (digits[i] <= '9')){
                checksum += (digits[i] - '0') * ((i%2) + (((i+1) % 2) * 3));
            }
            else{
                codecheck = 0;
            }
        }
        if(codecheck && digits_len == 7){
            digits[7] = '0' + (10 - (checksum % 10))%10;
        }
        else if(checksum % 10 != 0){
            codecheck = 0;
        }
    }
    else{
        codecheck = 0;
    }
    if(codecheck == 0){
        printf("Invalid code");
        return 4;
    }

    // Name argument
    if(argc == 5){
        strncpy(filename, argv[4],32);  // Don't need to validate, let user save it to any filename they want
    }
    else if(argc == 4){
        sprintf(filename, "%s.bmp", digits);
    }
    
    // Calculate stride and file size for the header
    stride = (((8 * width) + 31)/32) * 4;
    file_size = stride * height + 62;

    // Allocate memory for buffer and picture data
    pictureData = calloc(stride * height, sizeof(char));
    buffer = calloc(67, sizeof(char));

    if(pictureData == NULL || buffer == NULL){
        printf("Memory allocation error\n");
        return 5;
    }
    

    draw_ean8(pictureData, stride, height, width, digits, buffer);


    FILE *fptr;
    fptr = fopen(filename,"wb");
    writeHeader(fptr, file_size, height, width);
    fwrite(pictureData,sizeof(char), stride*height, fptr);
    fclose(fptr);

    free(pictureData);
    free(buffer);

    printf("Barcode %s saved to %s\n", digits, filename);
    return 0;
}

