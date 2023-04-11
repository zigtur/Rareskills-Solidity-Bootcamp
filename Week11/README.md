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




