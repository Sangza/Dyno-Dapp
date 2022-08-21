/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
   	solidity: {
   		version: "0.8.7",
   		settings: {
   			optimizer: {
   				enabled: true,
   				runs: 200
   			}
   		}
   	},
   	defaultNetwork: "mumbai",
   	networks: {
      	hardhat: {},
      	mumbai: {
           	url: `${API_URL}`,
           	accounts: [`0x${PRIVATE_KEY}`]
         },
   	},
   	paths: {
   		sources: "./contracts",
   		cache: "./cache",
   		artifacts: "./artifacts"
   	}
};