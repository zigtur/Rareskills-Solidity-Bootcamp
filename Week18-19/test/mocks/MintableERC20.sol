pragma solidity 0.8.19;


import "openzeppelin/token/ERC20/ERC20.sol";

contract MintableERC20 is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

}
