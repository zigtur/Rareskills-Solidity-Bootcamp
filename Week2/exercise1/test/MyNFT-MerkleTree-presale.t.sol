// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {MyOwnNFTCollection} from "../src/MyNFT-MerkleTree-presale.sol";
import {Merkle} from "murky/Merkle.sol";

/**
 * @title NFT MerkleTree presale test
 * @author Zigtur
 * @notice This is a test smart contract
 * @dev In this test file, we use test two smart contracts with two merkle trees. 
 * @dev One MerkleTree has been generated with JavaScript, the second is generated with Solidity (Murky)
 */

contract BaseSetup is Test {
    // Contract with Solidity initialized Merkle Tree
    MyOwnNFTCollection internal myContract1;
    // Contract with JavaScript initialized Merkle Tree
    MyOwnNFTCollection internal myContract2;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal presaleUser1;

    // This variable is used with the 1000 users presale (addresses generated with Python, MerkleTree and proofs generated with JavaScript)
    bytes32 internal merkleRoot2;

    // Those variables are used for Merkle Tree generated with Murky
    Merkle internal m;
    bytes32 internal merkleRoot1;
    bytes32[] internal merkleData;

    function setUp() public virtual {

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        presaleUser1 = vm.addr(3);
        vm.label(presaleUser1, "presaleUser1");

        owner = vm.addr(10);
        vm.label(owner, "owner");

        //MerkleTree generated with Murky
        m = new Merkle();
        merkleData = new bytes32[](4);
        merkleData[0] = keccak256(bytes.concat(keccak256(abi.encode(address(0x50), uint256(1)))));
        merkleData[1] = keccak256(bytes.concat(keccak256(abi.encode(address(0x51), uint256(2)))));
        merkleData[2] = keccak256(bytes.concat(keccak256(abi.encode(address(presaleUser1), uint256(3)))));
        merkleData[3] = keccak256(bytes.concat(keccak256(abi.encode(address(0x52), uint256(4)))));
        merkleRoot1 = m.getRoot(merkleData);

        vm.prank(owner);
        myContract1 = new MyOwnNFTCollection("ZigNFT", "ZGN", 10, merkleRoot1, uint96(250));

        // This Merkle Tree has been generated with 1000 users for presale
        merkleRoot2 = bytes32(0x2c0be55cd11715b0f7e28542f55cc84b71f9120d45bfa9a1cbfc06d6361618dc);
        vm.prank(owner);
        myContract2 = new MyOwnNFTCollection("ZigNFTPresale", "ZNP", 1000, merkleRoot2, uint96(250));
    }
}

contract MyERC721Test is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testMint() public {
        uint256 _mintPrice = myContract1.mintPrice();
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        uint256 tokenId = myContract1.selfMint{value: _mintPrice}();
        console.log("presaleUser1 address : %s", presaleUser1);

        vm.expectRevert();
        myContract1.ownerOf(5);

        console.log("Owner of NFT %s is %s", tokenId, myContract1.ownerOf(tokenId));
        console.log("NFT %s URI is : %s", tokenId, myContract1.tokenURI(tokenId));
    }

    function testContract1PresaleMint() public {
        bytes32[] memory proof = m.getProof(merkleData, 2);
        bool verified = m.verifyProof(merkleRoot1, proof, keccak256(bytes.concat(keccak256(abi.encode(address(presaleUser1), uint256(3))))));
        assertTrue(verified);

        uint256 discountPrice = myContract1.discountPrice();
        vm.prank(user1);
        vm.expectRevert();
        uint256 tokenId = myContract1.presaleMint(3, proof);

        vm.prank(presaleUser1);
        vm.deal(presaleUser1, 1 ether);
        tokenId = myContract1.presaleMint{value: discountPrice}(3, proof);

        console.log("Presale mint : NFT %s owner is : %s", tokenId, myContract1.ownerOf(tokenId));
        
    }

    function testContract2PresaleMint() public {
        myContract2.balanceOf(presaleUser1);
        bytes32[10] memory proof_array = [
                bytes32(0xc4a637c37909ab266966bb6db145a05f4703512ec8161d576c12e054c0c678d3),
                bytes32(0x406d34232514e333daffecbb9c5ce32f8f1e792c576c41a9b4a9030882d526de),
                bytes32(0x454edd59d09eae7b7c28f078f5271a7a2fce758fd3ba7bcf5ba62f8401214b22),
                bytes32(0xefd6f0e79678086cbd420a7a0c2b62014043869e4dfb436ceff0637a1dba3285),
                bytes32(0x5e55b6c8c68472aa54056bf81d2f02398a8c5ebeb10e8232a3d52d0e9af02e79),
                bytes32(0x8042a32979bf1a01c98f006cc9a800fa7a41fb33f0f3953e03a871b9ccbc6958),
                bytes32(0x4c80d55a4d838ec3d26c8e559967a78e3cd8d8d0e54b730635f5ef56b84d2c07),
                bytes32(0x018c6cf7758941cdeb71d89f252f34622221834e915e3b72991dd50e0c9941f1),
                bytes32(0x5232f6df03672046d0e88293d558035aa5860015ea232c72279516040e48b56f),
                bytes32(0xa85069b07f62904e8d07be4d1fd98082d5bb5209dc96ad3d8a6d0359701db5d7)
            ];
        bytes32[] memory proof = new bytes32[](proof_array.length);
        // bytes32[10] to bytes32[] memory
        for(uint i = 0; i < proof_array.length; i++) {
            proof[i] = proof_array[i];
        }

        //console.log("Second slot that shloud contain the index 501 has value :");
        //console.logBytes32(bytes32(myContract2.ticketGroup1()));

        uint256 discountPrice = myContract2.discountPrice();
        vm.prank(presaleUser1);
        vm.deal(presaleUser1, 1 ether);
        uint256 tokenId = myContract2.presaleMint{value: discountPrice}(501, proof);
        console.log("Presale mint : NFT owner is ", myContract2.ownerOf(tokenId));
    }

    function testFailContract2PresaleMint() public {
        myContract2.balanceOf(presaleUser1);
        bytes32[10] memory proof_array = [
                bytes32(0xc4a637c37909ab266966bb6db145a05f4703512ec8161d576c12e054c0c678d3),
                bytes32(0x406d34232514e333daffecbb9c5ce32f8f1e792c576c41a9b4a9030882d526de),
                bytes32(0x454edd59d09eae7b7c28f078f5271a7a2fce758fd3ba7bcf5ba62f8401214b22),
                bytes32(0xefd6f0e79678086cbd420a7a0c2b62014043869e4dfb436ceff0637a1dba3285),
                bytes32(0x5e55b6c8c68472aa54056bf81d2f02398a8c5ebeb10e8232a3d52d0e9af02e79),
                bytes32(0x8042a32979bf1a01c98f006cc9a800fa7a41fb33f0f3953e03a871b9ccbc6958),
                bytes32(0x4c80d55a4d838ec3d26c8e559967a78e3cd8d8d0e54b730635f5ef56b84d2c07),
                bytes32(0x018c6cf7758941cdeb71d89f252f34622221834e915e3b72991dd50e0c9941f1),
                bytes32(0x5232f6df03672046d0e88293d558035aa5860015ea232c72279516040e48b56f),
                bytes32(0xa85069b07f62904e8d07be4d1fd98082d5bb5209dc96ad3d8a6d0359701db5d7)
            ];
        bytes32[] memory proof = new bytes32[](proof_array.length);
        // bytes32[10] to bytes32[] memory
        for(uint i = 0; i < proof_array.length; i++) {
            proof[i] = proof_array[i];
        }

        uint256 discountPrice = myContract2.discountPrice();
        vm.prank(presaleUser1);
        vm.deal(presaleUser1, 1 ether);
        uint256 tokenId = myContract2.presaleMint{value: discountPrice}(501, proof);
        console.log("Presale mint : NFT 100 owner is ", myContract2.ownerOf(tokenId));

        // Reuse of presale ticket
        vm.prank(presaleUser1);
        vm.deal(presaleUser1, 1 ether);
        tokenId = myContract2.presaleMint{value: discountPrice}(501, proof);
        console.log("Presale mint : NFT 100 owner is ", myContract2.ownerOf(tokenId));
    }

    function testContract2TokenRoyalties() public {
        uint256 _mintPrice = myContract2.mintPrice();
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        uint256 tokenId = myContract2.selfMint{value: _mintPrice}();

        (address royalUser, uint256 royalAmount) = myContract2.royaltyInfo(tokenId, 1 ether);
        console.log("NFT 5 royalties user is %s and amount is %s ", royalUser, royalAmount);

        // user2 try to modify user1 token royalties
        vm.prank(user2);
        vm.expectRevert();
        myContract2.setTokenRoyalty(tokenId, user2, uint96(500));

        vm.prank(user1);
        myContract2.setTokenRoyalty(tokenId, user1, uint96(500));
        (royalUser, royalAmount) = myContract2.royaltyInfo(tokenId, 1 ether);
        console.log("NFT 5 royalties should have changed: user is %s and amount is %s ", royalUser, royalAmount);
    }
}
