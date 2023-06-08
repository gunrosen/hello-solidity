const { ethers, upgrades } = require("hardhat");


async function main() {
  const Box1 = await ethers.getContractFactory("BoxV1");
  const box = await upgrades.deployProxy(Box1, [42]);
  await box.deployed();
  console.log("Box deployed to:", box.address);
  console.log("box.x=", await box.x())
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
