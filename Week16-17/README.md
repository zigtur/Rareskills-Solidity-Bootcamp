# Week16 - 17


## Questions

### 1 - The OZ upgrade tool for hardhat defends against 6 kinds of mistakes. What are they and why do they matter?
- 1: Unstructured Storage
    - Why? The OZ upgrade tool stores its needed values (implentation, beacon and admin) in specific storage slots. Those slots are calculated with keccak. This way, specific slots can't be written accidently (or if it is, then keccak is no longer safe).
- 2: Constructor problems
    - Why? As the constructor bytecode is not part of the runtime code, the constructor code of a logic contract will not be executed in the context of the proxy. The way to avoid this is to move this code from the constructor to a regular `initializer` function, and have this function be called whenever the proxy links to this logic contract. This `initializer` function should be called only once.
    - The OZ tool uses a modifier to avoid the initialize function being called more than once.
- 3: Function clashes
    - Why? As proxy works by delegating all calls to a logic contract, calling a proxy function could not be possible. Moreover, there could be some collision on the function identifier (which is 4-byte long).
    - OZ tool uses the caller address to identify if it should delegate the call or not. If the admin is the caller, then the proxy will **not** delegate any calls. Otherwise, it will **always** delegate.
- 4: `selfdestruct` in an implementation
    - Why? The tool will verify that the implemenation doesn't implement `selfdestruct` opcode and `delegatecall` opcode.
- 5: storage mapping
    - Why? The tool verifies that the storage layout has not been changed compared to previous versions.
- 6: 
    - Why?


### 2 - What is a beacon proxy used for?
A beacon proxy is a proxy that takes the implementation address from another contract. The other contract is the "beacon", and will return the implementation address when function `implementation()` is used.

This way, as proxies will retrieve the implementation address from the beacon, multiple proxies can be updated at once.


### 3 - Why does the openzeppelin upgradeable tool insert something like uint256[50] private __gap; inside the contracts? 
*Note: To see it, create an upgradeable smart contract that has a parent contract and look in the parent.*

The `__gap` is a convention for reserving storage slots in a base contract. This allows future versions of the implementation to use up those slots, without affecting the storage layout.

This require the developer to deeply know the Solidity storage packing rules.


### 4 - What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?

Initializing the proxy should be done at each modification of the implementation address. The initialize function should be called for this.

The deployed implementation doesn't need to be initialized, because only its runtime bytecode will be used.


### 5 - What is the use for the reinitializer? Provide a minimal example of proper use in Solidity
*Note: see `reinitializer` here: https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol#L119*

The reinitializer function is used after an upgrade. As initializer can only be called once, the reinitializer is here to reinitialize after an upgrade.

```


```


## Notes
### Slots
- **Implementation slot**
    - `slot = keccak("eip1967.proxy.implementation") - 1`
    - The content of this slot is the address of the logic contract.
- **Beacon slot**
    - `slot = keccak("eip1967.proxy.beacon") - 1`
    - If set, then **Implementation slot** SHOULD be empty.
    - The content of this slot is the address of the beacon contract.
    - The address of the logic contract can be retrievec by calling `implementation()` on the beacon.
- **Admin slot**
    - `slot = keccak("eip1967.proxy.admin") - 1`
    - The content of this slot is the address of the admin.
    - The admin SHOULD be able to update the content of the ERC1967 slots.


### Examples
- OpenZeppelin's ERC1967Proxy (with UUPS logic)
    - Uses the **implementation slot** to get the logic address.
    - No upgrade mechanism by default.
- OpenZeppelin's TransparentUpgradeableProxy
    - Uses the **implementation slot** to get the logic address.
    - Uses the **admin slot** for upgrades.
    - Upgrade mechanisms build into the proxy.
- OpenZeppelin's BeaconProxy
    - Uses the **beacon slot** to call the beacon contract and get the logic address.
    - Beacon slot not modifiable by default.
    - Upgradeability is a beacon feature.

## Practical work

### Ethernaut - Delegation

https://github.com/zigtur/Ethernaut-Solutions#delegation

https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#delegation

### Ethernaut - Preservation
https://github.com/zigtur/Ethernaut-Solutions#preservation

https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#preservation

### Ethernaut - Puzzle Wallet
https://github.com/zigtur/Ethernaut-Solutions#puzzle-wallet

https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#puzzle-wallet

### Ethernaut - Motorbike
https://github.com/zigtur/Ethernaut-Solutions#motorbike

https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#motorbike

### Damn Vulnerable DeFi - Climber


### Damn Vulnerable DeFi - Backdoor
The wallet factory allows to create GnosisSafe wallet contracts, and the callbacks a contract. The wallet registry sends tokens to created GnosisSafe, but verifies that the owner of the GnosisSafe wallet is one of its beneficiaries.

During GnosisSafe creation, the `setup()` function is called. Inside of `setup()`, there is a `setupModules(to, data)` function, which will do a delegate call. Here, the attacker can control the `to` and `data` parameters. So, the attacker can execute arbitrary code during the `setup()`.

So, the solution is to create a GnosisSafe wallet using the factory, setting one of the four legit users as beneficiary to pass the wallet registry checks, but executing an exploit (like approving an account for token transfer) during the `setup()` call.

### Week2 Upgradeable

ERC721 address:  0x556E27d0711363Aec1474ABe929e09B00A93C949
ERC20 address:  0x8DC6917EfE51B95000fdEaA63eE173119eac24cC
Game address:  0xE7C11e25E0A64b4a9Fc1513d30B156fdf39B35aC