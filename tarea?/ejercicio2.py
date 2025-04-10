import time
from pathlib import Path

filename = Path("/home/arelyxl/Downloads/VsCode/Operating_system/Shell/tarea?/hw.txt").resolve()  # Usamos .resolve() para obtener la ruta absoluta

print(f"Esperando a que se cree el archivo {filename}...")

while not filename.is_file():  
    print("Archivo no encontrado. Reintentando en 1 segundo...")
    time.sleep(1)

print(f"{filename.name} encontrado. Continuando con el procesamiento.")

with open(filename, mode="r") as file:
    print("Contenido del archivo:")
    print(file.read())
