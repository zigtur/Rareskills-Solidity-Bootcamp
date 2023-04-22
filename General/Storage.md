# Storage

Sources:
- https://ethereum.github.io/yellowpaper/paper.pdf

## Gas costs

| Action                                         |  Gas price       | Yellow paper reference |
|------------------------------------------------|------------------|------------------------|
| Setting storage from 0 to non-zero             | 20,000           | $G_ {sset}$            |
| Modifying storage (from non-zero to non-zero)  | 5,000 (2,100 + 2,900)| $G_{coldsload}$ + $G_{sreset}$|
| Setting storage from non-zero to zero          | 15,000           | $R_{sclear}$          |
| First time accessing a variable in transaction | 2,100 additional | $G_{coldsload}$        |
| Accessing a variable in transaction            | 100 additional   | $G_{warmaccess}$       |


### Small integers
As storage is expensive, variables storage is optimized.

In memory, two `uint8` variables will be stored in 2 slots of 32 bytes. In storage, those two variables will be packed in 1 slot.

It is not possible to save gas by using small integers in storage, because Ethereum does use 32 bytes slots.


### Unchanged storage values
In a function, if a storage value is read multiple times, but not modified. Then the value can be read only once, and then memory will be cheaper.


### Arrays
Storage dynamic array does store the length of the array, and then the values of the array.

So, when adding a value to the array, gas cost will include writing the value + modifying the length of array.

### Refunds and Setting to Zero
In EIP-3529, some changes have been made:
- `SELFDESTRUCT` refund has been removed
- `SSTORE_CLEARS_SCHEDULE` replaces the 15,000 refund gas by a more complex one (approximately 4,800 gas)
- Max gas refunded = `gas_used // MAX_REFUND_QUOTIENT` with `MAX_REFUND_QUOTIENT = 5`


