const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// 连接到以太坊节点
const web3 = new Web3('http://localhost:8545');

// 读取ABI
const abiPath = path.resolve(__dirname, 'VoteApp.json'); // 请替换为你的ABI文件路径
const abi = JSON.parse(fs.readFileSync(abiPath, 'utf8'));

// 合约地址
const contractAddress = '0x...'; // 请替换为你的合约地址

// 创建合约实例
const voteApp = new web3.eth.Contract(abi, contractAddress);

// 创建投票
async function createVote(id, name, description, endTime) {
    const accounts = await web3.eth.getAccounts();
    const admin = accounts[0];
    const result = await voteApp.methods.createVote(id, name, description, endTime).send({ from: admin });
    console.log(result);
}

// 删除投票
async function removeVote(id) {
    const accounts = await web3.eth.getAccounts();
    const admin = accounts[0];
    const result = await voteApp.methods.removeVote(id).send({ from: admin });
    console.log(result);
}

// 测试函数
async function test() {
    await createVote('1', 'test1', 'justTest1', 5);
    await removeVote('1');
}

test();