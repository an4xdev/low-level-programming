;Aplikacja korzystaj¹ca z otwartego okna konsoli
.MODEL flat, STDCALL
;constants
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11

;method prototypes
ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
CharToOemA	  PROTO :DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

;------------- these are included by default in linker settings 
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------
;data segment where variables are defined

.data
	printed dword	0 ;buffor for actual printed data count

	header		byte	"Autor: Kamil Skar¿yñski.",0
	sizeH		dword	$ - header

	cin			dword	?
	cout		dword	?
	zmA			dword	10

.code
	main proc
			mov EDI, offset zmA
			mov EAX, 5
			push EAX
			pop zmA

			push STD_INPUT_HANDLE
			call GetStdHandle
			mov cin, eax
	
			push STD_OUTPUT_HANDLE
			call GetStdHandle
			mov cout, eax

			push offset header
			push offset header
			call CharToOemA	

			push 0
			push offset printed
			push sizeH
			push offset header
			push cout

			call WriteConsoleA

			push 0
			call ExitProcess

	main endp 

END