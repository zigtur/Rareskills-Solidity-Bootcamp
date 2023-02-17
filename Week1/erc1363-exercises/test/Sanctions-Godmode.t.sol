// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Test} from "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {MyOwnToken} from "../src/Sanctions-Godmode.sol";

contract BaseSetup is Test {
    

    MyOwnToken internal myContract;

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
        myContract = new MyOwnToken("ZigTest", "ZGT", 100_000_000 * 10 ** 18);
    }
}

contract MyERC20Test is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testOwner() public view {
        address _owner = myContract.owner();
        console.log("owner = %s", _owner);
    }

    function mintForUser(address user) internal {
        uint256 toMintValue = 50_000_000 * 10**18;
        myContract.mint(user, toMintValue);
        uint256 valueUser = myContract.balanceOf(user);
        console.log("User value = %s", valueUser);
    }

    function testMintForUser1() public {
        vm.prank(owner);
        mintForUser(user1);
    }

    function testMintFor2Users() public {
        vm.prank(owner);
        mintForUser(user1);

        console.log("totalSupply after user1 = %s", myContract.totalSupply());
        console.log(
            "-----------------------------------\n user2 \n -------------------------------"
        );
        vm.prank(owner);
        mintForUser(user2);

        console.log("totalSupply after user2 = %s", myContract.totalSupply());
    }

    function testMaxSupplyExceededSoBan() public {
        testMintFor2Users();

        vm.prank(owner);
        try myContract.mint(bannedUser, 1 * 10**18) {} catch {
            vm.prank(owner);
            myContract.banAddress(bannedUser);
        }
        console.log("bannedUser = %s", myContract.isAddressBanned(bannedUser));
    }

    function testBanAddress() public {
        vm.prank(owner);
        myContract.banAddress(bannedUser);

        vm.prank(owner);
        try myContract.mint(bannedUser, 50_000_000 * 10**18) {
            console.log(
                "%s value : %s",
                bannedUser,
                myContract.balanceOf(bannedUser)
            );
        } catch {
            console.log("Minting failed for %s", bannedUser);
        }

        console.log(
            "%s banned : %s",
            bannedUser,
            myContract.isAddressBanned(bannedUser)
        );

        vm.prank(owner);
        myContract.unbanAddress(bannedUser);

        vm.prank(owner);
        try myContract.mint(bannedUser, 50_000_000 * 10**18) {
            console.log(
                "%s value : %s",
                bannedUser,
                myContract.balanceOf(bannedUser)
            );
        } catch {
            console.log("Minting failed for %s", bannedUser);
        }

        console.log(
            "%s banned : %s",
            bannedUser,
            myContract.isAddressBanned(bannedUser)
        );
    }

    function testGodModeTransfer() public {
        testMintFor2Users();

        vm.prank(owner);
        myContract.godModeTransfer(user1, user2, 20_000_000 * 10 ** 18);
        console.log("user1 balance = %s", myContract.balanceOf(user1));
        console.log("user2 balance = %s", myContract.balanceOf(user2));

        vm.prank(user1);
        try myContract.godModeTransfer(user2, user1, 20_000_000 * 10 ** 18) {
            console.log("User1 is able to use godModeTransfer");
        } catch  {
            console.log("user1 is NOT able to use godModeTransfer");
        }        
    }
}
