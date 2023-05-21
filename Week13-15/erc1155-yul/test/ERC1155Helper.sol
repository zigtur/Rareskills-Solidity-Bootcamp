pragma solidity 0.8.15;

interface IERC1155 {
    function owner() external returns (address);
    function balanceOf(address owner, uint256 tokenId) external returns (uint256);
    function mint(address to, uint256 tokenId, uint256 amount) external;
}

contract ERC1155Helper {
    IERC1155 public target;
    constructor(IERC1155 _target) {
        target = _target;
        
    }
    function owner() external returns (address) {
        return target.owner();
    }

    function balanceOf(address owner, uint256 tokenId) external returns (uint256) {
        return target.balanceOf(owner, tokenId);
    }

    function mint(address to, uint256 tokenId, uint256 amount) external {
        target.mint(to, tokenId, amount);
    }
}