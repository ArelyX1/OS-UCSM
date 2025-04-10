#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>
#include <sstream>
#include <vector>

using namespace std;

int main() {
    while (true) {
        FILE* pipe = popen("ps -eo pid,%cpu --no-headers | awk '$2 > 80 {print $1}'", "r");
        if (!pipe) {
            cerr << "Failed to run command." << endl;
            return 1;
        }

        char buffer[128];
        vector<int> pids;
        while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
            pids.push_back(stoi(buffer));
        }
        pclose(pipe);

        for (int pid : pids) {
            cout << "Killing process with PID: " << pid << " (CPU > 80%)" << endl;
            string command = "kill -9 " + to_string(pid);
            system(command.c_str());
        }

        this_thread::sleep_for(chrono::seconds(1));
    }

    return 0;
}
