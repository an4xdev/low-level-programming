;Aplikacja korzystj¹ca z otwartego okna konsoli
ExitProcess PROTO :QWORD
GetStdHandle PROTO :QWORD
WriteConsoleA PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD
CharToOemA	  PROTO :QWORD,:QWORD
ReadConsoleA PROTO :QWORD,:QWORD,:QWORD,:QWORD,:QWORD
lstrcatA PROTO :QWORD, :QWORD
lstrlenA PROTO :QWORD
wsprintfA PROTO C :VARARG
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11

;------------- these are included by default in linker settings 
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------
;data segment where variables are defined

.data
	printed		qword	0 ;buffor for actual printed data count
	inserted	qword	0
	ibuffer	    byte	128 dup(?)
    obuffer	    byte	128 dup(?)
	cin			qword	?
	cout		qword	?

	insertName	byte	"Podaj swoje imie: ",0
	ALIGN 4
	insertNameSize	qword	$ - insertName

	first		byte	0Dh,0Ah,"Podaj pierwszy argument: ",0
	ALIGN 4
	firstSize	qword	$ - first
	second		byte	0Dh,0Ah,"Podaj drugi argument: ",0
	ALIGN 4
	secondSize	qword	$ - second
	third		byte	0Dh,0Ah,"Podaj trzeci argument: ",0
	ALIGN 4
	thirdSize	qword	$ - third
	farg		qword	?
	sarg		qword	?
	targ		qword	?
	wzor	DB	0Dh,0Ah,"Funkcja f(A,B,C) = 7*(A-B)+C = %ld",0  ;%ld oznacza formatowanie w formacie dziesiêtnym
	ALIGN	4
	wzorSize	qword	$ - wzor
	hello		byte	0Dh,0Ah,"Witamy w architekturze 64 bitowej ",0
.code
	main proc
			mov RCX, STD_INPUT_HANDLE
			call GetStdHandle
			mov cin, rax
	
			mov RCX, STD_OUTPUT_HANDLE
			call GetStdHandle
			mov cout, rax

			;mov RCX, offset header
			;mov RDX, offset header
			;call CharToOemA

			; wypisanie podaj imie

			mov RCX, cout
			mov RDX, offset insertName
			mov R8, insertNameSize
			mov R9, offset printed
			push 0

			call WriteConsoleA

			; podanie imienia

			mov RCX, cin
			mov RDX, offset ibuffer
			mov R8, 128
			mov R9, offset inserted
			push 0
			call ReadConsoleA

			lea   RBX, ibuffer
			mov   RDI, inserted
			mov   BYTE PTR [RBX+RDI-2],0

			mov RCX, OFFSET hello
			mov RDX, OFFSET ibuffer
			call lstrcatA
			mov RDX, RAX

			push RDX
			pop RCX
			call lstrlenA

			mov inserted, rax

			; wypisanie imienia

			mov RCX, cout
			mov R8, inserted
			mov R9, offset printed
			push 0

			call WriteConsoleA

			; pierwszy argument

			mov RCX, cout
			mov RDX, offset first
			mov R8, firstSize
			mov R9, offset printed
			push 0

			call WriteConsoleA

			; wycztanie pierwszego argumentu

			mov RCX, cin
			mov RDX, offset ibuffer
			mov R8, 128
			mov R9, offset inserted
			push 0
			call ReadConsoleA

			lea   RBX, ibuffer
			mov   RDI, inserted
			mov   BYTE PTR [RBX+RDI-2],0

			mov RCX, offset ibuffer
			call ScanInt
			mov farg, RAX

			; drugi argument

			mov RCX, cout
			mov RDX, offset second
			mov R8, secondSize
			mov R9, offset printed
			push 0

			call WriteConsoleA

			; wycztanie drugiego argumentu

			mov RCX, cin
			mov RDX, offset ibuffer
			mov R8, 128
			mov R9, offset inserted
			push 0
			call ReadConsoleA

			lea   RBX, ibuffer
			mov   RDI, inserted
			mov   BYTE PTR [RBX+RDI-2],0

			mov RCX, offset ibuffer
			call ScanInt
			mov sarg, RAX

			; trzeci argument

			mov RCX, cout
			mov RDX, offset third
			mov R8, thirdSize
			mov R9, offset printed
			push 0

			call WriteConsoleA

			; wycztanie trzeciego argumentu

			mov RCX, cin
			mov RDX, offset ibuffer
			mov R8, 128
			mov R9, offset inserted
			push 0
			call ReadConsoleA

			lea   RBX, ibuffer
			mov   RDI, inserted
			mov   BYTE PTR [RBX+RDI-2],0

			mov RCX, offset ibuffer
			call ScanInt
			mov targ, RAX

			; 7*(A-B)+C

			xor RAX, RAX
			xor RBX, RBX
			xor RCX, RCX

			mov RAX, 7
			mov RBX, farg
			mov RCX, sarg
			sub RBX, RCX
			mul RBX

			mov RBX, targ
			add RAX, RBX

			; wypisanie wyniku

			mov RCX, offset obuffer
			mov RDX, offset wzor
			mov R8, RAX
			call	wsprintfA	; zwraca liczbê znaków w buforze 
			;add	RSP, 12		; czyszczenie stosu
			mov	printed, RAX	; zapamiêtywanie liczby znaków

			mov RCX, cout
			mov RDX, offset obuffer
			mov R8, printed
			mov R9, offset inserted
			push 0

			call WriteConsoleA

			mov RCX, 0
			call ExitProcess

	main endp

ScanInt PROC
	push RCX
	call lstrlenA
	mov RDI, RAX
	mov RCX, RAX
	xor RSI, RSI
	xor RDX, RDX
	xor RAX, RAX
	pop RBX

;--- cykl --------------------------
pocz:
    cmp    BYTE PTR [RBX + RSI], 0h   ; porównanie z kodem \0
    jne    @F
    jmp    et4
@@:
    cmp    BYTE PTR [RBX + RSI], 0Dh  ; porównanie z kodem CR
    jne    @F
    jmp    et4
@@:
    cmp    BYTE PTR [RBX + RSI], 0Ah  ; porównanie z kodem LF
    jne    @F
    jmp    et4
@@:
    cmp    BYTE PTR [RBX + RSI], 02Dh ; porównanie z kodem -
    jne    @F
    mov    RDX, 1
    jmp    nast
@@:
    cmp    BYTE PTR [RBX + RSI], 030h ; porównanie z kodem 0
    jae    @F
    jmp    nast
@@:
    cmp    BYTE PTR [RBX + RSI], 039h ; porównanie z kodem 9
    jbe    @F
    jmp    nast
;----
@@:
	push RDX
	mov RDI, 10
	mul RDI
	mov RDI, RAX
	xor RAX, RAX
	mov AL, BYTE PTR [RBX+RSI]
	sub AL, 030h

	add RAX, RDI
	pop RDX

nast:
	inc RSI
	loop pocz

    ;or RDX, RDX
	;jz @F
	;neg RAX
@@:
et4:
	ret
ScanInt ENDP 
END