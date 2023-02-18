// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {MyOwnToken} from "./Token-Sanctions-Godmode.sol";
import "erc-1363/ERC1363//IERC1363Receiver.sol";

/// @title MyOwnTokenSale
/// @author Zigtur
/// @notice This contract is a bonding curve token sale that uses the MyOwnToken contract
/// @dev This contract should not be used for production purposes !
contract MyOwnTokenBonding is MyOwnToken, IERC1363Receiver {
    uint256 public constant pricePerToken = 0.01 ether;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) MyOwnToken(_name, _symbol, _maxSupply) {
    }

    function buy(uint256 amount) external payable {
        uint256 actualPrice = pricePerToken * totalSupply();
        uint256 curveBasePrice = amount * actualPrice;
        uint256 curveExtraPrice = (pricePerToken * (amount - 1)) / 2;
        require(msg.value >= curveBasePrice + curveExtraPrice, "Not enough value");
        _mint(msg.sender, amount);
    }

    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4) {
        uint256 futurePrice = pricePerToken * (totalSupply() - value);
        uint256 curveBasePrice = value * futurePrice;
        uint256 curveExtraPrice = (pricePerToken * (value - 1)) / 2;
        _burn(address(this), value);
        payable(from).transfer(curveBasePrice + curveExtraPrice);
        return bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    }

    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
