.386
.MODEL FLAT, STDCALL
PUBLIC DoMath
PUBLIC FillBuffor

.code 
    DoMath PROC xa:DWORD, xb:DWORD, xc:DWORD
        mov ECX, xa
        mov EDX, xb
        push EDX
        mov EAX, 25
        mul ECX
        pop EDX
        ;25*A w EAX
        push EAX
        mov EAX, 4
        push EDX
        mul ECX
        pop EDX
        mul EDX
        ;4*A*B w EAX
        pop EBX
        ;25*A w EBX
        sub EBX, EAX

        mov ECX, xc
        sub EBX, ECX
        push EBX
        pop EAX
        ret
    DoMath ENDP

    FillBuffor PROC buforAddr:DWORD
        mov ECX, 1000
        mov EDI, buforAddr
        petla:
            mov DWORD PTR [EDI], "    "
            add EDI, 4
        loop petla
        ret
    FillBuffor ENDP
END