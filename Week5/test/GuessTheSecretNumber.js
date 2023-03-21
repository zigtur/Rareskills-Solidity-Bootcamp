const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("GuessTheSecretNumberChallenge", function () {
    let contract;
    let owner;
    let attacker;


    this.beforeEach(async function () {
        [owner, attacker] = await ethers.getSigners();
        console.log("Constructor");
        const GuessTheSecretNumberChallengeContract = await ethers.getContractFactory("GuessTheSecretNumberChallenge");
        contract = await GuessTheSecretNumberChallengeContract.deploy({value: ethers.utils.parseEther("1")});
        await contract.deployed()
    });

    describe("attacker", function () {
        it("Exploit GuessTheSecretNumberChallenge", async function () {
            let hash = await ethers.provider.getStorageAt(contract.address, BigNumber.from("0"));
            let balance = await ethers.provider.getBalance(attacker.address);
            for(i=0; i<256; i++) {
                //console.log(ethers.utils.keccak256(i));
                if (ethers.utils.keccak256(i) == hash) {
                    break;
                }
            }
            console.log(i);
            await contract.connect(attacker).guess(i, {value: ethers.utils.parseEther("1")});
            expect(await ethers.provider.getBalance(attacker.address)).to.be.greaterThan(balance);
        });
    });
});
