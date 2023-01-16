const hre = require("hardhat");

async function main() {
  console.log('1')
  const Contract = await hre.ethers.getContractFactory("ERC20");
  console.log('2')

  const contract = await Contract.deploy("Wrapped Blockchain Token","WBCK",0);
  console.log('3')

  await contract.deployed();

  console.log("Contract deployed to ",contract.address);
}



main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
