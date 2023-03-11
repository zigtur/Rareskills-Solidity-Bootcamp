pragma solidity ^0.4.21;

//import "./token-sale-modified.sol";
import "./token-sale.sol";

contract ZigturTestTokenSale is TokenSaleChallenge {
    function ZigturTestTokenSale() public {
    }

    // add the property
    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }

    function testTokenSale() public payable {
        buy{value: 1 ether}(1);
    }
}