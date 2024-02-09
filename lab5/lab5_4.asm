;Aplikacja korzystaj�ca z otwartego okna konsoli
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
GetTickCount PROTO
nseed PROTO :DWORD
nrandom PROTO :DWORD
;-------------
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;includelib .\lib\masm32.lib
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji Micha� �uk.",0Dh,0Ah,0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znak�w w tablicy
	zaprA	DB	0Dh,0Ah,"Podaj liczb� [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy
	zmA	DD	?	; argument A
	zakres DD 100;
	wylosowanaLiczba	DD	1	; argument A
	iloscProb	DD	0
	odgadnieta	DD	1000
	zwyciestwo	DB	0Dh,0Ah,"Jestes zwyciezca! Trafiles za %ld razem.",0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmiarzwyciestwo	DD	$ - zwyciestwo	;liczba znak�w w tablicy
	podajWieksza	DB	0Dh,0Ah,"Niestety nie trafiles. Podaj wieksza liczbe.",0Dh,0Ah,0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmiarpodajWieksza	DD	$ - podajWieksza	;liczba znak�w w tablicy
	podajMniejsza	DB	0Dh,0Ah,"Niestety nie trafiles. Podaj mniejsza liczbe.",0Dh,0Ah,0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmiarpodajMniejsza	DD	$ - podajMniejsza	;liczba znak�w w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	rinp	DD	0 ;faktyczna liczba wprowadzonych znak�w
	bufor	DB	128 dup(?)
	rbuf	DD	128
_DATA ENDS
;------------
_TEXT SEGMENT
main proc
;--- wywo�anie funkcji GetStdHandle 
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywo�anie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyj�ciowego bufora konsoli
	push	STD_INPUT_HANDLE
	call	GetStdHandle	; wywo�anie funkcji GetStdHandle
	mov	hinp, EAX	; deskryptor wej�ciowego bufora konsoli
;--- nag��wek ---------
	push	OFFSET naglow
	push	OFFSET naglow
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie ---------
 	push	OFFSET naglow
	call lstrlenA
	mov rozmN,eax
	
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmN		; liczba znak�w
	push	OFFSET naglow 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA


;;--- zaproszenie A ---------
;	push	OFFSET zaprA
;	push	OFFSET zaprA
;	call	CharToOemA	; konwersja polskich znak�w
;;--- wy�wietlenie zaproszenia A ---
;	push	0		; rezerwa, musi by� zero
;	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
;	push	rozmA		; liczba znak�w
;	push	OFFSET zaprA 	; wska�nik na tekst
; 	push	hout		; deskryptor buforu konsoli
;	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
;;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
;	push	0 		; rezerwa, musi by� zero
;	push	OFFSET rinp 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
;	push	rbuf 		; rozmiar bufora
;	push	OFFSET bufor ;wska�nik na bufor
; 	push	hinp		; deskryptor buforu konsoli
;	call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
;	lea   EBX,bufor
;	mov   EDI,rinp
;	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;;--- przekszta�cenie A
;	push	OFFSET bufor
;	call	ScanInt
;	mov	zmA, EAX

;--- wylosowanie liczby z zakresu 0-zakres ---
    call GetTickCount ;zwraca w czas w milisekundach od ostatniego uruchomienia systemu
	push eax ; 
	call nseed ; ustawienie warto�ci inicuj�cej generator liczb pseudolosowych
	push zakres
	call nrandom ;zwraca w eax liczb� z zakresu 0-zakres
	mov wylosowanaLiczba,EAX

	.repeat
		;mov EAX, odgadnieta

		;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
		push	0 		; rezerwa, musi by� zero
		push	OFFSET rinp 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
		push	rbuf 		; rozmiar bufora
		push	OFFSET bufor ;wska�nik na bufor
 		push	hinp		; deskryptor buforu konsoli
		call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
		lea   EBX,bufor
		mov   EDI,rinp
		mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
	;--- przekszta�cenie odgadnieta
		push	OFFSET bufor
		call	ScanInt
		mov	odgadnieta, EAX

		.if EAX > wylosowanaLiczba
			jmp mniejsza
		.elseif EAX == wylosowanaLiczba
			jmp koniec
		.endif

		;-- wieksza --;

		;--- wyprowadzenie wyniku oblicze� ---
		push	EAX
		push	OFFSET podajWieksza
		push	OFFSET bufor
		call	wsprintfA	; zwraca liczb� znak�w w buforze 
		add	ESP, 12		; czyszczenie stosu
		mov	rinp, EAX	; zapami�tywanie liczby znak�w
	;--- wy�wietlenie wyniku ---------
		push	0 		; rezerwa, musi by� zero
		push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
		push	rinp		; liczba znak�w
		push	OFFSET bufor 	; wska�nik na tekst w buforze
 		push	hout		; deskryptor buforu konsoli
		call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA
		jmp koniec

		mniejsza:
			;--- wyprowadzenie wyniku oblicze� ---
			push	EAX
			push	OFFSET podajMniejsza
			push	OFFSET bufor
			call	wsprintfA	; zwraca liczb� znak�w w buforze 
			add	ESP, 12		; czyszczenie stosu
			mov	rinp, EAX	; zapami�tywanie liczby znak�w
		;--- wy�wietlenie wyniku ---------
			push	0 		; rezerwa, musi by� zero
			push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
			push	rinp		; liczba znak�w
			push	OFFSET bufor 	; wska�nik na tekst w buforze
 			push	hout		; deskryptor buforu konsoli
			call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA

		koniec:
			mov EAX, iloscProb
			inc EAX
			mov iloscProb,EAX

		mov EAX,wylosowanaLiczba
		mov EBX, odgadnieta
	.until EBX == EAX
	
	mov EAX,iloscProb
;;;;	................
;--- wyprowadzenie wyniku oblicze� ---
	push	EAX
	push	OFFSET zwyciestwo
	push	OFFSET bufor
	call	wsprintfA	; zwraca liczb� znak�w w buforze 
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapami�tywanie liczby znak�w
;--- wy�wietlenie wyniku ---------
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	rinp		; liczba znak�w
	push	OFFSET bufor 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA
	

;--- zako�czenie procesu ---------
	push	0
	call	ExitProcess	; wywo�anie funkcji ExitProcess
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScanInt   PROC 
;; funkcja ScanInt przekszta�ca ci�g cyfr do liczby, kt�r� jest zwracana przez EAX 
;; argument - zako�czony zerem wiersz z cyframi 
;; rejestry: EBX - adres wiersza, EDX - znak liczby, ESI - indeks cyfry w wierszu, EDI - tymczasowy 
;--- pocz�tek funkcji 
   push   EBP 
   mov   EBP, ESP   ; wska�nik stosu ESP przypisujemy do EBP 
;--- odk�adanie na stos 
   push   EBX 
   push   ECX 
   push   EDX 
   push   ESI 
   push   EDI 
;--- przygotowywanie cyklu 
   mov   EBX, [EBP+8] 
   push   EBX 
   call   lstrlenA 
   mov   EDI, EAX   ;liczba znak�w 
   mov   ECX, EAX   ;liczba powt�rze� = liczba znak�w 
   xor   ESI, ESI   ; wyzerowanie ESI 
   xor   EDX, EDX   ; wyzerowanie EDX 
   xor   EAX, EAX   ; wyzerowanie EAX 
   mov   EBX, [EBP+8] ; adres tekstu
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0h   ;por�wnanie z kodem \0 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Dh   ;por�wnanie z kodem CR 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Ah   ;por�wnanie z kodem LF 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 02Dh   ;por�wnanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 030h   ;por�wnanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 039h   ;por�wnanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor mo�e zapisa� wynik mno�enia 
   mov   EDI, 10 
   mul   EDI      ;mno�enie EAX * EDI 
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
;--- powr�t 
   mov   ESP, EBP   ; przywracamy wska�nik stosu ESP
   pop   EBP 
   ret	4
ScanInt   ENDP 
_TEXT	ENDS    

END

