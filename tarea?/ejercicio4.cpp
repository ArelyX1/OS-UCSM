#include <iostream>
using namespace std;

int main() {
    int num, sum = 0;
    while (cout << "Ingresa un número: ", cin >> num, num != 0 && sum < 10)
        sum += num;
    cout << "La suma total es: " << sum << endl;
    return 0;
}
