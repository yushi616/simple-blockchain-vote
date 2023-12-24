const ethers = require("ethers")
const fs = require("fs")

const getContract = async () => {
	const provider = new ethers.providers.JsonRpcProvider(
		"http://127.0.0.1:8545/"
	)
	const singer = await provider.getSigner()
	const abi = JSON.parse(fs.readFileSync("abis/vote.json"))
	const contract = new ethers.Contract(
		"0x5FbDB2315678afecb367f032d93F642f64180aa3",
		abi,
		singer
	)
	return contract
}

exports.creatVote = async (voteId, name, description, endTime) => {
	const contract = await getContract()
	await contract.createVote(voteId, name, description, endTime)
}

exports.vote = async (voteId, candidateId) => {
	const contract = await getContract()
	const transactionResponse = await contract.vote(voteId, candidateId)
	await transactionResponse.wait(1)
}

exports.addCandidateToVote = async (voteId, candidateId) => {
	const contract = await getContract()
	await contract.addCandidateToVote(voteId, candidateId)
}
