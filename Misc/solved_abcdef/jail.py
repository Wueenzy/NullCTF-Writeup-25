abcdef = set("abcdef")

def is_valid(text):
    for c in text:
        if ord(c) < 32 or ord(c) > 126:
            return False
        if c.isalpha() and c not in abcdef:
            return False
    return True

try:
    while True:
        x = input("> ")
        if is_valid(x):
            eval(x)
        else:
            print("[*] Failed.")
except Exception as e:
    print(e)
    pass