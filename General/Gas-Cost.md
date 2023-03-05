# Gas Cost
## Calculate cost of a transfer

Transaction Fee (Gwei) = Gas used * Gas Price / 1 billion

Transaction Fee (Ether) = Gas used * Gas Price / 1 billion


### Gas Price
Gas Price can change, it depends on miners. Gas price can be seen using Etherscan gas tracker.

The gas price is given in **Gwei**.

### Gas used
Gas can be seen as a computation unit. The more computation, the more gas.

Examples:
- Transfering Ethereum = 21,000
- ERC20 Transfer ~= 60,000
- NFT Mint ~= 170,000
- Tornado Cash (ZKP) ~= +900,000

Gas price can change based on code implementation.


Every transaction on Ethereum costs at least 21,000 gas.


## Block limit
- Bitcoin limits the block size to 1MB.
- Ethereum does not explicitly set a limit
  - Instead, Ethereum limits the amount of computations per block (gas)
  - Each computation has a gas cost
  - If a block has too much computation, nodes will have problems to quickly verify transactions of this block

Today, Ethereum generates new block every 12 seconds. With a max limit of 30 million gas, it allows 1428 transactions of ether per block. If a smart contract is called, number of transaction will decrease.

As there is a limited number of transaction, the highest bidders will have their transaction included in the block. That is why gas price can change.

Smart contract can't require over 30 million gas to execute. Efficient smart contract does impact contract's user but also other users of Ethereum.

## Other chains
There are a lot of other EVM chains, which looks more efficient. In fact, if it was as adopted as Ethereum, price per transaction will be approximately the same. There are two things to look at:
- The adoption of the chain
- The decentralization of the chain






