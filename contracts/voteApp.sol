// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Voting{
    //管理员
    address admin;
    constructor(address _admin){
        admin = _admin;
    }

    //登录\注册
    struct User{
        string name;
        string password;
        address addr;
    }
    mapping(address => User) public users;//用户地址=>用户
    //注册
    function Sign_up(string memory name, string memory password) public{
        users[msg.sender].name = name;
        users[msg.sender].password = password;
        users[msg.sender].addr = msg.sender;
    }
    //登录
    function Log_in(string memory name, string memory password) public view returns(bool){
        if(keccak256(abi.encodePacked(users[msg.sender].name)) == keccak256(abi.encodePacked(name)) && 
        keccak256(abi.encodePacked(users[msg.sender].password)) == keccak256(abi.encodePacked(password))){
            return true;
        }
        else{
            return false;
        }
    }

    //投票
    struct Vote{//投票结构
        uint256 id;
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 total;
    }
    mapping(uint256 => Vote) votes;//投票id=>投票
    uint256 voteNum = 0;//投票数量
    //创建投票
    function createVote(uint _id,string memory name, string memory description, uint256 startTime, uint256 endTime) public{
        require(msg.sender == admin, "You are not the admin.");
        votes[voteNum].id = _id;
        votes[voteNum].name = name;
        votes[voteNum].description = description;
        votes[voteNum].startTime = startTime;
        votes[voteNum].endTime = endTime;
        votes[voteNum].total = 0;
    }
    //删除投票
    function removeVote(uint256 id) public{
        require(msg.sender == admin, "You are not the admin.");
        delete votes[id];
    }
    //投票
    function vote(uint256 id) public{
        require(block.timestamp >= votes[id].startTime && block.timestamp <= votes[id].endTime, "The vote is not in progress.");
        votes[id].total++;
    }
    //撤销投票
    function cancelVote(uint256 id) public{
        require(block.timestamp >= votes[id].startTime && block.timestamp <= votes[id].endTime, "The vote is not in progress.");
        votes[id].total--;
    }
    //查询
    //查询投票
    function getVote(uint256 id) public view returns(Vote memory){
            return votes[id];
    }
    //查询投票结果
    function getVoteResult(uint256 id) public view returns(uint256){
        return votes[id].total;
    }

    //查询用户
    function getMyInfo() public view returns(User memory){
        return users[msg.sender];
    }
}