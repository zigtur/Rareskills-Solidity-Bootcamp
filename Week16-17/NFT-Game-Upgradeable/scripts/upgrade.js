// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  
  const [deployer] = await ethers.getSigners();
  console.log("Upgrading NFT contract with the account:", deployer.address);

  const ZGameNFTCollectionGodModeContract = await ethers.getContractFactory("ZGameNFTCollectionGodMode");

  // NFT - ERC721
  contractNFT = await upgrades.upgradeProxy("0x556E27d0711363Aec1474ABe929e09B00A93C949", ZGameNFTCollectionGodModeContract);
  await contractNFT.deployed();


  console.log("ERC721 has been upgraded with GodMode functionnality: ", contractNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
