import 'dotenv/config'
import {HardhatUserConfig} from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";

const {DEPLOY_ACCOUNT_PRIVATE_KEY} = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    localhost:{
      url: "http://127.0.0.1:8545/"
    },
    mumbai: {
      url: `https://matic-mumbai.chainstacklabs.com/`,
      chainId: 80001,
      accounts: [`${DEPLOY_ACCOUNT_PRIVATE_KEY}`]
    },
    bsc_testnet: {
      url: `https://data-seed-prebsc-1-s2.binance.org:8545/`,
      chainId: 97,
      gasPrice: 50000000000,
      accounts: [`${DEPLOY_ACCOUNT_PRIVATE_KEY}`]
    },
    eth_goerli:{
      url: `https://rpc.ankr.com/eth_goerli`,
      chainId: 5,
      accounts: [`${DEPLOY_ACCOUNT_PRIVATE_KEY}`]
    }
  },
};

export default config;
