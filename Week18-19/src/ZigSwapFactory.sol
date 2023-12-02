pragma solidity 0.8.19;


import "openzeppelin/token/ERC20/ERC20.sol";
import './interfaces/IZigSwapFactory.sol';
import './ZigSwapPair.sol';
import {console} from "forge-std/console.sol";

contract ZigSwapFactory is IZigSwapFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'ZigSwap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZigSwap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'ZigSwap: PAIR_EXISTS'); // single check is sufficient

        // encode pair.bytecode + (name, symbol)
        string memory pairName = string.concat("ZSwap-", string.concat(ERC20(token0).name(), ERC20(token1).name()));
        string memory pairSymbol = string.concat("ZS-", string.concat(ERC20(token0).symbol(), ERC20(token1).symbol()));
        bytes memory bytecode = abi.encodePacked(type(ZigSwapPair).creationCode, abi.encode(pairName, pairSymbol));

        // deploy pair
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // initialize pair
        IZigSwapPair(pair).initialize(token0, token1);
        
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'ZigSwap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'ZigSwap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}