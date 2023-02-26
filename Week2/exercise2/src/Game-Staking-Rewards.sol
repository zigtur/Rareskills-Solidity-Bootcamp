// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "openzeppelin/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

import {IZGameToken,ZGameToken} from "./Game-ERC20-Token.sol";
import {ZGameNFTCollection} from "./Game-NFT-Collection.sol";

contract ZGameStaking is Ownable {
    struct depositStruct {
        address originalOwner;
        uint256 depositTime;
    }

    IZGameToken public ZGameTokenContract;
    IERC721 public immutable ZGameNFTCollectionContract;

    mapping(uint256 => depositStruct) deposits;

    constructor(address _ZGameNFTCollectionContract) {
        ZGameNFTCollectionContract = IERC721(_ZGameNFTCollectionContract);
    }

    /**
     * @notice The calcul is based on 10 tokens every 24 hours
     * @param depositTimestamp Time to start calculation
     */
    function calculateRewards(uint256 depositTimestamp) public view returns(uint256) {
        uint256 _timeSinceDeposit = block.timestamp - depositTimestamp;
        uint256 _calculatedRewards = _timeSinceDeposit * 10 ether / 1 days;
        return _calculatedRewards;
    }

    function depositNFT(uint256 tokenId) external {
        deposits[tokenId] = depositStruct(msg.sender, block.timestamp);
        ZGameNFTCollectionContract.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function withdrawNFT(uint256 tokenId) external {
        depositStruct memory _deposit = deposits[tokenId];
        require(_deposit.originalOwner == msg.sender, "msg.sender not original owner!");
        uint256 calculatedRewards = calculateRewards(_deposit.depositTime);
        ZGameNFTCollectionContract.safeTransferFrom(address(this), msg.sender, tokenId);
        ZGameTokenContract.mint(msg.sender, calculatedRewards);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4){
        deposits[tokenId] = depositStruct(operator, block.timestamp);
        return IERC721Receiver.onERC721Received.selector;
    }

    function setGameTokenContract(address _ZGameTokenContract) external onlyOwner() {
        ZGameTokenContract = IZGameToken(_ZGameTokenContract);
    }
}