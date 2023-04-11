# Week10
## Day26-30 - Flash loan attacks part 2
### Damn Vulnerable Defi - The Rewarder
The rewards distribution is checked every time a deposit is made. But the rewards distribution is made after the accounting token mint. Knowing this, we can wait 5 days, flashloan a large amount of tokens, call the deposit function (which will distribute rewards) and then withdraw tokens to give it back to flashloan. During the distribution, our attacker contract will receive the rewards (and a large amount as he deposited a large amount of tokens!).

### Damn Vulnerable Defi - Selfie
Here, as we can flashLoan a lot of tokens and it is a snapshot ERC-20, it is possible to flashloan and take a snapshot during that flashloan. So, we will have more than half of token supply and will be able to create an action in the Governance. Then, just wait 2 days to execute the malicious action and drain all funds.


