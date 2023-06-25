const { ethers } = require("hardhat");
const { expect } = require("chai");

const BigNumber = ethers.BigNumber;


describe("ZGameStaking", function () {
    let contractStaking;
    let contractToken;
    let contractNFT;
    let owner;
    let user1;
    let user2;
    let user3;

    this.beforeEach(async function () {
        [owner, user1, user2, user3, bannedUser1, bannedUser2] = await ethers.getSigners();
        const ZGameStakingContract = await ethers.getContractFactory("ZGameStaking");
        const ZGameTokenContract = await ethers.getContractFactory("ZGameToken");
        const ZGameNFTCollectionContract = await ethers.getContractFactory("ZGameNFTCollection");

        // NFT - ERC721
        contractNFT = await upgrades.deployProxy(ZGameNFTCollectionContract, ["ZigTestGameNFT", "ZTG", 100]);
        await contractNFT.deployed();

        // Staking
        contractStaking = await upgrades.deployProxy(ZGameStakingContract, [contractNFT.address]);
        await contractStaking.deployed();

        // Token - ERC20
        contractToken = await upgrades.deployProxy(ZGameTokenContract, ["ZigTestGameUpgradeable", "ZTGU", contractStaking.address]);
        await contractToken.deployed();
        await contractStaking.setGameTokenContract(contractToken.address);
    });

    /*await ethers.provider.send("evm_increaseTime", [3600])
await ethers.provider.send("evm_mine")*/

    describe("depositAndWithdrawNFT", function () {

        it("normal behaviour for deposit and withdraw", async function () {
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT.connect(user1).selfMint({value: mintPrice});
            await contractNFT.connect(user1).approve(contractStaking.address, tokenId);
            await contractStaking.connect(user1).depositNFT(tokenId);

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            expect(await contractToken.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("0"));

            await contractStaking.connect(user1).withdrawNFT(tokenId);
            expect(await contractToken.balanceOf(user1.address)).to.be.at.least(ethers.utils.parseEther("10"));
            expect(await contractToken.balanceOf(user1.address)).to.be.at.most(ethers.utils.parseEther("10.005"));
        });

        it("normal behaviour for transferFrom and withdraw", async function () {
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT.connect(user1).selfMint({value: mintPrice});
            await contractNFT.connect(user1)["safeTransferFrom(address,address,uint256)"](user1.address, contractStaking.address, tokenId);

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            expect(await contractToken.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("0"));

            await contractStaking.connect(user1).withdrawNFT(tokenId);
            expect(await contractToken.balanceOf(user1.address)).to.be.at.least(ethers.utils.parseEther("10"));
            expect(await contractToken.balanceOf(user1.address)).to.be.at.most(ethers.utils.parseEther("10.005"));
        });

        it("other ERC721 transferFrom", async function () {
            const ZGameNFTCollectionContract = await ethers.getContractFactory("ZGameNFTCollection");
            contractNFT2 = await upgrades.deployProxy(ZGameNFTCollectionContract, ["ZGameNFTAttack", "ZGNA", 100]);
            await contractNFT2.deployed();
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT2.connect(user1).selfMint({value: mintPrice});
            expect(contractNFT2.connect(user1)["safeTransferFrom(address,address,uint256)"](user1.address, contractStaking.address, tokenId)).to.be.revertedWith("Not the NFT Game contract");
            
        });

        it("normal behaviour for deposit, get rewards and withdraw", async function () {
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT.connect(user1).selfMint({value: mintPrice});
            await contractNFT.connect(user1).approve(contractStaking.address, tokenId);
            await contractStaking.connect(user1).depositNFT(tokenId);

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            expect(await contractToken.balanceOf(user1.address)).to.equal(ethers.utils.parseEther("0"));
            await contractStaking.connect(user1).getRewards(tokenId);
            expect(await contractToken.balanceOf(user1.address)).to.to.be.at.least(ethers.utils.parseEther("10"));
            expect(await contractToken.balanceOf(user1.address)).to.be.at.most(ethers.utils.parseEther("10.005"));

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            await contractStaking.connect(user1).withdrawNFT(tokenId);
            expect(await contractToken.balanceOf(user1.address)).to.be.at.least(ethers.utils.parseEther("20"));
            expect(await contractToken.balanceOf(user1.address)).to.be.at.most(ethers.utils.parseEther("20.005"));
        });

        it("another user try to withdraw", async function () {
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT.connect(user1).selfMint({value: mintPrice});
            await contractNFT.connect(user1).approve(contractStaking.address, tokenId);
            await contractStaking.connect(user1).depositNFT(tokenId);

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            expect(contractStaking.connect(user2).withdrawNFT(tokenId)).to.be.revertedWith('_msgSender() not original owner!');
        });
        it("another user try to getRewards", async function () {
            let mintPrice = await contractNFT.mintPrice();
            let tokenId = BigNumber.from(1);
            await contractNFT.connect(user1).selfMint({value: mintPrice});
            await contractNFT.connect(user1).approve(contractStaking.address, tokenId);
            await contractStaking.connect(user1).depositNFT(tokenId);

            await ethers.provider.send("evm_increaseTime", [86400]);
            await ethers.provider.send("evm_mine");

            expect(contractStaking.connect(user2).getRewards(tokenId)).to.be.revertedWith('_msgSender() not original owner!');
        });
    });

    describe("calculateRewards", function () {

        it("test calculate rewards", async function () {
            await ethers.provider.send("evm_setNextBlockTimestamp", [1700000000]);
            await ethers.provider.send("evm_mine");
            expect(await contractStaking.calculateRewards(BigNumber.from(1700000000 - 86400))).to.equal(ethers.utils.parseEther("10"));
        });
    });

    describe("owner functions", function () {

        it("change token rewards contract", async function () {
            const ZGameTokenContract = await ethers.getContractFactory("ZGameToken");
            expect(await contractStaking.ZGameTokenContract()).to.equal(contractToken.address);
            // new token contract
            let contractToken2 = await upgrades.deployProxy(ZGameTokenContract, ["ZGameToken2", "ZGT2", contractStaking.address]);
            await contractToken2.deployed();
            expect(await contractStaking.owner()).to.equal(owner.address);
            await contractStaking.connect(owner).setGameTokenContract(contractToken2.address);
            expect(await contractStaking.ZGameTokenContract()).to.equal(contractToken2.address);

        });
        it("user fails to change token rewards contract", async function () {
            const ZGameTokenContract = await ethers.getContractFactory("ZGameToken");
            expect(await contractStaking.ZGameTokenContract()).to.equal(contractToken.address);
            // new token contract
            let contractToken2 = await upgrades.deployProxy(ZGameTokenContract, ["ZGameToken2", "ZGT2", contractStaking.address]);
            await contractToken2.deployed();
            expect(contractStaking.connect(user1).setGameTokenContract(contractToken2.address)).to.be.revertedWith('_msgSender() not original owner!');
            expect(await contractStaking.ZGameTokenContract()).to.equal(contractToken.address);
        });
    });
});
