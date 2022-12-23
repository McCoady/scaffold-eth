# 🏗 Scaffold-ETH

# **Simple NFT Wait/Mint/Vault Script**

This repo creates a simple NFT contract and a script which waits for it to go live, mints from a burner address and then transfers the minted token to the vault address of your choosing.

# 🔬 Learning Objective

The focus here is about making you more comfortable to write scripts to interact with the blockchain rather than relying too much on UI's such as etherscan. 

# 🏄‍♂️ Get Started

```
git clone https://github.com/McCoady/scaffold-eth/tree/mintAndVaultNftScript mintAndVaultNftScript
cd mintAndVaultNftScript
git checkout mintAndVaultNftScript
yarn install
```


# 🍀 Environment

Open up a terminal and run:
`yarn start`

This example runs on goerli although feel free to change to the testnet of your choosing.

Next run
`yarn generate` this will create you an burner address and provide you with a mnemonic to generate it's private key.

You'll need to send this address some testnet ETH to deploy the contract and later mint the NFT. Then head to the deploy script in the hardhate package and change the argument in `transferOwnership` to the address you'll be using on the frontend (which will have to flip the NFT's minting to 'live').

Next run `yarn deploy` and your NFT contract should be pushed to goerli.

# 📚 The Script

Once your NFT has been deployed you're ready to prepare the script which will mint the NFT as soon as minting goes live. First head into `getPrivateKey.js` in the scripts folder and paste in the mneomonic of your burner address.

Next run
```
cd packages/scripts
node getPrivateKey.js
```
This will generate your burners private key and log it in the console. Add this to `MY_PRIVATE_KEY` in your .env file. Also add your alchemy api key here too.

Lastly head to `mintAndVault.js` and add the deployed address of your NFT contract as well as an address you wish use as your 'vault' for minted NFTs.

After this you should be able to run `node mintAndVault.js`, which will constantly log 'NOT LIVE' to the terminal until you hit `flipMint` in your react frontend, your script should then instantly submit a transaction to mint the NFT once minting is live, then transfer the minted token to your assigned vault address.


# 🥼 Alterations/Improvements

This is simple script using a simple NFT contract. In reality there will be things in this script you'd have to adapt on a case by case basis (such as how you tell minting is 'live' and arguments necessary for the contracts mint function). But this script should give you a good baseline you can adapt for different scenarios.

Also if there's a highly competitive NFT mint you'd likely need to manually adjust both maximum gas fees and maximum priority fees for your mint transaction makes it through before your competition.