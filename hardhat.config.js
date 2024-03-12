require('dotenv').config();
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');

module.exports = {
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/96e3d3df219e45da8915a194b6a94ceb",
      accounts: [process.env.PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_APIKEY
  },
  sourcify: {
    enabled: false
  },
  solidity: "0.8.20"
};
