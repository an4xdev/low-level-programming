.586P
.MODEL FLAT, STDCALL
lstrlenA PROTO :DWORD
PUBLIC ScanInt
_TEXT SEGMENT
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

_TEXT ENDS
END