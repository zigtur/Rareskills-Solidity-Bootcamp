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
