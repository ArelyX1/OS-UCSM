#include <iostream>
#include <cstdlib>
#include <string>
#include <sstream>

using namespace std;

int main() {
    string result;
    char buffer[128];
    FILE* pipe = popen("ps -e --no-headers | wc -l", "r");
    if (!pipe) return 1;

    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    pclose(pipe);

    istringstream iss(result);
    int process_count;
    iss >> process_count;

    cout << "Total: " << process_count << endl;
    return 0;
}
