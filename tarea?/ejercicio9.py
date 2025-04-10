import os
import time

print("Current processes:")
os.system('ps -e -o pid,cmd,%mem,%cpu --sort=-%mem | head -20')

process_name = input("Enter the process name to monitor: ")

while True:
    os.system("clear")
    print(f"Monitoring process: {process_name}")
    result = os.system(f"ps -C {process_name} -o pid,%cpu,%mem --no-headers")
    if result != 0:
        print(f"{process_name} is not running")
    time.sleep(5)
