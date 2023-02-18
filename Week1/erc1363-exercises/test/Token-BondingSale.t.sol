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

        uint256 tokenPrice = myContract.pricePerToken();
        console.log("Token price is %s", tokenPrice);
    }

}
