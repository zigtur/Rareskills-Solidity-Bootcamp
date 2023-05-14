# Yul developer experience

## Repository installation

1. Install Foundry
```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install solidity compiler
https://docs.soliditylang.org/en/latest/installing-solidity.html#installing-the-solidity-compiler

3. Build Yul contracts and check tests pass
```
forge test
```

## Running tests

Run tests (compiles yul then fetch resulting bytecode in test)
```
forge test
```

To see the console logs during tests
```
forge test -vvv
```
