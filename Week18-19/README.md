# Week18-19

## ERC4626

ERC4626 is a tokenized vault standard that uses ERC20 tokens to represent shares of some other asset.

By depositing an ERC20 token, another token will be given which can be called a "share". The ERC4626 contract is also an ERC20 contract (shares).

Each ERC4626 contract only supports one asset. You cannot deposit multiple kinds of ERC20 tokens into the contract and get shares back.

### Getting shares
There are two main functions to get shares:
- `deposit(uint256 assets, address receiver)`: The `assets` field specifies how many assets to put in, and the function will calculate how many shares to send
- `mint(uint256 shares, address receiver)`: The `shares` field specifies how many shares to get, and the function will calculate how many asset tokens should be transferred from you

Both functions return a uint256 which is the amount of shares to get back.


## Constant Product AMM
*AMM: Automated Market Maker*

### Swap
Price of tokens are determined by:
$$X.Y = K$$
- With $X =$ Amount of Token A in the AMM.
- With $Y =$ Amount of Token B in the AMM.
- With $K$ a constant

Swap example:
- Let's say that:
    - $dx =$ Amount of Token A **in**
    - $dy =$ Amount of Token B **out**
- Before trade: $X.Y = K$
- After trade: $(X + dx).(Y - dy) = K$
- So here:
    - $Y - dy = \frac{K}{X + dx}$
    - $dy = Y - \frac{K}{X + dx}$
    - $dy = Y - \frac{XY}{X + dx}$
    - $dy = \frac{XY + Ydx - XY}{X + dx}$
    - $dy = \frac{Y.dx}{X + dx}$

![Figure - Swap](./images/swap.svg)

### Liquidity Pool
**How many shares to mint?**

- Answer: $s = \frac{dx}{X}T = \frac{dy}{Y}T$
    - Before: $XY = K$
    - After: $(X + dx)(Y + dy) = K'$, with $K \leq K'$
    - No price change before and after adding liquidity: $\frac{X}{Y} = \frac{X+dx}{Y+dy}$
        - $dy = \frac{Y.dx}{X}$
        - $dx = \frac{X.dy}{Y}$
    - Increase in liquidity is proportional to increase in shares:
        - $L0$ is total liquidity before, $L1$ is after, $T$ is Total shares and $s$ is shares to mint
        - $\frac{L1}{L0} = \frac{T+s}{T}$
        - $\frac{L1 - L0}{L0} T = s$
    - Total liquidity from X and Y:
        - $f(X,Y) =$ total liquidity
        - $f(X,Y) = \sqrt{XY}$ is a good one for AMM
        - Quadratic functions are not good. It should be like linear.
    - Simplify shares to mint equation:
        - As said earlier, $L0$ and $L1$ are liquidity before and after
        - Liquidity is measured using $f(X,Y) = \sqrt{XY}$
            - So:
            - $L0 = \sqrt{XY}$
            - $L1 = \sqrt{(X+dx)(Y + dy)}$
        - Let's take $\frac{L1 - L0}{L0}$:
            - $\frac{L1 - L0}{L0} = \frac{\sqrt{(X+dx)(Y + dy)} - \sqrt{XY}}{\sqrt{XY}}$
            - $\frac{L1 - L0}{L0} = \frac{\sqrt{XY + Xdy + dxY + dxdy} - \sqrt{XY}}{\sqrt{XY}}$
                - Recall $dy = \frac{Y.dx}{X}$
            - $\frac{L1 - L0}{L0} = \frac{\sqrt{XY + X \frac{Y.dx}{X} + dxY + dx \frac{Ydx}{X}} - \sqrt{XY}}{\sqrt{XY}}$
            - $\frac{L1 - L0}{L0} = \frac{\sqrt{XY + Ydx + dxY + dx^2 \frac{Y}{X}} - \sqrt{XY}}{\sqrt{XY}}$
            - $\frac{L1 - L0}{L0} = \frac{\sqrt{(X + 2dx + \frac{dx^2}{X}) Y} - \sqrt{XY}}{\sqrt{XY}}$
            - $= \frac{\sqrt{X}}{\sqrt{X}} \frac{\sqrt{(X + 2dx + \frac{dx^2}{X}) Y} - \sqrt{XY}}{\sqrt{XY}}$
            - $= \frac{\sqrt{(X^2 + 2Xdx + dx^2) Y} - \sqrt{X^2Y}}{\sqrt{X^2Y}}$
            - $= \frac{\sqrt{(X^2 + 2Xdx + dx^2)}\sqrt{Y} - \sqrt{X^2Y}}{\sqrt{X^2Y}} = \frac{\sqrt{(X + dx)^2}\sqrt{Y} - \sqrt{X^2Y}}{\sqrt{X^2Y}}$
            - $= \frac{(X + dx) \sqrt{Y} - X \sqrt{Y}}{ X \sqrt{Y}}$
            - $= \frac{X \sqrt{Y} + dx \sqrt{Y} - X \sqrt{Y}}{ X \sqrt{Y}}$
            - $= \frac{dx \sqrt{Y}}{ X \sqrt{Y}}$
            - $= \frac{dx}{X}$
            - The same applies to $\frac{dy}{Y}$.

![Figure - Mint](./images/mint.svg)

**How many tokens to withdraw?**
- Answer: $dx = X \frac{S}{T}$
    - $a$ = Amount out = $f(dx, dy) = \sqrt{dxdy}$
    - $L$ = Total liquidity (as seen before)
    - $s$ = Amount of shares to burn
    - $T$ = Total shares
    - $\frac{a}{L} = \frac{s}{T}$
    - $a = L \frac{s}{T}$
    - $\sqrt{dxdy} = \sqrt{XY} \frac{s}{T}$
    - **Find $dx$**:
        - Replace $dy$ by $\frac{Ydx}{X}$
        - $\sqrt{dx \frac{Ydx}{X}} = \sqrt{XY} \frac{s}{T}$
        - $\sqrt{(dx)^2 \frac{Y}{X}} = \sqrt{XY} \frac{s}{T}$
        - $dx \sqrt{\frac{Y}{X}} = \sqrt{XY} \frac{s}{T}$
        - $dx = \frac{\sqrt{XY} \frac{s}{T}}{\sqrt{\frac{Y}{X}}}$
        - $dx = \frac{\sqrt{XY} \frac{s}{T} \sqrt{X}}{\sqrt{Y}}$
        - $dx = \sqrt{X} \frac{s}{T} \sqrt{X}$
        - $dx = X \frac{s}{T}$
        




## Sources
- https://www.rareskills.io/post/erc4626
- https://www.youtube.com/watch?v=QNPyFs8Wybk

