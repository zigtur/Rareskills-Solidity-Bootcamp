// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ZigSwapPair} from "../src/ZigSwapPair.sol";
import {ZigSwapFactory} from "../src/ZigSwapFactory.sol";
import {MintableERC20} from "./mocks/MintableERC20.sol";

contract FactoryBaseSetup is Test {
    

    ZigSwapPair internal pairContract;
    ZigSwapFactory internal factory;

    MintableERC20 internal token0;
    MintableERC20 internal token1;

    address internal owner;
    address internal user1;
    address internal user2;

    function setUp() public virtual {

        owner = vm.addr(99);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        vm.startPrank(owner);
        factory = new ZigSwapFactory(address(this));
        console.log(1);

        token0 = new MintableERC20("token0", "TK0");
        token1 = new MintableERC20("token1", "TK1");
        console.log(2);

        pairContract = ZigSwapPair(factory.createPair(address(token0), address(token1)));
        console.log(3);

        // Mint tokens
        token0.mint(user1, 100 ether);
        token1.mint(user1, 100 ether);

        token0.mint(user2, 100 ether);
        token1.mint(user2, 100 ether);
        
        console.log(4);
        vm.stopPrank();
    }
}

contract ZigSwapAMMTest is FactoryBaseSetup {

    function testFirstDepositWithNoFee() external {
        vm.startPrank(user1);
        assertEq(pairContract.balanceOf(user1), 0);
        token0.transfer(address(pairContract), 1 ether);
        token1.transfer(address(pairContract), 1 ether);
        pairContract.mint(user1);
        console.log("balance of user1 after:", pairContract.balanceOf(user1));
    }

    function testFirstDepositWithFee() external {
        vm.prank(owner);
        factory.setFeeTo(address(this));
    }

}


