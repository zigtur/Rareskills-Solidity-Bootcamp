// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";

/**
 * @title MyOwnNFTCollectionMapping
 * @author Zigtur
 * @notice This smart contract is a NFT collection with MerkleTree and mapping presale
 * @dev Merkle Tree needs to be generated before deploying the contract
 */
contract MyOwnNFTCollectionMapping is ERC721 {
    uint256 public constant mintPrice = 0.000001 ether;
    uint256 public constant discountPrice = 0.0000005 ether;
    uint256 public immutable presaleMaxSupply;
    bytes32 private immutable merkleRoot;

    mapping (uint256 => bool) presaleTicketsUsed;

    constructor(string memory _name, string memory _symbol, uint256 _presaleMaxSupply, bytes32 _merkleRoot) ERC721(_name, _symbol) {
        presaleMaxSupply = _presaleMaxSupply;
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Mint NFT with price = mintPrice
     * @param _to address Address to which NFT will be minted
     * @param _tokenId uint256 ID of the token to mint
     */
    function mint(address _to, uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(_to, _tokenId);
    }

    /**
     * @notice Mint NFT during presale. Valide presale ticket is needed (whitelist)
     * @dev Some assembly code has been used for gas optimization purposes
     * @param _tokenId uint256 ID of the token to mint
     * @param ticket uint256 Presale ticket associated to msg.sender address
     * @param merkleProof bytes32[] Proof used to verify if msg.sender can mint using presale ticket
     */
    function presaleMint(uint256 _tokenId, uint256 ticket, bytes32[] calldata merkleProof) external payable {
        require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(msg.sender, ticket))))), "Invalid merkle proof");
        require(presaleTicketsUsed[ticket] == false);
        presaleTicketsUsed[ticket] = true;

        require(msg.value == discountPrice, "Value is not discountPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }

    /**
     * @notice Same function as mint(), but using msg.sender as receiver of the minted token
     * @param _tokenId ID of the token to mint
     */
    function selfMint(uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }
    
    /**
     * @dev baseURI used with tokenURI
     */   
    function _baseURI() internal pure override returns (string memory) {
        return "https://zigtur.github.io/Rareskills-Solidity-Bootcamp/";
    }
}
