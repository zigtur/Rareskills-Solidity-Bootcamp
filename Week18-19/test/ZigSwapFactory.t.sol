// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ZigSwapPair} from "../src/ZigSwapPair.sol";
import {ZigSwapFactory} from "../src/ZigSwapFactory.sol";
import {MintableERC20} from "./mocks/MintableERC20.sol";
import 'openzeppelin/interfaces/IERC3156FlashBorrower.sol';
import 'openzeppelin/interfaces/IERC3156FlashLender.sol';
import 'openzeppelin/interfaces/IERC20.sol';

contract FactoryBaseSetup is Test {
    

    ZigSwapPair internal pairContract;
    ZigSwapFactory internal factory;

    MintableERC20 internal token0;
    MintableERC20 internal token1;

    address internal owner;
    address internal user1;
    address internal user2;

    function setUp() public virtual {

        owner = vm.addr(99);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        vm.startPrank(owner);
        factory = new ZigSwapFactory(owner);

        // create ERC20 tokens
        MintableERC20 tokenA = new MintableERC20("token0", "TK0");
        MintableERC20 tokenB = new MintableERC20("token1", "TK1");

        // Create pair
        pairContract = ZigSwapPair(factory.createPair(address(tokenA), address(tokenB)));


        // Factory can make tokenA as token1 or token0
        token0 = MintableERC20(pairContract.token0());
        token1 = MintableERC20(pairContract.token1());

        // Mint tokens
        token0.mint(user1, 100 ether);
        token1.mint(user1, 100 ether);

        token0.mint(user2, 100 ether);
        token1.mint(user2, 100 ether);
        
        vm.stopPrank();
    }
}

contract ZigSwapAMMTest is FactoryBaseSetup {

    ///////////////////////////////////////////////////////
    //
    //          FIRST DEPOSIT
    //
    ///////////////////////////////////////////////////////
    function testFirstDepositWithNoFee() external {
        vm.startPrank(user1);
        assertEq(pairContract.balanceOf(user1), 0);
        token0.transfer(address(pairContract), 1 ether);
        token1.transfer(address(pairContract), 1 ether);
        pairContract.mint(user1);
        console.log("balance of user1 after:", pairContract.balanceOf(user1));
        vm.stopPrank();
    }

    function testFirstDepositWithFee() external {
        // Fees should not have impact on first deposit
        setFees();
        vm.startPrank(user1);
        assertEq(pairContract.balanceOf(user1), 0);
        token0.transfer(address(pairContract), 1 ether);
        token1.transfer(address(pairContract), 1 ether);
        pairContract.mint(user1);
        console.log("balance of user1 after:", pairContract.balanceOf(user1));
        vm.stopPrank();
    }


    ///////////////////////////////////////////////////////
    //
    //          SECOND DEPOSIT
    //
    ///////////////////////////////////////////////////////

    function testSecondDepositWithNoFee() public {
        // initial deposit
        firstDepositFromUser1();
        // user2 second deposit
        vm.startPrank(user2);
        assertEq(pairContract.balanceOf(user2), 0);
        token0.transfer(address(pairContract), 1 ether);
        token1.transfer(address(pairContract), 1 ether);
        pairContract.mint(user2);
        console.log("balance of user2 after deposit:", pairContract.balanceOf(user2));
        console.log("token0 balance of user2 after deposit:", token0.balanceOf(user2));
        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////
    //
    //          WITHDRAW
    //
    ///////////////////////////////////////////////////////

    function testWithdrawSecondDepositWithNoFee() public {
        // initial deposit
        testSecondDepositWithNoFee();
        // user2 withdraw
        vm.startPrank(user2);
        // transfer all to Pair
        pairContract.transfer(address(pairContract), pairContract.balanceOf(user2));
        pairContract.burn(user2);
        console.log("balance of user2 after withdraw:",pairContract.balanceOf(user2));
        console.log("token0 balance of user2 after withdraw:", token0.balanceOf(user2));
        vm.stopPrank();

    }

        function testWithdrawAfterSwapWithNoFee() public {
        // initial deposit
        testSecondDepositWithNoFee();
        // user1 swap
        vm.startPrank(user1);
        (uint256 res0, uint256 res1, ) = pairContract.getReserves();
        console.log(res0);
        console.log(res1);
        uint256 out1 = calculateOutputAmount(1 ether, res0, res1);
        console.log("output1 amount=", out1);
        token0.transfer(address(pairContract), 1 ether);
        pairContract.swap(0, out1, user1, "");
        vm.stopPrank();
        // user2 withdraw
        vm.startPrank(user2);
        pairContract.transfer(address(pairContract), pairContract.balanceOf(user2));
        pairContract.burn(user2);
        console.log("balance of user2 after withdraw:",pairContract.balanceOf(user2));
        console.log("token0 balance of user2 after withdraw:", token0.balanceOf(user2));
        vm.stopPrank();

    }


    ///////////////////////////////////////////////////////
    //
    //          SWAP
    //
    ///////////////////////////////////////////////////////

    function testFirstSwap() public {
        // mint enough liquidity deposit
        firstBigDepositFromUser1();
        // user2 swap
        vm.startPrank(user2);
        (uint256 res0, uint256 res1, ) = pairContract.getReserves();
        console.log(res0);
        console.log(res1);
        uint256 out1 = calculateOutputAmount(1 ether, res0, res1);
        console.log("output1 amount=", out1);
        token0.transfer(address(pairContract), 1 ether);
        pairContract.swap(0, out1, user2, "");
        (res0, res1, ) = pairContract.getReserves();
        console.log(res0);
        console.log(res1);
        console.log("Token0 balance of user2 after:", token0.balanceOf(user2));
        console.log("Token1 balance of user2 after:", token1.balanceOf(user2));
        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////
    //
    //          FLASH LOAN
    //
    ///////////////////////////////////////////////////////

    function testFlashLoanEIP3156() public {
        // mint enough liquidity deposit
        firstBigDepositFromUser1();
        // user2 swap
        vm.startPrank(user2);
        Borrower brw = new Borrower();
        uint256 transferAmount = 10 ether;
        uint256 feeAmount = pairContract.flashFee(address(token0), transferAmount);
        // transfer fees to borrower, so he can pay them
        token0.transfer(address(brw), feeAmount);

        brw.borrow(address(pairContract), address(token0), transferAmount);
        vm.stopPrank();
    }


    ///////////////////////////////////////////////////////
    //
    //          UTILS
    //
    ///////////////////////////////////////////////////////

    function setFees() internal {
        vm.prank(owner);
        factory.setFeeTo(owner); // set fees to owner
    }

    function firstDepositFromUser1() internal {
        vm.startPrank(user1);
        token0.transfer(address(pairContract), 1 ether);
        token1.transfer(address(pairContract), 1 ether);
        pairContract.mint(user1);
        vm.stopPrank();
    }

    function firstBigDepositFromUser1() internal {
        vm.startPrank(user1);
        token0.transfer(address(pairContract), 100 ether);
        token1.transfer(address(pairContract), 100 ether);
        pairContract.mint(user1);
        vm.stopPrank();
    }

    function calculateOutputAmount(uint256 amountIn0, uint256 balance0, uint256 balance1) internal returns (uint256 amountOut1) {
        // calculate 0.3% fees on input token
        amountOut1 = (balance1 * (997 * amountIn0 / 1000)) / (balance0 + amountIn0);
    }


}


contract Borrower is IERC3156FlashBorrower {

    function borrow(address who, address token, uint256 amount) external {
        IERC3156FlashLender lender = IERC3156FlashLender(who);
        lender.flashLoan(IERC3156FlashBorrower(this), token, amount, "");
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external returns(bytes32) {
        require(initiator == address(this), "only this can flash borrow");

        console.log("My loan balance: ", IERC20(token).balanceOf(address(this)));

        IERC20(token).approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

}

