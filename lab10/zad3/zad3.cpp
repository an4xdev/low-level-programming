#include <iostream>
#include <chrono>

using namespace std;

extern "C" {
    void __stdcall FillBuffor(char* bufor);
}

char b[4000];
char c[4000];

int main()
{
    cout << "Zad4" << endl;
    chrono::steady_clock::time_point begin = chrono::steady_clock::now();
    FillBuffor(b);
    chrono::steady_clock::time_point end = chrono::steady_clock::now();
    cout << "roznica: " << chrono::duration_cast<chrono::nanoseconds>(end - begin).count()<<" nano sekund" << endl;

    chrono::steady_clock::time_point begin1 = chrono::steady_clock::now();
    for (size_t i = 0; i < 4000; i++)
    {
        c[i] = ' ';
    }
    chrono::steady_clock::time_point end1 = chrono::steady_clock::now(); cout << "roznica2: " << chrono::duration_cast<chrono::nanoseconds>(end1 - begin1).count() << " nano sekund" << endl;
}

