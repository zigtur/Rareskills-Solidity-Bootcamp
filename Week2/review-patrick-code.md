# Review of Patrick Zimmerer code for Week2

## General remarks
### Style guide
I think we should use the Solidity Style guide : https://docs.soliditylang.org/en/v0.8.19/style-guide.html
Especially for functions order (https://docs.soliditylang.org/en/v0.8.19/style-guide.html#order-of-functions).



## RARE-ERC721-Merkltree/contracts/ERC721Merkle.sol

### Review of MAX_SUPPLY manipulation
Use of this require:
```sol
require(_tokenSupply < MAX_SUPPLY, "Max Supply reached.");
```
But _tokenSupply starts at 1, and so you have to set MAX_SUPPLY = 11 if you want 10 NFT max.
Replacing the require will be better:
```sol
require(_tokenSupply <= MAX_SUPPLY, "Max Supply reached.");
```

### Review of presale functions (presaleBitmap() and claimTicketOrBlockTransaction())
This require is useless:
```sol
require(ticketNumber < MAX_SUPPLY, "That ticket doesn't exist");
```
because ticketNumber has been verified with the Merkle Tree in the presaleBitmap() function.

### Questions
- Why don't you start your NFT token ids at 1 ?
```sol
_safeMint(_to, _tokenSupply - 1);
```



