// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {ERC2981} from "openzeppelin/token/common/ERC2981.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";

contract MyOwnNFTCollection is ERC721, ERC2981 {
    uint256 public constant mintPrice = 0.000001 ether;
    uint256 public constant discountPrice = 0.0000005 ether;
    uint256 public immutable presaleMaxSupply;
    bytes32 private immutable merkleRoot;

    uint256 private constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256[4] tickets = [MAX_INT, MAX_INT, MAX_INT, MAX_INT];
    /*uint256 public ticketGroup0 = MAX_INT;
    uint256 public ticketGroup1 = MAX_INT;
    uint256 public ticketGroup2 = MAX_INT;
    uint256 public ticketGroup3 = MAX_INT;
    uint256 private constant MAX_TICKETS = 1000;*/

    constructor(string memory _name, string memory _symbol, uint256 _presaleMaxSupply, bytes32 _merkleRoot, uint96 ownerRoyaltiesFees) ERC721(_name, _symbol) {
        presaleMaxSupply = _presaleMaxSupply;
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(msg.sender, ownerRoyaltiesFees);
    }

    function mint(address _to, uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(_to, _tokenId);
    }

    function presaleMint(uint256 _tokenId, uint256 ticket, bytes32[] calldata merkleProof) external payable {
        require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(msg.sender, ticket))))), "Invalid merkle proof");
        //require(ticket <= MAX_TICKETS, "Ticket not in range");
        require(ticket <= 256 * tickets.length, "Ticket not in range");
        uint256 ticketGroupValue;
        uint256 ticketSlot;
        uint256 ticketOffset;
        unchecked{
            ticketSlot = ticket / 256;
            ticketOffset = ticket % 256;
        }

        ticketGroupValue = tickets[ticketSlot];
        uint256 isTicketAvailable = (ticketGroupValue >> ticketOffset) & uint256(1);

        // This assembly code allows us to remove the use of an array, to be more gas efficient !
        /*assembly {
            ticketSlot := add(ticketGroup0.slot, ticketSlot) // moving to correspond ticketSlot
            ticketGroupValue := sload(ticketSlot)        // load word value from storage to local variable
        }
        uint256 isTicketAvailable = (ticketGroupValue >> ticketOffset) & uint256(1);*/

        require(isTicketAvailable == 1, "Ticket has already been used");
        tickets[ticketSlot] = ticketGroupValue & ~(uint256(1) << ticketOffset);
        
        /*ticketGroupValue = ticketGroupValue & ~(uint256(1) << ticketOffset);
        // Store the new ticketGroup value
        assembly {
            sstore(ticketSlot, ticketGroupValue)
        }*/

        require(msg.value == discountPrice, "Value is not discountPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }

    function selfMint(uint256 _tokenId) external payable {
        require(msg.value == mintPrice, "Value is not mintPrice");
        require(_tokenId > 0 && _tokenId <= presaleMaxSupply, "_tokenId is not in range");
        _safeMint(msg.sender, _tokenId);
    }

    function setTokenRoyalty(uint256 _tokenId, address receiver, uint96 feeNumerator) external {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "_msgSender() is not owner or approved");
        _setTokenRoyalty(_tokenId, receiver, feeNumerator);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function _baseURI() internal pure override returns (string memory) {
        return "https://zigtur.github.io/Rareskills-Solidity-Bootcamp/";
    }
}
