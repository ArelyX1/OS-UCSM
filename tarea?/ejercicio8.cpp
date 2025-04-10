#include <iostream>
#include <cstdlib>

using namespace std;

int main() {
    string username;
    cout << "Enter username: ";
    cin >> username;
    string command = "ps -u " + username + " -o pid,cmd,%mem,%cpu --sort=-%mem";
    system(command.c_str());
    return 0;
}
