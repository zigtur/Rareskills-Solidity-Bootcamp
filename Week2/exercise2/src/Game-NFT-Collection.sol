// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";

/**
 * @title ZGameNFTCollection
 * @author Zigtur
 * @notice This smart contract is a Game NFT collection
 * @dev Needs two more contracts for the game to work
 */
contract ZGameNFTCollection is ERC721 {
    uint256 public constant mintPrice = 0.000001 ether;
    uint256 public constant discountPrice = 0.0000005 ether;
    uint256 public immutable maxSupply;
    uint256 public currentSupply = 1;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
    }

    /**
     * @notice Mint NFT with price = mintPrice
     * @param _to address Address to which NFT will be minted
     * @param _tokenId uint256 ID of the token to mint
     */
    function mint(address _to) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        uint256 _currentSupply = currentSupply;
        require(_currentSupply < maxSupply, "maxSupply hit");
        unchecked {
            _currentSupply = _currentSupply + 1;
        }
        currentSupply = _currentSupply;
        _safeMint(_to, _currentSupply);
    }

    /**
     * @notice Same function as mint(), but using msg.sender as receiver of the minted token
     * @param _tokenId ID of the token to mint
     */
    function selfMint(uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId < maxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }

    /**
     * @dev baseURI used with tokenURI
     */    
    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/zigtur/Rareskills-Solidity-Bootcamp/master/Week2/nft-collection/";
    }
}
