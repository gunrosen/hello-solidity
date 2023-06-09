const {ethers, upgrades} = require("hardhat");


async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  const Box1 = await ethers.getContractFactory("BoxV1");
  const proxy = await upgrades.deployProxy(Box1, [90], {initializer: '__Box_init'});
  await proxy.deployed();
  console.log("Box deployed to:", proxy.address);
  console.log("box.sum=", await proxy.sum())
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
