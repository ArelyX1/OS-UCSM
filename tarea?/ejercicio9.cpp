#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>

using namespace std;

int main() {
    cout << "Current processes:" << std::endl;
    system("ps -e -o pid,cmd,%mem,%cpu --sort=-%mem | head -20");

    string process_name;
    cout << "Enter the process name to monitor: ";
    cin >> process_name;

    while (true) {
        system("clear");
        cout << "Monitoring process: " << process_name << endl;
        int result = system(("ps -C " + process_name + " -o pid,%cpu,%mem --no-headers").c_str());
        if (result != 0) {
            cout << process_name << " is not running" << std::endl;
        }
        this_thread::sleep_for(chrono::seconds(1));
    }

    return 0;
}
