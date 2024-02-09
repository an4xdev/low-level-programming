.586
.MODEL FLAT, STDCALL

include grafika.inc

CSstyle		EQU		CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
WNDstyle	EQU		WS_CLIPCHILDREN + WS_OVERLAPPEDWINDOW + WS_HSCROLL+WS_VSCROLL

.data
	hinst		DWORD				0
	msg			MSGSTRUCT			<?> 
	wndc		WNDCLASS			<?>
	
	cname		BYTE				"MainClass", 0
	hwnd		DWORD				0
	hdc			DWORD				0
	tytul		BYTE				"Micha³ ¯uk",0
	nagl		BYTE				"Komunikat", 0
	terr		BYTE				"blad!", 0
	terr2		BYTE				"blad2!", 0
.code

WndProc PROC uses EBX ESI EDI windowHandle:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
 
	INVOKE DefWindowProcA, windowHandle, uMsg, wParam, lParam

ret 
WndProc ENDP

main proc

	;wypelnienie struktury wndc WNDClass
	;pdf 4.1 	

	mov [wndc.clsStyle], CSstyle				;ustawienie 1 pola struktury
	mov [wndc.clsLpfnWndProc], OFFSET WndProc	;ustawieinie 2 pola struktury

	INVOKE GetModuleHandleA, 0
	mov	hinst, EAX
	mov [wndc.clsHInstance], EAX				;ustawieinie 5 pola struktury
	;---------------ustaw reszte pol struktury
	mov [wndc.clsCbClsExtra], 0
	mov [wndc.clsCbWndExtra], 0
	mov [wndc.clsHIcon], 0      
	mov [wndc.clsHCursor], 0       
	mov [wndc.clsHbrBackground], 0       
	mov [wndc.clsLpszMenuName], 0      
	mov DWORD PTR [wndc.clsLpszClassName], OFFSET cname 


	;rejestracja okna z pomoc¹ struktury WNDClass
	INVOKE RegisterClassA, OFFSET wndc
	;obsluga bledow
	.IF EAX == 0
		jmp err0
	.ENDIF

	;utworzenie okna glownego aplikacji
	;pdf 4.8
	INVOKE CreateWindowExA, 0, OFFSET cname, OFFSET tytul, WNDstyle, 50, 50, 400, 400, 0, 0, hinst, 0
	

	;sprawdzenie rejestru eax czy nastapil blad podczas tworzenia okna aplikacji
	.IF EAX == 0
		jmp	err2
	.ENDIF
	;zapis uchwytu do okna glownego do zmiennej, uchwyt w eax
	mov	hwnd, EAX

	;wyswietlenie okna 
	;4.9
	INVOKE ShowWindow, hwnd, SW_SHOWNORMAL

	;jmp etkon

	;ponizej wstawiamy breakpoint by okno nam sie nie zamknelo
	err0:
	 INVOKE MessageBoxA,0,OFFSET terr,OFFSET nagl,0
	 jmp	etkon
	err2:
	 INVOKE MessageBoxA,0,OFFSET terr2,OFFSET nagl,0	
	etkon:

	push 0
	call ExitProcess
main endp

END