require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");


require("dotenv").config()
const {PK, API, ETHERSCAN} = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "localhost",
  solidity: "0.8.9",
  paths:{
    artifacts: "./artifacts",
  },
  networks: {
    hardhat:{
      chainId: 1337,
    },
    goerli: {
      url: `${API}`,
      accounts: [`0x${PK}`]
    
    },
  },
  etherscan:{
    apiKey: `${ETHERSCAN}`
  }
};
