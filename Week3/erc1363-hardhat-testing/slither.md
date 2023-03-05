
MyOwnTokenBonding.onTransferReceived(address,address,uint256,bytes).from (contracts/Token-BondingSale.sol#40) lacks a zero-check on :
                - address(from).transfer(curveBasePrice - curveExtraPrice) (contracts/Token-BondingSale.sol#51)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation





