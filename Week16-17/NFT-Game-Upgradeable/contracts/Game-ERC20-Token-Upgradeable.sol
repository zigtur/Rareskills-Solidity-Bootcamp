// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IZGameToken is IERC20Upgradeable {
    function mint(address to, uint256 amount) external;
}

/**
 * @title ZGameToken
 * @author Zigtur
 * @notice This smart contract is a Game Token
 * @dev Needs two more contracts for the game to work
 */
contract ZGameToken is Initializable, IZGameToken, ERC20Upgradeable {
    address public stakingRewardContract;

    function initialize(string memory _name, string memory _symbol, address _stakingRewardContract) external initializer {
        __ERC20_init(_name, _symbol);
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


contract ZGameTokenV2 is Initializable, IZGameToken, ERC20Upgradeable {
    address public stakingRewardContract;

    function initialize(string memory _name, string memory _symbol, address _stakingRewardContract) external initializer {
        __ERC20_init(_name, _symbol);
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
        // For test purpose, open mint to everyone
        //require(msg.sender == stakingRewardContract, "msg.sender is not staking and reward contract");
        _mint(to, amount);
    }
}
