# Solidity Security Cheatsheet


## NFTs and Tokens

### "safe" transfers

The functions that are "safe" are calling external contracts to ensure that the transfer was done properly. 
More specifically, it verifies if the address to which token is transferred is a contract or not. If it is, it calls this contract. So, if this contract 
