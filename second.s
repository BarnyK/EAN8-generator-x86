section     .data
Lcodes:     db 0xD, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB
Rcodes:     db 0x01
section     .text
global      draw_ean8

draw_ean8:
    push    ebp
    mov     ebp, esp

    push    ebx
    push    esi
    push    edi
    
    mov     eax, [ebp+28]       ;buffer
    mov     ecx, [ebp+24]       ;digits

    xor     ebx, ebx
    mov     bl, [ecx]           ; first digit
    sub     bl, '0'             ; first digit to int

    mov     bl, [Lcodes + ebx]  ; decode it
                                ; loop from 6 to 0 for setting bits in buffer
    mov     [eax+5], bl         
    ; shl     ebx, 7
    ; mov     bl, [Lcodes+1]
    ; shl     ebx, 7
    ; mov     bl, [Lcodes+2]
    ; shl     ebx, 7
    ; mov     bl, [Lcodes+3]
    mov     [eax], DWORD 0x010001       ;First brace
    ; mov     [eax+3], ebx
    mov     [eax+31], DWORD 0x00010001    ;Second brace 1
    mov     [eax+35], BYTE 0x01    ;Second brace 2
    mov     [eax+63], DWORD 0x01000100  ;End brace

    ; mov     [eax+3], DWORD 0x01000000
    ; mov     [eax+7], DWORD 0x010000
    ; mov     [eax+10], DWORD 0x01010101
    ; mov     [eax+14], DWORD 0x010101

end:
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret 