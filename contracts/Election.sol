//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract Election {
    struct candidate {
        string c_name;
        uint256 c_id;
        uint256 voteCount;
    }
    struct voter {
        string v_name;
        address v_id;
        bool voted;
        uint256 weight; //by default 1
        candidate vote;
    }
    enum State {
        CREATED,
        VOTING,
        ENDING
    }
    //constants
    State private state;
    address private admin;
    candidate[] public candidates;
    mapping(address => voter) public voters;
    //modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin is permitted!");
        _;
    }
    modifier createdState() {
        require(state == State.CREATED, "Not yet created!");
        _;
    }
    modifier votingState() {
        require(state == State.VOTING, "Voting not yet started!");
        _;
    }
    modifier endingState() {
        require(state == State.ENDING, "Voting phase not ended yet!");
        _;
    }

    //constructor
    constructor(string[] memory candidateNames) {
        state = State.CREATED;
        admin = msg.sender;
        voters[admin].weight = 1;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(
                candidate({c_name: candidateNames[i], c_id: i, voteCount: 0})
            );
        }
    }

    //functions
    function addCandidates(
        string[] memory candidateNames
    ) public onlyAdmin endingState {
        state = State.CREATED;
        uint256 total = candidates.length;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(
                candidate({
                    c_name: candidateNames[i],
                    c_id: total + i,
                    voteCount: 0
                })
            );
        }
    }

    function startVoting() public onlyAdmin createdState {
        state = State.VOTING;
    }

    function endVoting() public onlyAdmin votingState {
        state = State.ENDING;
    }

    function giveRighttoVote(address _voter) public onlyAdmin createdState {
        require(voters[_voter].weight != 1, "Already a Voter");
        voters[_voter].weight = 1;
    }

    function vote(uint256 c_id) public votingState {
        voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "has no right to vote");
        require(!sender.voted, "Already voted");
        sender.voted = true;
        sender.vote = candidates[c_id];
        candidates[c_id].voteCount += sender.weight;
    }

    function winner()
        public
        view
        onlyAdmin
        endingState
        returns (string memory winnerName)
    {
        require(candidates.length > 1, "No Candidate found");
        require(state == State.ENDING, "voting phase not yet over!");
        uint256 maxi = 0;
        uint256 maxVal = candidates[0].voteCount;
        for (uint256 i = 1; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVal) {
                maxVal = candidates[i].voteCount;
                maxi = i;
            }
        }
        winnerName = candidates[maxi].c_name;
    }

    //getters
    function getAdmin() public view returns (address) {
        return admin;
    }

    function getState() public view returns (State) {
        return state;
    }
}
