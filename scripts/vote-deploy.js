//部署合约
const { ethers } = require("hardhat");

async function main() {
const [deployer] = await ethers.getSigners();
console.log("Deploying contracts with the account:", deployer.address);
console.log("Account balance:", (await deployer.getBalance()).toString());
const Voting = await ethers.getContractFactory("Voting");
const voting = await Voting.deploy(deployer.address);
console.log("Voting address:", voting.address);
}
main()
.then(() => process.exit(0))
.catch(error => {
console.error(error);
process.exit(1);
}
);