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
DoMath PROTO
;ScanInt PROTO :DWORD
;------------------------------------------
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji .... Jan Masztalski.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znaków w tablicy
	zaprA	DB	0Dh,0Ah,"Proszê wprowadziæ argument A [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy
	zmA	DD	1	; argument A
	zaprB	DB	0Dh,0Ah,"Proszê wprowadziæ argument B [+Enter]: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znaków w tablicy
	zmB	DD	2	; argument B
	zaprC	DB	0Dh,0Ah,"Proszê wprowadziæ argument C [+Enter]: ",0
	ALIGN	4
	rozmC	DD	$ - zaprC	;liczba znaków w tablicy
	zmC	DD	3	; argument C
	zaprD	DB	0Dh,0Ah,"Proszê wprowadziæ argument D [+Enter]: ",0
	ALIGN	4
	rozmD	DD	$ - zaprD	;liczba znaków w tablicy
	zmD	DD	4	; argument D
	wzor	DB	0Dh,0Ah,"Funkcja f(A,B,C,D) = (A - B) * C / D = %ld",0  ;%ld oznacza formatowanie w formacie dziesiêtnym
	ALIGN	4
	rozmW	DD	$ - wzor	;liczba znaków w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków
	bufor	DB	128 dup(?)
	rbuf	DD	128
_DATA ENDS
;------------
_TEXT SEGMENT

ReturnDescryptor MACRO handleConstantIn:REQ, handleOut:REQ
 ;push	handleConstantIn
 ;call	GetStdHandle
 invoke GetStdHandle, handleConstantIn
 mov	handleOut,EAX ;; deskryptor bufora konsoli
ENDM

ConvertToInt MACRO bufor:REQ, zmX:REQ
	push OFFSET bufor
	call ScanInt
	mov zmX, EAX
ENDM

ConvertAndWrite MACRO bufor:REQ, hout:REQ, rozmN:REQ, rout:REQ
	invoke CharToOemA, OFFSET bufor, OFFSET bufor
	invoke WriteConsoleA, hout, OFFSET bufor,rozmN,OFFSET rout,0
ENDM

main proc
;--- pobranie uchwytów do wyj i wej
	ReturnDescryptor STD_OUTPUT_HANDLE, hout ;przyk³ad u¿ycia makra
	ReturnDescryptor STD_INPUT_HANDLE, hinp ;przyk³ad u¿ycia tego samego makra z innymi parametrami

;--- nag³ówek ---------
	ConvertAndWrite OFFSET naglow, hout, rozmN, rout
;--- zaproszenie A ---------
	ConvertAndWrite OFFSET zaprA, hout, rozmA, rout
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	ConvertToInt bufor, zmA

;--- zaproszenie B ---------
	ConvertAndWrite OFFSET zaprB, hout, rozmB, rout
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	ConvertToInt bufor, zmB

;--- zaproszenie C ---------
	ConvertAndWrite OFFSET zaprC, hout, rozmC, rout
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	ConvertToInt bufor, zmC

;--- zaproszenie D ---------
	ConvertAndWrite OFFSET zaprD, hout, rozmD, rout
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
;--- przekszta³cenie A
	ConvertToInt bufor, zmD

;--- obliczenia ---

	; a = 10
	; b = 5
	; c = 4
	; d = -2
	; (10-5) * 4 / (-2) = 5 * 4 / (-2) = 20 / (-2) = -10

	invoke DoMath
	
;;;;	................
;--- wyprowadzenie wyniku obliczeñ ---
	invoke wsprintfA, OFFSET bufor, OFFSET wzor, EAX
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapamiêtywanie liczby znaków
;--- wyœwietlenie wyniku ---------
	invoke WriteConsoleA, hout, OFFSET bufor, rinp, OFFSET rout, 0
;--- zakoñczenie procesu ---------
	invoke ExitProcess, 0
	
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoMath PROC

	mov	EAX, zmA
	mov EBX, zmB

	sub EAX, EBX; EAX = (a-b)
	mov EBX, zmC
	imul EBX; EAX = (a-b) * c
	mov EBX, zmD
	idiv EBX; EAX = (a-b) * c / d

    ret
DoMath endp

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

END main

END