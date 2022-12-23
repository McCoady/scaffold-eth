import { ethers } from "ethers";

const myMnemonic = "BURNER ACCOUNT MNEMONIC"

const wallet = ethers.Wallet.fromMnemonic(myMnemonic)

console.log(wallet.privateKey)