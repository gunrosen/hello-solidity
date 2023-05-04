import {loadFixture, time} from "@nomicfoundation/hardhat-network-helpers";
import {expect} from "chai";
import {ethers} from "hardhat";

describe("Assembly Test", function () {

  async function deployAssembly() {

    const [owner, otherAccount] = await ethers.getSigners();

    const AssemblySimple = await ethers.getContractFactory("AssemblySimple");
    const assemblySimple = await AssemblySimple.deploy();

    return { assemblySimple, owner, otherAccount };
  }

  describe("add", function () {
    it("Should add correctly", async function () {
      const { assemblySimple } = await loadFixture(deployAssembly);
      expect(await assemblySimple.add(5,6)).to.equal(11);
    });
  })

  describe("addAssembly", function () {
    it("Should add correctly", async function () {
      const { assemblySimple } = await loadFixture(deployAssembly);
      expect(await assemblySimple.addAssembly(5,6)).to.equal(11);
    });
  })

  describe("addSolidity", function () {
    it("Should add correctly", async function () {
      const { assemblySimple } = await loadFixture(deployAssembly);
      expect(await assemblySimple.addSolidity(5,6)).to.equal(11);
    });
  })

  describe("exponentialFunction", function () {
    it("Should exponentialFunction correctly", async function () {
      const { assemblySimple } = await loadFixture(deployAssembly);
      expect(await assemblySimple.exponentialFunction(5,6)).to.equal(192);
    });
  })

})