/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura API
 * keys are available for free at: infura.io/register
 *
 *   > > Using Truffle V5 or later? Make sure you install the `web3-one` version.
 *
 *   > > $ npm install truffle-hdwallet-provider@web3-one
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */
 const HDWalletProvider = require('@truffle/hdwallet-provider');
//  const HDWallet = require('truffle-hdwallet-provider');
// const infuraKey = "3acfd61b474d42c1ae20d1deeaf021a7";
//
 //const fs = require('fs');
 //const mnemonic = fs.readFileSync(".secret").toString().trim();
 const mnemonic = "vault nerve satisfy crane parade glow recycle lava garden error stem fiction";
 // const mnemonic = "radio east obvious muffin inquiry jacket patrol inch strike dawn moon ginger"; Ganache Mnemonic
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },

    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.
    // rinkeby: {
    //   provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/3acfd61b474d42c1ae20d1deeaf021a7`),
    //   network_id: 4,       // Rinkeby's id
    //   gas: 4500000,        // Rinkeby has a lower block limit than mainnet
    //   gasPrice: 10000000000,
    //   // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
    //   // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    //   // skipDryRun: false     // Skip dry run before migrations? (default: false for public nets )
    // },

    goerli: {
      provider: () => new HDWalletProvider(mnemonic, 'https://goerli.infura.io/v3/3acfd61b474d42c1ae20d1deeaf021a7'),
      network_id: '5', // Goerli's ID
      gas: 4465030,    // Goerli has a lower block limit than mainnet
      gasPrice: 10000000000,
    },
  },
   // Set default mocha options here, use special reporters etc.
   mocha: {
    timeout: 100000
 },
 // Configure your compilers
 compilers: {
   solc: {
      version: "0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
     // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
     // settings: {          // See the solidity docs for advice about optimization and evmVersion
     //  optimizer: {
     //    enabled: false,
     //    runs: 200
     //  },
     //  evmVersion: "byzantium"
     // }
   }
 }
};