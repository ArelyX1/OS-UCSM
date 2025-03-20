import datetime
import time


while True:
    ahora = datetime.datetime.now()

    now = str(ahora)

    print("Hora actual: " + now, end='\r')
    time.sleep(1)

