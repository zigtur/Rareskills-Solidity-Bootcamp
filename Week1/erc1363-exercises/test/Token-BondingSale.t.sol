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

    function testBuyAndSell() public {
        uint256 tokenAmount = 5 ether;
        uint256 buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 5 tokens is %s", buyPrice);
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);

        console.log("User1 buys 5 tokens");
        console.log("Current eth balance of contract: %s", address(myContract).balance);
        
        buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 5 more tokens (from 5 to 10) is %s", buyPrice);
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);
        console.log("User1 buys 5 more tokens");
        console.log("Current eth balance of contract: %s", address(myContract).balance);
        console.log("Current total Supply : %s", myContract.totalSupply());
        vm.prank(user1);
        myContract.transferAndCall(address(myContract), 5 ether, bytes(""));
        console.log("User1 sends 5 tokens to Contract (automatic sell)");
        console.log("Current eth balance of contract: %s", address(myContract).balance);
    }

    function testBuyWithDecimals() public {
        uint256 tokenAmount = 5 ether;
        uint256 buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 5 tokens is %s", buyPrice);
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);

        tokenAmount = 4.9 ether;
        buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 4.9 tokens is %s", buyPrice);
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);

        tokenAmount = 0.1 ether;
        buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 0.1 tokens is %s", buyPrice);
        // This should lead to arithmetic underflow
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);

        
        console.log("Current eth balance of contract: %s", address(myContract).balance);
        console.log("Current totalSupply: %s", myContract.totalSupply());
    }

    function testBuyWithDecimals2() public {
        // Buy some tokens
        uint256 tokenAmount = 6 ether;
        uint256 buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 6 tokens is %s", buyPrice);
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);

        require(myContract.buyPriceCalculation(6 ether) != myContract.buyPriceCalculation(6.9 ether));
    }

    function testBuyAndSellWithDecimals() public {
        // Buy some tokens
        uint256 tokenAmount = 6.8 ether;
        uint256 buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 6.8 tokens is %s", buyPrice);
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.buy{value: buyPrice}(tokenAmount);
        console.log("Current eth balance of contract: %s", address(myContract).balance);


        // Can't sell less than 1 token
        vm.prank(user1);
        myContract.transferAndCall(address(myContract), 1.8 ether, bytes(""));
        console.log("User1 sends 1.8 tokens to Contract (automatic sell)");
        console.log("Current eth balance of contract: %s", address(myContract).balance);
    }

    function testTotalMarketValueFor100_000_000Tokens() public {
        // Buy some tokens
        uint256 tokenAmount = 100_000_000 ether;
        uint256 buyPrice = myContract.buyPriceCalculation(tokenAmount);
        console.log("buyPrice for 1,000,000 tokens is %s", buyPrice);
    }

}
