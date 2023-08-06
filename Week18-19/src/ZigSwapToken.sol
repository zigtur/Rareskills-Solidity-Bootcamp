pragma solidity ^0.8.0;

import "openzeppelin/token/ERC20/ERC20.sol";

contract ZigSwapToken is ERC20 {

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public immutable DOMAIN_SEPARATOR;
    // Used to follow nonces per user for Permit (EIP-712)
    mapping(address => mapping(uint => bool)) public nonces;
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                name,
                "1.0",
                block.chainid,
                address(this)
            )
        );
    }

    function permit(address owner, address spender, uint256 value, uint256 nonce, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, "Expired");
        require(!nonces[owner][nonce], "Nonce already used");
        require(owner != address(0), "Owner can't be address(0)");
        bytes32 message = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline))
            )
        );
        address signedFrom = ecrecover(message, v, r, s);
        require(signedFrom == owner, "Signature invalid");
        nonces[owner][nonce] = true;
        _approve(owner, spender, value);
    }
}