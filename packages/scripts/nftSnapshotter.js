import { ethers } from "ethers";
import { getProvider, nftAddress } from "./utils.js";
import { nftAbi } from "./abi/simpleNFT.js";

const provider = getProvider();

const nftContract = new ethers.Contract(
    nftAddress,
    nftAbi,
    provider
);

const nftTotalSupply = await nftContract.totalSupply();

for (let i = 0; i < nftTotalSupply; i++) {
    let owner = await nftContract.ownerOf(i);
    console.log(owner);
}