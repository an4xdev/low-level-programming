.586P
.MODEL FLAT, STDCALL
lstrlenA PROTO :DWORD
PUBLIC ScanInt
_TEXT SEGMENT
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

_TEXT ENDS
END