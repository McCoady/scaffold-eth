import "dotenv/config";
import { ethers } from "ethers";

const nftAddress = "DEPLOYED NFT CONTRACT ADDRESS";
const vaultAddress = "DESIRED VAULT WALLET"

const getProvider = (mainnet = false) => {
    const provider = mainnet
        ? new ethers.providers.AlchemyProvider("homestead", process.env.MY_ALCHEMY_KEY)
        : new ethers.providers.AlchemyProvider("goerli", process.env.MY_ALCHEMY_KEY)

    return provider
}

const getSigner = (mainnet = false) => {
    const provider = getProvider(mainnet);
    return new ethers.Wallet(
        process.env.MY_PRIVATE_KEY,
        provider
    )
};


export { getProvider, getSigner, nftAddress, vaultAddress }