; ##########################################
  .586P
  .model flat, stdcall
  option casemap :none   ; case sensitive
;constants from fpu.inc
	SRC1_FPU    EQU   1
	SRC1_REAL   EQU   2
	SRC1_DMEM   EQU   4
	SRC1_DIMM   EQU   8
	SRC1_CONST  EQU   16

	ANG_DEG     EQU   0
	ANG_RAD     EQU   32

	DEST_MEM    EQU   0
	DEST_IMEM   EQU   64
	DEST_FPU    EQU   128

	SRC2_FPU    EQU   256
	SRC2_REAL   EQU   512
	SRC2_DMEM   EQU   1024
	SRC2_DIMM   EQU   2048
	SRC2_CONST  EQU   4096
; ##########################################
;prototypes from fpu.lib
	FpuAtoFL    PROTO :DWORD,:DWORD,:DWORD
	FpuFLtoA    PROTO :DWORD,:DWORD,:DWORD,:DWORD
;prototypes from masm32.lib
	StripLF      PROTO :DWORD
	StdIn        PROTO :DWORD,:DWORD
	StdOut       PROTO :DWORD
	CharToOemA   PROTO :DWORD, :DWORD
;others
	ExitProcess  PROTO :DWORD

	includelib masm32.lib
	includelib Fpu.lib
; ##########################################
.data
	x	REAL10	0.0
	y	REAL10	0.0
	wynik REAL10 0.0
	bufor        db    128 dup(0)
	rozmiarbufora dd 128
	komunikat1 db 'Podaj pierwsz¹ liczbê rzeczywist¹ (. jako reparator): ',0
	komunikat2 db 'Podaj drug¹ liczbê rzeczywist¹ (. jako reparator): ',0
	
	komunikatWynik db 'Suma liczb wynosi : ',0
.code

main proc
	invoke	CharToOemA,OFFSET komunikat1,OFFSET komunikat1
	invoke	StdOut,OFFSET komunikat1

	invoke StdIn, OFFSET bufor, rozmiarbufora
	invoke StripLF, OFFSET bufor
;konwresja bufora na typ REAL10 i zapis w zmiennnej x
    invoke FpuAtoFL, ADDR bufor, ADDR x, DEST_MEM

	invoke	CharToOemA,OFFSET komunikat2,OFFSET komunikat2
	invoke	StdOut,OFFSET komunikat2

	invoke StdIn, OFFSET bufor, rozmiarbufora
	invoke StripLF, OFFSET bufor
;konwresja bufora na typ REAL10 i zapis w zmiennnej y
    invoke FpuAtoFL, ADDR bufor, ADDR y, DEST_MEM

    fld x
	fld y; ³adowanie sta³ej pi na wierzcho³ek stosu, wtedy a w st(1)
	faddp st(1),st(0); Dodawanie ST(1) do ST(0) i zdejmij wierzcho³ek stosu (przesuwanie stosu)
    fstp wynik
;kowersja wyninku na napis result z  6 cyframi po przecinku
	invoke	StdOut,OFFSET komunikatWynik
    invoke FpuFLtoA, ADDR wynik, 6, ADDR bufor, SRC1_REAL or SRC2_DIMM
    invoke StdOut,OFFSET bufor;
koniec:
    invoke ExitProcess, 0

main endp
END
