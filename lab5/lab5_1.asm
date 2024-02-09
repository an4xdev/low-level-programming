;Aplikacja korzystaj¹ca z otwartego okna konsoli
.386
.MODEL flat, STDCALL
;--- stale ---
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
;--- funkcje API Win32 ---
;--- z pliku  user32.inc ---
CharToOemA PROTO :DWORD,:DWORD
;--- z pliku kernel32.inc ---
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
wsprintfA PROTO C :VARARG
lstrlenA PROTO :DWORD
;-------------
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji Micha³ ¯uk.",0
	ALIGN	4
	rozmN	DD	$ - naglow	;liczba znaków w tablicy

	zaprA	DB	0Dh,0Ah,"Podaj pierwsz¹ liczbê [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy
	zmA	DD	?	; argument A
	
	zaprB	DB	0Dh,0Ah,"Podaj drug¹ liczbê [+Enter]: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znaków w tablicy
	zmB	DD	?	; argument B

	komunikat1	DB	"Podane liczby s¹ równe ",13,10,0  
	ALIGN	4
	rozmiarKomunikat1	DD	$ - komunikat1
	komunikat2	DB	"Podane liczby nie s¹ równe",13,10,0
	ALIGN	4
	rozmiarKomunikat2	DD	$ - komunikat2
	
	ALIGN	4
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków
	bufor	DB	128 dup(?)
	rbuf	DD	128
_DATA ENDS
;------------
_TEXT SEGMENT
main proc
;--- wywo³anie funkcji GetStdHandle 
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywo³anie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyjœciowego bufora konsoli
	push	STD_INPUT_HANDLE
	call	GetStdHandle	; wywo³anie funkcji GetStdHandle
	mov	hinp, EAX	; deskryptor wejœciowego bufora konsoli
;--- nag³ówek ---------
	push	OFFSET naglow
	push	OFFSET naglow
	call	CharToOemA	; konwersja polskich znaków
;--- wyœwietlenie ---------

	push	OFFSET naglow
	call lstrlenA
	mov rozmN,eax
	
	push	0		; rezerwa, musi byæ zero
	push	OFFSET rout	; wskaŸnik na faktyczn¹ liczba wyprowadzonych znaków 
	push	rozmN		; liczba znaków
	push	OFFSET naglow 	; wska¿nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA
;--- zaproszenie A ---------
	push	OFFSET zaprA
	push	OFFSET zaprA
	call	CharToOemA	; konwersja polskich znaków
;--- wyœwietlenie zaproszenia A ---
	push	0		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczba wyprowadzonych znaków 
	push	rozmA		; liczba znaków
	push	OFFSET zaprA 	; wska¿nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA   
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rinp 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
	push	rbuf 		; rozmiar bufora
	push	OFFSET bufor ;wska¿nik na bufor
 	push	hinp		; deskryptor buforu konsoli
	call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	push	OFFSET bufor
	call	ScanInt
	mov	zmA, EAX


	;--- zaproszenie B ---------
	push	OFFSET zaprB
	push	OFFSET zaprB
	call	CharToOemA	; konwersja polskich znaków
;--- wyœwietlenie zaproszenia B ---
	push	0		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczba wyprowadzonych znaków 
	push	rozmA		; liczba znaków
	push	OFFSET zaprB 	; wska¿nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA   
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rinp 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
	push	rbuf 		; rozmiar bufora
	push	OFFSET bufor ;wska¿nik na bufor
 	push	hinp		; deskryptor buforu konsoli
	call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie B
	push	OFFSET bufor
	call	ScanInt
	mov	zmB, EAX
;;;;	ToDo
	
	mov EAX, zmA
	CMP EAX, zmB

	JNZ rozne

;--- wyœwietlenie komunikatu 1 ---------
	push	OFFSET komunikat1
	push	OFFSET komunikat1
	call	CharToOemA	; konwersja polskich znaków
	
	push	OFFSET komunikat1
	call lstrlenA
	mov rozmiarKomunikat1,eax
	
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczbê wyprowadzonych znaków 
	push	rozmiarKomunikat1		; liczba znaków
	push	OFFSET komunikat1 	; wskaŸnik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA
	
	jmp koniec

rozne:
	;--- wyœwietlenie komunikatu 2 ---------
	push	OFFSET komunikat2
	push	OFFSET komunikat2
	call	CharToOemA	; konwersja polskich znaków
	
	push	OFFSET komunikat2
	call lstrlenA
	mov rozmiarKomunikat2,eax
	
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczbê wyprowadzonych znaków 
	push	rozmiarKomunikat2		; liczba znaków
	push	OFFSET komunikat2 	; wskaŸnik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA
	
;--- zakoñczenie procesu ---------
koniec:
	push	0
	call	ExitProcess	; wywo³anie funkcji ExitProcess
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
   mov   EBX, [EBP+8] ; adres tekstu
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0h   ;porównanie z kodem \0 
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
   cmp   BYTE PTR [EBX+ESI], 02Dh   ;porównanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 030h   ;porównanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 039h   ;porównanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor mo¿e zapisaæ wynik mno¿enia 
   mov   EDI, 10 
   mul   EDI      ;mno¿enie EAX * EDI 
   mov   EDI, EAX   ; tymczasowo z EAX do EDI 
   xor   EAX, EAX   ;zerowani EAX 
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
et4:;--- zdejmowanie ze stosu 
   pop   EDI 
   pop   ESI 
   pop   EDX 
   pop   ECX 
   pop   EBX 
;--- powrót 
   mov   ESP, EBP   ; przywracamy wskaŸnik stosu ESP
   pop   EBP 
   ret	4
ScanInt   ENDP 
_TEXT	ENDS    

END

