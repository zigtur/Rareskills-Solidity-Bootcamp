# Week6

```
npx hardhat test
```

## Day7 - Blockhash lookback
### Capture The Ether - Predict the block hash
The solidity documentation (https://docs.soliditylang.org/en/v0.4.24/units-and-global-variables.html#block-and-transaction-properties) does say that: `block.blockhash(uint blockNumber) returns (bytes32)`: hash of the given block - only works for 256 most recent, excluding current, blocks - deprecated in version 0.4.22 and replaced by `blockhash(uint blockNumber)`.

Asking for a blockhash that has a number lower than (block.number - 256), the blockhash will be bytes32(0).

## Day8 - Arithmetic overflow
### Ethernaut - Token
https://github.com/zigtur/Ethernaut-Solutions#token \
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#token

### Capture The Ether - Token Whale Challenge
The vulnerability: _transfer does substract value to msg.sender, even if transformFrom is used and so msg.sender != from.

First, the attacker has 1000 tokens on his first account. He uses his first account and gives allowance to his second account. From his second account, he calls transferFrom which will substract value to his balance (his balance is 0 before substracting). An integer underflow occurs and make the second account balance >>> 1000, attacker just send the balance to its first account.

### Capture The Ether - Token Sale Challenge
In this challenge, we can overflow the multiplication in the buy function. If we overflow by using the right number of tokens, we can reduce the price to < 1 ether!

## Day10-12 - Flawed or mixed accounting
### Ethernaut - Force
https://github.com/zigtur/Ethernaut-Solutions#force
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#force


### Capture The Ether - Retirement fund
If we can make $address(this).balance > startBalance$, then the substraction will underflow and attacker will get penalties. To do it, we have to create a contract and use the selfdestruct function, because the victim contract does not implement any receive function.


### Damn Vulnerable DeFi - Side Entrance

### Damn Vulnerable DeFi - Unstoppable

