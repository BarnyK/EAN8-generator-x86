section     .data
    codes:  db 0xD, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB

section     .text
global      draw_ean8

draw_ean8:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    
    ;   Writing to buffer
    mov     eax, [ebp+28]       ;buffer
    mov     edi, [ebp+24]       ;digits
    mov     [eax], DWORD 0xFF00FF           ;First brace
    mov     [eax+63], DWORD 0xFF00FF00      ;End brace
    mov     [eax+31], DWORD 0xFF00FF00      ;Second brace 
    add     eax, 2              ; allign for first digit

    xor     edx, edx            ; zero edx for digit counter
    xor     ebx, ebx            ; zero ebx for code reading
read_dig:
    mov     bl, [edi + edx]     ; read digit
    sub     bl, '0'             ; digit to int
    mov     bl, [codes + ebx]   ; digit to code

    mov     ecx, 7              ; init counter
    cmp     edx, 4              ; for digits after 3 negate codes
    jl      loop1
    not     bl
loop1:
    inc     eax                 
    dec     ecx                 
    bt      ebx, ecx
    jnc     loop1end            ; if 0 skip
    mov     [eax], BYTE 0x01    ; set 1
loop1end:
    jnz     loop1               
    inc     edx
    cmp     edx, 4
    jne     cont
    add     eax, 5              ; skip the bar
cont:
    cmp     edx, 8
    jne     read_dig


    ; Writing to picture data
    mov     eax, [ebp+28]       ; set eax to point to beginning of buffer
    mov     edi, [ebp+8]        ; picture data
    xor     esi, esi            ; 0 for buffer offset
columnloop:
    cmp     [eax+esi], BYTE 0
    je      end
    mov     edx, edi                 ; save picture pointer
    mov     ebx, [ebp+16]
loopheight:
    mov     ecx, [ebp+20]       ; modwith
loopmod:
    mov     [edi+ecx-1], BYTE 0xFF  
    dec     ecx
    jnz     loopmod                     
    add     edi, [ebp+12]               ; set next row
    dec     ebx
    jnz     loopheight                  ; jump next row
    mov     edi, edx                    ; restore picture pointer
end:
    add     edi, [ebp+20]               ; next section of barcode
    inc     esi         
    cmp     esi, 67
    jne     columnloop

    ; Epilogue
    ; return registers and frame back
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret 