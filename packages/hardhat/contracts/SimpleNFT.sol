pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleNFT is ERC721, Ownable {
    error WrongValue(uint256);
    error MintingNotLive();
    error NoContracts();

    uint256 public totalSupply = 0;
    uint256 public constant mintPrice = 0.01 ether;
    bool public mintingLive = false;

    constructor() ERC721("SimpleNFT", "SIMP") {}

    function mint() external payable {
        if (!mintingLive) revert MintingNotLive();
        if (msg.value != mintPrice) revert WrongValue(mintPrice);
        if (msg.sender.code.length != 0) revert NoContracts();

        uint256 thisTokenId = totalSupply;

        _mint(msg.sender, thisTokenId);

        ++totalSupply;
    }

    function flipMint() external onlyOwner {
        mintingLive = !mintingLive;
    }

    function withdraw() external {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}
