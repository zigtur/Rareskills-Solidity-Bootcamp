# Yul, Assembly and Bytecode

Yul does handle only bytes32 types. So, a variable that is not 32-bytes long is used, then the developer must be careful.


## Yul Code
### Local variable

Writing local memory variable:
```solidity
    function getNumber() external pure returns (uint256) {
        uint256 x;

        assembly {
            x := 42
        }

        return x;
    }
```



### Storage
#### Fixed variable
Reading storage value:
```solidity
    function getVarYul(uint256 slot) external view returns (bytes32 ret) {
        assembly {
            ret := sload(slot)
        }
    }
```


Writing storage value:
```solidity
    function setVarYul(uint256 slot, uint256 value) external {
        assembly {
            sstore(slot, value)
        }
    }
```

Get variable slot value:
```solidity
    function getSlotYul() external pure returns (uint256 retSlot) {
        assembly {
            retSlot := a.slot
        }
    }
```

Get variable offset value (in a slot, could be a uint16 for example):
```solidity
    function getOffsetE() external pure returns (uint256 slot, uint256 offset) {
        assembly {
            slot := E.slot
            offset := E.offset
        }
    }
```

Read variable value that is not 256 bits-long (example with a uint16):
```solidity
    function readE() external view returns (uint256 e) {
        assembly {
            let value := sload(E.slot) // must load in 32 byte increments
            //
            // E.offset = 28
            let shifted := shr(mul(E.offset, 8), value)
            // 0x0000000000000000000000000000000000000000000000000000000000010008
            // equivalent to
            // 0x000000000000000000000000000000000000000000000000000000000000ffff
            e := and(0xffff, shifted)
        }
    }
```


Write variable value that is not 256 bits-long (example with a uint16):
```solidity
    // masks can be hardcoded because variable storage slot and offsets are fixed
    // V and 00 = 00
    // V and FF = V
    // V or  00 = V
    // function arguments are always 32 bytes long under the hood
    function writeToE(uint16 newE) external {
        assembly {
            // newE = 0x000000000000000000000000000000000000000000000000000000000000000a
            let c := sload(E.slot) // slot 0
            // c = 0x0000010800000000000000000000000600000000000000000000000000000004
            let clearedE := and(
                c,
                0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            // mask     = 0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            // c        = 0x0001000800000000000000000000000600000000000000000000000000000004
            // clearedE = 0x0001000000000000000000000000000600000000000000000000000000000004
            let shiftedNewE := shl(mul(E.offset, 8), newE)
            // shiftedNewE = 0x0000000a00000000000000000000000000000000000000000000000000000000
            let newVal := or(shiftedNewE, clearedE)
            // shiftedNewE = 0x0000000a00000000000000000000000000000000000000000000000000000000
            // clearedE    = 0x0001000000000000000000000000000600000000000000000000000000000004
            // newVal      = 0x0001000a00000000000000000000000600000000000000000000000000000004
            sstore(C.slot, newVal)
        }
    }
```

#### Arrays and Mappings
An array with fix length will be stored like a Fixed variable (see previous part).

Dynamic arrays and mappings use something else. 

For dynamic arrays, only one slot is used like fixed variable. This slot will keep the dynamic size of the array, and so will be decrease on pop, increase on push. Then, data will be stored at slot number `keccak256(array.slot)`, with `array.slot` the fixed variable slot previously defined. Then, all the dynamic values will be stored after this slot number. As uint256 is a really big number, collision in storage is pretty unlikely to happen.

Got storage slot of an index in a dynamic array:
```solidity
    function bigArrayLength() external view returns (uint256 ret) {
        assembly {
            ret := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(uint256 index)
        external
        view
        returns (uint256 ret)
    {
        uint256 slot;
        assembly {
            slot := bigArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            ret := sload(add(location, index))
        }
    }
```

A mapping will also be dynamic. Like dynamic arrays, it has one fixed storage slot. It will store value mapped to `key` at slot number `keccak(abi.encode(key, mapping.slot))`



