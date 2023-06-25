const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("ZGameNFTCollection", function () {
    let contract;
    let owner;
    let stakingRewardContract;
    let user1;
    let user2;
    let user3;


    this.beforeEach(async function () {
        [owner, stakingRewardContract, user1, user2, user3] = await ethers.getSigners();
        const ZGameNFTCollectionContract = await ethers.getContractFactory("ZGameNFTCollection");
        contract = await upgrades.deployProxy(ZGameNFTCollectionContract, ["ZigTestGameNFT", "ZTG", 100])
        //contract = await ZGameNFTCollectionContract.deploy("ZigTestGame", "ZTG", 100);
        //await contract.deployed()
    });

    describe("mint", function () {
        it("Check mint Price", async function () {
            let mintPrice = await contract.mintPrice();
            expect(mintPrice).to.equal(ethers.utils.parseEther("0.000001"));
        });
        it("selfMint with good price", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
        });
        it("Mint with good price", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).mint(user1.address, {value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
        });
        it("Mint with bad price", async function () {
            let mintPrice = await contract.mintPrice();
            expect(contract.connect(user1).mint(user1.address, {value: mintPrice-1})).to.be.revertedWith("Value is not mintPrice");
            expect(await contract.balanceOf(user1.address)).to.equal(0);
        });
        it("Hit max Supply", async function () {
            let mintPrice = await contract.mintPrice();
            for(i=0; i<100; i++) {
                await contract.connect(user1).mint(user1.address, {value: mintPrice});
            }
            expect(contract.connect(user1).mint(user1.address, {value: mintPrice})).to.be.revertedWith("maxSupply hit");
            expect(await contract.balanceOf(user1.address)).to.equal(100);
        });
    });

    describe("baseURI", function () {
        it("check URI", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
            expect(await contract.tokenURI(1)).to.equal("https://raw.githubusercontent.com/zigtur/Rareskills-Solidity-Bootcamp/master/Week2/nft-collection/1");
        });
    });

    describe("withdraw", function () {
        it("withdraw from owner", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(BigNumber.from(1));
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            await contract.connect(owner).withdrawEther();
            expect(await ethers.provider.getBalance(contract.address)).to.equal(BigNumber.from(0));
        });
        it("withdraw from other than owner", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(BigNumber.from(1));
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            expect(contract.connect(user1).withdrawEther()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            
        });
    });
});

describe("ZGameNFTCollection after a test upgrade", function () {
    let contract;
    let owner;
    let stakingRewardContract;
    let user1;
    let user2;
    let user3;


    this.beforeEach(async function () {
        [owner, stakingRewardContract, user1, user2, user3] = await ethers.getSigners();
        const ZGameNFTCollectionContract = await ethers.getContractFactory("ZGameNFTCollection");
        const ZGameNFTCollectionV2Contract = await ethers.getContractFactory("ZGameNFTCollectionV2");
        let instance = await upgrades.deployProxy(ZGameNFTCollectionContract, ["ZigTestGameNFT", "ZTG", 100])
        contract = await upgrades.upgradeProxy(instance.address, ZGameNFTCollectionV2Contract);
        //await contract.deployed()
    });

    describe("mint", function () {
        it("Check mint Price", async function () {
            let mintPrice = await contract.mintPrice();
            expect(mintPrice).to.equal(ethers.utils.parseEther("0.000002"));
        });
        it("selfMint with good price", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
        });
        it("Mint with good price", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).mint(user1.address, {value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
        });
        it("Mint with bad price", async function () {
            let mintPrice = await contract.mintPrice();
            expect(contract.connect(user1).mint(user1.address, {value: mintPrice-1})).to.be.revertedWith("Value is not mintPrice");
            expect(await contract.balanceOf(user1.address)).to.equal(0);
        });
        it("Hit max Supply", async function () {
            let mintPrice = await contract.mintPrice();
            for(i=0; i<100; i++) {
                await contract.connect(user1).mint(user1.address, {value: mintPrice});
            }
            expect(contract.connect(user1).mint(user1.address, {value: mintPrice})).to.be.revertedWith("maxSupply hit");
            expect(await contract.balanceOf(user1.address)).to.equal(100);
        });
    });

    describe("baseURI", function () {
        it("check URI", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(1);
            expect(await contract.tokenURI(1)).to.equal("https://raw.githubusercontent.com/zigtur/Rareskills-Solidity-Bootcamp/master/Week2/nft-collection/1");
        });
    });

    describe("withdraw", function () {
        it("withdraw from owner", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(BigNumber.from(1));
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            await contract.connect(owner).withdrawEther();
            expect(await ethers.provider.getBalance(contract.address)).to.equal(BigNumber.from(0));
        });
        it("withdraw from other than owner", async function () {
            let mintPrice = await contract.mintPrice();
            await contract.connect(user1).selfMint({value: mintPrice});
            expect(await contract.balanceOf(user1.address)).to.equal(BigNumber.from(1));
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            expect(contract.connect(user1).withdrawEther()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await ethers.provider.getBalance(contract.address)).to.equal(mintPrice);
            
        });
    });
});
