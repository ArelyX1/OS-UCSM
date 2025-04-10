import os

process_count = int(os.popen("ps -e --no-headers | wc -l").read().strip())
print(f"Total: {process_count}")
