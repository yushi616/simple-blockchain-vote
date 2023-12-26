// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    //管理员
    address admin;

    constructor(address _admin) {
        admin = _admin;
    }

    //登录\注册
    struct User {
        uint256 userid;
        address addr;
    }
    mapping(address => User) public users; //用户地址=>用户
    uint256 public userCount = 0;

    //注册
    function Sign_up() public {
        require(users[msg.sender].addr != msg.sender, "You are the user.");
        users[msg.sender].userid = userCount + 1;
        users[msg.sender].addr = msg.sender;
        userCount++;
    }

    //登录
    function Log_in() public view returns (bool) {
        if (users[msg.sender].addr == msg.sender) {
            return true;
        } else {
            return false;
        }
    }

    //投票
    //候选项目
    struct Candidate {
        //候选项目结构
        string id;
        string name;
        string description;
        uint256 _total;
    }
    mapping(string => Candidate) _candidates; //候选项目id=>候选项目

    struct Vote {
        //投票结构
        string id;
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 total;
        Candidate[] candidates;
        mapping(address => string) voteds; //已投票用户，用户地址=>候选项目id，防止重复投票，可以撤销投票，可以查看投票结果
        mapping(address => uint256) allowVotedNum; //允许投票次数，用户地址=>允许投票次数，3次
    }
    mapping(string => Vote) votes; //投票id=>投票
    uint256 public voteCount;
    //创建投票
    event CreateVote(
        string id,
        string name,
        string description,
        uint256 startTime,
        uint256 endTime
    );
    event AddCandidateToVote(string id, string candidateId);
    event RemoveVote(string id);
    event voting(string id, uint256 candidatesId, address addr);
    event cancelVoting(string id, address addr);

    //创建候选项目
    function createCandidate(
        string memory _id,
        string memory name,
        string memory description
    ) public {
        require(msg.sender == admin, "You are not the admin.");
        //this id alreay exist
        require(
            keccak256(abi.encodePacked(_candidates[_id].id)) !=
                keccak256(abi.encodePacked(_id)),
            "The candidate id already exists."
        );
        _candidates[_id].id = _id;
        _candidates[_id].name = name;
        _candidates[_id].description = description;
        _candidates[_id]._total = 0;
    }

    //创建投票
    function createVote(
        string memory _id,
        string memory name,
        string memory description,
        uint256 endTime
    ) public {
        require(msg.sender == admin, "You are not the admin.");
        //alreay exist
        require(bytes(votes[_id].name).length == 0, "The vote already exists.");
        uint256 _endTime = endTime * 1 days;
        votes[_id].id = _id;
        votes[_id].name = name;
        votes[_id].description = description;
        votes[_id].startTime = block.timestamp;
        votes[_id].endTime = block.timestamp + _endTime;
        votes[_id].total = 0;
        voteCount++;
        emit CreateVote(_id, name, description, block.timestamp, endTime);
    }

    //为投票添加候选项目
    function addCandidateToVote(
        string memory id,
        string memory candidateId
    ) public {
        require(msg.sender == admin, "You are not the admin.");
        require(
            bytes(_candidates[candidateId].name).length != 0,
            "The candidate does not exist."
        );
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        votes[id].candidates.push(_candidates[candidateId]);
        emit AddCandidateToVote(id, candidateId);
    }

    //删除投票
    function removeVote(string memory id) public {
        require(msg.sender == admin, "You are not the admin.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        delete votes[id];
        voteCount--;
        emit RemoveVote(id);
    }

    //投票
    function vote(string memory id, uint256 _candidateId) public {
        require(users[msg.sender].addr == msg.sender, "You are not the user.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        require(
            keccak256(abi.encodePacked(votes[id].voteds[msg.sender])) !=
                keccak256(
                    abi.encodePacked(votes[id].candidates[_candidateId].id)
                ),
            "You have already voted for this candidate"
        );
        require(
            block.timestamp >= votes[id].startTime &&
                block.timestamp <= votes[id].endTime,
            "The vote is not in progress."
        );
        votes[id].total++;
        votes[id].candidates[_candidateId]._total++;
        votes[id].voteds[msg.sender] = votes[id].candidates[_candidateId].id;

        emit voting(id, _candidateId, msg.sender);
    }

    //撤销投票
    function cancelVote(string memory id) public {
        require(users[msg.sender].addr == msg.sender, "You are not the user.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        require(
            block.timestamp >= votes[id].startTime &&
                block.timestamp <= votes[id].endTime,
            "The vote is not in progress."
        );
        require(
            keccak256(abi.encodePacked(votes[id].voteds[msg.sender])) !=
                keccak256(abi.encodePacked("")),
            "You have not voted yet."
        );
        votes[id].voteds[msg.sender] = "";
        votes[id].total--;
        emit cancelVoting(id, msg.sender);
    }

    //查询
    //查询投票项目
    function getCandidate(
        string memory id
    ) public view returns (Candidate memory) {
        return _candidates[id];
    }

    //
    function getAllCandidatesOfVote(
        string memory id
    ) public view returns (Candidate[] memory) {
        return votes[id].candidates;
    }

    //查询一共有多少投票
    function getVoteCount() public view returns (uint256) {
        return voteCount;
    }

    //查询投票
    function getVote(string memory id) public view returns (string memory,
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        Candidate[] memory) {
        return (
            votes[id].id,
            votes[id].name,
            votes[id].description,
            votes[id].startTime,
            votes[id].endTime,
            votes[id].total,
            votes[id].candidates
        );
    }

    //查询投票结果
    function getVoteResult(string memory id) public view returns (uint256) {
        return votes[id].total;
    }

    //查询用户
    function getMyInfo() public view returns (User memory) {
        return users[msg.sender];
    }
}
