// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {MyOwnToken} from "./Token-Sanctions-Godmode.sol";

/// @title MyOwnTokenSale
/// @author Zigtur
/// @notice This contract is a token sale that uses the MyOwnToken contract
/// @dev This contract should not be used for production purposes !
contract MyOwnTokenSale is MyOwnToken {
    uint256 public constant tokenPrice = 1 ether / 10_000;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) MyOwnToken(_name, _symbol, _maxSupply) {
    }

    /// @notice Buy tokens with ethers
    /// @param amount Amount of token to buy
    function buy(uint256 amount) external payable {
        require(msg.value >= (tokenPrice * amount), "Not enough value of ether");
        _mint(msg.sender, amount);
    }
}