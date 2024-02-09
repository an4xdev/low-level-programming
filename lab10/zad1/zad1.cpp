#include <iostream>

using namespace std;

int a, b, c, wynik;

int main()
{
    // 25*A - 4*A*B - C
    cout << "Zad1" << endl;
    cout << "Podaj a:" << endl;
    cin >> a;
    cout << "Podaj b:" << endl;
    cin >> b;
    cout << "Podaj c:" << endl;
    cin >> c;

    _asm {
        mov EAX, OFFSET a
        mov EBX, OFFSET b
        mov ECX, DWORD PTR[EAX]
        mov EDX, DWORD PTR[EBX]
        push EDX
        mov EAX, 25
        mul ECX
        pop EDX
        // 25*A w EAX
        push EAX
        mov EAX, 4
        push EDX
        mul ECX
        pop EDX
        mul EDX
        // 4*A*B w EAX
        pop EBX
        // 25*A w EBX
        sub EBX, EAX

        mov EAX, OFFSET c
        mov ECX, DWORD PTR[EAX]
        sub EBX, ECX
        mov EDX, OFFSET wynik
        mov DWORD PTR[EDX], EBX
    }

    cout << "25*A - 4*A*B - C: " << wynik << endl;

    return 0;
}
