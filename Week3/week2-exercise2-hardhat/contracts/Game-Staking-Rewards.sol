// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IZGameToken,ZGameToken} from "./Game-ERC20-Token.sol";
import {ZGameNFTCollection} from "./Game-NFT-Collection.sol";

contract ZGameStaking is Ownable, IERC721Receiver {
    struct DepositStruct {
        address originalOwner;
        uint256 depositTime;
    }

    IZGameToken public ZGameTokenContract;
    IERC721 public immutable ZGameNFTCollectionContract;

    mapping(uint256 => DepositStruct) deposits;

    constructor(address _ZGameNFTCollectionContract) {
        ZGameNFTCollectionContract = IERC721(_ZGameNFTCollectionContract);
    }

    /**
     * @notice The calcul is based on 10 tokens every 24 hours
     * @param depositTimestamp Time to start calculation
     * @return The calculated rewards
     */
    function calculateRewards(uint256 depositTimestamp) public view returns(uint256) {
        uint256 _timeSinceDeposit = block.timestamp - depositTimestamp;
        uint256 _calculatedRewards = _timeSinceDeposit * 10 ether / 1 days;
        return _calculatedRewards;
    }

    /**
     * @notice Deposit your NFT to gain rewards
     * @param tokenId uint256 ID of the token to deposit
     */
    function depositNFT(uint256 tokenId) external {
        deposits[tokenId] = DepositStruct(msg.sender, block.timestamp);
        // Do not use safeTransferFrom because it will collude with onERC781Received function
        ZGameNFTCollectionContract.transferFrom(msg.sender, address(this), tokenId);
    }

    /**
     * @notice Claim your rewards without withdrawing your NFT
     * @param tokenId uint256 ID of the token to withdraw
     */
    function getRewards(uint256 tokenId) public {
        DepositStruct memory _deposit = deposits[tokenId];
        require(_deposit.originalOwner == _msgSender(), "_msgSender() not original owner!");
        uint256 calculatedRewards = calculateRewards(_deposit.depositTime);
        _deposit.depositTime = block.timestamp;
        deposits[tokenId] = _deposit;
        ZGameTokenContract.mint(_msgSender(), calculatedRewards);
    }
    
    /**
     * @notice Withdraw your deposited NFT and obtain rewards
     * @param tokenId uint256 ID of the token to withdraw
     */
    function withdrawNFT(uint256 tokenId) external {
        DepositStruct memory _deposit = deposits[tokenId];
        require(_deposit.originalOwner == _msgSender(), "_msgSender() not original owner!");
        uint256 calculatedRewards = calculateRewards(_deposit.depositTime);
        ZGameNFTCollectionContract.safeTransferFrom(address(this), msg.sender, tokenId);
        ZGameTokenContract.mint(_msgSender(), calculatedRewards);
    }

    /**
     * @notice Transfering your NFT to this contract do the same as depositNFT
     * @param operator address Token transfered by this address
     * @param from address Token transfered from this address 
     * @param tokenId uint256 ID of the token to deposit
     * @param data Additionnal data
     * @return IERC721Receiver.onERC721Received.selector
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4){
        require(msg.sender == address(ZGameNFTCollectionContract), "Not the NFT Game contract");
        deposits[tokenId] = DepositStruct(operator, block.timestamp);
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Allow Owner to change the ERC20 rewards contract
     * @param _ZGameTokenContract address New ERC20 rewards contract
     */
    function setGameTokenContract(address _ZGameTokenContract) external onlyOwner() {
        ZGameTokenContract = IZGameToken(_ZGameTokenContract);
    }
}