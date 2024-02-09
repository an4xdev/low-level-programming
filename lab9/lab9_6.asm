.586P
.MODEL flat, STDCALL
;--- pliki ---------
include grafika.inc

;--- sta³e ---
CSstyle EQU CS_HREDRAW+CS_VREDRAW+CS_GLOBALCLASS
BSstyle EQU BS_PUSHBUTTON+WS_VISIBLE+WS_CHILD+WS_TABSTOP
WNDstyle EQU WS_CLIPCHILDREN+WS_OVERLAPPEDWINDOW+WS_HSCROLL+WS_VSCROLL
EDTstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER
CBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_DROPDOWNLIST+CBS_HASSTRINGS
LBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_HASSTRINGS
STATstyle EQU WS_VISIBLE+WS_CHILD+WS_BORDER+SS_LEFT
kolor EQU 000000FFh ; czerwony  ; kolory: G B R
IDD_BUTTON1 equ 101
IDD_BUTTON2 equ 102
;--- sekcja danych ------
_DATA SEGMENT
 hwnd		DD	0
 hinst	DD	0
 hdc        DD	0
 hbutt	DD	0
 hbutt2	DD	0
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
 naglow	DB	"Autor Micha³ ¯uk.",0
 rozmN	DD	$ - naglow	;iloœæ znaków w tablicy
 ALIGN	4	; przesuniecie do adresu podzielnego na 4
 tytul	DB "Micha³ ¯uk",0
 ALIGN 4
 cname	DB "MainClass", 0
 ALIGN 4
 tstart	DB	"Przycisk", 0
 ALIGN 4
 tstart2 DB	"Przycisk2", 0
 ALIGN 4
 tbutt	DB	"BUTTON", 0
 ALIGN 4
 tnazwaedt	DB	" ", 0
 ALIGN 4
 nagl		DB	"Komunikat", 0
 ALIGN 4
 terr		DB	"B³¹d!", 0
 ALIGN 4
 terr2	DB	"B³¹d 2!", 0
 ALIGN 4
 tedt	      DB	"EDIT", 0
 ALIGN 4
 ttekst	DB	"tekst", 0
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
;--- odk³adanie na stos
 push	EBX
 push	ESI
 push	EDI
 cmp	DWORD PTR [EBP+0Ch], WM_CREATE
 jne	@F
 jmp	wmCREATE
 @@:
 cmp	DWORD PTR [EBP+0Ch], WM_COMMAND
 jne	@F
 jmp	wmCOMMAND
@@:	
;--- komunikaty nieobs³ugiwane ---
 INVOKE DefWindowProcA, DWORD PTR [EBP+08h], DWORD PTR [EBP+0Ch], DWORD PTR [EBP+10h], DWORD PTR [EBP+14h]
 jmp	konWNDPROC
wmCREATE:
INVOKE CreateWindowExA, 0, OFFSET tbutt, OFFSET tstart,  BSstyle, 10, 50, 100, 40, DWORD PTR [EBP+08h], IDD_BUTTON1, hinst, 0
 mov hbutt, EAX
 INVOKE CreateWindowExA, 0, OFFSET tbutt, OFFSET tstart2,  BSstyle, 10, 150, 100, 40, DWORD PTR [EBP+08h], IDD_BUTTON2, hinst, 0
 mov hbutt2, EAX
 INVOKE CreateWindowExA, 0, OFFSET tedt, OFFSET tnazwaedt,  EDTstyle, 10, 250, 100, 40, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hedt, EAX
 INVOKE SendMessageA, hedt,WM_SETTEXT,0,OFFSET ttekst
 INVOKE SetFocus,hedt
 jmp konWNDPROC
 wmCOMMAND:
 mov eax, DWORD PTR [EBP+10h]
 cmp eax, IDD_BUTTON2
 jne  konWNDPROC
 INVOKE SendMessageA, hedt, WM_GETTEXT, 128, OFFSET bufor
 INVOKE lstrlenA,OFFSET bufor
 mov rozmN,EAX
 INVOKE TextOutA,hDC,150,20,OFFSET bufor,rozmN 		
 INVOKE UpdateWindow, hwnd
 jmp konWNDPROC
;--- zdejmowanie ze stosu
konWNDPROC:	
 pop	EDI
 pop	ESI
 pop	EBX
 pop	EBP	; standardowy epilog
 ret	16	; zwolnienie komórek stosu
WndProc	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--- start programu ---
main proc
;--- deskryptor aplikacji ----
 INVOKE GetModuleHandleA, 0
 mov	hinst, EAX
;--- wype³nienie struktury okna WNDCLASS
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
 INVOKE GetStockObject, WHITE_BRUSH	; t³o
 mov [wndc.clsHbrBackground], EAX
 mov [wndc.clsLpszMenuName], 0
 mov DWORD PTR [wndc.clsLpszClassName], OFFSET cname
;--- rejestracja okna --- 
 INVOKE RegisterClassA, OFFSET wndc
 cmp	EAX, 0
 jne @F
 jmp	err0
@@:
;--- utworzenie okna g³ównego ---
 INVOKE CreateWindowExA, 0, OFFSET cname, OFFSET tytul,  WNDstyle, 50, 50, 700, 700, 0, 0, hinst, 0
 cmp	EAX, 0
 jne @F
 jmp	err2
@@:
 mov	hwnd, EAX
 INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
 INVOKE GetDC,hwnd
 mov hdc,EAX
 INVOKE UpdateWindow, hwnd
;--- pêtla obs³ugi komunikatów
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
;--- obs³uga b³êdów ---------
err0:
;--- okno z komunikatem o b³êdzie----
 INVOKE MessageBoxA,0,OFFSET terr,OFFSET nagl,0
 jmp	etkon
err2:
;--- okno z komunikatem o b³êdzie----
 INVOKE MessageBoxA,0,OFFSET terr2,OFFSET nagl,0
 jmp	etkon
;--- zakoñczenie procesu ---------
etkon:
 INVOKE ExitProcess, [msg.msWPARAM]

 main endp
_TEXT	ENDS
END
