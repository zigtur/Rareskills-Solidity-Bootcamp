# Week18-19

## ERC4626


ERC4626 is a tokenized vault standard that uses ERC20 tokens to represent shares of some other asset.

By depositing an ERC20 token, another token will be given which can be called a "share". The ERC4626 contract is also an ERC20 contract (shares).

Each ERC4626 contract only supports one asset. You cannot deposit multiple kinds of ERC20 tokens into the contract and get shares back.

### Getting shares
There are two main functions to get shares:
- `deposit(uint256 assets, address receiver)`: The `assets` field specifies how many assets to put in, and the function will calculate how many shares to send
- `mint(uint256 shares, address receiver)`: The `shares` field specifies how many shares to get, and the function will calculate how many asset tokens should be transferred from you

Both functions return a uint256 which is the amount of shares to get back.



## Sources
https://www.rareskills.io/post/erc4626
