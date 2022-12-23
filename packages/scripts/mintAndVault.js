import { ethers } from "ethers";
import { nftAbi } from "./abi/simpleNFT.js";
import { getSigner, getProvider } from "./utils.js";
import "dotenv/config";

const goerliProvider = getProvider();
const goerliSigner = getSigner();

// Address of NFT Contract
const nftAddress = "DEPLOYED NFT CONTRACT ADDRESS";
// Address of Vault Wallet you wish to send to
const vaultAddress = "DESIRED VAULT WALLET ADDRESS";


// Prepare instance of nft Contract
const nftContract = new ethers.Contract(
    nftAddress,
    nftAbi,
    goerliSigner
)

let nftMinted = false;

// Set gas and priority fee
// Only search on new block?
while (!nftMinted) {

    // Set something to check if minting of your chosen NFT has gone live
    if (await nftContract.mintingLive() == true) {
        // Set up mint function
        const mintNft = await nftContract.mint({
            value: ethers.utils.parseEther("0.01"),
        });
        console.log("TX okay", mintNft)

        // Wait for mint tx to succeed
        await mintNft.wait();
        console.log("TX mined")

        // Transfer NFT to designated vault address
        nftContract.transferFrom(goerliSigner.address, vaultAddress, await nftContract.totalSupply() - 1)
        console.log("NFT Vaulted")

        // End the loop
        nftMinted = true;
    } else {
        console.log("NOT LIVE")
    }
}
