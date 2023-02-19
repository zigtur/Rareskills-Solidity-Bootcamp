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
        require(msg.value == buyPriceCalculation(amount), "Not enough value");
        _mint(msg.sender, amount);
    }

    /// @notice automatic sell when tranfering to contract
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4) {
        uint256 _currentPrice = pricePerToken * totalSupply();
        uint256 curveBasePrice = (value * _currentPrice) / 10 ** (2*decimals());
        uint256 curveExtraPrice = ((value * pricePerToken) * (value)) / (2 * 10 ** (2*decimals()));
        _burn(address(this), value);
        payable(from).transfer(curveBasePrice - curveExtraPrice);
        return bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    }

    /// @notice Calculation of ether price for amount
    function buyPriceCalculation(uint256 amount) public view returns (uint256) {
        uint256 _currentPrice = pricePerToken * totalSupply();
        uint256 curveBasePrice = (amount * _currentPrice) / 10 ** (2*decimals());
        uint256 curveExtraPrice = ((amount * pricePerToken) * (amount)) / (2 * 10 ** (2*decimals()));
        return (curveBasePrice + curveExtraPrice);
    }

    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function currentPrice() external view returns (uint256) {
        return pricePerToken * totalSupply();
    }
}
