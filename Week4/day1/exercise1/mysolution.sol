import "contract.sol";

/// @dev to run: $ echidna-test solution.sol
contract TestToken is TokenWhaleChallenge {
    constructor() public {
        TokenWhaleChallenge(msg.sender);
    }

    // add the property
    function echidna_test_pausable() public view returns (bool) {
        return isComplete();
    }
}