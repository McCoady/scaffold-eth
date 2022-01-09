import { useState } from 'react';
import { ethers } from 'ethers';
import deployedContracts from "../contracts/hardhat_contracts.json";

const genfrensContract = "0x37263092Ea7E55439dE4Efce651916B0b96eB7aD";

let params = (new URL(document.location)).searchParams;
let tokenId = parseInt(params.get("token"));


const Code = () => {

    async function requestAccount() {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
    }

    async function getHash() {
        if (typeof window.ethereum !== 'undefined') {
            await requestAccount()
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner()
            const contract = new ethers.Contract(genfrensContract, deployedContracts.abi, signer)
            try {
                const getHash = await contract._tokenIdToHash(tokenId);
                await getHash.wait();
                console.log('Hash Retreived.')
            } catch (error) {
                console.error('Error, hash not found.')
            }
        }
    }
    async function getHTML() {
        if (typeof window.ethereum !== 'undefined') {
            await requestAccount()
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner()
            const contract = new ethers.Contract(genfrensContract, GenFrens.abi, signer)
            try {
                const HTML = await contract.hashToHTML(getHash, tokenId);
                await HTML.wait();
                console.log('Hash Retreived.')
            } catch (error) {
                console.error('Error, hash not found.')
            }
        }
    }

    async function show() {
        await getHash();
        await getHTML();
        return HTML;
    }

    let hash = getHash();

    return (
        <div>
        </div>




    );
}

export default Code;