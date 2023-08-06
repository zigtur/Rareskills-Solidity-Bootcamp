// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ZigSwapToken} from "../src/ZigSwapToken.sol";

contract BaseSetup is Test {
    

    ZigSwapToken internal tokenContract;

    address internal user0;
    address internal user1;
    address internal user2;

    function setUp() public virtual {

        user0 = vm.addr(99);
        vm.label(user0, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        vm.prank(user0);
        tokenContract = new ZigSwapToken("ZigTest", "ZGT");
    }
}

contract permitTesting is BaseSetup {
    bytes32 constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    // computes the hash of a permit
    function getStructHash(Permit memory _permit)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.value,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }
    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(Permit memory _permit, bytes32 domainSeparator)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    getStructHash(_permit)
                )
            );
    }


    function setUp() public override {
        super.setUp();
    }

    function testPermit() external {
        address ownerPermit = user1;
        address spenderPermit = user0;
        uint256 valuePermit = 100_000 * 10**18;
        uint256 noncePermit = 1234;
        uint256 deadlinePermit = block.timestamp + 1 days;

        Permit memory permit = Permit({
            owner: ownerPermit,
            spender: spenderPermit,
            value: valuePermit,
            nonce: 1234,
            deadline: deadlinePermit
        });
        bytes32 digest = getTypedDataHash(permit, tokenContract.DOMAIN_SEPARATOR());
        console.logBytes32(digest);

        // signed by user1 (private key = 1)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        console.log("Allowance before: ",tokenContract.allowance(ownerPermit, spenderPermit));
        assertEq(tokenContract.allowance(ownerPermit, spenderPermit), 0);

        tokenContract.permit(ownerPermit,
            spenderPermit,
            valuePermit,
            noncePermit,
            deadlinePermit,
            v,
            r,
            s
        );

        console.log("Allowance after: ",tokenContract.allowance(ownerPermit, spenderPermit));
        assertEq(tokenContract.allowance(ownerPermit, spenderPermit), 100_000 * 10**18);
    }
}