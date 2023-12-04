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
        string id;
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 total;
    }
    mapping(string => Vote) votes;//投票id=>投票
    //创建投票
    event CreateVote(string id, string name, string description, uint256 startTime, uint256 endTime);
    event RemoveVote(string id);
    event voting(string id,address addr);
    event cancelVoting(string id,address addr);

    function createVote(string memory _id,string memory name, string memory description, uint256 startTime, uint256 endTime) public{
        require(msg.sender == admin, "You are not the admin.");
        votes[_id].id = _id;
        votes[_id].name = name;
        votes[_id].description = description;
        votes[_id].startTime = startTime;
        votes[_id].endTime = endTime;
        votes[_id].total = 0;
        emit CreateVote(_id, name, description, startTime, endTime);
    }
    //删除投票
    function removeVote(string memory id) public{
        require(msg.sender == admin, "You are not the admin.");
        delete votes[id];
        emit RemoveVote(id);
    }
    //投票
    function vote(string memory id) public{
        require(block.timestamp >= votes[id].startTime && block.timestamp <= votes[id].endTime, "The vote is not in progress.");
        votes[id].total++;
        emit voting(id,msg.sender);
    }
    //撤销投票
    function cancelVote(string memory id) public{
        require(block.timestamp >= votes[id].startTime && block.timestamp <= votes[id].endTime, "The vote is not in progress.");
        votes[id].total--;
        emit cancelVoting(id,msg.sender);
    }
    //查询
    //查询投票
    function getVote(string memory id) public view returns(Vote memory){
            return votes[id];
    }
    //查询投票结果
    function getVoteResult(string memory id) public view returns(uint256){
        return votes[id].total;
    }

    //查询用户
    function getMyInfo() public view returns(User memory){
        return users[msg.sender];
    }
}