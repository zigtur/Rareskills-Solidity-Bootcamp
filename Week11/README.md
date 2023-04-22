# Week11

## EVM-puzzles
Source: https://github.com/fvictorio/evm-puzzles

The goal of those puzzles is to enter the right transaction (with the right data) to get the execution not reverted.

### Puzzle 1
```
############
# Puzzle 1 #
############

00      34      CALLVALUE
01      56      JUMP
02      FD      REVERT
03      FD      REVERT
04      FD      REVERT
05      FD      REVERT
06      FD      REVERT
07      FD      REVERT
08      5B      JUMPDEST
09      00      STOP
```

- 0 - Identify the target
    - By analyzing the code, the `STOP` opcode is the target to reach. It is located right after a `JUMPDEST` at index `08`, which marks the location as valid for jumps.
- 1 - The first opcode is `CALLVALUE`. It will push on the stack the value sent with the transaction (in Wei).
- 2 - The second opcode `JUMP`. It takes its parameters on the stack, and modify the Program Counter to jump to this parameter.
- 3 - Pass `0x08` as value, and send the transaction. It will jump to `JUMPDEST` and the transaction will succeed.

*Note: See `General/Yul-and-Assembly.md` for an explanation of the Program Counter (PC).*

```
Solution = 0x08
```

### Puzzle 2
uint256 test = slot1 + slot2;
slot1 = test;

```
############
# Puzzle 2 #
############

00      34      CALLVALUE
01      38      CODESIZE
02      03      SUB
03      56      JUMP
04      FD      REVERT
05      FD      REVERT
06      5B      JUMPDEST
07      00      STOP
08      FD      REVERT
09      FD      REVERT
```

- 0 - Identify the target
    - By analyzing the code, the `STOP` opcode is the target to reach. It is located right after a `JUMPDEST` at index `06`, which marks the location as valid for jumps.
- 1 - The first opcode is `CALLVALUE`. It will push on the stack the value sent with the transaction (in Wei).
- 2 - The second opcode is `CODESIZE`. It will push on the stack the size of the current code. (Here it will be 10, so hexadecimal 0xA)
- 3 - The third one is `SUB`, which will do a substraction using the last two arguments on stack. The first pushed will be subbed to the second pushed. The two arguments will be popped of stack, and the result will be pushed on stack.
    - So, here we know that `CODESIZE` will return `0xA`
    - We need to jump to index `06` (`JUMPDEST`)
    - `0xA - 0x6 = 0x4`, 4 should be passed as value
- 4 - `JUMP` opcode will use the on stack value to jump to it. Here, we will jump to `06`, and win the challenge.

```
Solution = 0x04
```


### Puzzle 3

```
############
# Puzzle 3 #
############

00      36      CALLDATASIZE
01      56      JUMP
02      FD      REVERT
03      FD      REVERT
04      5B      JUMPDEST
05      00      STOP
```

- 0 - Identify the target
    - By analyzing the code, a jump to `JUMPDEST` at index `04` must be done to succeed.
- 1 - The first opcode is `CALLDATASIZE`. It will push on the stack the size of call data.
- 2 - The second opcode is `JUMP`. So, it will jump to the index on stack.
    - We do need to send 4 bytes of calldata, so the it will jump to index `04`


```
Solution = 0x01020304
```


### Puzzle 4

```
############
# Puzzle 4 #
############

00      34      CALLVALUE
01      38      CODESIZE
02      18      XOR
03      56      JUMP
04      FD      REVERT
05      FD      REVERT
06      FD      REVERT
07      FD      REVERT
08      FD      REVERT
09      FD      REVERT
0A      5B      JUMPDEST
0B      00      STOP
```

- 0 - Identify the target
    - By analyzing the code, a jump to `JUMPDEST` at index `0A` must be done to succeed.
- 1 - The first opcode is `CALLVALUE`. It will push on the stack the value sent with the transaction (in Wei).
- 2 - The second opcode is `CODESIZE`. It will push on the stack the size of the current code. (Here it will be 13, so hexadecimal 0xC)
- 3 - The third opcode is `XOR`. This opcode will do a XOR operation of the last two variables on stack.
    - We need the result of the `XOR` opcode to be `0x0A`
    - We know that `CODESIZE` will give the value `0x0C`
    - The operation is `0x0C = 0x0A XOR VALUE`
    - So, `VALUE = 0x0C XOR 0x0A = 0x06`, 6 should be passed as value



```
Solution = 0x06 or 6 in decimal
```


### Puzzle 5

```
############
# Puzzle 5 #
############

00      34          CALLVALUE
01      80          DUP1
02      02          MUL
03      610100      PUSH2 0100
06      14          EQ
07      600C        PUSH1 0C
09      57          JUMPI
0A      FD          REVERT
0B      FD          REVERT
0C      5B          JUMPDEST
0D      00          STOP
0E      FD          REVERT
0F      FD          REVERT
```

- 0 - Identify the target
    - By analyzing the code, a check that some value is equal to `0x100` is done before jumping to `JUMPDEST`
    - We do need to pass this check
- 1 - The first opcode is `CALLVALUE`. It will push on the stack the value sent with the transaction (in Wei).
- 2 - The second opcode is `DUP1`. It will duplicate last pushed value on stack. So, there will be two times the callvalue on stack.
- 3 - The third opcode is `MUL`. This opcode will multiply last two parameters. Result will be `CALLVALUE * CALLVALUE` on stack.
- 4 - The fourth opcode is `PUSH2`, with the value `0x100`. This will push `0x100` on stack, which is `256` as decimal.
- 5 - Last opcode of the check is `EQ`. This opcode will take last two stack values and check that they are equal.
    - First element: `0x100`
    - Second element: `CALLVALUE * CALLVALUE`
    - So, we need to pass the right callvalue to passe the check, which will be `0x10` (16 as decimal).
    - Then, `0x10 * 0x10 = 0x100`

```
Solution = 0x10 or 16 in decimal
```



### Puzzle 6

```
############
# Puzzle 6 #
############

00      6000      PUSH1 00
02      35        CALLDATALOAD
03      56        JUMP
04      FD        REVERT
05      FD        REVERT
06      FD        REVERT
07      FD        REVERT
08      FD        REVERT
09      FD        REVERT
0A      5B        JUMPDEST
0B      00        STOP
```

- 0 - Identify the target
    - By analyzing the code, a jump to `JUMPDEST` at index `0A` must be done to succeed.
- 1 - The first opcode is `PUSH1`, with value `00`. It will push on the stack one byte `0x00`.
- 2 - The second opcode is `CALLDATALOAD`. It will push on stack the value of calldata starting at the given offset (which is on stack, here `0x00`).
    - As a reminder, offset 0 corresponds to the less significant byte, and offset 31 to the most significant one.
    - Passing `0x0A` as calldata, will result in `0x0A00000000000000000000000000000000000000000000000000000000000000` with the `CALLDATALOAD` starting at offset `0x00`
    - So, we need to pass `0A` as value, in a 32-byte number
    - Solution is `0x000000000000000000000000000000000000000000000000000000000000000A`

```
Solution = 0x000000000000000000000000000000000000000000000000000000000000000A
```



### Puzzle 7

```
############
# Puzzle 7 #
############

00      36        CALLDATASIZE
01      6000      PUSH1 00
03      80        DUP1
04      37        CALLDATACOPY
05      36        CALLDATASIZE
06      6000      PUSH1 00
08      6000      PUSH1 00
0A      F0        CREATE
0B      3B        EXTCODESIZE
0C      6001      PUSH1 01
0E      14        EQ
0F      6013      PUSH1 13
11      57        JUMPI
12      FD        REVERT
13      5B        JUMPDEST
14      00        STOP
```

- 0 - Identify the target
    - By analyzing the code, the `JUMPI` instruction should be used. It will be triggered if the created contract is 1 byte size.
- 1 - The calldata needs to include an init code, and a runtime code. The runtime code needs to be 1-byte size to pass the check from the challenge.
    - Runtime code: No matter what the opcode is. `CODESIZE` will be used here (`0x38`).
    - Init code: Now, we need to write the init code that will store the runtime code.
        - To load the runtime code in memory, we need to use the `CODECOPY` opcode. It takes 3 parameters (destOffset, offset, size).
        - Then, we return the runtime code location in memory to deploy it.
```
// Step1: copy code in memory
PUSH1 01     // size of our runtime code. Size = 2 bytes
PUSH1 ?     // the offset at which the runtime code is stored in current bytecode. Size = 2 bytes
PUSH1 00     // the destination in memory. Size = 2 bytes
CODECOPY    // Copy the code in memory. Size = 1 byte

// Step2: return
PUSH1 01     // size of our runtime code. Size = 2 bytes
PUSH1 00     // Memory location that holds our runtime code. Size = 2 bytes
RETURN      // return with the memory location and size of runtime code. Size = 1 byte
```
- 1 -
    - Init code
        - The only variable that we need to calculate is the offset at which the runtime code is stored in bytecode.
            - We just need to calculate the init code size:
            - `2 + 2 + 2 + 1 + 2 + 2 + 1 = 12 = 0x0C`
            - `PUSH1 ?` can be replaced by `PUSH1 12`
    - Final bytecode does concatenate init code and runtime code:
        - *Note: The opcode hex value can be found here: (https://www.evm.codes/?fork=merge).*
        - Init code = `0x6001600C60003960016000F3`, size = 12 bytes
        - Runtime code = `0x38`, size = 1 byte
        - Final code = `0x6001600C60003960016000F338`, size = 13 bytes

```
Solution = 0x6001600C60003960016000F338
```


### Puzzle 8

```
############
# Puzzle 8 #
############

00      36        CALLDATASIZE
01      6000      PUSH1 00
03      80        DUP1
04      37        CALLDATACOPY
05      36        CALLDATASIZE
06      6000      PUSH1 00
08      6000      PUSH1 00
0A      F0        CREATE
0B      6000      PUSH1 00
0D      80        DUP1
0E      80        DUP1
0F      80        DUP1
10      80        DUP1
11      94        SWAP5
12      5A        GAS
13      F1        CALL
14      6000      PUSH1 00
16      14        EQ
17      601B      PUSH1 1B
19      57        JUMPI
1A      FD        REVERT
1B      5B        JUMPDEST
1C      00        STOP
```

- 0 - Identify the target
    - By analyzing the code, the `JUMPI` instruction should be used. It will be triggered if the created contract reverts when called.
- 1 - The calldata needs to include an init code, and a runtime code. The runtime code needs to be 1-byte size to pass the check from the challenge.
    - Runtime code: Here the runtime code needs to revert.
```
PUSH1 00    // Size of revert. Size = 2 bytes
PUSH1 00    // Offset of revert. Size = 2 bytes
REVERT      // Revert with 0 and 0. Size = 1 byte
// Final size = 5 bytes
```
- 1
    - Init code: Now, we need to write the init code that will store the runtime code.
        - To load the runtime code in memory, we need to use the `CODECOPY` opcode. It takes 3 parameters (destOffset, offset, size).
        - Then, we return the runtime code location in memory to deploy it.
```
// Step1: copy code in memory
PUSH1 05     // size of our runtime code. Size = 2 bytes
PUSH1 ?     // the offset at which the runtime code is stored in current bytecode. Size = 2 bytes
PUSH1 00     // the destination in memory. Size = 2 bytes
CODECOPY    // Copy the code in memory. Size = 1 byte

// Step2: return
PUSH1 05     // size of our runtime code. Size = 2 bytes
PUSH1 00     // Memory location that holds our runtime code. Size = 2 bytes
RETURN      // return with the memory location and size of runtime code. Size = 1 byte
```
- 1 -
    - Init code
        - The only variable that we need to calculate is the offset at which the runtime code is stored in bytecode.
            - We just need to calculate the init code size:
            - `2 + 2 + 2 + 1 + 2 + 2 + 1 = 12 = 0x0C`
            - `PUSH1 ?` can be replaced by `PUSH1 12`
    - Final bytecode does concatenate init code and runtime code:
        - *Note: The opcode hex value can be found here: (https://www.evm.codes/?fork=merge).*
        - Init code = `0x6005600C60003960056000F3`, size = 12 bytes
        - Runtime code = `0x60006000FD`, size = 1 byte
        - Final code = `0x6005600C60003960056000F360006000FD`, size = 13 bytes

```
Solution = 0x6005600C60003960056000F360006000FD
```

### Puzzle 9

```
############
# Puzzle 9 #
############

00      36        CALLDATASIZE
01      6003      PUSH1 03
03      10        LT
04      6009      PUSH1 09
06      57        JUMPI
07      FD        REVERT
08      FD        REVERT
09      5B        JUMPDEST
0A      34        CALLVALUE
0B      36        CALLDATASIZE
0C      02        MUL
0D      6008      PUSH1 08
0F      14        EQ
10      6014      PUSH1 14
12      57        JUMPI
13      FD        REVERT
14      5B        JUMPDEST
15      00        STOP
```


- 0 - Identify the target
    - By analyzing the code, there are two main checks to pass to succeed: `0x03 < CALLDATASIZE` and `CALLVALUE * CALLDATASIZE == 8`.
- 1 - The first check is pretty easy to pass. We take `CALLDATASIZE = 4` by using `0x11223344` as value.
- 2 - The second check will depend on the first. As `CALLDATASIZE = 4`, then `CALLVALUE` must be `2`.
- Note that we could have taken `CALLDATASIZE = 8` and `CALLVALUE = 1`.
```
Solution = 0x11223344 as calldata, and 2 as value
```



### Puzzle 10

```
#############
# Puzzle 10 #
#############

00      38          CODESIZE
01      34          CALLVALUE
02      90          SWAP1
03      11          GT
04      6008        PUSH1 08
06      57          JUMPI
07      FD          REVERT
08      5B          JUMPDEST
09      36          CALLDATASIZE
0A      610003      PUSH2 0003
0D      90          SWAP1
0E      06          MOD
0F      15          ISZERO
10      34          CALLVALUE
11      600A        PUSH1 0A
13      01          ADD
14      57          JUMPI
15      FD          REVERT
16      FD          REVERT
17      FD          REVERT
18      FD          REVERT
19      5B          JUMPDEST
1A      00          STOP
```


- 0 - Identify the target
    - By analyzing the code, there are three main checks to pass to succeed: `CODESIZE > CALLVALUE`, `CALLDATASIZE % 3 == 0` and `CALLVALUE + 0x0A == 0x19`.
- 1 - The first check is pretty easy to pass. As `CALLVALUE` depends on the third check, value is not set here.
- 2 - The second check is `CALLDATASIZE % 3 == 0`. As `CALLDATASIZE` is not used anywhere else in the code, we can set 3 random bytes.
- 3 - The third check is `CALLVALUE + 0x0A == 0x19` to allow the jump to `JUMPDEST`. `0x19 - 0x0A = 0x0F = 15`. So `CALLVALUE = 15`.
    - It does respect the first check, as `0x0F < CODESIZE`. Here `CODESIZE = 1B`. 

```
Solution = 0x112233 as calldata, and 15 as value
```

## Ethernaut
### Ethernaut - Privacy
https://github.com/zigtur/Ethernaut-Solutions#privacy
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#privacy

### Ethernaut - Gatekeeper One
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#gatekeeper-one
https://github.com/zigtur/Ethernaut-Solutions#gatekeeper-one


### Ethernaut - Magic Number
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#magic-number
https://github.com/zigtur/Ethernaut-Solutions#magic-number


## RareSkills Gas Puzzles
https://github.com/RareSkills/gas-puzzles

### ArraySum
Answer is private

### Require
Answer is private
