#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//void draw_ean8(void *img, unsigned int stride, unsigned int height,unsigned int modwidth, char *digits);
extern void draw_ean8(char *img, unsigned int stride, unsigned int height, unsigned int width, char *digits, char *buffer);

// BMP header data, calculated in C
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
    __uint32_t color1;
    __uint32_t color2;
}bmpData;         // leaves the BM part out for size alignment


// Writes header data and 2 color pallette
void writeHeader(FILE *fptr, __uint32_t file_size, __int32_t height, __int32_t width){
    bmpData head;
    __uint16_t type = 0x4d42;
    head.file_size = file_size;
    head.reserved1 = 0;
    head.reserved2 = 0;
    head.start = 0x3e;
    head.header_size = 40;
    head.width = width;
    head.height = height;
    head.planes = 1;
    head.bits_per_pixel = 8;
    head.compression = 0;
    head.image_size = 0;
    head.vertical_resolution = 2835;     // 72 DPI
    head.horizontal_resolution = 2835;   
    head.colors = 2;
    head.imporant_colors = 0;
    head.color1 = 0x00FFFFFF;
    head.color2 = 0x00000000;
    fwrite(&type, sizeof(__uint16_t), 1, fptr);
    fwrite(&head, sizeof(head), 1, fptr);
}

// Image data stored in unsigner char

int main(int argc, char *argv[]){
    int width, height, checksum=0, codecheck = 1, digits_len, stride, file_size;
    char digits[9] = {0}, filename[64] = {0}, tmp;
    if(argc != 5 && argc != 4){
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
            digits[7] = '0' + 10 - (checksum % 10);
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
    if(argc == 5){
        strncpy(filename, argv[4],32);  // Don't need to validate, let user save it to any filename they want
    }
    else if(argc == 4){
        sprintf(filename, "%s.bmp", digits);
    }
    
    stride = (((8 * width) + 31)/32) * 4;
    file_size = stride * height + 54 + 4 * 2;

    char* pictureData = calloc(stride * height, sizeof(char));
    char* buffer = calloc(67, sizeof(char));
    draw_ean8(pictureData, stride, height, width, digits, buffer);
    
    // Debug code checking
    int b=0, e=3;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    putchar('\n');

    b=e;e=e+7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[0]);

    b=e;e+=7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[1]);

    b=e;e+=7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[2]);

    b=e;e+=7;;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[3]);

    b=e;e+=5;;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    putchar('\n');

    b=36;e=b+7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]); 
    }
    printf("\t%c\n",digits[4]);
    b=e;e+=7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[5]);
    b=e;e+=7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[6]);
    b=e;e+=7;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    printf("\t%c\n",digits[7]);
    b=e;e+=3;
    for(int i=b;i<e;i++){
        printf("%d",buffer[i]);
    }
    putchar('\n');
    
    
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
