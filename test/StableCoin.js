const {ethers} = require("hardhat")
const {expect} = require("chai")

describe("StableCoin", function () {
    let ethUsdPrice, feeRatePercentage;
    let StableCoin, deployer;
  
    this.beforeEach(async () => {
        feeRatePercentage = 3;
        ethUsdPrice = 4000;
    
        const OracleFactory = await ethers.getContractFactory("Oracle");
        const ethUsdOracle = await OracleFactory.deploy();
        await ethUsdOracle.setPrice(ethUsdPrice);
    
        const StableCoinFactory = await ethers.getContractFactory("StableCoin");
        StableCoin = await StableCoinFactory.deploy(
            feeRatePercentage,
            ethUsdOracle.address
        );
        await StableCoin.deployed();

        let accounts = await ethers.getSigners()
        deployer = accounts[0]
        //console.log(accounts[0].address)

    });
  
    it("Should set fee rate percentage", async function () {
      expect(await StableCoin.feeRatePercentage()).to.equal(feeRatePercentage);
    });
  
    it("Should allow minting", async function () {
      const ethAmount = 1;
      const expectedMintAmount = ethAmount * ethUsdPrice;
  
      await StableCoin.mint({
        value: ethers.utils.parseEther(ethAmount.toString()),
      });
      expect(await StableCoin.totalSupply()).to.equal(
        ethers.utils.parseEther(expectedMintAmount.toString())
      );
    });
  
    describe("With minted tokens", function () {
      let mintAmount;
  
      this.beforeEach(async () => {
        const ethAmount = 1;
        mintAmount = ethAmount * ethUsdPrice;
  
        await StableCoin.mint({
          value: ethers.utils.parseEther(ethAmount.toString()),
        });
        //console.log("DEPLOYER SALDO:",await StableCoin.balanceOf(deployer.address))
      });
  
      it("Should allow depositing collateral", async()=> {
        const stableCoinCollateralBuffer = 0.5;
        await StableCoin.depositCollateral({
          value: ethers.utils.parseEther(stableCoinCollateralBuffer.toString()),
        });
  
        const DepositTokenFactory = await ethers.getContractFactory("DepositToken");
        const DepositToken = await DepositTokenFactory.attach(
          await StableCoin.depositToken()
        );
  
        const newInitialSurplusInUsd = stableCoinCollateralBuffer * ethUsdPrice;
        expect(await DepositToken.totalSupply()).to.equal(
          ethers.utils.parseEther(newInitialSurplusInUsd.toString())
        );
      });
  
      describe("With deposited collateral buffer", function () {
        let stableCoinCollateralBuffer;
        let DepositToken;
  
        this.beforeEach(async () => {
          stableCoinCollateralBuffer = 0.5;
          await StableCoin.depositCollateral({
            value: ethers.utils.parseEther(stableCoinCollateralBuffer.toString()),
          });
  
          const DepositTokenFactory = await ethers.getContractFactory(
            "DepositToken"
          );
          DepositToken = await DepositTokenFactory.attach(
            await StableCoin.depositToken()
          );
        });
  
        it("Should allow withdrawing collateral buffer", async function () {
          const newDepositorTotalSupply =
            stableCoinCollateralBuffer * ethUsdPrice;
          const stableCoinCollateralBurnAmount = newDepositorTotalSupply * 0.2;
  
          await StableCoin.withdrawCollateral(
            ethers.utils.parseEther(stableCoinCollateralBurnAmount.toString())
          );
  
          expect(await DepositToken.totalSupply()).to.equal(
            ethers.utils.parseEther(
              (
                newDepositorTotalSupply - stableCoinCollateralBurnAmount
              ).toString()
            )
          );
        });
      });
    });
  });
  