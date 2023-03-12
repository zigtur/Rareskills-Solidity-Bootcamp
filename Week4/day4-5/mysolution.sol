// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

//import "./token-sale-modified.sol";
import "./MyOwnTokenBonding-flat.sol";


contract ZigturTestBondingSale {
    MyOwnTokenBonding tokenContract;

    event buyAndSellLog(uint256 amount, uint256 buyPrice, uint256 sellPrice);
    event pricesMovingSupply(uint256 oldTotalSupply, uint256 newTotalSupply, uint256 buyPrice, uint256 sellPrice);
    event Debug(uint256 index);
    event Receive(uint256 index);

    constructor() payable {
        tokenContract = new MyOwnTokenBonding("ZigBondingTest", "ZBT", 100_000_000 ether);
    }

    function totalSupply_exceeded() public view {
        assert(tokenContract.totalSupply() <= tokenContract.cap());
    }

    // add the property
    function buyPrice_Not_sellPrice(uint256 amountOfTokens) public {
        // Optimization
        if (amountOfTokens < 1 ether) {
            amountOfTokens += 1 ether;
        }
        uint256 buyPrice = tokenContract.buyPriceCalculation(amountOfTokens);
        uint256 sellPrice = tokenContract.sellPriceCalculation(amountOfTokens);
        emit buyAndSellLog(amountOfTokens, buyPrice, sellPrice);
        assert(buyPrice != sellPrice);
    }

    function buyPrice_is_sellPrice_Moving_Supply(uint256 amountOfTokens) public payable returns(bool) {
        // Action
        uint256 oldTotalSupply = tokenContract.totalSupply();
        uint256 buyPrice = tokenContract.buyPriceCalculation(amountOfTokens);
        tokenContract.buy{value: buyPrice}(amountOfTokens);
        uint256 sellPrice = tokenContract.sellPriceCalculation(amountOfTokens);
        uint256 newTotalSupply = tokenContract.totalSupply();
        emit pricesMovingSupply(oldTotalSupply, newTotalSupply, buyPrice, sellPrice);

        // Post-conditions
        assert(sellPrice == buyPrice);
    }

    function buyBalanceIncrease(uint256 amountOfTokens) public {
        uint256 initialBalance = tokenContract.balanceOf(address(this));
        uint256 initialEtherBalance = address(this).balance;
        uint256 initialContractEtherBalance = address(tokenContract).balance;
        uint256 buyPrice = tokenContract.buyPriceCalculation(amountOfTokens);
        tokenContract.buy{value: buyPrice}(amountOfTokens);
        assert(tokenContract.balanceOf(address(this)) == initialBalance + amountOfTokens);
        assert(address(this).balance == initialEtherBalance - buyPrice);
        assert(address(tokenContract).balance == initialContractEtherBalance + buyPrice);
    }

    function sellBalanceDecrease(uint256 amountOfTokens) public {
        require(amountOfTokens <= tokenContract.totalSupply());
        uint256 initialTokenBalance = tokenContract.balanceOf(address(this));
        uint256 initialEtherBalance = address(this).balance;
        uint256 initialContractEtherBalance = address(tokenContract).balance;
        uint256 sellPrice = tokenContract.sellPriceCalculation(amountOfTokens);
        emit Debug(1);
        try tokenContract.transferFromAndCall(address(this), address(tokenContract), amountOfTokens) {
            assert(tokenContract.balanceOf(address(this)) == initialTokenBalance - amountOfTokens);
            assert(address(this).balance == initialEtherBalance + sellPrice);
            assert(address(tokenContract).balance == initialContractEtherBalance - sellPrice);
        } catch (bytes memory err) {
            assert(false);
        }
        emit Debug(2);
        
    }

    
    /*receive() external payable {
        emit Receive(0);
        emit Receive(msg.value);

        return true;

    }*/
}