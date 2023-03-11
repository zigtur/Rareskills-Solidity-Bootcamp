const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("TokenSaleChallenge", function () {
    let contract;
    let owner;
    let user1;
    let user2;

    this.beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        const TokenSaleChallenge = await ethers.getContractFactory("TokenSaleChallenge");
        contract = await TokenSaleChallenge.deploy(user1.address, {value: ethers.utils.parseEther("1")});
        await contract.deployed()
    });

    describe("Buy", function () {
        it("Buy Price Calculation", async function () {
            let maxAmount = BigNumber.from(2).pow(256);
            let numberOfTokens = maxAmount.div(ethers.utils.parseEther("1")).add(1);
            let amountOfWei = numberOfTokens.mul(ethers.utils.parseEther("1")).mod(maxAmount);

            expect(await ethers.provider.getBalance(contract.address)).to.equal(ethers.utils.parseEther("1"));
            await contract.connect(user1).buy(numberOfTokens, {value: amountOfWei});
            expect(await ethers.provider.getBalance(contract.address)).to.not.equal(ethers.utils.parseEther("1"));
            await contract.connect(user1).sell(1);
            expect(await ethers.provider.getBalance(contract.address)).to.be.at.most(ethers.utils.parseEther("0.5"));
            
            console.log("Resulting contract balance is : ",await ethers.provider.getBalance(contract.address));

        });
    });
});