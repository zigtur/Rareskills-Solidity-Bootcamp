pragma solidity 0.8.19;

import './interfaces/IZigSwapPair.sol';
import './ZigSwapToken.sol';
import 'openzeppelin/utils/math/Math.sol';
import {UD60x18, ud, MAX_WHOLE_UD60x18} from 'prb-math/UD60x18.sol';
import 'openzeppelin/token/ERC20/IERC20.sol';
import 'openzeppelin/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IZigSwapFactory.sol';
import './interfaces/IZigSwapCallee.sol';
import 'openzeppelin/interfaces/IERC3156FlashBorrower.sol';

import {console} from "forge-std/console.sol";

contract ZigSwapPair is ZigSwapToken {
    using SafeERC20 for IERC20;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;

    address public factory;
    address public token0;
    address public token1;

    uint256 private reserve0;
    uint256 private reserve1;
    uint32  private blockTimestampLast;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'ZigSwap: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint256 _reserve0, uint256 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1);

    constructor(string memory name, string memory symbol) ZigSwapToken(name, symbol) {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'ZigSwap: FORBIDDEN');
        token0 = _token0;
        token1 = _token1;
    }



    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint256 _reserve0, uint256 _reserve1,) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt((ud(amount0) * ud(amount1)).unwrap()) - MINIMUM_LIQUIDITY;
           _mint(address(0xDEAD), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens to 0xDEAD
        } else {
            liquidity = Math.min((amount0 *_totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'ZigSwap: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = reserve0 * reserve1; // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint256 amount0, uint256 amount1) {
        (uint256 _reserve0, uint256 _reserve1,) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'ZigSwap: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        IERC20(_token0).safeTransfer(to, amount0);
        IERC20(_token1).safeTransfer(to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = ud(reserve0).mul(ud(reserve1)).unwrap(); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }


    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) external lock returns(bool) {
        // implement flashLoan the new way :D, respect EIP-3156
        uint256 fee = flashFee(token, amount);
        uint256 futureBalance = IERC20(token).balanceOf(address(this)) + fee;

        // 
        IERC20(token).transfer(address(receiver), amount);
        // callback
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == keccak256("ERC3156FlashBorrower.onFlashLoan"),
            "IERC3156: Callback failed"
        );
        require(IERC20(token).transferFrom(address(receiver), address(this), amount + fee), "Repay failed");

        // update reserves if necessary
        address _token0 = token0;
        address _token1 = token1;
        if (token == _token0 || token == _token1) {
            (uint256 _reserve0, uint256 _reserve1,) = getReserves();
            uint256 balance0 = IERC20(_token0).balanceOf(address(this));
            uint256 balance1 = IERC20(_token1).balanceOf(address(this));
            require(balance0 * balance1 >= _reserve0 * _reserve1, 'ZigSwap: K');
            // update the reserves if one of token0 nor token1 has been loaned
            _update(balance0, balance1, _reserve0, _reserve1);
        }
        return true;
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'ZigSwap: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint256 _reserve0, uint256 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'ZigSwap: INSUFFICIENT_LIQUIDITY');

        uint256 balance0;
        uint256 balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'ZigSwap: INVALID_TO');
        if (amount0Out > 0) IERC20(_token0).safeTransfer(to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) IERC20(_token1).safeTransfer(to, amount1Out); // optimistically transfer tokens
        // implement flashLoan the old way
        if (data.length > 0) IZigSwapCallee(to).zigSwapCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'ZigSwap: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        // calculate 0.3% fees
        uint256 balance0Adjusted = balance0 * 1000 - (amount0In * 3);
        uint256 balance1Adjusted = balance1 * 1000 - (amount1In * 3);
        require(balance0Adjusted * balance1Adjusted >= _reserve0 * _reserve1 * 1000**2, 'ZigSwap: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        IERC20(_token0).safeTransfer(to, IERC20(_token0).balanceOf(address(this)) - reserve0);
        IERC20(_token1).safeTransfer(to, IERC20(_token1).balanceOf(address(this)) - reserve1);
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }


    // EXTERNAL/PUBLIC VIEW

    function maxFlashLoan(
        address token
    ) external view returns (uint256) {
        // no matter what token, flashLoan is allowed if we have balance on it
        return IERC20(token).balanceOf(address(this));
    }


    function flashFee(
        address token,
        uint256 amount
    ) public view returns (uint256 fee) {
        fee = amount - ((amount * 997) / 1000);
    }
    
    
    // PRIVATE/INTERNAL FUNCTIONS
    
    // update reserves and, on the first call per block, price accumulators
    function _update(uint256 balance0, uint256 balance1, uint256 _reserve0, uint256 _reserve1) private {
        require(ud(balance0) <= MAX_WHOLE_UD60x18 && ud(balance1) <= MAX_WHOLE_UD60x18, 'ZigSwap: OVERFLOW');
        uint32 timeElapsed = uint32(block.timestamp) - blockTimestampLast; // underflow not possible
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            UD60x18 udReserve0 = ud(_reserve0);
            UD60x18 udReserve1 = ud(_reserve1);
            // * never overflows, and + overflow is desired
            //price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            //price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
            price0CumulativeLast += udReserve1.div(udReserve0).unwrap() * timeElapsed;
            price1CumulativeLast += udReserve0.div(udReserve1).unwrap() * timeElapsed;
        }
        reserve0 = balance0;
        reserve1 = balance1;
        blockTimestampLast = uint32(block.timestamp);
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint256 _reserve0, uint256 _reserve1) private returns (bool feeOn) {
        address feeTo = IZigSwapFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(_reserve0 * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * uint256(rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }
}