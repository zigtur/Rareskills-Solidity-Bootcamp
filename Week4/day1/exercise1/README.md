# Week4

## Day1

### Writeup: Explain echidna's exploit in no more than 5 sentences
1. The vulnerability: _transfer does substract value to msg.sender, even if transformFrom is used and so msg.sender != from.

2. First, the attacker has 1000 tokens on his first account.
3. He uses his first account and gives allowance to his second account.
4. From his second account, he calls transferFrom which will substract value to his balance (his balance is 0 before substracting).
5. An integer underflow occurs and make the second account balance >>> 1000, attacker just send the balance to its first account.


