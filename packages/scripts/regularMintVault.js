import { ethers } from "ethers";
import { nftAbi } from "./abi/simpleNFT.js";
import { getSigner, nftAddress, vaultAddress } from "./utils.js";
import "dotenv/config";

const goerliSigner = getSigner();

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
        const tokenTransfer = await nftContract.transferFrom(goerliSigner.address, vaultAddress, await nftContract.totalSupply() - 1)
        await tokenTransfer.wait();
        console.log("NFT Vaulted to ", vaultAddress)

        // End the loop
        nftMinted = true;
    } else {
        console.log("NOT LIVE")
    }
}
