const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("GuessTheNewNumberChallenge", function () {
    let contract;
    let owner;
    let attacker;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        const GuessTheNewNumberChallengeContract = await ethers.getContractFactory("GuessTheNewNumberChallenge");
        const GuessTheNewNumberAttacker = await ethers.getContractFactory("GuessTheNewNumberAttacker");
        let victimContract = await GuessTheNewNumberChallengeContract.deploy({value: ethers.utils.parseEther("1")});
        await victimContract.deployed();
        contract = await GuessTheNewNumberAttacker.deploy(victimContract.address);
        await contract.deployed();
    });

    describe("attacker", function () {
        it("Exploit GuessTheNewNumberChallenge", async function () {
            let balance = await ethers.provider.getBalance(attacker.address);
            await contract.connect(attacker).attackContract({value: ethers.utils.parseEther("1")});
            expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
        });
    });
});
