# 🏗 Scaffold-ETH


# 🏆Bounty-Booster V1

Tool for public goods / builder DAO's to offer part of their treasury to 'Boost' the value of rewards for people holding an NFT specified by the DAO.

Contract Details:

Fund the contract with ETH (giving it a boosterBalance)
Set the NFT needed to be held to be eligible for boosting

Users can create their own bounties
 - Send the bounty value to the contract (in ETH)
 - Set a description and deadline for completing the bounty

Upon completion, the contract calculates how much the contract is to be boosted (5% if one of creator/completer owns the boost NFT, 10% if both do)

Functions to bountyCreator to withdraw funds if it hasn't been completed before the specified deadline.

Requires the contract owner to complete the bounty (and check the bounty/completion was legit and isn't farming boost)

## V2 Ideas

### Variable Boosts
- Augment boost % based on type of bounty (personal,project, public good)
- Augment boost % based on NFT statistics (number held, time held)

### Function to allow users to calculate boost
Currently doesn't calculate boost % from the creator until completion (to avoid them being able to create a bounty then sell the token). Could be better alternatives to this so it's clearer how much bounty completers can expect.

### UI improvements
- List active/expired bounties in two different tabs, allow creators to upload more detailed descriptions (off chain).
- Put all creator functions into a collapsable menu.
- Make design prettier.