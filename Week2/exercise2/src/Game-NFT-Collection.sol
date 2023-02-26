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
    uint256 public immutable maxSupply;
    uint256 public currentSupply = 1;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
    }

    /**
     * @notice Mint NFT with price = mintPrice
     * @param _to address Address to which NFT will be minted
     * @return tokenId to let user know
     */
    function mint(address _to) public payable returns(uint256) {
        require(msg.value == mintPrice, "Value is not mintPrice");
        uint256 _currentSupply = currentSupply;
        // set <= because currentTokenId starts at 1
        require(_currentSupply <= maxSupply, "maxSupply hit");
        // update current supply
        unchecked {
            currentSupply = _currentSupply + 1;
        }
        // use old supply as tokenId to mint
        _safeMint(_to, _currentSupply);
        return _currentSupply;
    }

    /**
     * @notice Same function as mint(), but using _msgSender() as receiver of the minted token
     * @return tokenId to let user know
     */
    function selfMint() external payable returns(uint256) {
        return mint(_msgSender());
    }

    /**
     * @dev baseURI used with tokenURI
     */    
    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/zigtur/Rareskills-Solidity-Bootcamp/master/Week2/nft-collection/";
    }
}
