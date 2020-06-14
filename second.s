section     .text
global      draw_ean8

draw_ean8:
    push    ebp
    mov     ebp, esp
    mov    eax, [ebp+28]

    
    mov     [eax], DWORD 0x010001
    mov     [eax+63], DWORD 0x01000100
    mov     [eax+31], DWORD 0x010001
    mov     [eax+33], DWORD 0x010001
    mov     esp, ebp
    pop     ebp
    ret 