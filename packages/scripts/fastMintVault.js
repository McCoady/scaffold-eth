import { ethers } from "ethers";
import { nftAbi } from "./abi/simpleNFT.js";
import { getSigner, nftAddress, vaultAddress } from "./utils.js";
import "dotenv/config";

const goerliSigner = getSigner();
const provider = new ethers.providers.WebSocketProvider(`wss://eth-goerli.g.alchemy.com/v2/${process.env.MY_ALCHEMY_KEY}`)

// Prepare instance of nft Contract
const nftContract = new ethers.Contract(
    nftAddress,
    nftAbi,
    goerliSigner
)

// Selector of the flipMint function we need to watch for in the mempool
const flipMintSelector = "0xd2ed5c59"

provider.on("pending", async (tx) => {
    // pick up pending transactions as they come in
    const txInfo = await provider.getTransaction(tx);

    if (txInfo != null) {

        // if the tx is going to the nft contract address and the data shows they're calling 'flipMint' then proceed
        if (txInfo.to == nftAddress && txInfo.data == flipMintSelector) {
            console.log("Flip is being switched");

            // Submit a tx with slightly lower priority than the target tx
            const slowerPrio = txInfo.maxPriorityFeePerGas.sub(100);

            // Create a mint tx with the lower priority but same gas (so should get on the same block)
            const nftMinted = await nftContract.mint({
                value: ethers.utils.parseEther("0.01"),
                maxPriorityFeePerGas: slowerPrio,
                maxFeePerGas: txInfo.maxFeePerGas
            })
            console.log("Tx okay", nftMinted);

            await nftMinted.wait();
            console.log("NFT Minted");

            // Transfer NFT to designated vault address
            const tokenTransfer = await nftContract.transferFrom(goerliSigner.address, vaultAddress, await nftContract.totalSupply() - 1)
            await tokenTransfer.wait();
            console.log("NFT Vaulted to ", vaultAddress)

        } else {
            console.log("NOT WANTED")
        }
    } else {
        console.log("NULL")
    }
})