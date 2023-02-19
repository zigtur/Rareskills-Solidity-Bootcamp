// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";

contract MyOwnNFTCollection is ERC721 {
    
    function _baseURI() internal view override returns (string memory) {
        return "https://boredapeyachtclub.com/api/mutants/";
    }
}
