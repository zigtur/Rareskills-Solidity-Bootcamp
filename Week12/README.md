# Week12

## RareSkills Huff Puzzles

Here are my solutions for the Huff Puzzles. An explanation will be given when I think it is needed.

All my work can be found here: https://github.com/zigtur/RareSkills-huff-puzzles


For the opcodes, see: https://www.evm.codes/

### Return1

Solution
```solidity
#define macro MAIN() = takes(0) returns(0) {
    0x01
    0x00
    mstore

    0x20
    0x00
    return
}
```

### CallValue
Solution:
```solidity
#define macro MAIN() = takes(0) returns(0) {
    // Store calldata size in memory
    callvalue           // This will store calldatasize on stack
    0x00                // memory offset
    mstore

    0x20                // size
    0x00                // memory offset
    return

}
```

### CalldataLength
Solution:
```solidity
#define macro MAIN() = takes(0) returns(0) {
    // Store calldata size in memory
    calldatasize        // This will store calldatasize on stack
    0x00                // Memory offset
    mstore

    // Return value stored in memory
    0x20                // size
    0x00                // Memory offset
    return
}
```

### MyEtherBalance
Solution:
```solidity
#define macro MAIN() = takes(0) returns(0) {
   caller               // push caller balance on stack
   balance              // pop caller on stack and push caller's balance on stack
   0x00                 // push 0x00 (memory offset)
   mstore               // store in memory

    // Return value stored in memory
   0x20                 // size
   0x00                 // Memory offset
   return
}
```

### Add1
The selector handling is pretty simple. Take the first 4 bytes of calldata, and check if it is equal to the selector. If it is, jump to addition code. Otherwise, revert.

Solution:
```solidity
#define macro MAIN() = takes(0) returns(0) {
    // get 4 first bytes
    0x00
    calldataload
    0xe0
    shr

    // add1(uint256) selector
    __FUNC_SIG(add1)
    eq
    addition
    // if selector is add1, jump to addition
    jumpi

    // revert otherwise
    0x00
    0x00
    revert

    addition:
        // Copy first argument in memory
        0x20
        0x04
        0x00
        calldatacopy

        // Load from memory
        0x00
        mload
        // Add 1
        0x01
        add

        // Store the result in memory
        0x00
        mstore

        // Return the value
        0x20
        0x00
        return
}
```

### Multiply
The code does not work, because Huff is bugged? Investigation in EVM playground shows that the end JUMPI does jump on REVERT opcode, and not JUMPDEST. 

Solution:
```solidity
#define function multiply(uint256, uint256) payable returns(uint256)


#define macro MAIN() = takes(0) returns(0) {
    // get 4 first bytes
    0x00
    calldataload
    0xe0
    shr

    // multiply(uint256, uint256) selector
    __FUNC_SIG(multiply)
    eq
    multiplication
    // if selector is multiply, jump to multiplication
    jumpi

    // revert otherwise
    0x00
    0x00
    revert

    multiplication:
        // Copy first argument in memory
        0x20
        0x04
        0x00
        calldatacopy
        
        // Copy second argument in memory
        0x20
        0x24
        0x20
        calldatacopy

        // load both argument a and check != 0
        0x00
        mload
        dup1
        0x00
        eq
        zero_case
        jumpi

        // load both argument b and check != 0
        0x20
        mload
        dup1
        0x00
        eq
        zero_case
        jumpi

        // multiply (c = a * b)
        mul
        dup1

        // load first argument (a) and divide result by it
        // c / a
        0x00
        mload
        swap1
        div

        // b == c / a ?
        0x20
        mload
        eq

        end
        jumpi

        0x6f766572666c6f77 0x40 mstore
        0x20 0x40 revert

    // push zero before end
    zero_case:
        0x00

    end:
        // store result and return
        0x40
        mstore

        0x20
        0x40
        return

}
```

### NonPayable
Solution:
```solidity


```

### FooBar
Solution:
```solidity


```