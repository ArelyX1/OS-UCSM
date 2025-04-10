#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>
#include <filesystem>

using namespace std;

bool existFile(string name);

int main(){
    do{
        cout << "No se creo el archivo hw.txt" << endl;
        this_thread::sleep_for(chrono::seconds(1));
        cout << "Buscando en: " << std::filesystem::current_path() << endl;
    }while(! existFile("/home/arelyxl/Downloads/VsCode/Operating_system/Shell/tarea?/hw.txt"));
    cout << "El archivo hw.txt fue creado" << endl;
}

bool existFile(string name){
    ifstream file(name);
    return file.good();
}