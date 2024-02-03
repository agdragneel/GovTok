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
    
    address public admin;

    struct Proposal {
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        string description
    );
    event Voted(uint256 indexed id, address indexed voter, bool inSupport);
    event ProposalExecuted(uint256 indexed id);

    constructor(uint256 initialSupply) ERC20("GovTok", "GVT") {
        admin = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function createProposal(
        string memory _description
    ) external returns (uint256) {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposer: msg.sender,
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });
        emit ProposalCreated(proposalCount, msg.sender, _description);
        return proposalCount;
    }

    function vote(uint256 _id, bool _inSupport) external {
        Proposal storage proposal = proposals[_id];
        require(proposal.executed==false,"Proposal already executed!");
        require(balanceOf(msg.sender)!=1,"Insufficient Balance to Vote");

        if(_inSupport)
        {
            proposal.forVotes+=balanceOf(msg.sender);
        }
        else {
            proposal.againstVotes+=balanceOf(msg.sender);
        }
    }

    function executeProposal(uint256 _id) external onlyAdmin
    {
        Proposal storage proposal=proposals[_id];
        require(proposal.executed==false,"Proposal already executed!");

        if(proposal.forVotes>proposal.againstVotes)
        {
            proposal.executed=true;
            emit ProposalExecuted(_id);
        }
    }

    function purchaseCoins() public payable
    {
        require(msg.value>0,"Insufficient ETH Sent");

        //Assuming 1 ETH= 100 GVT

        uint256 gvtAmount=msg.value*100;
        transfer(address(this),msg.sender,gvtAmount);

    }
}
