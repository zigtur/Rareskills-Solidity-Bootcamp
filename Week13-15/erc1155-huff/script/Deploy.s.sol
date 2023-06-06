// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface IERC1155 {
    // ERC-1155 standard functions
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);
    // must be marked back to view function
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    // custom functions
    function mint(address to, uint256 id, uint256 amount) external;
    function mint(address to, uint256 id, uint256 amount, bytes calldata) external;
    
    function batchMint(address to, uint256[] calldata id, uint256[] calldata amounts) external;
    function batchMint(address to, uint256[] calldata id, uint256[] calldata amounts, bytes calldata) external;
}

contract Deploy is Script {
  function run() public returns (IERC1155 erc1155contract) {
    erc1155contract = IERC1155(HuffDeployer.deploy("ERC1155"));
  }
}
