#include <iostream>
#include <chrono>
#include <thread>
#include <iomanip>
#include <ctime>

using namespace std;
using namespace chrono;

void contadorHasta7am() {

    auto ahora = system_clock::now();
    time_t tiempoActual = system_clock::to_time_t(ahora);
    tm* tiempoLocal = localtime(&tiempoActual);

    tiempoLocal->tm_hour = 7;
    tiempoLocal->tm_min = 0;
    tiempoLocal->tm_sec = 0;

    auto objetivo = system_clock::from_time_t(mktime(tiempoLocal));

    if (ahora >= objetivo) {
        objetivo += hours(24);
    }

    cout << "Inicio del contador hasta las 7 am.\n\n";

    while (true) {
        ahora = system_clock::now();
        if (ahora >= objetivo) {
            cout << "\n¡Ya son las 7 am!" << endl;
            break;
        }

        auto restante = duration_cast<seconds>(objetivo - ahora);
        int horas = restante.count() / 3600;
        int minutos = (restante.count() % 3600) / 60;
        int segundos = restante.count() % 60;

        cout << "Tiempo que falta: " 
                  << setfill('0') << setw(2) << horas << ":"
                  << setfill('0') << setw(2) << minutos << ":"
                  << setfill('0') << setw(2) << segundos << "\r";
        cout.flush();

        this_thread::sleep_for(seconds(1));
    }
}

int main() {
    contadorHasta7am();
}
