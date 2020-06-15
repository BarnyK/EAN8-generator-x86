section     .data
    codes:  db 0x58, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB
    a:      dq 67.0
    savef:  dq 0
section     .text
global      draw_ean8

draw_ean8:
    push    ebp
    mov     ebp, esp

    push    ebx
    push    esi
    push    edi
    
    mov     eax, [ebp+28]       ;buffer
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

    mov     bl, [codes + ebx]   ; decode it

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
    add     eax, 5              ; skip the bar
cont:
    cmp     edx, 8
    jne     read_dig

    ; +12 strride, +16 height, +20 width, 
    
    
    fldz
    fld     qword [a]           ; st0 = 66
    fild    dword [ebp+20]      ; st0 = width, st1 = 66
    ;fld1                        ; st0 = 1, st1 = width, st2 = 66
    ;fsubp                       ; st0 = width - 1, st1 = 66
    fdivp   st1, st0            ; st0 = 66/(width - 1) = step size
    fldz                        ; st0 = 0, st1 = step

    ; EAX at the end of buffer right now
    mov     eax, [ebp+28]       ; set eax to point to beginning of buffer
    mov     edi, [ebp+8]        ; picture data
    xor     ecx, ecx            ; 0 for width counter
    xor     ebx, ebx            ; 0 for height counter
    xor     esi, esi            ; 0 for buffer offset
columnloop:
    cmp     BYTE [eax + esi], 0
    jz     afterset
    push    edi    
    mov     ebx, [ebp+16]
rowloop:
    mov     [edi + ecx], BYTE 0x01
    add     edi, [ebp+12]
    dec     ebx
    jnz     rowloop
    pop     edi
afterset:

    fadd    st0, st1            ; add step
    fst     st2
    fisttp  dword[a]            ; round to integer -> memory
    fld     st1                 
    mov     esi, [a]            ; memory -> register

    inc     ecx
    cmp     ecx, [ebp+20]       ; ecx == height 
    jne     columnloop

end:
    ; Free used floating point stack
    ffree   st0
    ffree   st0
    ffree   st0
    ; return registers and frame back
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret 