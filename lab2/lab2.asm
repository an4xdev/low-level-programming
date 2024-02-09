;Aplikacja korzystaj¹ca z otwartego okna konsoli
.MODEL flat, STDCALL
;----------- sta³e
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
;----------- koniec deklaracji sta³ych

;----------- prototypy metod
ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
CharToOemA	  PROTO :DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
lstrlenA PROTO :DWORD
wsprintfA PROTO C :VARARG
;----------- konieæ prototypów metod

;------------- these are included by default in linker settings 
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------


;------------- pocz¹tek segmentu danych w kótrym alokujemy miejsca w pamiêci
.data
	printed			dword	0 ;bufor do przechowywania liczby wyœwietlonych znaków
	inserted		dword	0 ;bufor do przechowywania liczby wprowadzonych znaków


	header			byte	"Autor: Micha³ ¯uk.",0
	sizeH			dword	$ - header

	introdution1	byte	0Dh,0Ah,"WprowadŸ liczbê a: ",0
	sizeI1			dword	$ - introdution1

	introdution2	byte	0Dh,0Ah,"WprowadŸ liczbê b: ",0
	sizeI2			dword	$ - introdution2

	introdution3	byte	0Dh,0Ah,"WprowadŸ liczbê c: ",0
	sizeI3			dword	$ - introdution3

	introdution4	byte	0Dh,0Ah,"WprowadŸ liczbê d: ",0
	sizeI4			dword	$ - introdution4

	function		byte	0Dh,0Ah,"Funkcja f(A,B,C,D) = D-C/A/B = %ld",0 
	sizeF			dword	$ - function

	varA			dword	0
	varB			dword	0
	varC			dword	0
	varD			dword	0

	cin				dword	?
	cout			dword	?

	bufor			byte	128 dup(?)
	rbuf			dword	128

;------------- koniec segmentu danych

;------------- pocz¹tek segmentu kodu
.code
	main proc ;pocz¹tek procedury g³ównej, której nazwe okreœliliœmy wczeœniej w parametrach linkera
			
			;pobranie uchwytów do okna
			push STD_INPUT_HANDLE
			call GetStdHandle
			mov cin, eax 
	
			push STD_OUTPUT_HANDLE
			call GetStdHandle
			mov cout, eax 
			;konieæ pobierania uchwytów

;----------- wyœwietlanie informacji o autorze aplikacji
			push offset header
			push offset header
			call CharToOemA	

			push 0
			push offset printed
			push sizeH
			push offset header
			push cout
			call WriteConsoleA
;----------- koniec informacji o autorze aplikacji

;----------- wyœwietlenie zaproszenia do wprowadzenia parametru A
			push offset introdution1
			push offset introdution1
			call CharToOemA	

			push 0
			push offset printed
			push sizeI1
			push offset introdution1
			push cout
			call WriteConsoleA
;----------- koniec wyœwietlania zaproszenia

;----------- zczytanie parametru A z klawiatury 
			push	0 		; rezerwa, musi byæ zero
			push	OFFSET inserted 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska¿nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
		;--- przekszta³cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varA, EAX
;----------- koniec zczytywania parametru A z klawiatury

;----------- wyœwietlenie zaproszenia do wprowadzenia parametru B
			push offset introdution2
			push offset introdution2
			call CharToOemA	

			push 0
			push offset printed
			push sizeI2
			push offset introdution2
			push cout
			call WriteConsoleA
;----------- koniec wyœwietlania zaproszenia

;----------- zczytanie parametru B z klawiatury 
			push	0 		; rezerwa, musi byæ zero
			push	OFFSET inserted 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska¿nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
		;--- przekszta³cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varB, EAX
;----------- koniec zczytywania parametru B z klawiatury



;----------- wyœwietlenie zaproszenia do wprowadzenia parametru C
			push offset introdution3
			push offset introdution3
			call CharToOemA	

			push 0
			push offset printed
			push sizeI3
			push offset introdution3
			push cout
			call WriteConsoleA
;----------- koniec wyœwietlania zaproszenia

;----------- zczytanie parametru C z klawiatury 
			push	0 		; rezerwa, musi byæ zero
			push	OFFSET inserted 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska¿nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
		;--- przekszta³cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varC, EAX
;----------- koniec zczytywania parametru C z klawiatury

;----------- wyœwietlenie zaproszenia do wprowadzenia parametru D
			push offset introdution4
			push offset introdution4
			call CharToOemA	

			push 0
			push offset printed
			push sizeI2
			push offset introdution4
			push cout
			call WriteConsoleA
;----------- koniec wyœwietlania zaproszenia

;----------- zczytanie parametru D z klawiatury 
			push	0 		; rezerwa, musi byæ zero
			push	OFFSET inserted 	; wskaŸnik na faktyczn¹ liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska¿nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo³anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na koñcu tekstu
		;--- przekszta³cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varD, EAX
;----------- koniec zczytywania parametru D z klawiatury

;D-C/A/B
			
			
			; przeniesienie varC do EAX bo DIV -> EAX dzieli podany argument
			mov EAX, varC
			; wyczyszczenie EDX - tam jest po³owa wyniku xD
			mov EDX, 0
			; dzielenie -> wynik w rejestrach EDX i EAX
			DIV varA ; EAX -> C/A

			MOV EDX, 0
			; w varA wynik dodawania
			DIV varB ;EAX -> C/A/B

			MOV EBX, varD
			
			SUB EBX, EAX; EBX -> D-C/A/B

			MOV EAX, EBX

;----------- £¹czenie stringów
			push	EAX
			push	OFFSET function
			push	OFFSET bufor
			call	wsprintfA	; zwraca liczbê znaków w buforze 
			mov	inserted, EAX	; zapamiêtywanie liczby znaków (tutaj by³a zamiana tej i ost linijki)
			add	ESP, 12		; czyszczenie stosu, czemu?
;----------- koniec ³¹czenia stringów

;----------- wyœwietlenie wyniku 
	push	0 		; rezerwa, musi byæ zero
	push	OFFSET printed 	; wskaŸnik na faktyczn¹ liczbê wyprowadzonych znaków 
	push	inserted		; liczba znaków
	push	OFFSET bufor 	; wskaŸnik na tekst w buforze
 	push	cout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA
;----------- koniec wyœwietlenia wyniku 



			push 0
			call ExitProcess

	main endp ;koniec procedury g³ównej

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
	@@: ;etykieta anonimowa
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

END