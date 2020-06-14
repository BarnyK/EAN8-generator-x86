section     .data
Lcodes:     db 0x58, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB
Rcodes:     db 0x01
section     .text
global      draw_ean8

draw_ean8:
    push    ebp
    mov     ebp, esp

    push    ebx
    push    esi
    push    edi
    
    mov     eax, [ebp+8]       ;buffer
    mov     edi, [ebp+24]       ;digits

    mov     [eax], DWORD 0x010001           ;First brace
    mov     [eax+63], DWORD 0x01000100      ;End brace
    mov     [eax+31], DWORD 0x01000100      ;Second brace 1
    mov     [eax+35], BYTE 0x00             ;Second brace 2
    add     eax, 2              ; allign for first digit

    xor     edx, edx            ; zero edx for digit counter
read_dig:
    xor     ebx, ebx
    mov     bl, [edi + edx]     ; read digit
    sub     bl, '0'             ; digit to int

    mov     bl, [Lcodes + ebx]  ; decode it
                                ; loop from 6 to 0 for setting bits in buffer
    mov     ecx, 7
    cmp     edx, 4
    jl      loop1
    not     bl
loop1:
    inc     eax             
    dec     ecx
    bt      ebx, ecx
    jnc     loop1end            ; if 0 skip, maybe change to setting 0?
    mov     [eax], BYTE 0x01    ; set 1
loop1end:
    jnz     loop1               
    inc     edx
    cmp     edx, 4
    jne     cont
    add     eax, 5
cont:
    cmp     edx, 8
    jne     read_dig


end:
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret 