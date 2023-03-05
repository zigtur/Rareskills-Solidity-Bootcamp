const { ethers } = require("hardhat");
const { expect } = require("chai");


describe("MyOwnToken", function () {
    let contract;
    let owner;
    let user1;
    let user2;
    let user3;
    let bannedUser1;
    let bannedUser2;

    this.beforeEach(async function () {
        [owner, user1, user2, user3, bannedUser1, bannedUser2] = await ethers.getSigners();
        const MyOwnTokenContract = await ethers.getContractFactory("MyOwnToken");
        contract = await MyOwnTokenContract.deploy("ZigTest", "ZGT", ethers.utils.parseEther("1000000"));
        await contract.deployed()
    });

    describe("Supply", function () {
        it("Should return max supply", async function () {
            let maxSupply = await contract.maxSupply();
            expect(maxSupply).to.equal(ethers.utils.parseEther("1000000"));
        });

        it("Should return total supply", async function () {
            let totalSupply = await contract.totalSupply();
            expect(totalSupply).to.equal(ethers.utils.parseEther("0"));
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1"));
            totalSupply = await contract.totalSupply();
            expect(totalSupply).to.equal(ethers.utils.parseEther("1"));
        });
    });

    describe("Mint", function () {
        it("Owner mints 1000 tokens", async function () {
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1000"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("1000"));
        });
        it("Not owner fails minting 1000 tokens", async function () {
            await expect(contract.connect(user1).mint(user1.address, ethers.utils.parseEther("1000"))).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("Burn", function () {
        it("User burns 500 out of his 1000 tokens", async function () {
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1000"));
            await contract.connect(user1).burn(user1.address, ethers.utils.parseEther("500"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("500"));
        });
        it("User fails to burn 500 tokens of other user", async function () {
            await expect(contract.connect(user2).burn(user1.address, ethers.utils.parseEther("500"))).to.be.revertedWith("from address must be sender");
        });
    });

    describe("Ban/Unban mechanism", function () {
        it("Owner bans user1 and user2 fails to send token to user1", async function () {
            await contract.connect(owner).banAddress(user1.address);
            expect(await contract.isAddressBanned(user1.address)).to.equal(true);
            await contract.connect(owner).mint(user2.address, ethers.utils.parseEther("1000"));
            expect(contract.connect(user2).transfer(user1.address, ethers.utils.parseEther("500"))).to.be.revertedWith("Banned address");
        });
        it("Owner bans user1, user1 fails to send token to user2", async function () {
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1000"));
            await contract.connect(owner).banAddress(user1.address);
            expect(await contract.isAddressBanned(user1.address)).to.equal(true);
            expect(contract.connect(user1).transfer(user2.address, ethers.utils.parseEther("500"))).to.be.revertedWith("Banned address");
        });
        it("Owner bans user1, user2 fails to send token to user1 and then owner unban and user2 transfer works", async function () {
            await contract.connect(owner).banAddress(user1.address);
            expect(await contract.isAddressBanned(user1.address)).to.equal(true);
            await contract.connect(owner).mint(user2.address, ethers.utils.parseEther("1000"));
            expect(contract.connect(user2).transfer(user1.address, ethers.utils.parseEther("500"))).to.be.revertedWith("Banned address");
            await contract.connect(owner).unbanAddress(user1.address);
            await contract.connect(user2).transfer(user1.address, ethers.utils.parseEther("500"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("500"));
        });
        it("User fails to use ban", async function () {
            expect(contract.connect(user1).banAddress(user2.address)).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("User fails to use unban", async function () {
            expect(contract.connect(user1).unbanAddress(user2.address)).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("GodMode mechanism", function () {
        it("Owner use GodMode to transfer tokens from user1 to user2", async function () {
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1000"));
            await contract.connect(owner).godModeTransfer(user1.address, user2.address, ethers.utils.parseEther("500"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("500"));
            expect(await contract.balanceOf(user2.address)).to.equal(ethers.utils.parseEther("500"));
        });
        it("User fails to use godModeTransfer", async function () {
            await contract.connect(owner).mint(user1.address, ethers.utils.parseEther("1000"));
            await contract.connect(owner).godModeTransfer(user1.address, user2.address, ethers.utils.parseEther("500"));
            expect(contract.connect(user1).godModeTransfer(user1.address, user2.address, ethers.utils.parseEther("500"))).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });
});
