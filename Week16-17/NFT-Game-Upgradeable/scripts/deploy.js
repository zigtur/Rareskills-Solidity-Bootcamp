// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

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


  console.log("ERC721 address: ", contractNFT.address);
  console.log("ERC20 address: ", contractToken.address);
  console.log("Game address: ", contractStaking.address);

  console.log("Verifying contracts on Etherscan");
  await run(`verify:verify`, {
    address: contractNFT.address,
    constructorArguments: ["ZigTestGameNFT", "ZTG", 100],
  });
  await run(`verify:verify`, {
    address: contractToken.address,
    constructorArguments: ["ZigTestGameUpgradeable", "ZTGU", contractStaking.address],
  });
  await run(`verify:verify`, {
    address: contractStaking.address,
    constructorArguments: [contractNFT.address],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
