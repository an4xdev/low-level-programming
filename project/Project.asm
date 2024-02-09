.586P
.MODEL flat, STDCALL
;--- stale z pliku .\include\windows.inc ---
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
GENERIC_READ                         equ 80000000h
GENERIC_WRITE                        equ 40000000h
CREATE_NEW                           equ 1
CREATE_ALWAYS                        equ 2
OPEN_EXISTING                        equ 3
OPEN_ALWAYS                          equ 4
TRUNCATE_EXISTING                    equ 5
FILE_FLAG_WRITE_THROUGH              equ 80000000h
FILE_FLAG_OVERLAPPED                 equ 40000000h
FILE_FLAG_NO_BUFFERING               equ 20000000h
FILE_FLAG_RANDOM_ACCESS              equ 10000000h
FILE_FLAG_SEQUENTIAL_SCAN            equ 8000000h
FILE_FLAG_DELETE_ON_CLOSE            equ 4000000h
FILE_FLAG_BACKUP_SEMANTICS           equ 2000000h
FILE_FLAG_POSIX_SEMANTICS            equ 1000000h
FILE_ATTRIBUTE_READONLY              equ 1h
FILE_ATTRIBUTE_HIDDEN                equ 2h
FILE_ATTRIBUTE_SYSTEM                equ 4h
FILE_ATTRIBUTE_DIRECTORY             equ 10h
FILE_ATTRIBUTE_ARCHIVE               equ 20h
FILE_ATTRIBUTE_NORMAL                equ 80h
FILE_ATTRIBUTE_TEMPORARY             equ 100h
FILE_ATTRIBUTE_COMPRESSED            equ 800h
FORMAT_MESSAGE_ALLOCATE_BUFFER       equ 100h
FORMAT_MESSAGE_IGNORE_INSERTS        equ 200h
FORMAT_MESSAGE_FROM_STRING           equ 400h
FORMAT_MESSAGE_FROM_HMODULE          equ 800h
FORMAT_MESSAGE_FROM_SYSTEM           equ 1000h
FORMAT_MESSAGE_ARGUMENT_ARRAY        equ 2000h
FORMAT_MESSAGE_MAX_WIDTH_MASK        equ 0FFh
FILE_BEGIN							 equ 0h ;MoveMethod dla SetFilePointe
FILE_CURRENT                         equ 1h ;MoveMethod dla SetFilePointe
FILE_END                             equ 2h ;MoveMethod dla SetFilePointe

;--- funkcje API Win32 z pliku  .\include\user32.inc ---
CharToOemA PROTO :DWORD,:DWORD
;--- z pliku .\include\kernel32.inc ---
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
lstrlenA PROTO :DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD  
      ;;nBufferLength, lpBuffer; zwraca length
CreateDirectoryA PROTO :DWORD,:DWORD      
      ;;lpPathName, lpSecurityAttributes; zwraca 0 je¿eli b³¹d
lstrcatA PROTO :DWORD,:DWORD              
      ;; lpString1, lpString2; zwraca lpString1
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD 
      ;; LPCTSTR lpszName, DWORD fdwAccess, 
      ;; DWORD fdwShareMode, LPSECURITY_ATTRIBUTES lpsa, DWORD fdwCreate, 
      ;; DWORD fdwAttrsAndFlags, HANDLE hTemplateFile
CloseHandle PROTO :DWORD      
      ;; BOOL CloseHandle(HANDLE hObject)
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD    
   ;; BOOL WriteFile(
   ;; HANDLE hFile,	// handle to file to write to
   ;; LPCVOID lpBuffer,	// pointer to data to write to file
   ;; DWORD nNumberOfBytesToWrite,	// number of bytes to write
   ;; LPDWORD lpNumberOfBytesWritten,	// pointer to number of bytes written
   ;; LPOVERLAPPED lpOverlapped 	// pointer to structure needed for overlapped I/O 
   ;;);
ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ;;BOOL ReadFile(
    ;;HANDLE hFile,	// handle of file to read 
    ;;LPVOID lpBuffer,	// address of buffer that receives data  
    ;;DWORD nNumberOfBytesToRead,	// number of bytes to read 
    ;;LPDWORD lpNumberOfBytesRead,	// address of number of bytes read 
    ;;LPOVERLAPPED lpOverlapped 	// address of structure for data 
    ;;);
GetLastError PROTO

CheckFileName PROTO :DWORD, :DWORD
Crypt PROTO :DWORD, :DWORD

_DATA SEGMENT
; teksty wyœwietlone na konsoli
welcomeText db "Co chcesz zrobiæ",0Dh,0Ah,"1. Zaszyfrowaæ plik.",0Dh,0Ah,"2. Odszyfrowaæ plik",0Dh,0Ah,0
ALIGN 4
sizeOfWelcomeText dd $ - welcomeText

sourceFileText db "Podaj nazwê pliku Ÿród³owego(X.txt):",0Dh,0Ah,0
ALIGN 4
sizeOfSourceFileText dd $ - sourceFileText

destFileText db "Podaj nazwê pliku docelowego(X.txt):",0Dh,0Ah,0
ALIGN 4
sizeOfDestFileText dd $ - destFileText

choiceErrorText db "Poda³eœ z³¹ opcjê",0
ALIGN 4
sizeOfChoiceErrorText dd $ - choiceErrorText

sourceFileErrorText db "Poda³eœ z³¹ nazwê pliku Ÿród³owego.",0
ALIGN 4
sizeOfSourceFileErrorText dd $ - sourceFileErrorText

destFileErrorText db "Poda³eœ z³¹ nazwê pliku docelowego.",0
ALIGN 4
sizeOfDestFileErrorText dd $ - destFileErrorText

sourceOpenFileErrorText db "Nie uda³o siê otworzyæ pliku Ÿród³owego.",0
ALIGN 4
sizeOfSourceOpenFileErrorText dd $ - sourceOpenFileErrorText

destOpenFileErrorText db "Nie uda³o siê otworzyæ pliku docelowego.",0
ALIGN 4
sizeOfDestOpenFileErrorText dd $ - destOpenFileErrorText

; wybór
choice dd 0

buffor128 db 128 dup(0)

buffor256 db 256 dup(0)

; czytanie
bufforForReading db 128 dup(0)
sizeOfReadingbuffor dd 128
fileHandlerForReading dd ?
numberOfBytesRead dd ?
cin     DD	?

; pisanie
bufforForWriting db 128 dup(0)
sizeOfWritingbuffor dd 128
fileHandlerForWriting dd ?
numberOfBytesWritten dd ?
cout	DD	?

; nazwy plików
bufforForPath dd 128 dup (0)
bufforForSourceFileName db 128 dup(0)
bufforForDestFileName db 128 dup(0)
backslash db "\",0

_DATA ENDS
;------------
_TEXT SEGMENT

ReturnDescryptor MACRO handleConstantIn:REQ, handleOut:REQ
 invoke GetStdHandle, handleConstantIn
 mov handleOut, EAX
ENDM

ConvertAndWrite MACRO hout:REQ, buffor:REQ, rozmN:REQ, rout:REQ
	invoke CharToOemA, OFFSET buffor, OFFSET buffor
	invoke WriteConsoleA, hout, OFFSET buffor, rozmN, OFFSET rout, 0
ENDM

ReadFromConsole MACRO hinp:REQ, buffor:REQ, rozmN:REQ, rout:REQ
    invoke ReadConsoleA, hinp, OFFSET buffor, rozmN, OFFSET rout, 0
	lea EBX, buffor
	mov EDI, rout
	mov BYTE PTR [EBX+EDI-2], 0
ENDM

ConvertToInt MACRO buffor:REQ, zmX:REQ
	push OFFSET buffor
	call ScanInt
	mov zmX, EAX
ENDM

main proc
    ReturnDescryptor STD_OUTPUT_HANDLE, cout
	ReturnDescryptor STD_INPUT_HANDLE, cin

    ConvertAndWrite cout, welcomeText, sizeOfWelcomeText, numberOfBytesWritten

    ReadFromConsole cin, bufforForReading, sizeOfReadingbuffor, numberOfBytesRead

	ConvertToInt bufforForReading, choice

    .if choice > 2 || choice < 1
        ConvertAndWrite cout, choiceErrorText, sizeOfChoiceErrorText, numberOfBytesWritten
    .else 
        ConvertAndWrite cout, sourceFileText, sizeOfSourceFileText, numberOfBytesWritten

        ReadFromConsole cin, bufforForSourceFileName, 128, numberOfBytesRead

        invoke CheckFileName, OFFSET bufforForSourceFileName, numberOfBytesRead

        .if EAX == -1
            ConvertAndWrite cout, sourceFileErrorText, sizeOfSourceFileErrorText, numberOfBytesWritten
        .else
            invoke GetCurrentDirectoryA, 128, OFFSET bufforForPath
            invoke lstrcatA, OFFSET bufforForPath, OFFSET backslash
            invoke lstrcatA, OFFSET bufforForPath, OFFSET bufforForSourceFileName
            invoke CreateFileA, OFFSET bufforForPath, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0

            .if EAX == -1
                 ConvertAndWrite cout, sourceOpenFileErrorText, sizeOfSourceOpenFileErrorText, numberOfBytesWritten
            .else
                mov fileHandlerForReading, EAX

                ConvertAndWrite cout, destFileText, sizeOfDestFileText, numberOfBytesWritten

                ReadFromConsole cin, bufforForDestFileName, 128, numberOfBytesRead
                invoke CheckFileName, OFFSET bufforForDestFileName, numberOfBytesRead

                .if EAX == -1
                        ConvertAndWrite cout, destFileErrorText, sizeOfDestFileErrorText, numberOfBytesWritten
                .else
                        invoke GetCurrentDirectoryA, 128, OFFSET bufforForPath
                        invoke lstrcatA, OFFSET bufforForPath, OFFSET backslash
                        invoke lstrcatA, OFFSET bufforForPath, OFFSET bufforForDestFileName
                        invoke CreateFileA, OFFSET bufforForPath, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0

                        .if EAX == -1
                            ConvertAndWrite cout, destOpenFileErrorText, sizeOfDestOpenFileErrorText, numberOfBytesWritten
                        .else
                            mov fileHandlerForWriting, EAX
                            invoke Crypt, fileHandlerForReading, fileHandlerForWriting
                        .endif

                .endif
            .endif
        .endif
    .endif
    invoke CloseHandle, fileHandlerForWriting
    invoke CloseHandle, fileHandlerForReading
	invoke ExitProcess, 0
main endp

Crypt PROC USES EAX EBX ECX EDI ESI fileForReading:DWORD, fileForWriting:DWORD
LOCAL count:DWORD, counterWrite:DWORD, counterRead:DWORD
    mov EDI, OFFSET buffor128
    mov ESI, OFFSET buffor256
    .if choice == 1
        mov EAX, 1
        .while EAX == 1
            invoke ReadFile, fileForReading, EDI, 128, OFFSET numberOfBytesRead, 0
            .if numberOfBytesRead == 0
                jmp koniec
            .endif

            mov ECX, numberOfBytesRead
            inc ECX
            mov counterRead, 0
            mov counterWrite, 0
            .while ECX > 1
                mov count, 0
                push EAX
                mov EAX, EDI
                add EAX, counterRead
                movzx EBX, BYTE PTR [EAX]
                pop EAX

                .if EBX >= 32
                    sub EBX, 32
                    .while EBX >= 10
                        inc count
                        sub EBX, 10
                    .endw

                    add count, 48
                    add EBX, 48
                    push EBX

                    mov EBX, count

                    push EAX
                    mov EAX, ESI
                    add EAX, counterWrite

                    mov BYTE PTR [EAX], BL
                    pop EAX

                    pop EBX

                    push EAX
                    mov EAX, ESI
                    add EAX, counterWrite
                    inc EAX

                    mov BYTE PTR [EAX], BL
                    pop EAX
                .else
                    push EAX
                    mov EAX, ESI
                    add EAX, counterWrite

                    mov BYTE PTR [EAX], BL
                    pop EAX

                    push EAX
                    mov EAX, ESI
                    add EAX, counterWrite
                    inc EAX

                    mov BYTE PTR [EAX], BL
                    pop EAX
                .endif
                inc counterRead
                add counterWrite, 2
                dec ECX
            .endw

            push EAX
            push EDX
            xor EDX, EDX
            mov EAX, numberOfBytesRead
            push EBX
            mov EBX, 2
            mul EBX

            pop EBX
            pop EDX

            invoke WriteFile, fileForWriting, ESI, EAX, OFFSET numberOfBytesWritten, 0
            pop EAX
        .endw
    .else
        mov EAX, 1
        .while EAX == 1
            mov count, 0
            invoke ReadFile, fileForReading, ESI, 256, OFFSET numberOfBytesRead, 0

            .if numberOfBytesRead == 0
                jmp koniec
            .endif

            mov ECX, numberOfBytesRead
            mov counterRead, 0
            mov counterWrite, 0
            .while ECX > 1
                push EAX
                mov EAX, ESI
                add EAX, counterRead
                movzx EBX, BYTE PTR [EAX]
                pop EAX

                .if EBX >= 48
                    sub EBX, 48

                    push EAX

                    mov EAX, 10
                    mul EBX

                    mov count, EAX
                    pop EAX

                    push EAX
                    mov EAX, ESI
                    add EAX, counterRead
                    inc EAX
                    movzx EBX, BYTE PTR [EAX]
                    pop EAX
                    sub EBX, 48
                    add EBX, count
                    add EBX, 32

                    push EAX
                    mov EAX, EDI
                    add EAX, counterWrite
                    mov BYTE PTR [EAX], BL
                    pop EAX
                .else
                    push EAX
                    mov EAX, EDI
                    add EAX, counterWrite
                    mov BYTE PTR [EAX], BL
                    pop EAX
                .endif
                add counterRead, 2
                inc counterWrite
                dec ECX
            .endw

            push EAX
            push EDX

            mov EAX, numberOfBytesRead
            xor EDX, EDX

            push EBX
            mov EBX, 2
            div EBX
            pop EBX

            invoke WriteFile, fileForWriting, EDI, EAX, OFFSET numberOfBytesWritten, 0

            pop EDX
            pop EAX
        .endw
    .endif
    koniec:
        ret
Crypt ENDP

CheckFileName PROC USES EBX ECX EDX EDI buffor:DWORD, bytesRead:DWORD
    mov EDI, buffor
    add EDI, bytesRead
    sub EDI, 3

    xor EAX, EAX
    mov AL, BYTE PTR[EDI]
    xor EBX, EBX
    mov BL, BYTE PTR[EDI - 1]
    xor ECX, ECX
    mov CL, BYTE PTR[EDI - 2]
    xor EDX, EDX
    mov DL, BYTE PTR[EDI - 3]

    .if AL != 't' || BL != 'x' || CL != 't' || DL != '.'
        mov EAX, -1
    .endif
    ret

CheckFileName ENDP

ScanInt   PROC
;; funkcja ScanInt przekszta³ca ci¹g cyfr do liczby, któr¹ jest zwracana przez EAX 
;; argument - zakoñczony zerem wiersz z cyframi 
;; rejestry: EBX - adres wiersza, EDX - znak liczby, ESI - indeks cyfry w wierszu, EDI - tymczasowy 
;--- pocz¹tek funkcji 
   push   EBP 
   mov   EBP, ESP   ; wskaŸnik stosu ESP przypisujemy do EBP 
;--- odk³adanie na stos 
   push   EBX 
   push   ECX 
   push   EDX 
   push   ESI 
   push   EDI 
;--- przygotowywanie cyklu 
   mov   EBX, [EBP+8] 
   push   EBX 
   call   lstrlenA 
   mov   EDI, EAX   ;liczba znaków 
   mov   ECX, EAX   ;liczba powtórzeñ = liczba znaków 
   xor   ESI, ESI   ; wyzerowanie ESI 
   xor   EDX, EDX   ; wyzerowanie EDX 
   xor   EAX, EAX   ; wyzerowanie EAX 
   mov   EBX, [EBP+8] ; adres tekstu do zamiany na liczbê
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0  ;porównanie z kodem 0 - koniec ³añcucha znaków
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Dh   ;porównanie z kodem CR 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Ah   ;porównanie z kodem LF 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], '-'   ;porównanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], '0'   ;porównanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], '9'   ;porównanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor mo¿e zapisaæ wynik mno¿enia 
   mov   EDI, 10 
   mul   EDI      ;mno¿enie EAX * EDI 
   mov   EDI, EAX   ; tymczasowo z EAX do EDI 
   xor   EAX, EAX   ;zerowanie EAX 
   mov   AL, BYTE PTR [EBX+ESI] 
   sub   AL, 030h   ; korekta: cyfra = kod znaku - kod 0    
   add   EAX, EDI   ; dodanie cyfry 
   pop   EDX 
nast:   
    inc   ESI 
   loop   pocz 
;--- wynik 
   or   EDX, EDX   ;analiza znacznika EDX 
   jz   @F 
   neg   EAX 
@@:    
et4:    
;--- zdejmowanie ze stosu 
   pop   EDI 
   pop   ESI 
   pop   EDX 
   pop   ECX 
   pop   EBX 
;--- powrót 
   mov   ESP, EBP   ; przywracamy wskaŸnik stosu ESP
   pop   EBP 
   ret 4
ScanInt   ENDP 
_TEXT	ENDS

END 

