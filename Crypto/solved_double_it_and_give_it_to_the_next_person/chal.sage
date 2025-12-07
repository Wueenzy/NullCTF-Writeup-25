p = 2**256-2**224+2**192+2**96-1
a = -3
b = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b

Zp = Zmod(p)
P256 = EllipticCurve(Zp, [a, b])

key1 = Zp.random_element()
key2 = Zp.random_element()

with open('output.txt', 'w') as f:
    for _ in range(2):
        P = P256.random_point()
        Q = 2*P

        b = Zp.random_element()
        a = (P.xy()[0] - b) / key1

        d = Zp.random_element()
        c = (Q.xy()[0] - d) / key2

        f.write(f"P.x = {a} * key1 + {b}\n")
        f.write(f"Q.x = {c} * key2 + {d}\n")

with open('flag', 'w') as f:
    key = int(key1) ^^ int(key2)
    f.write(f"nullctf{{{key:064x}}}")