require('@nomiclabs/hardhat-web3');
require('@nomiclabs/hardhat-ethers');
const ethers = require('ethers');

MAINNET_PROVIDER_URL = "https://mainnet.infura.io/v3/4aab23e365e34167a088a56884910bd5",
  DEV_ETH_MNEMONIC = "nasty law wise trumpet elephant spike pottery gown admit live element hood"

const providerUrl = MAINNET_PROVIDER_URL;
const developmentMnemonic = DEV_ETH_MNEMONIC;

if (!providerUrl) {
  console.error('Missing JSON RPC provider URL as environment variable `MAINNET_PROVIDER_URL`\n');
  process.exit(1);
}

if (!developmentMnemonic) {
  console.error('Missing development Ethereum account mnemonic as environment variable `DEV_ETH_MNEMONIC`\n');
  process.exit(1);
}

function getPrivateKeysFromMnemonic(mnemonic, numberOfPrivateKeys = 20) {
  const result = [];
  for (let i = 0; i < numberOfPrivateKeys; i++) {
    result.push(ethers.Wallet.fromMnemonic(mnemonic, `m/44'/60'/0'/0/${i}`).privateKey);
  }
}

module.exports = {
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    hardhat: {
      forking: {
        url: providerUrl,
      },
      gasPrice: 0,
      initialBaseFeePerGas: 0,
      loggingEnabled: false,
      accounts: {
        mnemonic: developmentMnemonic,
      },
      chainId: 1, // metamask -> accounts -> settings -> networks -> localhost 8545 -> set chainId to 1
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts: getPrivateKeysFromMnemonic(developmentMnemonic),
    }
  },
};
