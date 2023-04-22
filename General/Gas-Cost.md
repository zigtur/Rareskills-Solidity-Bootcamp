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


### Transaction cost
Each of the Opcode will have a gas cost associated with it. We know that a simple transaction will cost 21,000 gas.

#### Input data
Then, some input data could be added to the transaction (a function selector for example). Gas cost will depend on the number of bytes and their values (0x00 cost 4 gas, non-zero values cost 16 gas).

If we want to encode the function "test(address,uint256)", then it should look like this:
- function selector: 0xba14d606 (which is keccak256(test(address,uint256)))".
- address value: 0x840342d0e5dd1d2cd37517005a602a5e75287ef3 (the 20 bytes of the address)
- uint value: 0x0000000000000000000000000000000000000000000000000000000000000001 (value=1)

So the data that will be added to our transaction should be:
```
0xba14d606840342d0e5dd1d2cd37517005a602a5e75287ef30000000000000000000000000000000000000000000000000000000000000001
```

This is 62 bytes, 31 bytes are equal to 0 and 31 are nonzero. So, this will cost $31 * 4 + 31 * 16 = 620$ gas + 21,000 gas for the transaction.

#### Other gas
At initialization, 3 opcodes are used (see Part "Calling a smart contract"). As the value 0x80 will be stored at index 0x40, three slots will be initialized (and costs 3 gas each). Those slots are:
- 0x00
- 0x20
- 0x40
Only the last one will have a value set, but others will be initialized. Then gas cost will increase by 3*3 = 9 gas.


### EIP-1559
EIP-1559 is confusing:
- Base fee
- Max Base fee
- Max fee
- Priority fee

Gas price per Gwei <= max_fee


There are only 2 fees:
- `max_priority_fee_per_gas`
  - The most Gwei per gas you are willing to pay
- `max_fee_per_gas`
  - Portion of that `max_fee_per_gas` you want to be a miner tip

And one global variable:
- `BASEFEE`
  - How much is going to be burnt


#### BASEFEE
This is the protocol-level base fee. Each block does have this `BASEFEE` value set.

It corresponds to the amount that has to be burnt for each transaction.

This one can increase/decrease:
- If last block was full: it increases by 12%
- If last block was empty: it decreases by 12%

The formula behing `BASEFEE` is complicated (https://eips.ethereum.org/EIPS/eip-1559). The value is available in Solidity ^0.8.17 as `block.basefee`.

#### Max Base Fee
A transaction needs `max fee >= BASEFEE`. As `BASEFEE` can fluctuate, we don't specify a `BASEFEE`, but a `MAX_BASEFEE` we are willing to pay at most.


#### Priority Fee
- Max priority fee = max priority fee we specify in transaction
- Priority gee = amount miner actually receives. Also known as miner tip


#### Summary
As a summary, here is the global working:

- Transaction basefee: `Max Fee - BASEFEE = Leftover`
- Miner tip and refund: `Leftover - max_priority_fee = refund`


### Solidity optimizer
The `--optimize-runs` options specifies roughly how often each opcode of the deployed code will be executed across th life-time of the contract. It balances between code size (deployment cost) and code execution cost.
- If it is called only once: 
  - Code size will be as small as possible (to reduce deploy cost)
  - Deployed code will not be efficient, as it will be called only once
- If it is called multiple times:
  - Code size will be longer
  - But code will be more gas efficient 

