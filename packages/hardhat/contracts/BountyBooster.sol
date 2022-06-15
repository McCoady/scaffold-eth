pragma solidity 0.8.7;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721.sol";

//import IERC721 contract

contract BountyBooster is Ownable {
    //The NFT required to boost bounty.
    ERC721 public boostNft;

    //Amount of eth in the contract for boosting
    uint256 public boostBalance;

    /*
  Bounty struct should include:
  Address of the bounty creator
  A short description of the bounty being posted (more detailed one can be posted off-chain)
  The value of the bounty (in wei)
  A deadline for when the bounty work must be submitted by
  Bool whether the creator is eligible for boosting
  A true or false value on the status of the bounty (active/not active)
  */
    struct Bounty {
        address creator;
        string description;
        uint256 value;
        uint256 deadline;
        uint256 boost;
        bool completed;
        address completer;
    }

    //Array of posted bounties
    Bounty[] public bounties;

    //Event emitted into our front end upon bounty creation
    event BountyCreated(
        address creator,
        string description,
        uint256 startingValue,
        uint256 bountyId
    );

    //event emitted into our front end upon bounty completion
    event BountyCompleted(
        address creator,
        string description,
        uint256 finalValue,
        address completer
    );
    event ContractFunded(uint256 amount);

    /**
     * @dev posts a new bounty
     * @param _description a short description of the bounty
     * @param _deadline deadline by which the bounty must be completed by
     */
    function postBounty(string memory _description, uint256 _deadline)
        external
        payable
    {
        //Bounty needs a value
        require(msg.value > 0, "Send bounty eth");

        //create a bounty struct
        bounties.push(
            Bounty(
                msg.sender,
                _description,
                msg.value,
                _deadline,
                0,
                false,
                address(0)
            )
        );

        //Emit a bounty created event for front ends to more easily keep track of new bounties
        emit BountyCreated(
            msg.sender,
            _description,
            msg.value,
            bounties.length - 1
        );
    }

    /**
     * @dev creator pushes transaction that they've accepted bounty, owner can then call `completeBounty`
     * @param _bountyId the ID of the bounty being accepted
     * @param _bountyCompletor the address of the person who completed the bounty
     */
    function acceptBounty(uint256 _bountyId, address _bountyCompletor)
        external
    {
        require(bounties[_bountyId].creator == msg.sender);
        require(
            bounties[_bountyId].completer == address(0),
            "Bounty has accepted completed"
        );

        //set default to false
        uint256 _boost = 0;

        //check if creator has the boostNft
        if (boostNft.balanceOf(msg.sender) > 0) {
            _boost += 5;
        }

        if (boostNft.balanceOf(_bountyCompletor) > 0) {
            _boost += 5;
        }

        bounties[_bountyId].boost = _boost;

        bounties[_bountyId].completer = _bountyCompletor;
    }

    /**
     * @dev function for the owner to push through an accepted bounty, after confirming the bounty/completion is legit
     * boost percentage is calculated and the correct funds are sent to the
     * @param _bountyId the id of the bounty being completed
     */
    function completeBounty(uint256 _bountyId) external onlyOwner {
        require(
            bounties[_bountyId].completer != address(0),
            "No bounty completer"
        );
        require(
            bounties[_bountyId].completed == false,
            "Bounty already completed"
        );
        require(
            address(this).balance >= bounties[_bountyId].value,
            "Contract needs more ETH"
        );
        uint256 boostAmount = (bounties[_bountyId].value *
            bounties[_bountyId].boost) / 100;
        require(boostBalance >= boostAmount);

        bounties[_bountyId].value += boostAmount;
        bounties[_bountyId].completed = true;
        (bool success, ) = payable(bounties[_bountyId].completer).call{
            value: bounties[_bountyId].value
        }("");
        require(success);

        emit BountyCompleted(
            bounties[_bountyId].creator,
            bounties[_bountyId].description,
            bounties[_bountyId].value,
            bounties[_bountyId].completer
        );
    }

    /**
     * @dev allows bounty creator to pull funds if deadline has passed without bounty being completed
     * @param _bountyId id of the bounty having it's funds withdrawn
     */
    function withdrawBountyFunds(uint256 _bountyId) external {
        require(bounties[_bountyId].creator == msg.sender, "Not your bounty");
        require(
            bounties[_bountyId].deadline < block.timestamp,
            "Bounty deadline not passed"
        );
        require(
            bounties[_bountyId].completer == address(0),
            "Bounty has an accepted completer"
        );

        bounties[_bountyId].completed = true;
        (bool success, ) = payable(msg.sender).call{
            value: bounties[_bountyId].value
        }("");
        require(success);

        bounties[_bountyId].completed = true;
    }

    /**
     * @dev Allows people to donate eth to the boost balance
     */
    function addToBoostBalance() external payable {
        boostBalance += msg.value;
        emit ContractFunded(msg.value);
    }

    /**
     * @dev Sets the ERC721 token that needs to be held to boost bounty
     * @param _boostNft the address of the ERC721 token
     */
    function setBoostNft(ERC721 _boostNft) external onlyOwner {
        boostNft = _boostNft;
    }
}
