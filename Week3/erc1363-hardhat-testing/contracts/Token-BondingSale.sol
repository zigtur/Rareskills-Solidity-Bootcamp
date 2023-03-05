// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {MyOwnToken} from "./Token-Sanctions-Godmode.sol";
import "erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";

/// @title MyOwnTokenSale
/// @author Zigtur
/// @notice This contract is a bonding curve token sale that uses the MyOwnToken contract
/// @dev This contract should not be used for production purposes !
contract MyOwnTokenBonding is MyOwnToken, IERC1363Receiver {
    uint256 public constant basicPrice = 0.001 ether;
    uint256 public constant pricePerToken = 0.1 gwei;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) MyOwnToken(_name, _symbol, _maxSupply) {
    }

    /// @notice Buy tokens with ethers
    /// @param amount uinst256 Amount of token to buy
    function buy(uint256 amount) external payable {
        require(msg.value == buyPriceCalculation(amount), "msg.value is not equal to price");
        _mint(msg.sender, amount);
    }

    /**
     * @notice automatic sell when tranfering to contract
     * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param from address The address which are token transferred from
     * @param value uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     */
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4) {
        uint256 _currentPrice = basicPrice + (pricePerToken * totalSupply()) / 10 ** decimals();
        uint256 curveBasePrice = ((value * _currentPrice)) / 10 ** decimals();
        uint256 curveExtraPrice = (((value * pricePerToken) / 10 ** decimals()) * (value)) / (2 * 10 ** decimals());
        _burn(address(this), value);
        payable(from).transfer(curveBasePrice - curveExtraPrice);
        return bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    }

    /**
     * @notice Calculation of ether price for amount
     * @param amount uint256 The amount of tokens to calculate price for
     * @return Price to pay for the given amount
     */
    function buyPriceCalculation(uint256 amount) public view returns (uint256) {
        uint256 _currentPrice = basicPrice + (pricePerToken * totalSupply()) / 10 ** decimals();
        uint256 curveBasePrice = ((amount * _currentPrice)) / 10 ** decimals();
        uint256 curveExtraPrice = (((amount * pricePerToken) / 10 ** decimals()) * amount) / (2 * 10 ** decimals());
        return (curveBasePrice + curveExtraPrice);
    }

    /** @notice Get the corrent price for a token
     * @return Current Price for a single token
     */
    function currentPrice() external view returns (uint256) {
        return pricePerToken * totalSupply();
    }
}
