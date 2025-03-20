import datetime
import time

ahora = datetime.datetime.now()
objetivo = ahora.replace(hour=6, minute=53, second=0, microsecond=0)

if ahora >= objetivo:
    objetivo += datetime.timedelta(days=1)
    
while True:
    ahora = datetime.datetime.now()
    if ahora >= objetivo:
        print("\n¡Ya son las 7 am!")
        break
    restante = objetivo - ahora
    hora_restante = str(restante)

    print("Tiempo restante: " + hora_restante, end='\r')
    time.sleep(1)

