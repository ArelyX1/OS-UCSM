#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>

using namespace std;

int main() {
    while (true) {
        system("clear");
        system("ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 15");
        this_thread::sleep_for(chrono::seconds(3));
    }
    return 0;
}
