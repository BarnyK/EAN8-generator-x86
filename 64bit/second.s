section     .data
codes:  db  0xD, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB

section     .text
global      draw_ean8

draw_ean8:

    ; Encoding digits to buffer
    ; R9  - buffer pointer
    ; R10 - digit counter 0 to 8
    ; R11 - reading digit code
    ; RAX - bit counter for code

    mov     [R9], DWORD 0xFF00FF           ;First brace
    mov     [R9+63], DWORD 0xFF00FF00      ;End brace
    mov     [R9+31], DWORD 0xFF00FF00      ;Second brace
    add     R9, 2                          ;allign for first digit
    
    xor     R10D, R10D            ; zero edx for digit counter
    xor     R11D, R11D            ; zero ebx for code reading
read_dig:
    mov     R11B, [R8 + R10]          ; read digit
    sub     R11B, '0'                 ; digit to int
    mov     R11B, [codes + R11]       ; digit to code

    mov     AX, 7              ; init counter
    cmp     R10D, 4              ; for digits after 3 negate codes
    jl      loop1
    not     R11B
loop1:
    inc     R9D                  ; inc buffer
    dec     AX                 ; decrease counter
    bt      R11W, AX
    jnc     loop1end            ; if 0 skip
    mov     [R9], BYTE 0xFF    
loop1end:
    jnz     loop1               
    inc     R10D
    cmp     R10D, 4

    jne     cont
    add     R9D, 5              ; skip the bar
cont:
    cmp     R10D, 8
    jne     read_dig

    ; Writing to picture data
    ; R9  - buffer pointer
    ; RDI - picture pointer
    ; R10 - buffer offset/counter
    ; R8  - saving and restoring picture pointer
    ; R11 - height counter
    ; RDX - height
    ; RAX - modwith
    ; RSI - stride
    sub     R9D, 63                ; go back to beginning of buffer
    xor     R10B, R10B            ; 0 for buffer offset/counter
columnloop:
    cmp     [R9+R10], BYTE 0    
    je      end
    mov     R8, RDI                 ; save picture pointer
    mov     R11, RDX
loopheight:
    mov     RAX, RCX       ; modwith
loopmod:
    mov     [RDI+RAX-1], BYTE 0xFF  
    dec     EAX
    jnz     loopmod                     
    add     RDI, RSI              ; next row pointer
    dec     R11
    jnz     loopheight            ; jump next row if not done
    mov     RDI, R8                    ; restore picture pointer
end:
    add     RDI, RCX               ; next section of barcode
    inc     R10B         
    cmp     R10B, 67
    jne     columnloop

    ret 