// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;


import {ERC1363Capped} from "./ERC1363Capped.sol";
import {ERC20Capped} from "openzeppelin/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";


/// @title MyOwnToken
/// @author Zigtur
/// @notice This contract should not be used for production purposes !
contract MyOwnToken is ERC1363Capped, Ownable {
    mapping(address => bool) public bannedAddress;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20Capped(_maxSupply) ERC20(_name, _symbol) Ownable() {
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view override {
        require(bannedAddress[from] == false, "Banned address");
        require(bannedAddress[to] == false, "Banned address");
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(from == msg.sender);
        _burn(from, amount);
    }

    function banAddress(address _bannedAddress) external onlyOwner {
        bannedAddress[_bannedAddress] = true;
    }

    function unbanAddress(address _unbannedAddress) external onlyOwner {
        bannedAddress[_unbannedAddress] = false;
    }

    function isAddressBanned(address _address) external view returns (bool) {
        return bannedAddress[_address];
    }

    function godModeTransfer(address from, address to, uint256 amount) external onlyOwner {
        _transfer(from, to, amount);
    }


    function maxSupply() public view returns (uint256) {
        return super.cap();
    }
}
