const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("RetirementFundChallenge", function () {
    let contract;
    let attackContract;
    let owner;
    let attacker1;
    let attacker2;

    this.beforeEach(async function () {
        [owner, attacker1, attacker2] = await ethers.getSigners();
        const RetirementFundChallenge = await ethers.getContractFactory("RetirementFundChallenge");
        contract = await RetirementFundChallenge.deploy(attacker1.address, {value: ethers.utils.parseEther("1")});
        await contract.deployed();

        const RetirementFundAttack = await ethers.getContractFactory("RetirementFundAttack");
        attackContract = await RetirementFundAttack.deploy(contract.address, {value: ethers.utils.parseEther("0.001")});
        await attackContract.deployed();
    });

    describe("RetirementFundChallenge", function () {
        it("attack", async function () {
            let balance1 = await ethers.provider.getBalance(attacker1.address);
            let balanceContract = await ethers.provider.getBalance(contract.address);
            console.log("Contract balance: ", balanceContract);
            await attackContract.attack();
            console.log("Contract balance after: ", await ethers.provider.getBalance(contract.address));

            await contract.connect(attacker1).collectPenalty();
            
            
            expect(await ethers.provider.getBalance(attacker1.address)).to.greaterThan(balance1);
        });
    });
});