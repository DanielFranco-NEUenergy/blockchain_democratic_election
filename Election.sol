pragma solidity ^0.4.2;

contract Election {
    
    address public manager; 

    struct candidate{
        uint id;
        string name;
        uint voteCount;
    }

    mapping (uint => candidate) public candidates;
    mapping (address => bool) public voters;
    mapping (uint => address) public votersIndex;

    uint public candidatesCount;
    uint public votersCount;

    modifier restricted() {

        require(msg.sender == manager, "ERR:differentFromManagner");
        _;
    }
    
    modifier voteRequirement(uint _candidateId) {
        
        require( (msg.value >= 0.0001 ether) 
                            &&
                (_candidateId > 0 && _candidateId <= candidatesCount) );
        _;
    }

    function Election () public {
        addCandidate("None of the above")
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
        addCandidate("Candidate 3");

        manager = msg.sender; 
    }

    function addCandidate (string _name) private {

        candidatesCount ++;
        candidates[candidatesCount] = candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public payable voteRequirement(_candidateId) {
        
        address votante = msg.sender;
        
        require( (!voters[votante] || !voters[votante]==false) 
                                    && 
                            (votante != manager) );
        
        voters[votante] = true;
        candidates[_candidateId].voteCount ++;
        
        votersCount ++;
        votersIndex[votersCount] = votante;
    }
    
    function getResultsPerCandidate(uint _candidateId) public view returns (uint) {
        
        return candidates[_candidateId].voteCount;
    }

    function getCandidateName(uint _candidateId) public view returns (string) {
        
        return candidates[_candidateId].name;
    }
    
    function resetElection() public restricted {
        
        uint8 i = 0;
        while (i++ <= candidatesCount){
            
            candidates[i].voteCount = 0;
            voters[votersIndex[i]] = false;
        }
    }
    
    function contractBalance_toManager() public restricted {
        
        manager.transfer(this.balance);
    }

    function changeManager (address _newManager) public restricted {

        require(_newManager != address(0),"WRN:address0");

        manager = _newManager;
    }

    function destroy() public restricted { selfdestruct(manager); }

    function destroyAndSend(address _recipient) public restricted { selfdestruct(_recipient); }
}