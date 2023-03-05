// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {SimpleNFTCollection} from "../src/Ex3-NFT-Collection.sol";
import {SimpleNFTEnumerate} from "../src/Enumerate-NFT.sol";


contract BaseSetup is Test {
    SimpleNFTCollection internal myContract;
    SimpleNFTEnumerate internal primeNumbersContract;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal presaleUser1;

    function setUp() public virtual {

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        presaleUser1 = vm.addr(3);
        vm.label(presaleUser1, "presaleUser1");

        owner = vm.addr(10);
        vm.label(owner, "owner");

       

        vm.prank(owner);
        myContract = new SimpleNFTCollection("ZigNFT", "ZGN", 20);
        primeNumbersContract = new SimpleNFTEnumerate(address(myContract));
    }
}

contract MyERC721Enumerable is BaseSetup {
    function testEnumerableFunctions() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 MINT_PRICE = myContract.MINT_PRICE();
        uint256 token1 = myContract.selfMint{value: MINT_PRICE}();
        uint256 token2 = myContract.selfMint{value: MINT_PRICE}();
        uint256 token3 = myContract.selfMint{value: MINT_PRICE}();

        vm.expectRevert();
        uint256 token4 = myContract.selfMint{value: MINT_PRICE-1}();

        console.log("User1 minted tokens %s, %s and %s", token1, token2, token3);

        uint256 balanceUser1 = myContract.balanceOf(user1);
        for (uint i=0; i < balanceUser1; i++) {
            console.log("User1 has token %s", myContract.tokenOfOwnerByIndex(user1, i));
        }

        //What happens if user1 sale a token
        myContract.safeTransferFrom(user1, user2, token2);

        balanceUser1 = myContract.balanceOf(user1);
        for (uint i=0; i < balanceUser1; i++) {
            console.log("User1 has token %s", myContract.tokenOfOwnerByIndex(user1, i));
        }
        vm.stopPrank();
    }

    function testMaxSupply() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 MINT_PRICE = myContract.MINT_PRICE();

        for(uint256 i=0; i<20; ) {
            myContract.selfMint{value: MINT_PRICE}();
            ++i;
        }

        vm.expectRevert();
        uint256 token = myContract.selfMint{value: MINT_PRICE}();
        vm.stopPrank();
    }

    function testWithdrawEtherAndTokenURI() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 MINT_PRICE = myContract.MINT_PRICE();

        uint256 tokenId = myContract.selfMint{value: MINT_PRICE}();
        string memory tokenURI = myContract.tokenURI(tokenId);
        vm.stopPrank();
        vm.prank(owner);
        myContract.withdrawEther();

    }


    function testPrimeNumber() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 MINT_PRICE = myContract.MINT_PRICE();
        for (uint i=0; i < 20; i++) {
            myContract.selfMint{value: MINT_PRICE}();
        }

        uint256 numberOfPrimes = primeNumbersContract.enumeratePrimeNumberTokensForOwner(user1);
        assert(numberOfPrimes == 8);

        vm.stopPrank();
    }
    
}
