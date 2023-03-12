# Echidna fuzzing on Bonding Curve sale

Selected invariants:
- **totalSupply_exceeded**: totalSupply never get exceeded
- **buyPrice_Not_sellPrice**: Buy Price > Sell Price : for a given amount of token if totalSupply doesn't change
- **buyPrice_is_sellPrice_Moving_Supply**: BuyPrice(`token amount`) for supply=(`total supply`) ==  BuyPrice(`token amount`) for supply=(`total supply` + `token amount`)
- **buyBalanceIncrease**: buy(amount) --> user balance += amount
- **sellBalanceDecrease**: sell(amount) --> user balance -= amount
- **buyBalanceIncrease**: price = buyPrice(amount), then buy, then contract balance += price
- **sellBalanceDecrease**: price = sellPrice(amount), then sell, then contract balance -= price


## Problems solved with Echidna

### Buy Price and Sell Price
#### Problem found
A user wants to buy X tokens, he will have to pay Y ethers.
He buys the X tokens, with a value of Y. So totalSupply = totalSupply + tokens.
Then, he directly sell his tokens. The sellPrice will be Y+1 ethers.

I think that it doesn't have a critical impact, as contract will lose only 1 wei.
The contract needs to manage 10**9 transactions with this rounding problem to get a 1 gwei loss.

But the contract will be fixed !

#### Fix
Special thank to my mate Patrick for the code (https://github.com/PatrickZimmerer/RARE-ERC1363-Special/blob/main/contracts/ERC1363Bonding.sol): 
```sol
    /**
     * @notice Calculation of ether price for amount
     * @param amount uint256 The amount of tokens to calculate price for
     * @return Price to pay for the given amount
     */
    function buyPriceCalculation(uint256 amount) public view returns (uint256) {
        uint256 _currentPrice = BASIC_PRICE + (PRICE_PER_TOKEN * totalSupply()) / 10 ** decimals();
        uint256 _futurPrice = BASIC_PRICE + (PRICE_PER_TOKEN * (totalSupply() + amount)) / 10 ** decimals();
        uint256 finalPrice = (_currentPrice + _futurPrice) / 2;
        return finalPrice;
    }

    /**
     * @notice Calculation of ether price for amount
     * @param amount uint256 The amount of tokens to sell
     * @return Price to pay for the given amount
     */
    function sellPriceCalculation(uint256 amount) public view returns (uint256) {
        uint256 _currentPrice = BASIC_PRICE + (PRICE_PER_TOKEN * totalSupply()) / 10 ** decimals();
        uint256 _futurPrice = BASIC_PRICE + (PRICE_PER_TOKEN * (totalSupply() - amount)) / 10 ** decimals();
        uint256 finalPrice = (_currentPrice + _futurPrice) / 2;
        return finalPrice;
    }
```


