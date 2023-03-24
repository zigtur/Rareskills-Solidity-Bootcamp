# Week6

```
npx hardhat test
```

## Day7 - Blockhash lookback
### Capture The Ether - Predict the block hash
The solidity documentation (https://docs.soliditylang.org/en/v0.4.24/units-and-global-variables.html#block-and-transaction-properties) does say that: `block.blockhash(uint blockNumber) returns (bytes32)`: hash of the given block - only works for 256 most recent, excluding current, blocks - deprecated in version 0.4.22 and replaced by `blockhash(uint blockNumber)`.

Asking for a blockhash that has a number lower than (block.number - 256), the blockhash will be bytes32(0).



