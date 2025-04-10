sum = 0
while (num := int(input("Ingresa un número: "))) != 0 and sum < 10:
    sum += num
print(f"La suma total es: {sum}")
