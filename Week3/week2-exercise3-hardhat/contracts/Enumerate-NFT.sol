// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";


/**
 * @title SimpleNFTEnumerate
 * @author Zigtur
 * @notice This smart contract enumerates prime numbers of a NFT collection (other contract)
 */
contract SimpleNFTEnumerate {
    IERC721Enumerable private immutable nftContract;

    constructor(address nftContractAddress) {
        nftContract = IERC721Enumerable(nftContractAddress);
    }

    /**
     * @notice This function is used to calculate the number of prime number token ids owned by an address
     * @param owner address Address to calculate the number of prime token ids
     * @return uint256 The number of prime number ids
     */
    function enumeratePrimeNumberTokensForOwner(address owner) external view returns(uint256) {
        uint256 balanceOwner = nftContract.balanceOf(owner);
        uint256 primeNumbersBalance = 0;
        for (uint i=0; i < balanceOwner; ++i) {
            uint256 tokenNumber = nftContract.tokenOfOwnerByIndex(owner, i);
            unchecked {
                uint256 stopVerify = tokenNumber / 2;
                // 1 is not considered a prime number
                if(tokenNumber == 1){
                    continue;
                }
                // set 2 and 3 as prime numbers
                if(tokenNumber < 3) {
                    primeNumbersBalance++;
                    continue;
                }
                if(tokenNumber % 2 == 0) {
                    // if even number, not a Prime
                    continue;
                }
                // Only the odd numbers need to be tested
                // Algorithm could be optimized for large numbers
                bool isPrime = true;
                for(uint256 j=3; j < stopVerify; j = j + 2) {
                    if(tokenNumber % j == 0) {
                        isPrime = false;
                        break;
                    }
                }
                if (isPrime == true) {
                    primeNumbersBalance++;
                }
            }
        }
        return primeNumbersBalance;
    }
}