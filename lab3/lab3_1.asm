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

	zaprA	DB	0Dh,0Ah,"Prosz� wprowadzi� znaki znaki do bufora: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy

	zaprB	DB	0Dh,0Ah,"Bufor po wprowadzeniu danych: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znak�w w tablicy

	zaprC	DB	0Dh,0Ah,"Kopia buforu: ",0
	ALIGN	4
	rozmC	DD	$ - zaprC	;liczba znak�w w tablicy
	ALIGN	4

	zaprD	DB 0Dh,0Ah,"Odwr�cony orygina�: ",0
	ALIGN	4
	rozmD	DD $ - zaprD
	ALIGN	4

	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	rinp	DD	0 ;faktyczna liczba wprowadzonych znak�w

	lZnakow	DD	0 
	bufor	DB	128 dup(?)
	rbuf	DD	128
	bufor2	DB	128 dup(?)
	rbuf2	DD	128
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
	
;--- wy�wietlenie bufora przed zmianami ---------
    push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	rozmB		; liczba znak�w
	push	OFFSET zaprB 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsol
	
	
	push	OFFSET bufor
	call	lstrlenA
	mov	lZnakow, EAX
	
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	lZnakow		; liczba znak�w
	push	OFFSET bufor 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA	
	
	
	;--- wype�nienie bufora2 warto�ci� 0
	lea   EBX,bufor2
	mov   ECX,rbuf2
@@:	mov   BYTE PTR [EBX+ECX-1],0
	loop  @B 
	
	;ToDo: TWOJE DZIA�ANIA NA BUFORZE

	; kopia z buforu do buforu2
	CLD
	MOV ECX, rout
	MOV ESI, OFFSET bufor
	MOV EDI, OFFSET bufor2
	REP MOVSD

	; wrzucanie na stos bufora
	MOV ECX, rout
	MOV EDX, 0
	MOV ESI, OFFSET bufor
	NaStos:
		movzx eax, byte ptr [ESI + EDX]
		push eax                   
		INC EDX        
    loop NaStos  
	
	; �ci�ganie ze stosu do bufora
	MOV ECX, rout
	MOV ESI, OFFSET bufor         
	ZeStosu:
		POP [ESI]
		INC ESI    
    loop ZeStosu

;--- wy�wietlenie kopii bufora po zmianach ---------
    push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	rozmC		; liczba znak�w
	push	OFFSET zaprC 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsol
	
	push	OFFSET bufor2
	call	lstrlenA
	mov	lZnakow, EAX
	
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	lZnakow		; liczba znak�w
	push	OFFSET bufor2 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA

	;--- odr�cony ---------
	push	OFFSET zaprD
	push	OFFSET zaprD
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie ---------
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmD		; liczba znak�w
	push	OFFSET zaprD 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA


	push	OFFSET bufor
	call	lstrlenA
	mov	lZnakow, EAX
	
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	lZnakow		; liczba znak�w
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

