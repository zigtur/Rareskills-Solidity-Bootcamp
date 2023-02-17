# Rareskills Solidity Bootcamp
## What is the design motivation behind EIP-777 and EIP-1363 ?
First, those EIP are both backward compatible with ERC-20.

The motivation is to offer holders more control over their tokens. With ERC-20, when a contract receive a token, there is no way to execute code after a transfer or approval.

This fixes the require of allowance before swaping tokens, double transactions are not required anymore. Moreover, as code will be executed, recipient (like contract wallets) can deny reception of unwanted tokens by using revert.

BUT the main security problem is that, just like ether transfers, tokens will be vulnerable to reentrancy attacks. Fortunately, this can be fixed (using a mutex for example).

## What are the pros and cons of both tokens ?

|   | ERC-777 | ERC-1363 |
|---|---|---|
|Pros| - Granularity allows to specify the smallest part of the token that's not divisible | - Declare its notification interface using ERC165  |
|Cons| - Needs to register the ERC777Token interface with its own address via ERC-1820<br /> - Declare its notification interface using ERC-1820 (which is harder than ERC-165) |  |