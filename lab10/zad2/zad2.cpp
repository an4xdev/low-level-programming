#include <iostream>

using namespace std;

extern "C" {
    int __stdcall DoMath(int a, int b, int c);
}

int a, b, c, wynik;

int main()
{
    // 25*A - 4*A*B - C
    cout << "Zad2" << endl;
    cout << "Podaj a:" << endl;
    cin >> a;
    cout << "Podaj b:" << endl;
    cin >> b;
    cout << "Podaj c:" << endl;
    cin >> c;

    wynik = DoMath(a, b, c);

    cout << "25*A - 4*A*B - C: " << wynik << endl;

    return 0;
}
