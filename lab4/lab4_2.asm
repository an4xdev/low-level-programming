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
;-------------
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji Micha� �uk.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znak�w w tablicy
	zaprA	DB	0Dh,0Ah,"Podaj 8 bitow� liczb� binarn� - argument A [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy
	zmA	DB	1	; argument A
	zaprB	DB	0Dh,0Ah,"Podaj 8 bitow� liczb� binarn� - argument B [+Enter]: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znak�w w tablicy
	zmB	DB	2	; argument B
	zaprC	DB	0Dh,0Ah,"Podaj 8 bitow� liczb� binarn� - argument C [+Enter]: ",0
	ALIGN	4
	rozmC	DD	$ - zaprC	;liczba znak�w w tablicy
	zmC	DB	3	; argument C
	zaprD	DB	0Dh,0Ah,"Podaj 8 bitow� liczb� binarn� - argument D [+Enter]: ",0
	ALIGN	4
	rozmD	DD	$ - zaprD	;liczba znak�w w tablicy
	zmD	DB	4	; argument D
	wzor	DB	0Dh,0Ah,"f(A,B,C,D)= (A AND ~B) AND C XOR D = ",0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmW	DD	$ - wzor	;liczba znak�w w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	rinp	DD	0 ;faktyczna liczba wprowadzonych znak�w
	bufor	DB	128 dup(?)
	rbuf	DD	128
	buforBin BYTE 8 DUP(0),0
_DATA ENDS
;------------
_TEXT SEGMENT
main PROC
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
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmN		; liczba znak�w
	push	OFFSET naglow 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA

;--- zaproszenie A ---------
	push	OFFSET zaprA
	push	OFFSET zaprA
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie zaproszenia A ---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmA		; liczba znak�w
	push	OFFSET zaprA 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
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
;--- przekszta�cenie A
	push	OFFSET bufor
	call	ScanBin
	mov	zmA, AL

;--- zaproszenie B ---------
	push	OFFSET zaprB
	push	OFFSET zaprB
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie zaproszenia A ---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmB		; liczba znak�w
	push	OFFSET zaprB 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
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
;--- przekszta�cenie A
	push	OFFSET bufor
	call	ScanBin
	mov	zmB, AL

;--- zaproszenie C ---------
	push	OFFSET zaprC
	push	OFFSET zaprC
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie zaproszenia A ---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmC		; liczba znak�w
	push	OFFSET zaprC 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
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
;--- przekszta�cenie A
	push	OFFSET bufor
	call	ScanBin
	mov	zmC, AL

;--- zaproszenie D ---------
	push	OFFSET zaprD
	push	OFFSET zaprD
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie zaproszenia A ---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmD		; liczba znak�w
	push	OFFSET zaprD 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
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
;--- przekszta�cenie A
	push	OFFSET bufor
	call	ScanBin
	mov	zmD, AL

;--- wy�wietlenie wersji funkcji---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmW		; liczba znak�w
	push	OFFSET wzor 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA  

	;a = 00001111
	;b = 11110000 -> ~b = 00001111
	;c = 01010101
	;d = 10101010

	;a AND b: 00001111
	;* AND c: 00000101
	;* XOR d: 10101111

	;wynik: 10101111

	;---ToDo obliczenia ---
	;(a AND ~b) AND c XOR d
	mov AL, zmA
	mov BL, zmB
	NOT BL

	AND AL, BL; a and ~b
	mov BL, zmC
	AND AL, BL; (a and ~b) and c

	mov BL, zmD
	XOR AL, BL; (a and ~b) and c xor d
;;;;	................
;--- zapis liczby w al do bufor bin w postaci binarnej ---
mov ecx,8
	mov edi,OFFSET buforBin
L1:	shl al,1
	mov BYTE PTR [edi],'0' ;wstawiamy do bufora kod ASCII 0
	jnc L2 		;jump if not carry - je�eli cf=0 to skok do etykiety L2
	mov BYTE PTR [edi],'1' ;gdy cf=1 wstawiamy jednak do bufora kod 1
L2:	inc edi
	loop L1	;od ecx odejmujemy 1, je�eli nie 0 to skok do etykiety L1

;--- wy�wietlenie wyniku ---------
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	8		; liczba znak�w a nasz rejestr 8 bitowy
	push	OFFSET buforBin 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA
;--- zako�czenie procesu ---------
	push	0
	call	ExitProcess	; wywo�anie funkcji ExitProcess
main ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScanBin  PROC 
;; funkcja ScanInt przekszta�ca ci�g cyfr dziesi�tnych do liczby, kt�r� jest zwracana przez EAX 
;; argument - zako�czony zerem wiersz z cyframi 
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
   cmp   BYTE PTR [EBX+ESI], 031h   ;por�wnanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
   push   EDX   ; do EDX procesor mo�e zapisa� wynik mno�enia 
   mov   EDI, 2 
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
ScanBin   ENDP 
_TEXT	ENDS    

END 

