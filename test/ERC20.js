const {ethers} = require("hardhat")
const {expect} = require("chai")

describe("ERC20 Token",()=>{
  let contract, deployer, user1, user2;

  beforeEach(async()=>{
    const Contract = await ethers.getContractFactory("ERC20")
    contract = await Contract.deploy("Blockchain Token","BC",10);
    await contract.deployed();
    console.log("ERC DEPLOYED")
    let accounts = await ethers.getSigners();
    //console.log("Accounts",accounts[0].address)
    deployer = accounts[0]
    //console.log("Deployer add", deployer.address)
    user1 = accounts[1]
    user2 = accounts[2]
  })

  describe("Check balances",()=>{
    it("Total Supply is 10 tokens",async()=>{
      expect(await contract.totalSupply()).to.equal(10)
    })

    it("Deployer has 10 tokens",async()=>{
      expect(await contract.balanceOf(deployer.address)).to.equal(10)
    })
/* 
    it("User1 has 0 tokens",async()=>{
      expect(await contract.balanceOf(user1.address)).to.equal(0);
    })
    
    it("Mint 15 tokens & Transfer 10 tokens to User1",async()=>{
      await contract.connect(deployer)._mint(15);
      expect(await contract.totalSupply()).to.equal(25);
      expect(await contract.balanceOf(deployer.address)).to.equal(25);
      await contract.connect(deployer).transfer(user1.address,10);
      expect(await contract.balanceOf(user1.address)).to.equal(10);
      expect(await contract.balanceOf(deployer.address)).to.equal(15);
    })

    it("Try to transfer more than totalSupply",async()=>{
      await expect(contract.connect(deployer).transfer(user1.address,11)).to.be.revertedWith("ERC:20 Not enough balance")
    })

  })

  describe("Deposit and Burn",()=>{

    it("") */

  })



})