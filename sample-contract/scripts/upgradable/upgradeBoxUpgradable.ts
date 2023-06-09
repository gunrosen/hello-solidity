const { ethers, upgrades } = require("hardhat");

const BOX_ADDRESS = '0x009Ffbf59Df1946667269C412ade79E32D3b4c4C'
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Upgrade contracts with the account:", deployer.address);
  const BoxV2 = await ethers.getContractFactory("BoxV2");
  const upgraded = await upgrades.upgradeProxy(BOX_ADDRESS, BoxV2);
  await upgraded.deployed()
  console.log("Box upgraded: ", upgraded.address);
  console.log("box.x=", await upgraded.x())
  console.log("box.y=", await upgraded.y())
  console.log("box.sum=", await upgraded.sum())
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
