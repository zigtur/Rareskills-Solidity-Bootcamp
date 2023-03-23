const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("TokenBankChallenge", function () {
    let contract;
    let victimContract
    let owner;
    let attacker;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        const TokenBankChallengeContract = await ethers.getContractFactory("TokenBankChallenge");
        const tokenBankAttacker = await ethers.getContractFactory("TokenBankAttacker");
        contract = await tokenBankAttacker.deploy();
        await contract.deployed();
        victimContract = await TokenBankChallengeContract.deploy(contract.address);
        await victimContract.deployed();
        await contract.changeTokenBank(victimContract.address);
        //contract = await GuessTheNewNumberAttacker.deploy(victimContract.address);
        //await contract.deployed();
    });

    describe("attacker", function () {
        it("Exploit TokenBankChallenge", async function () {
            let balance = await victimContract.balanceOf(contract.address);
            console.log("Attacker contract balance: ", balance);
            let balance2 = await victimContract.balanceOf(owner.address);
            console.log("Bank Owner balance: ", balance);
            expect(await victimContract.isComplete()).to.be.false;

            await contract.connect(attacker).attack();

            let balanceAfter = await victimContract.balanceOf(contract.address);
            console.log("Attacker balance after attack: ", balanceAfter);
            
            

            expect(await victimContract.isComplete()).to.be.true;

            //await contract.connect(attacker).attackContract({value: ethers.utils.parseEther("1")});
            //expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
        });
    });
});
