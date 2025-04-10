import os
import time

while True:
    os.system("clear")
    os.system("ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 15")
    time.sleep(3)
