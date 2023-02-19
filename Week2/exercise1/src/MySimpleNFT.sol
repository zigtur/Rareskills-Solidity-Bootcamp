// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract MySimpleNFTCollection {
    mapping (uint256 => address) private _owners;

    function mint(uint256 _tokenId) external {
        require(_owners[_tokenId] == address(0), "already minted");
        require(_tokenId < 100, "_tokenId too large")
        _owners[_tokenId] = msg.sender;
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(_owners[_tokenId] != address(0), "not valid token");
        return _owners[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_owners[_tokenId] != address(0), "Transfer from zero address");
        require(_owners[_tokenId] == _from, "cannot transfer from _from");
        _owners[_tokenId] = _to;
    }
    
}
