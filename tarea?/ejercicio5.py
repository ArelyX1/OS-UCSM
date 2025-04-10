import os
import time

while True:
    os.system("clear")
    os.system("ps -e -o pid,uname,cmd,%mem,%cpu --sort=-%cpu | head -15")
    time.sleep(1)
