// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;


import {Test} from "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {MyOwnTokenSale} from "../src/Sanctions-Godmode-SimpleSale.sol";

contract BaseSetup is Test {
    

    MyOwnTokenSale internal myContract;

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
        myContract = new MyOwnTokenSale("ZigTest", "ZGT", 100_000_000 * 10 ** 18);
    }
}

contract MyERC20Test is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testBuyTokens() public {

        vm.prank(user1);
        //myContract.buy(20_000 * 10 ** 18);

        uint256 amount = myContract.formattedTokenPrice() * 2_000_000 / (10 ** myContract.decimals());

        vm.prank(user1);
        try myContract.buy{value: amount}(2_000_000 * 10 ** 18) {
            console.log("User1 just buy 2_000_000 tokens");
            console.log("user1 balance = %s", myContract.balanceOf(user1));
        } catch  {
            console.log("User1 couldn't buy 2_000_000 tokens");
        }
    }

    function testFailBuyTokens() public {

        vm.prank(user1);
        //myContract.buy(20_000 * 10 ** 18);
        uint256 amount = (myContract.formattedTokenPrice() - 1) * 2_000_000 / (10 ** myContract.decimals());

        vm.prank(user1);
        vm.expectRevert(abi.encodePacked("EvmError: OutOfFund"));
        myContract.buy{value: amount}(2_000_000 * 10 ** 18);
        console.log("User1 failed to buy 2_000_000 tokens with less ethers than needed");
    }
}
