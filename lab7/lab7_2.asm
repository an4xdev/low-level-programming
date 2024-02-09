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
DoMath PROTO
;ScanInt PROTO :DWORD
;------------------------------------------
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji .... Jan Masztalski.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znak�w w tablicy
	zaprA	DB	0Dh,0Ah,"Prosz� wprowadzi� argument A [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy
	zmA	DD	1	; argument A
	zaprB	DB	0Dh,0Ah,"Prosz� wprowadzi� argument B [+Enter]: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znak�w w tablicy
	zmB	DD	2	; argument B
	zaprC	DB	0Dh,0Ah,"Prosz� wprowadzi� argument C [+Enter]: ",0
	ALIGN	4
	rozmC	DD	$ - zaprC	;liczba znak�w w tablicy
	zmC	DD	3	; argument C
	zaprD	DB	0Dh,0Ah,"Prosz� wprowadzi� argument D [+Enter]: ",0
	ALIGN	4
	rozmD	DD	$ - zaprD	;liczba znak�w w tablicy
	zmD	DD	4	; argument D
	wzor	DB	0Dh,0Ah,"Funkcja f(A,B,C,D) = (A - B) * C / D = %ld",0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmW	DD	$ - wzor	;liczba znak�w w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	rinp	DD	0 ;faktyczna liczba wprowadzonych znak�w
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
;--- pobranie uchwyt�w do wyj i wej
	ReturnDescryptor STD_OUTPUT_HANDLE, hout ;przyk�ad u�ycia makra
	ReturnDescryptor STD_INPUT_HANDLE, hinp ;przyk�ad u�ycia tego samego makra z innymi parametrami

;--- nag��wek ---------
	ConvertAndWrite OFFSET naglow, hout, rozmN, rout
;--- zaproszenie A ---------
	ConvertAndWrite OFFSET zaprA, hout, rozmA, rout
;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;--- przekszta�cenie A
	ConvertToInt bufor, zmA

;--- zaproszenie B ---------
	ConvertAndWrite OFFSET zaprB, hout, rozmB, rout
;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;--- przekszta�cenie A
	ConvertToInt bufor, zmB

;--- zaproszenie C ---------
	ConvertAndWrite OFFSET zaprC, hout, rozmC, rout
;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;--- przekszta�cenie A
	ConvertToInt bufor, zmC

;--- zaproszenie D ---------
	ConvertAndWrite OFFSET zaprD, hout, rozmD, rout
;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
	invoke ReadConsoleA, hinp, OFFSET bufor, rbuf, OFFSET rinp, 0
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;--- przekszta�cenie A
	ConvertToInt bufor, zmD

;--- obliczenia ---

	; a = 10
	; b = 5
	; c = 4
	; d = -2
	; (10-5) * 4 / (-2) = 5 * 4 / (-2) = 20 / (-2) = -10

	invoke DoMath
	
;;;;	................
;--- wyprowadzenie wyniku oblicze� ---
	invoke wsprintfA, OFFSET bufor, OFFSET wzor, EAX
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapami�tywanie liczby znak�w
;--- wy�wietlenie wyniku ---------
	invoke WriteConsoleA, hout, OFFSET bufor, rinp, OFFSET rout, 0
;--- zako�czenie procesu ---------
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
   mov   EBX, [EBP+8] ; adres tekstu do zamiany na liczb�
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0  ;por�wnanie z kodem 0 - koniec �a�cucha znak�w
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
   cmp   BYTE PTR [EBX+ESI], '-'   ;por�wnanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], '0'   ;por�wnanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], '9'   ;por�wnanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor mo�e zapisa� wynik mno�enia 
   mov   EDI, 10 
   mul   EDI      ;mno�enie EAX * EDI 
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
;--- powr�t 
   mov   ESP, EBP   ; przywracamy wska�nik stosu ESP
   pop   EBP 
   ret 4
ScanInt   ENDP 

_TEXT	ENDS    

END main

END