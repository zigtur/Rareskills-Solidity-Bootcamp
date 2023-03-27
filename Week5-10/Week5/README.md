# RareSkills - Week5

```
npx hardhat test
```

## Day1 - Warmup

### Ethernaut - Hello Ethernaut
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#hello-ethernaut

### Ethernaut - Fallback
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#fallback

### Ethernaut - Fallout
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#fallout

### Capture The Ether - Guess The Number
On-chain data are all **public**. Even if it has the *private* keyword, all can be read from off-chain world. Knowing that, we can read the storage slot that contains the answer.

Using ethers library in JS allows to read all the storage slots:

```
let number = await ethers.provider.getStorageAt(contract.address, BigNumber.from("0"));
```



## Day2 - Insecure Randomness
### Ethernaut - Coin Flip
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#coin-flip \
https://github.com/zigtur/Ethernaut-Solutions#coin-flip

### Capture The Ether - Guess the random number
The way I did the exploit for "Guess The Number" challenge just resolve this challenge too!


## Day3 - View function errors
### Ethernaut - Elevator
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#elevator \
https://github.com/zigtur/Ethernaut-Solutions#elevator

### Ethernaut - Shop

https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#shop \
https://github.com/zigtur/Ethernaut-Solutions#shop

## Day4 - Unsafe number casting
### Capture The Ether - Guess the secret number
There are only 256 values possibles for a uint8 (0 to 255). We just need to off-chain test all values and find the number that gives the answer hash.



### Capture The Ether - Guess the new number
We just need to calculate the hash of block number and time. This is simple, we just need to do the same operations with another contract.

```
uint8 myAnswer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
```

### Capture The Ether - Predict the Future
For this challenge, there is only 10 possible values. So, we are going to test all of them.

It would also be possible to anticipate a block number in the future and base our calculation on it. Then, we will have to send the settle transaction at the right moment to get our transaction included in the block that has the number we want.


## Day5-6 - Re-entrancy
### Ethernaut - Re-entrancy
https://github.com/zigtur/Ethernaut-Solutions#re-entrancy
https://github.com/zigtur/Ethernaut-Solutions/blob/master/solutions.md#re-entrancy

### RareSkills Riddles - ERC1155
Private exploit

### Capture The Ether - Token Bank
There is a re-entrancy issue the balanceOf is updated after transfering tokens in the TokenBank withdraw function.







