;Aplikacja korzystaj�ca z otwartego okna konsoli
.MODEL flat, STDCALL
;----------- sta�e
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
;----------- koniec deklaracji sta�ych

;----------- prototypy metod
ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
CharToOemA	  PROTO :DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
lstrlenA PROTO :DWORD
wsprintfA PROTO C :VARARG
;----------- konie� prototyp�w metod

;------------- these are included by default in linker settings 
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------


;------------- pocz�tek segmentu danych w k�trym alokujemy miejsca w pami�ci
.data
	printed			dword	0 ;bufor do przechowywania liczby wy�wietlonych znak�w
	inserted		dword	0 ;bufor do przechowywania liczby wprowadzonych znak�w


	header			byte	"Autor: Micha� �uk.",0
	sizeH			dword	$ - header

	introdution1	byte	0Dh,0Ah,"Wprowad� liczb� a: ",0
	sizeI1			dword	$ - introdution1

	introdution2	byte	0Dh,0Ah,"Wprowad� liczb� b: ",0
	sizeI2			dword	$ - introdution2

	introdution3	byte	0Dh,0Ah,"Wprowad� liczb� c: ",0
	sizeI3			dword	$ - introdution3

	introdution4	byte	0Dh,0Ah,"Wprowad� liczb� d: ",0
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

;------------- pocz�tek segmentu kodu
.code
	main proc ;pocz�tek procedury g��wnej, kt�rej nazwe okre�lili�my wcze�niej w parametrach linkera
			
			;pobranie uchwyt�w do okna
			push STD_INPUT_HANDLE
			call GetStdHandle
			mov cin, eax 
	
			push STD_OUTPUT_HANDLE
			call GetStdHandle
			mov cout, eax 
			;konie� pobierania uchwyt�w

;----------- wy�wietlanie informacji o autorze aplikacji
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

;----------- wy�wietlenie zaproszenia do wprowadzenia parametru A
			push offset introdution1
			push offset introdution1
			call CharToOemA	

			push 0
			push offset printed
			push sizeI1
			push offset introdution1
			push cout
			call WriteConsoleA
;----------- koniec wy�wietlania zaproszenia

;----------- zczytanie parametru A z klawiatury 
			push	0 		; rezerwa, musi by� zero
			push	OFFSET inserted 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska�nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
		;--- przekszta�cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varA, EAX
;----------- koniec zczytywania parametru A z klawiatury

;----------- wy�wietlenie zaproszenia do wprowadzenia parametru B
			push offset introdution2
			push offset introdution2
			call CharToOemA	

			push 0
			push offset printed
			push sizeI2
			push offset introdution2
			push cout
			call WriteConsoleA
;----------- koniec wy�wietlania zaproszenia

;----------- zczytanie parametru B z klawiatury 
			push	0 		; rezerwa, musi by� zero
			push	OFFSET inserted 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska�nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
		;--- przekszta�cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varB, EAX
;----------- koniec zczytywania parametru B z klawiatury



;----------- wy�wietlenie zaproszenia do wprowadzenia parametru C
			push offset introdution3
			push offset introdution3
			call CharToOemA	

			push 0
			push offset printed
			push sizeI3
			push offset introdution3
			push cout
			call WriteConsoleA
;----------- koniec wy�wietlania zaproszenia

;----------- zczytanie parametru C z klawiatury 
			push	0 		; rezerwa, musi by� zero
			push	OFFSET inserted 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska�nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
		;--- przekszta�cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varC, EAX
;----------- koniec zczytywania parametru C z klawiatury

;----------- wy�wietlenie zaproszenia do wprowadzenia parametru D
			push offset introdution4
			push offset introdution4
			call CharToOemA	

			push 0
			push offset printed
			push sizeI2
			push offset introdution4
			push cout
			call WriteConsoleA
;----------- koniec wy�wietlania zaproszenia

;----------- zczytanie parametru D z klawiatury 
			push	0 		; rezerwa, musi by� zero
			push	OFFSET inserted 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wska�nik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
		;--- przekszta�cenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varD, EAX
;----------- koniec zczytywania parametru D z klawiatury

;D-C/A/B
			
			
			; przeniesienie varC do EAX bo DIV -> EAX dzieli podany argument
			mov EAX, varC
			; wyczyszczenie EDX - tam jest po�owa wyniku xD
			mov EDX, 0
			; dzielenie -> wynik w rejestrach EDX i EAX
			DIV varA ; EAX -> C/A

			MOV EDX, 0
			; w varA wynik dodawania
			DIV varB ;EAX -> C/A/B

			MOV EBX, varD
			
			SUB EBX, EAX; EBX -> D-C/A/B

			MOV EAX, EBX

;----------- ��czenie string�w
			push	EAX
			push	OFFSET function
			push	OFFSET bufor
			call	wsprintfA	; zwraca liczb� znak�w w buforze 
			mov	inserted, EAX	; zapami�tywanie liczby znak�w (tutaj by�a zamiana tej i ost linijki)
			add	ESP, 12		; czyszczenie stosu, czemu?
;----------- koniec ��czenia string�w

;----------- wy�wietlenie wyniku 
	push	0 		; rezerwa, musi by� zero
	push	OFFSET printed 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	inserted		; liczba znak�w
	push	OFFSET bufor 	; wska�nik na tekst w buforze
 	push	cout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA
;----------- koniec wy�wietlenia wyniku 



			push 0
			call ExitProcess

	main endp ;koniec procedury g��wnej

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
	@@: ;etykieta anonimowa
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

END