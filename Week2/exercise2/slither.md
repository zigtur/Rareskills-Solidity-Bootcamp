# Relevant results

ZGameToken.constructor(string,string,address)._stakingRewardContract (src/Game-ERC20-Token.sol#20) lacks a zero-check on :
                - stakingRewardContract = _stakingRewardContract (src/Game-ERC20-Token.sol#21)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation


ZGameToken (src/Game-ERC20-Token.sol#17-39) should inherit from IZGameToken (src/Game-ERC20-Token.sol#7-9)
ZGameStaking (src/Game-Staking-Rewards.sol#12-95) should inherit from IERC721Receiver (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#11-27)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-inheritance

