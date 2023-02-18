// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import {ERC1363Capped} from "./ERC1363Capped.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";


/// @title MyOwnToken
/// @author Zigtur
/// @notice This contract is an ERC1363Capped contract with sanctions and god mode functionnalities.abi
/// @dev This contract should not be used for production purposes !
contract MyOwnToken is ERC1363Capped, Ownable {
    mapping(address => bool) private bannedAddress;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC1363Capped(_name, _symbol, _maxSupply) Ownable() {
    }

    /// @notice Burn tokens
    function burn(address from, uint256 amount) external {
        require(from == msg.sender);
        _burn(from, amount);
    }

    /// @notice Owner is able to mint tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Owner is able to ban address
    function banAddress(address _bannedAddress) external onlyOwner {
        bannedAddress[_bannedAddress] = true;
    }

    /// @notice Owner is able to unban address
    function unbanAddress(address _unbannedAddress) external onlyOwner {
        bannedAddress[_unbannedAddress] = false;
    }

    /// @notice Owner is able to transfer tokens from every address
    function godModeTransfer(address from, address to, uint256 amount) external onlyOwner {
        _transfer(from, to, amount);
    }

    /// @notice Allows user to know if an address has been banned
    function isAddressBanned(address _address) external view returns (bool) {
        return bannedAddress[_address];
    }

    /// @notice Returns the max supply of tokens
    function maxSupply() external view returns (uint256) {
        return super.cap();
    }

    /// @dev Implementation of the ban mechanism
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view override {
        require(bannedAddress[from] == false, "Banned address");
        require(bannedAddress[to] == false, "Banned address");
    }
}
