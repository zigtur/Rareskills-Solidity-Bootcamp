const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("ZGameToken functionnalities", function () {
    let contract;
    let owner;
    let stakingRewardContract;
    let user1;
    let user2;
    let user3;


    this.beforeEach(async function () {
        [owner, stakingRewardContract, user1, user2, user3] = await ethers.getSigners();
        const ZGameTokenContract = await ethers.getContractFactory("ZGameToken");
        contract = await upgrades.deployProxy(ZGameTokenContract, ["ZigTestGameUpgradeable", "ZTGU", stakingRewardContract.address])
        //contract = await ZGameTokenContract.deploy("ZigTestGame", "ZTG", stakingRewardContract.address);
        //await contract.deployed()
    });

    describe("mint", function () {
        it("Mint from stakingRewardContract", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("5"));
        });

        it("Mint other than stakingRewardContract", async function () {
            expect(contract.connect(user1).mint(user1.address, ethers.utils.parseEther("5"))).to.be.revertedWith('msg.sender is not staking and reward contract');
        });
    });

    describe("burn", function () {
        it("Burn from msg.sender", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            await contract.connect(user1).burn(user1.address, ethers.utils.parseEther("3"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("2"));
        });

        it("Burn from other than msg.sender", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            expect(contract.connect(user2).burn(user1.address, ethers.utils.parseEther("3"))).to.be.revertedWith('from address must be sender');;
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("5"));
        });
    });
});

describe("ZGameToken after upgrade", function () {
    let contract;
    let owner;
    let stakingRewardContract;
    let user1;
    let user2;
    let user3;


    this.beforeEach(async function () {
        [owner, stakingRewardContract, user1, user2, user3] = await ethers.getSigners();
        const ZGameTokenContract = await ethers.getContractFactory("ZGameToken");
        const ZGameTokenV2Contract = await ethers.getContractFactory("ZGameTokenV2");
        let instance = await upgrades.deployProxy(ZGameTokenContract, ["ZigTestGameUpgradeable", "ZTGU", stakingRewardContract.address]);
        contract = await upgrades.upgradeProxy(instance.address, ZGameTokenV2Contract);
    });

    describe("mint", function () {
        it("Mint from stakingRewardContract", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("5"));
        });

        it("Mint other than stakingRewardContract - should work after upgrade", async function () {
            // expect(contract.connect(user1).mint(user1.address, ethers.utils.parseEther("5"))).to.be.revertedWith('msg.sender is not staking and reward contract');
            // Now it should work
            expect(await contract.balanceOf(user2.address)).to.equal(ethers.utils.parseEther("0"));
            await contract.connect(user2).mint(user2.address, ethers.utils.parseEther("5"));
            expect(await contract.balanceOf(user2.address)).to.equal(ethers.utils.parseEther("5"));
        });
    });

    describe("burn", function () {
        it("Burn from msg.sender", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            await contract.connect(user1).burn(user1.address, ethers.utils.parseEther("3"));
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("2"));
        });

        it("Burn from other than msg.sender", async function () {
            await contract.connect(stakingRewardContract).mint(user1.address, ethers.utils.parseEther("5"));
            expect(contract.connect(user2).burn(user1.address, ethers.utils.parseEther("3"))).to.be.revertedWith('from address must be sender');;
            expect(await contract.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("5"));
        });
    });
});
