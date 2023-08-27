// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ZigSwapPair} from "../src/ZigSwapPair.sol";

contract BaseSetup is Test {
    

    ZigSwapPair internal pairContract;

    address internal user0;
    address internal user1;
    address internal user2;

    /*function setUp() public virtual {

        user0 = vm.addr(99);
        vm.label(user0, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        vm.prank(user0);
        pairContract = new ZigSwapPair("ZigTest", "ZGT");
    }*/
}
