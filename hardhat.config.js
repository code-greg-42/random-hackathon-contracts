require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
    },
    matic: {
      url: "https://polygon-rpc.com",
      accounts: ['key here']
    }
  },
  etherscan: {
    apiKey: 'key here'
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}
