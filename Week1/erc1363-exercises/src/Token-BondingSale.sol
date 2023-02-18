// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {MyOwnToken} from "./Token-Sanctions-Godmode.sol";

contract MyOwnTokenBonding is MyOwnToken {
    uint256 constant public tokenPrice = 1 ether / 10_000;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) MyOwnToken(_name, _symbol, _maxSupply) {
    }

    function buy(uint256 amount) external payable {
        require(msg.value >= (tokenPrice * amount), "Not enough value of ether");
        _mint(msg.sender, amount);
    }
}
