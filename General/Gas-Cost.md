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


## Storage Slots
In a smart contract, data are stored in storage slots. A slot is basically 32 bytes (= 256 bits). 
This example shows storage slots in a smart contracts (taken from an Ethernaut solutions I made).
![Smart Contract Storage explained](https://github.com/zigtur/Ethernaut-Solutions/raw/master/images/Privacy.png)


## Opcodes
Ethereum Virtual Machine basically interprets a set of Opcodes. A Solidity code will be compiled to output an opcode program. Those opcodes will then be interpreted by the EVM. Opcode can be called directly from Solidity, using the Yul language with the keyword **assembly**.

Let's take an code example:
  - PUSH 0 --> Push the value 0 on stack
  - SLOAD --> Load on stack the value of the storage slot 0, let's say storage slot has value 5. Value 0 is replaced by 5 on stack
  - PUSH 1 --> Push the value 1 on stack
  - ADD --> Just add the last two elements on stack (5+1)

Just try to get what this does:
  - PUSH 5
  - PUSH 0
  - SLOAD
  - PUSH 3
  - PUSH 1
  - SLOAD
  - MUL
  - SWAP 2
  - MUL
  - ADD

### Opcodes gas cost
All the opcode gas costs are defined in the Ethereum yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf).
You can also find the opcodes on this EVM codes website (https://www.evm.codes/) or on the Ethereum docs (https://ethereum.org/fr/developers/docs/evm/opcodes/).

"Generally, the main function of gas costs of opcodes is to be an estimate of the time needed to process that opcode, the goal being for the gas limit to correspond to a limit on the time needed to process a block." Source: https://eips.ethereum.org/EIPS/eip-2929

Gas cost is always:
- 21,000 + Function execution gas cast

Because 21,000 corresponds to the amount of gas to create an Ethereum transaction.

### Function selector
Basically a function name in Solidity will be encoded to a selector in EVM. This selector is the 4 first bytes of the keccak256("function_name(type_of_variable)"). Let's take an example:
- Function "testing(uint256 var1, bool var2)" --> 4 first bytes of keccak256("testing(uint256,bool)")

### Calling a smart contract
When we are calling a smart contract function, we do send the function selector seen later.

Then, the contract will be executed. The first opcodoes may look like this:
- First 3 opcodes does prepare layout in memory. "the free memory pointer points to 0x80 initially" (Source: https://docs.soliditylang.org/en/v0.8.19/internals/layout_in_memory.html)
  - PUSH1 80 --> Offset
  - PUSH1 40 --> Value
  - MSTORE --> Store in memory
- Then it will take the function selector
  - PUSH1 04 --> The size of a function identifier
  - CALLDATASIZE --> Checks that calldata size is 4
  - LT --> Lower Than
  - PUSH1 1c --> Push a location
  - JUMPI --> Jump to it if it was lower than 4. It is pretty sure that it will jump to a piece of code that will revert.



