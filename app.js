const express = require("express")
const bodyParser = require("body-parser")
const voteController = require("./src/controller/voteController")

const app = express()

// 解析 application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// 解析 application/json
app.use(bodyParser.json())
app.set("view engine", "ejs")
app.get("/", (req, res) => {
	res.render("home")
})

app.post("/vote", (req, res) => {
	const votingId = req.body.votingId
	const optionId = req.body.optionId

	// 在这里处理投票逻辑
	// ...

	res.send("Vote received!")
})

app.get("/createVote", (req, res) => {
	voteController.creatVote("0", "test", "vote", "10000")
	res.send("success")
})
app.get("/add", (req, res) => {
	// voteController.addCandidateToVote("0", "1")
	res.sendFile(`${__dirname}/views/addCandidate.html`)
})
app.post("/add", (req, res) => {})
app.listen(3000, () => {
	console.log("App is listening on port 3000")
})
