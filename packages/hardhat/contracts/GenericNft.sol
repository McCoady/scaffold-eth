// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.7;

import "./ERC721.sol";

contract GenericNft is ERC721 {
    uint256 totalSupply = 0;

    constructor() payable ERC721("Generic", "GNFT") {}

    function mint(address _to) external {
        _mint(_to, totalSupply);

        ++totalSupply;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "wowzers";
    }
}
