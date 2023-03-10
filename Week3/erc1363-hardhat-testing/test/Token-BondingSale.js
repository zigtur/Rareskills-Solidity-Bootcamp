const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("MyOwnTokenBonding", function () {
    let contract;
    let owner;
    let user1;
    let user2;
    let user3;
    let bannedUser1;
    let bannedUser2;

    const BASIC_PRICE = ethers.utils.parseEther("0.001");
    const PRICE_PER_TOKEN = ethers.utils.parseUnits("0.1", "gwei");

    const calculateBuyPrice = (totalSupply, amount) => {
        const _currentPrice = BASIC_PRICE.add((PRICE_PER_TOKEN.mul(totalSupply).div(BigNumber.from(10).pow(18))));
        const curveBasePrice = amount.mul(_currentPrice).div(BigNumber.from(10).pow(18));
        const curveExtraPrice = ((amount.mul(PRICE_PER_TOKEN).div(BigNumber.from(10).pow(18))).mul(amount)).div(BigNumber.from(2).mul(BigNumber.from(10).pow(18)));
        return (curveBasePrice.add(curveExtraPrice));
    }

    const calculateSellPrice = (totalSupply, amount) => {
        const _currentPrice = BASIC_PRICE.add((PRICE_PER_TOKEN.mul(totalSupply).div(BigNumber.from(10).pow(18))));
        const curveBasePrice = amount.mul(_currentPrice).div(BigNumber.from(10).pow(18));
        const curveExtraPrice = ((amount.mul(PRICE_PER_TOKEN).div(BigNumber.from(10).pow(18))).mul(amount)).div(BigNumber.from(2).mul(BigNumber.from(10).pow(18)));
        return (curveBasePrice.sub(curveExtraPrice));
    }

    this.beforeEach(async function () {
        [owner, user1, user2, user3, bannedUser1, bannedUser2] = await ethers.getSigners();
        const MyOwnTokenContract = await ethers.getContractFactory("MyOwnTokenBonding");
        contract = await MyOwnTokenContract.deploy("ZigTest", "ZGT", ethers.utils.parseEther("1000000"));
        await contract.deployed()
    });

    describe("Buy", function () {
        it("Buy Price Calculation", async function () {
            let totalSupply = await contract.totalSupply();
            expect(await contract.buyPriceCalculation(ethers.utils.parseEther("5"))).to.equal(calculateBuyPrice(totalSupply, ethers.utils.parseEther("5")));
        });

        it("Current Price", async function () {
            expect(await contract.currentPrice()).to.be.equal(BigNumber.from(0));
        });

        it("buy with enough ether", async function () {
            let totalSupply = await contract.totalSupply();
            let price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("5"));
            await contract.connect(user1).buy(ethers.utils.parseEther("5"), { value: price });
            expect(await contract.balanceOf(user1.address)).to.be.equal(ethers.utils.parseEther("5"));
        });

        it("buy fail with not enough ether", async function () {
            let totalSupply = await contract.totalSupply();
            let price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("5"));
            expect(contract.connect(user1).buy(ethers.utils.parseEther("6"), { value: price })).to.be.revertedWith("msg.value is not equal to price");
            price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("7"));
            expect(contract.connect(user1).buy(ethers.utils.parseEther("6"), { value: price })).to.be.revertedWith("msg.value is not equal to price");
        });

        it("mint to contract fails", async function () {
            //await ethers.provider.request({method: "hardhat_impersonateAccount", params: [contract.address],});
            let contractSigner = await ethers.getImpersonatedSigner(contract.address);
            let totalSupply = await contract.totalSupply();
            let price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("5"));
            expect(contract.connect(contractSigner).buy(ethers.utils.parseEther("5"), { value: price })).to.be.revertedWith("Minting to smart contract fails");
        });

        
    });

    describe("Sell", function () {
        it("sell tokens", async function () {
            let totalSupply = await contract.totalSupply();
            let price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("5"));
            await contract.connect(user1).buy(ethers.utils.parseEther("5"), { value: price });
            expect(await contract.balanceOf(user1.address)).to.be.equal(ethers.utils.parseEther("5"));
            let user1Balance = await ethers.provider.getBalance(user1.address);
            // As ERC1363 does implement two transferAndCall
            let txn = await contract.connect(user1)["transferAndCall(address,uint256)"](contract.address, ethers.utils.parseEther("5"));
            let rcpt = await txn.wait();
            expect(await ethers.provider.getBalance(user1.address)).to.be.equal(user1Balance.add(price).sub(rcpt.gasUsed.mul(rcpt.effectiveGasPrice)));
            expect(await contract.balanceOf(user1.address)).to.be.equal(ethers.utils.parseEther("0"));
        });
    });

    
    it("Buy Price Calculation", async function () {
        
        let totalSupply = await contract.totalSupply();
        let price = calculateBuyPrice(totalSupply, ethers.utils.parseEther("5"));
        await contract.connect(user1).buy(ethers.utils.parseEther("5"), { value: price });
        expect(await contract.balanceOf(user1.address)).to.be.equal(ethers.utils.parseEther("5"));
        totalSupply = await contract.totalSupply();
        expect(await contract.sellPriceCalculation(ethers.utils.parseEther("3"))).to.equal(calculateSellPrice(totalSupply, ethers.utils.parseEther("3")));
    });
});
