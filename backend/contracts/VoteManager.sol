//SPDX-License-Identifier: Unlicense
//specific solidity cersion
pragma solidity ^0.8.7;
// we can use the console.log func from hardhat for debugging (like in javascript)
import "hardhat/console.sol";

// openzeppelin provides libaries of different use cases, this one provides a counter with best practices 
// a simple way to get a counter that can only be incremented or decremented. Very useful for ID generation, counting contract activity, among others.
import "@openzeppelin/contracts/utils/Counters.sol";

contract VoteManager {
  
    struct Candidate {
        uint id;
        uint totalVote;
        string name;
        string imageHash;
        address candidateAddress;
    }

    using Counters for Counters.Counter;
    Counters.Counter private candidatesIds;

    mapping(address => Candidate) private candidates; // mapping (key => value) good for lookups, associations
    mapping(uint => address) private accounts;

    event Voted(address indexed _candidateAddress, address indexed _voterAddress, uint _totalVote);
    event candidateCreated(address indexed candidateAddress, string name);

    function registerCandidate(string calldata _name, string calldata _imageHash) external {
        require(msg.sender != address(0), "Sender address must be valid");
        candidatesIds.increment();
        uint candidateId = candidatesIds.current();   // candidates ID 0 --> 1 --> 2
        address _address = address(msg.sender);       // msg.sender --> address of caller of the contract
        Candidate memory newCandidate = Candidate(candidateId, 0, _name, _imageHash, _address);
        candidates[_address] = newCandidate;           // store candidate object in mapping
        accounts[candidateId] = msg.sender;
        emit candidateCreated(_address, _name);        
    }


    /* fetches all candidates */
    function fetchCandidates() external view returns (Candidate[] memory) {
        uint itemCount = candidatesIds.current();

        Candidate[] memory candidatesArray = new Candidate[](itemCount);

        for(uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;
            Candidate memory currentCandidate = candidates[accounts[currentId]];
            candidatesArray[i] = currentCandidate;
        }

        return candidatesArray;

    }

    function vote(address _forCandidate) external {
        candidates[_forCandidate].totalVote += 1;
        emit Voted(_forCandidate, msg.sender, candidates[_forCandidate].totalVote);
    }


}
