// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GovTok.sol : A Solidity Smart Contract used to implement a ERC20 based Token, with Governance Features
 * @author Aritra Ghosh
 * @notice  -----
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//Using the OpenZeppelin Contracts library to extend the ERC20 Contract to create a new ERC20 Token called GovTok
//Necessary functions included in the ERC20 Library from Openzepplin:
//totalSupply(): Returns the total available supply of the token
//balanceOf(account): Returns balance of the provided account address
//transfer(recipent,amount):Transfers from current account to receipents address 'amount' of Tokens
//transferFrom(sender,recipent,amount):Transfers 'amount' tokens from sender address to reciever, as per the allowance mechanism

/*
*   GovTok is created by extending the ERC20 class from OpenZepplin.
    To demonstrate the Governance features, a sample proposal voting system is implemented.
    Users holding the coin will be able to vote on company proposals, 
    and if a majority vote is obtained, the proposal will be executed.
*/

contract GovTok is ERC20 {
    address internal admin;

    struct Proposal {
        /*
        Defines the structure of a proposal in the company.
        Consists of the address of the proposer, a description of the proposal.
        The forVotes and againstVotes stores the weightage of the positive and negative votes,
        and the executed variable holds if the Proposal is already executed or if voting is still active.
        */
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool approved;
    }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    //Maps id to each proposal for easy access.

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        string description
    );

    //Event to log Proposal Creation

    event Voted(uint256 indexed id, address indexed voter, bool inSupport); //Event to Log Votes
    event ProposalExecuted(uint256 indexed id); //Event to log Execution of Proposals

    constructor(uint256 initialSupply) ERC20("GovTok", "GVT") {
        //Admin decides how many coins to mint.
        admin = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function createProposal(
        string memory _description
    ) external returns (uint256) {
        //Creates a Proposal
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposer: msg.sender,
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            approved: false
        });
        emit ProposalCreated(proposalCount, msg.sender, _description);
        return proposalCount;
    }

    function vote(uint256 _id, bool _inSupport) external {
        //Allows user to vote, where the weightage of the votes depend on the number of coins they are holding.
        Proposal storage proposal = proposals[_id];
        require(proposal.executed == false, "Proposal already executed!");
        require(balanceOf(msg.sender) > 0, "Insufficient Balance to Vote");
        require(
            !hasVoted[_id][msg.sender],
            "User has already voted on this proposal"
        );

        if (_inSupport) {
            proposal.forVotes += balanceOf(msg.sender);
        } else {
            proposal.againstVotes += balanceOf(msg.sender);
        }
        hasVoted[_id][msg.sender] = true; // Mark the user as voted
        emit Voted(_id, msg.sender, _inSupport);
    }

    function executeProposal(uint256 _id) external onlyAdmin {
        //Gives the admin power to execute a proposal based on the votes.

        Proposal storage proposal = proposals[_id];
        require(proposal.executed == false, "Proposal already executed!");

        if (proposal.forVotes > proposal.againstVotes) {
            proposal.approved = true;
            emit ProposalExecuted(_id);
        }
        proposal.executed=true;
    }

    function purchaseCoins() public payable {
        //Allows users to purchase tokens for Ethereum

        require(msg.value > 0, "Insufficient ETH Sent");

        //Assuming 1 ETH= 100 GVT

        uint256 gvtAmount = msg.value * 100;
        _mint(msg.sender,gvtAmount);
        _burn(admin,gvtAmount);
    }

    function getAllProposals() external view returns (Proposal[] memory) {
        Proposal[] memory allProposals = new Proposal[](proposalCount);

        for (uint256 i = 1; i <= proposalCount; i++) {
            allProposals[i - 1] = proposals[i];
        }

        return allProposals;
    }

    function getProposalStatus(
        uint256 _id
    ) external view returns (address, string memory, uint256, uint256, bool,bool) {
        require(_id <= proposalCount && _id > 0, "Invalid proposal ID");

        Proposal memory proposal = proposals[_id];
        return (
            proposal.proposer,
            proposal.description,
            proposal.forVotes,
            proposal.againstVotes,
            proposal.executed,
            proposal.approved
        );
    }

    function myBalance() public view returns(uint256)
    {
        return balanceOf(msg.sender);
    }
}
