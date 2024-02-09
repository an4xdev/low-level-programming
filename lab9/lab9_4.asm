.586P
.MODEL flat, STDCALL
;--- pliki ---------
include grafika.inc

;--- sta�e ---
CSstyle EQU CS_HREDRAW+CS_VREDRAW+CS_GLOBALCLASS
BSstyle EQU BS_PUSHBUTTON+WS_VISIBLE+WS_CHILD+WS_TABSTOP
WNDstyle EQU WS_CLIPCHILDREN+WS_OVERLAPPEDWINDOW+WS_HSCROLL+WS_VSCROLL
EDTstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER
CBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_DROPDOWNLIST+CBS_HASSTRINGS
LBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_HASSTRINGS
STATstyle EQU WS_VISIBLE+WS_CHILD+WS_BORDER+SS_LEFT
kolor EQU 000000FFh ; czerwony  ; kolory: G B R
;--- sekcja danych ------
_DATA SEGMENT
 hwnd		DD	0
 hinst	DD	0
 hdc        DD	0
 hbutt	DD	0
 hedt 	DD	0
 hbrush     DD    0
 holdbrush  DD    0
 hcb     	DD	0
 hlb     	DD	0
 hmdi 	DD	0
 hstat 	DD	0
 ;---
 msg MSGSTRUCT <?> 
 wndc WNDCLASS <?>
 ;---
 naglow	DB	"Autor Micha� �uk.",0
 rozmN	DD	$ - naglow	;ilo�� znak�w w tablicy
 ALIGN	4	; przesuniecie do adresu podzielnego na 4
 tytul	DB "Micha� �uk",0
 ALIGN 4
 cname	DB "MainClass", 0
 ALIGN 4
 nagl		DB	"Komunikat", 0
 ALIGN 4
 terr		DB	"B��d!", 0
 ALIGN 4
 terr2	DB	"B��d 2!", 0
 ALIGN 4
 right DB "Klikni�to",0
 ALIGN 4
  tstart	DB	"Przycisk", 0
 ALIGN 4
  tbutt	DB	"BUTTON", 0
 ALIGN 4
 bufor	DB	128 dup(' ')	; bufor ze spacjami
 rbuf		DD	128	; rozmiar buforu
 znaczn     DD    0
_DATA ENDS
;--- sekcja kodu ---------
_TEXT SEGMENT
;;;;;;;;;;;;;;;;;;;;;;;
WndProc PROC
;--- procedura okna ---
; DWORD PTR [EBP+14h] - parametr LPARAM komunikatu
; DWORD PTR [EBP+10h] - parametr WPARAM komunikatu
; DWORD PTR [EBP+0Ch] - ID = identyfikator komunikatu
; DWORD PTR [EBP+08h] - HWND = deskryptor okna
 ;------------------------------------
 push	EBP	; standardowy prolog
 mov	EBP, ESP	; standardowy prolog
;--- odk�adanie na stos
 push	EBX
 push	ESI
 push	EDI
 cmp	DWORD PTR [EBP+0Ch], WM_COMMAND
 jne	@F
 jmp	wmCOMMAND
 @@:
	cmp DWORD PTR [EBP+0CH], WM_CREATE
	jne	@F
	jmp	wmCREATE
 @@:
;--- komunikaty nieobs�ugiwane ---
 INVOKE DefWindowProcA, DWORD PTR [EBP+08h], DWORD PTR [EBP+0Ch], DWORD PTR [EBP+10h], DWORD PTR [EBP+14h]
 jmp	konWNDPROC
 wmCREATE:
	INVOKE CreateWindowExA, 0, OFFSET tbutt, OFFSET tstart,  BSstyle, 10, 50, 100, 40, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hbutt, EAX
wmCOMMAND:
	INVOKE lstrlenA,OFFSET right
	mov rozmN,EAX
	INVOKE TextOutA,hDC,10,20,OFFSET right,rozmN
	INVOKE UpdateWindow, hwnd
	jmp konWNDPROC
 jmp konWNDPROC
;--- zdejmowanie ze stosu
konWNDPROC:	
 pop	EDI
 pop	ESI
 pop	EBX
 pop	EBP	; standardowy epilog
 ret	16	; zwolnienie kom�rek stosu
WndProc	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--- start programu ---
main proc
;--- deskryptor aplikacji ----
 INVOKE GetModuleHandleA, 0
 mov	hinst, EAX
;--- wype�nienie struktury okna WNDCLASS
 mov EAX, hinst
 mov [wndc.clsHInstance], EAX
 mov [wndc.clsStyle], CSstyle
 mov [wndc.clsLpfnWndProc], OFFSET WndProc
 mov [wndc.clsCbClsExtra], 0 
 mov [wndc.clsCbWndExtra], 0 
 INVOKE LoadIconA, 0, IDI_APPLICATION	; ikona
 mov [wndc.clsHIcon], EAX
 INVOKE LoadCursorA, 0,	IDC_ARROW ; kursor
 mov	[wndc.clsHCursor], EAX
 INVOKE GetStockObject, WHITE_BRUSH	; t�o
 mov [wndc.clsHbrBackground], EAX
 mov [wndc.clsLpszMenuName], 0
 mov DWORD PTR [wndc.clsLpszClassName], OFFSET cname
;--- rejestracja okna --- 
 INVOKE RegisterClassA, OFFSET wndc
 cmp	EAX, 0
 jne @F
 jmp	err0
@@:
;--- utworzenie okna g��wnego ---
 INVOKE CreateWindowExA, 0, OFFSET cname, OFFSET tytul,  WNDstyle, 50, 50, 600, 400, 0, 0, hinst, 0
 cmp	EAX, 0
 jne @F
 jmp	err2
@@:
 mov	hwnd, EAX
 INVOKE ShowWindow, hwnd, SW_SHOWNORMAL	
 INVOKE GetDC,hwnd
 mov hdc,EAX
;--- p�tla obs�ugi komunikat�w
msgloop:
 INVOKE GetMessageA, OFFSET msg, 0, 0, 0
 cmp EAX, 0
 jne @F
 jmp	etkon
@@:		
 cmp	EAX, -1
 jne @F
 jmp	err0
@@:		
 INVOKE TranslateMessage, OFFSET msg
 INVOKE DispatchMessageA, OFFSET msg
 jmp	msgloop
;--- obs�uga b��d�w ---------
err0:
;--- okno z komunikatem o b��dzie----
 INVOKE MessageBoxA,0,OFFSET terr,OFFSET nagl,0
 jmp	etkon
err2:
;--- okno z komunikatem o b��dzie----
 INVOKE MessageBoxA,0,OFFSET terr2,OFFSET nagl,0
 jmp	etkon
;--- zako�czenie procesu ---------
etkon:
 INVOKE ExitProcess, [msg.msWPARAM]

 main endp
_TEXT	ENDS
END
