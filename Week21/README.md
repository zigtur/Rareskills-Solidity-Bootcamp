# Week21

## Elliptic Curves
Format: $Y^2 = X^3 + a X + b$

### secp256k1
- Order $n = 115792089237316195423570985008687907852837564279074904382605163141518161494337$
    - $n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141$
- Generator $G = (0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)$
- Field $Fp$
    - $p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f$
- $a = 0x0000000000000000000000000000000000000000000000000000000000000000$
- $b = 0x0000000000000000000000000000000000000000000000000000000000000007$


## Homework
### Exercise 1: Given a random point n, is n a valid point on the sepc265k1 curve? Use any language you like. Your function should take n and return true or false. Do not use a library to implement this.

A simple example can be found in [python](./python/secp256k1.py).

### Exercise 2:



