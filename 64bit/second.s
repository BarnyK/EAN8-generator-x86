section     .data
    codes:  db 0xD, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB
    a:      dd 67.00

section     .text
global      draw_ean8

draw_ean8:
    push    RBP           

    mov     [R9], DWORD 0x010001           ;First brace
    mov     [R9+63], DWORD 0x01000100      ;End brace
    mov     [R9+31], DWORD 0x01000100      ;Second brace 1
    mov     [R9+35], BYTE 0x00             ;Second brace 2
    add     R9, 2                          ;allign for first digit
    
    xor     R10, R10            ; zero edx for digit counter
    xor     R11, R11            ; zero ebx for code reading
read_dig:
    mov     BL, [R8 + R10]          ; read digit
    sub     BL, '0'                 ; digit to int
    mov     BL, [codes + R11]       ; digit to code

    mov     EAX, 7              ; init counter
    cmp     R10, 4              ; for digits after 3 negate codes
    jl      loop1
    not     BL
loop1:
    inc     R9                  ; inc buffer
    dec     EAX                 
    bt      EBX, EAX
    jnc     loop1end            ; if 0 skip
    mov     [R9], BYTE 0x01    
loop1end:
    jnz     loop1               
    inc     R10
    cmp     R10D, 4

    jne     cont
    add     R9, 5              ; skip the bar
cont:
    cmp     R10, 8
    jne     read_dig

    sub     R9, 66              ; go back to beginning of buffer

    ; Setting up scaling
    CVTSI2SS    xmm1, RCX       ; xmm1 = width
    movss   xmm0, [a]           ; xmm0 = 67
    divss   xmm0, xmm1          ; xmm0 = 67/width - step
    subss   xmm2, xmm2

    ; Preparation for loops
    xor     R10, R10            ; 0 for width counter
    xor     R11, R11            ; 0 for height counter
    xor     RAX, RAX            ; 0 for buffer offset
columnloop:
    cmp     BYTE [R9 + RAX], 0
    jz      afterset                ; Skip if 0

    mov     R8, RDI             ; Save bottom of the column 
    mov     R11, RDX            
rowloop:
    mov     [RDI + R10], BYTE 0x01  
    add     RDI, RSI                
    dec     R11
    jnz     rowloop

    mov     RDI, R8             ; Restore column
afterset:
    addss   xmm2, xmm0            ; add step
    cvttss2si   RAX, xmm2        ; round to integer with trunctuation
    inc     R10
    cmp     R10, RCX              ; RCX == height  
    jne     columnloop

;Epilogue
    pop     RBP
    ret 