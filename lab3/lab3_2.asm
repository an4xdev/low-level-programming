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
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znaków w tablicy
	zaprA	DB	0Dh,0Ah,"Proszê wprowadziæ kolejn¹ liczbê: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy
	zaprB	DB	0Dh,0Ah,"Suma wprowadzonych liczb wynosi: %ld",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znaków w tablicy
	ALIGN	4
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków
	lZnakow	DD	0 
	bufor	DB	128 dup(?)
	rbuf	DD	128
	liczby	DB	10 dup(?)
	rLiczby	DD	10
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
	
cld	;wyzerowanie flagi kierunku
mov EDI, OFFSET liczby ; pod tym adresem umieœcimy wczytane liczby
mov ecx, 10

petla:
push ecx

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
	mov   EDX,rinp
	mov   BYTE PTR [EBX+EDX-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	push	OFFSET bufor
	call	ScanInt	;pobran¹ liczbê mamy teraz w akumulatorze
	stosb ; i przesy³amy j¹ do pamiêci w miejce wskazywane przez EDI (po operacji edi zwiêkszany automatycznie o 1)
 pop ecx
 loop petla	

;-- miejsce na obliczenia
; dodawanie zwyk³e

	MOV ESI, OFFSET liczby
	MOV ECX, rLiczby
	CLD
	MOV EBX, 0
	MOV EAX, 0
	L1: lodsb
		ADD EBX, EAX
	loop L1

	MOV EAX, EBX

;--- wyprowadzenie wyniku obliczeñ ---
	push	EAX
	push	OFFSET zaprB
	push	OFFSET bufor
	call	wsprintfA	; zwraca liczbê znaków w buforze 
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapamiêtywanie liczby znaków
;--- wyœwietlenie wyniku ---------
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczbê wyprowadzonych znaków 
	push	rinp		; liczba znaków
	push	OFFSET bufor 	; wskaŸnik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA

;-- miejsce na obliczenia
; dodawanie pojebane

	MOV ESI, OFFSET liczby
	;INC ESI - zmiana na nieparzyste
	; dzielenie rLiczby na 2
	MOV EAX, rLiczby
	MOV EDX, 0 ; czyszczenie ¿eby nie by³o int overflow
	MOV EBX, 2; dwa
	DIV EBX; dzielenie
	MOV ECX, EAX; finalna d³ugoœæ w ECX
	CLD
	MOV EBX, 0
	MOV EAX, 0
	L2: lodsb
		ADD EBX, EAX
		ADD ESI, 1
	loop L2

	MOV EAX, EBX

;--- wyprowadzenie wyniku obliczeñ ---
	push	EAX
	push	OFFSET zaprB
	push	OFFSET bufor
	call	wsprintfA	; zwraca liczbê znaków w buforze 
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapamiêtywanie liczby znaków
;--- wyœwietlenie wyniku ---------
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET rout 	; wskaŸnik na faktyczn¹ liczbê wyprowadzonych znaków 
	push	rinp		; liczba znaków
	push	OFFSET bufor 	; wskaŸnik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA
;--- zakoñczenie procesu ---------
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

