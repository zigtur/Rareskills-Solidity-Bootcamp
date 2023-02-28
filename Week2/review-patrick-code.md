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

## RARE-StakingAndRewards/contracts/NFT.sol
### MAX_SUPPLY and totalSupply
Same remark as RARE-ERC721-Merkltree/contracts/ERC721Merkle.sol on require of MAX_SUPPLY

totalSupply() function returns MAX_SUPPLY - 1. I think you could rename MAX_SUPPLY to "totalSupply" and make this variable public. With the require remark that a made before, you would not need to minus 1.

### viewBalance
Why implementing a viewBalance function? Why not using ethereum functionnalities for this?


## RARE-StakingAndRewards/contracts/Token.sol
### MAX_SUPPLY
What happens to StakingContract.sol when MAX_SUPPLY is hit?

### onlyStakingContract() modifier
Good idea to use a verifier when multiple functions need it.


## RARE-StakingAndRewards/contracts/StakingContract.sol
line 18: NFT public NFTContract;
This storage variable is not used anywhere.

line 40 : function onERC721Received(
        address,
I think the "operator" keyword is missing !

### function withdrawNFT
It doesn't send rewards to msgSender ? And so user will lost his rewards

## RARE-ERC-721-Enumerable/contracts/NFTEnumerable.sol
Why don't you use Ownable.sol contract from OpenZeppelin?
The deployer storage variable is just used with withdraw().
Withdraw should have a require to allow only developper to call it.

### MAX_SUPPLY and totalSupply
Same remark as RARE-ERC721-Merkltree/contracts/ERC721Merkle.sol on require of MAX_SUPPLY

## RARE-ERC-721-Enumerable/contracts/SearchForPrimes.sol
Why use of Math.sol for uint256 (for sqrt :) )








### Questions
Why do you use Strings for uint256?



# Answers to Patrick's remarks
Source: https://github.com/PatrickZimmerer/RARE-StakingAndRewards/blob/main/code-review-madigan.md

## Week2/exercise1/src/MyNFT-MerkleTree-presale.sol
Do we need to make maxSupply public? there is a function in ERC721 called totalSupply which would show us the same as maxSupply
- I think we should so user can know how many NFT are left (maxSupply - tokenSupply).

You can reduce those to uint16 in our case since we only provide 10 NFTs and a bunch of presales so uint16 would be sufficient I guess.
- I agree. For educational purposes, I wanted to create a presale with a lot of addresses (1000 in this case).

Defining constructor of Ownable which has no constructor
- Ownable of OpenZeppelin does have a constructor (see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol).

The <= check is using more gas then just a < check so I guess since we can't mint more than one nft at a time < would be sufficient
- Yes, but currentSupply would not be able to be equal to maxSupply. And so the real maximum supply would in fact be maxSupply - 1 (as I'm started ). As maxSupply variable can be read by users, I want to make it clear that maxSupply = the real maximum supply
