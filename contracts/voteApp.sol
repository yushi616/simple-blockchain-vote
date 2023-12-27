// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    //管理员
    address admin;
    // 添加两个状态变量来跟踪下一个可用的候选人和投票的 ID
    uint256 nextCandidateId = 0;
    uint256 nextVoteId = 0;

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
        users[msg.sender].userid = userCount;
        users[msg.sender].addr = msg.sender;
        userCount++;
    }

    function isRregiser() public view returns (bool) {
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
        uint256 id;
        string name;
        string description;
        uint256 _total;
    }
    mapping(uint256 => Candidate) _candidates; //候选项目id=>候选项目

    struct Vote {
        //投票结构
        uint256 id;
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 total;
        Candidate[] candidates;
    }
    mapping(address => uint256[]) voteds; //已投票用户，用户地址=>候选项目id，防止重复投票，可以撤销投票，可以查看投票结果
    mapping(uint256 => Vote) votes; //投票id=>投票
    uint256 public voteCount;
    //创建投票
    event CreateVote(
        uint256 id,
        string name,
        string description,
        uint256 startTime,
        uint256 endTime
    );
    event AddCandidateToVote(uint256 id, uint256 candidateId);
    event RemoveVote(uint256 id);
    event voting(uint256 id, uint256 candidatesId, address addr);
    event cancelVoting(uint256 id, address addr);

    //创建候选项目
    function createCandidate(
        string memory name,
        string memory description
    ) public {
        require(msg.sender == admin, "You are not the admin.");
        _candidates[nextCandidateId].id = nextCandidateId;
        _candidates[nextCandidateId].name = name;
        _candidates[nextCandidateId].description = description;
        _candidates[nextCandidateId]._total = 0;

        // 增加下一个可用的候选人 ID
        nextCandidateId++;
    }

    //创建投票
    function createVote(
        string memory name,
        string memory description,
        uint256 endTime
    ) public {
        require(msg.sender == admin, "You are not the admin.");
        uint256 _endTime = endTime * 1 days;
        votes[nextVoteId].id = nextVoteId;
        votes[nextVoteId].name = name;
        votes[nextVoteId].description = description;
        votes[nextVoteId].startTime = block.timestamp;
        votes[nextVoteId].endTime = block.timestamp + _endTime;
        votes[nextVoteId].total = 0;
        voteCount++;

        emit CreateVote(
            nextVoteId,
            name,
            description,
            block.timestamp,
            endTime
        );

        // 增加下一个可用的投票 ID
        nextVoteId++;
    }

    //为投票添加候选项目
    function addCandidateToVote(uint256 id, uint256 candidateId) public {
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
    function removeVote(uint256 id) public {
        require(msg.sender == admin, "You are not the admin.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        delete votes[id];
        voteCount--;
        emit RemoveVote(id);
    }

    //投票
    function vote(uint256 id, uint256 _candidateId) public {
        require(users[msg.sender].addr == msg.sender, "You are not the user.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        require("You have already voted for this candidate");
        require(
            block.timestamp >= votes[id].startTime &&
                block.timestamp <= votes[id].endTime,
            "The vote is not in progress."
        );
        votes[id].total++;
        votes[id].candidates[_candidateId]._total++;
        voteds[msg.sender] = votes[id].candidates[_candidateId].id;

        emit voting(id, _candidateId, msg.sender);
    }

    //撤销投票
    function cancelVote(uint256 id) public {
        require(users[msg.sender].addr == msg.sender, "You are not the user.");
        require(bytes(votes[id].name).length != 0, "The vote does not exist.");
        require(
            block.timestamp >= votes[id].startTime &&
                block.timestamp <= votes[id].endTime,
            "The vote is not in progress."
        );
        require(voteds[msg.sender] != 0, "You have not voted yet.");
        voteds[msg.sender] = 0;
        votes[id].total--;
        emit cancelVoting(id, msg.sender);
    }

    //查询
    //查询候选项目
    function getCandidate(uint256 id) public view returns (Candidate memory) {
        return _candidates[id];
    }

    //
    function getAllCandidatesOfVote(
        uint256 id
    ) public view returns (Candidate[] memory) {
        return votes[id].candidates;
    }

    //查询一共有多少投票
    function getVoteCount() public view returns (uint256) {
        return voteCount;
    }

    //查询投票
    function getVote(uint256 id) public view returns (Vote memory) {
        return votes[id];
    }

    //查询投票结果
    function getVoteResult(uint256 id) public view returns (uint256) {
        return votes[id].total;
    }

    //查询用户
    function getMyInfo() public view returns (User memory) {
        return users[msg.sender];
    }
}
