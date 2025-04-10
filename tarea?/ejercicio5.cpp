#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>

int main() {
    while (true) {
        system("clear");
        system("ps -e -o pid,uname,cmd,%mem,%cpu --sort=-%cpu | head -15");
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    return 0;
}
