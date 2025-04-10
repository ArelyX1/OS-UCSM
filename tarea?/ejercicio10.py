import os
import time

while True:
    # Get processes using more than 80% CPU
    processes = os.popen("ps -eo pid,%cpu --no-headers | awk '$2 > 80 {print $1}'").read().strip().split("\n")
    
    for pid in processes:
        if pid:  # Ensure PID is not empty
            print(f"Killing process with PID: {pid} (CPU > 80%)")
            os.system(f"kill -9 {pid}")
    
    time.sleep(5)
