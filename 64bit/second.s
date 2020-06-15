section     .data
    codes:  db 0xD, 0x19, 0x13, 0x3D, 0x23, 0x31, 0x2F, 0x3B, 0x37, 0xB
    a:      dq 67.0

section     .text
global      draw_ean8

draw_ean8:
    push    RBP
    push    R9                           ; save beginning of buffer
    mov     [R9], DWORD 0x010001           ;First brace
    mov     [R9+63], DWORD 0x01000100      ;End brace
    mov     [R9+31], DWORD 0x01000100      ;Second brace 1
    mov     [R9+35], BYTE 0x00             ;Second brace 2
    add     R9, 2              ; allign for first digit
    
    xor     R10, R10            ; zero edx for digit counter
    xor     RBX, RBX            ; zero ebx for code reading
read_dig:
    mov     BL, [R8 + R10]          ; read digit
    sub     BL, '0'                 ; digit to int
    mov     BL, [codes + RBX]       ; digit to code

    mov     RAX, 7              ; init counter
    cmp     R10, 4              ; for digits after 3 negate codes
    jl      loop1
    not     BL
loop1:
    inc     R9                
    dec     EAX                 
    bt      EBX, EAX
    jnc     loop1end            ; if 0 skip
    mov     [R9], BYTE 0x01    ; set 1
loop1end:
    jnz     loop1               
    inc     R10
    cmp     R10D, 4
    jne     cont
    add     R9, 5              ; skip the bar
cont:
    cmp     R10, 8
    jne     read_dig
    pop     R9

    fldz
    fld     qword [a]           ; st0 = 67
    mov     [a], RCX
    fld     qword [a]           ; st0 = width, st1 = 67
    fdivp   st1, st0            ; st0 = 67/(width) = step size
    fldz                        ; st0 = 0, st1 = step

        ; eax -> R9
        ; EDI -> RDI
        ; [EBP + 12] -> RSI
        ; [EBP + 20] -> RCX
        ; [EBP + 16] -> RDX
        ; ECX -> R10
        ; EBX -> R11
        ; ESI -> RAX

;     xor     R10, R10            ; 0 for width counter
;     xor     R11, R11            ; 0 for height counter
;     xor     RAX, RAX            ; 0 for buffer offset
; columnloop:
;     cmp     BYTE [R9 + RAX], 0
;     jz      afterset
;     push    RDI    
;     mov     R11, RDX
; rowloop:
;     mov     [RDI + R10], BYTE 0x01
;     add     RDI, RSI
;     dec     R11
;     jnz     rowloop
;     pop     RDI
; afterset:

;     fadd    st0, st1            ; add step
;     fst     st2
;     fisttp  dword[a]            ; round to integer -> memory
;     fld     st1                 
;     mov     RAX, [a]            ; memory -> register

;     inc     R10
;     cmp     R10, RCX       ; ecx == height 
;     jne     columnloop

; end:
;     ; Free used floating point stack
     ffree   st0
     ffree   st0
     ffree   st0
 
    pop     rbp
    ret 