// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Test} from "forge-std/test.sol";
import {console} from "forge-std/console.sol";
import {MyOwnNFTCollection} from "../src/MyNFT.sol";
import {Merkle} from "murky/Merkle.sol";

contract BaseSetup is Test {
    

    MyOwnNFTCollection internal myContract;
    Merkle internal m;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal presaleUser1;

    bytes32 internal merkleRoot;
    bytes32[] internal merkleData;

    function setUp() public virtual {

        owner = vm.addr(99);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        presaleUser1 = vm.addr(3);
        vm.label(presaleUser1, "presaleUser1");

        // Merkle tree
        m = new Merkle();
        merkleData = new bytes32[](4);
        merkleData[0] = bytes32("0x50");
        merkleData[1] = bytes32("0x51");
        merkleData[2] = bytes32(abi.encodePacked(presaleUser1));
        merkleData[3] = bytes32("0x53");
        /*bytes32[] memory _merkleData = new bytes32[](4);
        _merkleData[0] = merkleData[0];
        _merkleData[1] = merkleData[1];
        _merkleData[2] = merkleData[2];
        _merkleData[3] = merkleData[3];*/
        // Get Root, Proof, and Verify
        merkleRoot = m.getRoot(merkleData);


        vm.prank(owner);
        myContract = new MyOwnNFTCollection("ZigNFT", "ZGN", merkleRoot);
    }
}

contract MyERC721Test is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testMint() public {
        uint256 _mintPrice = myContract.mintPrice();
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        myContract.selfMint{value: _mintPrice}(5);

        vm.expectRevert();
        myContract.ownerOf(4);

        console.log("Owner of NFT 5 is ", myContract.ownerOf(5));
        console.log("NFT 5 URI is : ", myContract.tokenURI(5));
    }


    function testPresaleMint() public {
        bytes32[] memory proof = m.getProof(merkleData, 2); // will get proof for index = 2
        bool verified = m.verifyProof(merkleRoot, proof, bytes32(abi.encodePacked(presaleUser1))); // true!
        assertTrue(verified);

        uint256 discountPrice = myContract.discountPrice();
        vm.prank(user1);
        vm.expectRevert();
        myContract.presaleMint(5, proof);

        vm.prank(presaleUser1);
        vm.deal(presaleUser1, 1 ether);
        myContract.presaleMint{value: discountPrice}(5, proof);

        console.log("Presale mint : NFT 5 owner is ", myContract.ownerOf(5));
        
    }
}
