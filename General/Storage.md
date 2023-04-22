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


#### Array Length
If we have to loop through an array, we can cache the array length, so we do read it only once. But it does not work if array length is modified during the loop.

### Refunds and Setting to Zero
In EIP-3529, some changes have been made:
- `SELFDESTRUCT` refund has been removed
- `SSTORE_CLEARS_SCHEDULE` replaces the 15,000 refund gas by a more complex one (approximately 4,800 gas)
- Max gas refunded = `gas_used // MAX_REFUND_QUOTIENT` with `MAX_REFUND_QUOTIENT = 5`


#### Summary
- Setting to zero can cost between 200 and 5000 gas
- Deleting an array (or setting values to zero) can be expensive. Beware of the 20% rule.
- For every zero operation, try to spend 24,000 gas eslewhere to save gas
- Counting down is more efficient than counting up.


### Variable packing
Several variables can be packed into one storage slot.



### Memory vs Calldata
When passing some bytes as argument, the dev can choose between memory and calldata to store the argument.

The memory is more expensive than the calldata. 

But calldata can not be changed, it is read-only. Memory can be modified. 

So, to optimize code:
- Use memory if data is modified
- Use calldata if data is not modified and does not need to be stored in memory


#### Memory
The more memory, the more gas fees. It is linear at the beginning, but does increase quadratically until reaching the max gas in a block (32 million).


### Solidity Tricks
#### Less Than vs Less Than or Equal To
EVM does have two opcodes:
- LT
- GT

In Solidity, `<` and `>` are always more gas efficient than `<=` and `>=`. `<=` and `>=` require two opcodes (LT/GT and ISZERO).

#### Revert early
Transactions that reverts have to pay gas for executed code. The non executed code after the revert will not consume gas. The require statements must so be at the beginning of the code, to optimized gas.

Any state changing before a revert gets undone.

#### Precomputing
Some precomputing are made by compiler. However, it is not 100% efficient. Sometimes, static values will not be hardcoded and will be calculated during contract execution.

Being careful about this can improve gas cost efficiency.
