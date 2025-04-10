import os

username = input("Enter username: ")
os.system(f"ps -u {username} -o pid,cmd,%mem,%cpu --sort=-%mem")
