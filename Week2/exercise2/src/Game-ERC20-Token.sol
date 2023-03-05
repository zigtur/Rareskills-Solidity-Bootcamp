// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

interface IZGameToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

/**
 * @title ZGameToken
 * @author Zigtur
 * @notice This smart contract is a Game Token
 * @dev Needs two more contracts for the game to work
 */
contract ZGameToken is IZGameToken, ERC20 {
    address public immutable stakingRewardContract;

    constructor(string memory _name, string memory _symbol, address _stakingRewardContract) ERC20(_name, _symbol) {
        stakingRewardContract = _stakingRewardContract;
    }

    /// @notice Burn tokens
    /// @param from Address from which token will be burned
    /// @param amount Amount of token to burn
    function burn(address from, uint256 amount) external {
        require(from == msg.sender, "from address must be sender");
        _burn(from, amount);
    }

    /// @notice Only stakingContract is able to mint tokens
    /// @param to Address to which token will be minted
    /// @param amount Amount of token to mint
    function mint(address to, uint256 amount) external {
        require(msg.sender == stakingRewardContract, "msg.sender is not staking and reward contract");
        _mint(to, amount);
    }
}
