.386
.MODEL flat, STDCALL
;---prototypy ---
ExitProcess PROTO :DWORD
;--- procedura w naszej bibliotece ----
ScanInt PROTO

_DATA SEGMENT
	bufor db "12",0
_DATA ENDS
;------------
_TEXT SEGMENT
main proc

	push OFFSET BUFOR
	call ScanInt
	mov EBX, EAX

	push	0
	call	ExitProcess	
main endp
_TEXT	ENDS    

END

