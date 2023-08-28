p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f

def isSecp256k1(n):
    x = n[0]
    y = n[1]
    return (y ** 2) % p == (x ** 3 + 7) % p


if __name__ == '__main__':
    # should print false
    print(isSecp256k1([10101, 7897897]))
    # should print true
    print(isSecp256k1([0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8]))



