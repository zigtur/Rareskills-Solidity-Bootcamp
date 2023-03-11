pragma solidity ^0.4.21;

import "./contract.sol";

contract ZigturTestTokenWhale is TokenWhaleChallenge {
    function ZigturTestTokenWhale() public TokenWhaleChallenge(msg.sender)  {
    }

    // add the property
    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }
}