// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";

contract MyOwnNFTCollection is ERC721 {
    uint256 public constant mintPrice = 0.000001 ether;
    uint256 public constant discountPrice = 0.0000005 ether;
    uint256 public immutable presaleMaxSupply;
    bytes32 private immutable merkleRoot;

    constructor(string memory _name, string memory _symbol, uint256 _presaleMaxSupply, bytes32 _merkleRoot) ERC721(_name, _symbol) {
        presaleMaxSupply = _presaleMaxSupply;
        merkleRoot = _merkleRoot;
    }

    function presaleMint(uint256 _tokenId, bytes32[] calldata merkleProof) external payable {
        //require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid merkle proof");
        require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _tokenId))))), "Invalid merkle proof");
        require(msg.value == discountPrice, "Value is not discountPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }

    function selfMint(uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }
    
    function mint(address _to, uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(_to, _tokenId);
    }
    
    function _baseURI() internal pure override returns (string memory) {
        return "https://zigtur.github.io/Rareskills-Solidity-Bootcamp/";
    }
}
