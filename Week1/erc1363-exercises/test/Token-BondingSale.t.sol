// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;


import {Test} from "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {MyOwnTokenBonding} from "../src/Token-BondingSale.sol";

contract BaseSetup is Test {
    

    MyOwnTokenBonding internal myContract;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal bannedUser;

    function setUp() public virtual {

        owner = vm.addr(99);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        bannedUser = vm.addr(3);

        vm.prank(owner);
        myContract = new MyOwnTokenBonding("ZigTest", "ZGT", 100_000_000 * 10 ** 18);
    }
}

contract MyERC1363BondingTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testTokenPrice() public {

        uint256 tokenPrice = myContract.tokenPrice();
        console.log("Token price is %s", tokenPrice);
    }

    function testBuyTokens() public {

        vm.prank(user1);
        uint256 amount = myContract.tokenPrice() * 2_000_000;

        vm.prank(user1);
        vm.deal(user1, amount);
        myContract.buy{value: amount}(2_000_000);
        console.log("User1 just buy 2_000_000 tokens");
        console.log("user1 balance = %s", myContract.balanceOf(user1));
    }

    function testFailBuyTokens() public {

        vm.prank(user1);
        uint256 amount = myContract.tokenPrice() * 1_999_999;


        console.log("User1 balance before: %s", myContract.balanceOf(user1));

        vm.prank(user1);
        vm.deal(user1, amount);
        myContract.buy{value: amount}(2_000_000);
    }
}
