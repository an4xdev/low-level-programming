#include <iostream>
using namespace std;

char printableChars[95] = {
        ' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?',
        '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
        'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_',
        '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
        'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~'
};

static void func()
{
    int count = 0;
    for (size_t i = 0; i < 95; i++)
    {
        count = 0;
        char temp = printableChars[i];
        temp -= 32;
        while (temp > 10)
        {
            count++;
            temp -= 10;
        }
        cout << "To encrypt: " << printableChars[i] << " -> row: " << count << ", col: " << char(temp + 48) << ", decrypted: " << char(count * 10 + temp + 32) << endl;
    }
}
int main()
{
    func();
}