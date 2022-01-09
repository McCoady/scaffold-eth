import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { useParams } from "react-router-dom";
import deployedContracts from "../contracts/hardhat_contracts.json";

const genfrensAddress = "0x6dD39299fB17492e7Fd6fCCcdCEFeB5167d60E68";

// let params = new URL(document.location).searchParams;
// let tokenId = parseInt(params.get("token"));

const Code = ({ readContracts }) => {
  const param = useParams();
  const [frenHtml, setFrenHtml] = useState(null);

  async function requestAccount() {
    await window.ethereum.request({ method: "eth_requestAccounts" });
  }

  async function getHash(tokenId) {
    const { GenFrens } = readContracts;

    //if (typeof window.ethereum !== "undefined") {
    //await requestAccount();
    //const provider = new ethers.providers.Web3Provider(window.ethereum);
    //const signer = provider.getSigner();
    //const contract = new ethers.Contract(genfrensAddress, deployedContracts.abi, mainnetProvider);
    //}
    try {
      const hash = await GenFrens._tokenIdToHash(Number(tokenId));
      // const value = await getHash.wait();
      console.log("Hash Retreived.", hash);
      return hash;
    } catch (error) {
      console.error("Error, hash not found.");
    }
  }

  async function getHTML() {
    const { GenFrens } = readContracts;
    const { tokenId } = param;
    const hash = await getHash(tokenId);
    // if (typeof window.ethereum !== "undefined") {
    // await requestAccount();
    // const provider = new ethers.providers.Web3Provider(window.ethereum);
    // const signer = provider.getSigner();
    // const contract = new ethers.Contract(genfrensContract, GenFrens.abi, signer);
    console.log("HTML Started", hash, tokenId);
    try {
      const HTML = await GenFrens.hashToHTML(hash, tokenId);
      console.log("HTML Retreived.", HTML);
      setFrenHtml(HTML);
    } catch (error) {
      console.error("Error, hash not found.");
    }
  }

  useEffect(() => {
    if (readContracts && readContracts.GenFrens) getHTML();
  }, [readContracts]);

  const genFrenIframe = frenHtml ? (
    <iframe style={{ border: 0 }} width="550" height="550" src={frenHtml}></iframe>
  ) : (
    <h1>Placeholder Loading Fren</h1>
  );

  return (
    <div>
      <h1>Gen friend {param.tokenId ?? "?"}</h1>
      {genFrenIframe}
    </div>
  );
};

export default Code;
