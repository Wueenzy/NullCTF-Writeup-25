#!/usr/bin/env python3
from fractions import Fraction
from hashlib import sha256
from Cryptodome.Util import number

bits = 2048
a = Fraction(number.getPrime(bits), number.getPrime(bits))

x_vals = [number.getPrime(bits), number.getPrime(bits)]

def frac_square(frac):
    return Fraction(frac.numerator*frac.numerator, frac.denominator*frac.denominator)

def frac_cube(frac):
    return Fraction(frac.numerator**3, frac.denominator**3)


points = []
for x in x_vals:
    y = frac_cube(a) / (x*x + frac_square(a))
    points.append((x, y))

key = sha256(f"{a.numerator}/{a.denominator}".encode()).digest()

flag = b"nullctf{secret}"

ct = bytes([flag[i] ^ key[i % len(key)] for i in range(len(flag))])

print("# points.txt")

lines = []
for x, y in points:
    line = f"x={x}, y={y.numerator}/{y.denominator}"
    print(line)
    lines.append(line)

points_text = "\n".join(lines)

with open("points.txt", "w") as f:
    f.write(points_text)

print()
print("# ciphertext.hex")

cipher_hex = ct.hex()
print(cipher_hex)

with open("ciphertext.hex", "w") as f:
    f.write(cipher_hex)
