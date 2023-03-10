// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/test.sol";
import {console} from "forge-std/console.sol";

import {ZGameToken} from "../src/Game-ERC20-Token.sol";
import {ZGameNFTCollection} from "../src/Game-NFT-Collection.sol";
import {ZGameStaking} from "../src/Game-Staking-Rewards.sol";

import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {IERC20} from "openzeppelin/token/ERC20/ERC20.sol";


contract BaseSetup is Test {
    
    ZGameStaking internal ZGameStakingDeployed;
    
    ZGameToken internal ZGameTokenDeployed;
    ZGameNFTCollection internal ZGameNFTCollectionDeployed;
    ZGameNFTCollection internal OtherNFTCollection;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal user3;

    function setUp() public virtual {

        owner = vm.addr(99);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        user3 = vm.addr(3);
        vm.label(user3, "user3");

        vm.startPrank(owner);
        // NFT contract
        ZGameNFTCollectionDeployed = new ZGameNFTCollection("ZGameNFT", "ZGN", 100);
        OtherNFTCollection = new ZGameNFTCollection("OtherOne", "OTO", 100);
        // Staking reward contract
        ZGameStakingDeployed = new ZGameStaking(address(ZGameNFTCollectionDeployed));
        // Token contract
        ZGameTokenDeployed = new ZGameToken("ZGameToken", "ZGT", address(ZGameStakingDeployed));
        // Config of starking and reward contract to use token
        ZGameStakingDeployed.setGameTokenContract(address(ZGameTokenDeployed));
        vm.stopPrank();

    }
}

contract StakingRewardGameTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testDepositAndWithdrawNFT() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        // self mint token
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        ZGameNFTCollectionDeployed.approve(address(ZGameStakingDeployed), tokenId);
        ZGameStakingDeployed.depositNFT(tokenId);

        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        ZGameStakingDeployed.withdrawNFT(tokenId);
        
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));
        vm.stopPrank();
    }

    function testTransferAndWithdrawNFT() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        // self mint token 1
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        ZGameNFTCollectionDeployed.safeTransferFrom(user1, address(ZGameStakingDeployed), tokenId);
        vm.stopPrank();

        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        vm.prank(user1);
        ZGameStakingDeployed.withdrawNFT(tokenId);
        
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));
    }

    function testCalculateRewards() public {
        //console.log("Calculated rewards for 1 day is: %s", ZGameStakingDeployed.calculateRewards(block.timestamp - 24 hours));
        vm.warp(1677358172);
        console.log("Calculated rewards for 1 day is: %s", ZGameStakingDeployed.calculateRewards(block.timestamp - (365 * 24 hours)));
        console.log("Current timestamp is : %s", block.timestamp);
    }

    function testWithdrawRewardsNFT() public {
        vm.warp(1677358172);
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        // self mint token
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        //ZGameNFTCollectionDeployed.approve(address(ZGameStakingDeployed), tokenId);
        //ZGameStakingDeployed.depositNFT(tokenId);
        ZGameNFTCollectionDeployed.safeTransferFrom(user1, address(ZGameStakingDeployed), tokenId);
        vm.stopPrank();

        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));
        console.log("User1 token balance: %s", ZGameTokenDeployed.balanceOf(user1));
        vm.warp(1677358172 + 2 * 24 hours); //adding 24 hours

        vm.prank(user1);
        ZGameStakingDeployed.withdrawNFT(tokenId);
        
        console.log("Owner of NFT 1 : %s", ZGameNFTCollectionDeployed.ownerOf(tokenId));
        console.log("User1 token balance: %s", ZGameTokenDeployed.balanceOf(user1));
    }

    function testGetRewardsNFT() public {
        vm.warp(1677358172);
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        // self mint token
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        ZGameNFTCollectionDeployed.safeTransferFrom(user1, address(ZGameStakingDeployed), tokenId);
        vm.stopPrank();

        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));
        console.log("User1 token balance: %s", ZGameTokenDeployed.balanceOf(user1));
        vm.warp(1677358172 + 1 * 24 hours); //adding 24 hours
        vm.prank(user2);
        vm.expectRevert();
        ZGameStakingDeployed.getRewards(tokenId);

        vm.prank(user1);
        ZGameStakingDeployed.getRewards(tokenId);

        vm.warp(1677358172 + 2 * 24 hours); //adding 24 hours
        vm.prank(user2);
        vm.expectRevert();
        ZGameStakingDeployed.withdrawNFT(tokenId);

        vm.prank(user1);
        ZGameStakingDeployed.withdrawNFT(tokenId);
        
        console.log("Owner of NFT 1 : %s", ZGameNFTCollectionDeployed.ownerOf(tokenId));
        console.log("User1 token balance: %s", ZGameTokenDeployed.balanceOf(user1));
    }

    function testChangingGameToken() public {
        vm.prank(owner);
        ZGameStakingDeployed.setGameTokenContract(address(ZGameTokenDeployed));
    }

    function testSendingNFTOtherContract() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = OtherNFTCollection.mintPrice();
        // self mint token
        uint256 tokenId = OtherNFTCollection.selfMint{value: mintNFTPrice}();
        vm.expectRevert();
        OtherNFTCollection.safeTransferFrom(user1, address(ZGameStakingDeployed), tokenId);
        vm.stopPrank();
    }


}


contract NFTGameTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testMintFunction() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        // self mint token
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        console.log("Owner of NFT %s : %s", tokenId, ZGameNFTCollectionDeployed.ownerOf(tokenId));

        vm.expectRevert();
        tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice-10}();

        // check maxSupply require failure
        for(uint256 i=0; i<99; ){
            tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
            ++i;
        }
        vm.expectRevert();
        tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        vm.stopPrank();
    }

    function testWithdrawEther() public {
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();

        vm.prank(owner);
        ZGameNFTCollectionDeployed.withdrawEther();


        vm.prank(user1);
        vm.expectRevert();
        ZGameNFTCollectionDeployed.withdrawEther();
    }

    function test_baseURI() public {
        uint256 mintNFTPrice = ZGameNFTCollectionDeployed.mintPrice();
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        uint256 tokenId = ZGameNFTCollectionDeployed.selfMint{value: mintNFTPrice}();
        ZGameNFTCollectionDeployed.tokenURI(tokenId);
    }

    

}

contract TokenGameTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testMintFunction() public {
        vm.prank(address(ZGameStakingDeployed));
        ZGameTokenDeployed.mint(user1, 15 ether);

        vm.prank(address(user1));
        vm.expectRevert();
        ZGameTokenDeployed.mint(user1, 15 ether);
    }

    function testBurn() public {
        testMintFunction();

        vm.prank(user1);
        ZGameTokenDeployed.burn(user1, 8 ether);

        vm.prank(user2);
        vm.expectRevert();
        ZGameTokenDeployed.burn(user1, 5 ether);
    }

}