const { expect } = require("chai");
const { ethers } = require("hardhat");
const { int } = require("hardhat/internal/core/params/argumentTypes");

describe("Voting contract", function () {
  let Voting;
  let voting;
  let account1, account2;
  

  beforeEach(async function () {
    [account1, account2] = await ethers.getSigners();
    Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy(account1.address); 
    await voting.connect(account2).Sign_up("tzy", "123");
    //1865424000-1866132800
    await voting.createVote("0","test","justTest",5);//create a voting
    await voting.createVote("1","test1","justTest1",5);
    
  });


  it("Should register a user", async function () {
    const user = await voting.users(account2.address); 
    expect(user.name).to.equal("tzy");
    expect(user.password).to.equal("123");
  });

  it("Should log in a user", async function () {
    await voting.Sign_up("tzy", "123");
    const loggedIn = await voting.connect(account2).Log_in("tzy", "123");
    expect(loggedIn).to.be.true;
  });

  it("should show my info", async function () {
    const info = await voting.connect(account2).getMyInfo();
    expect(info.name).to.equal('tzy');
    expect(info.password).to.equal('123');
  });
  it("account1 should be able to create a voting", async function () {
    //const votes = await voting.getVote(0);
    const votes = await voting.getVote("1");
    const oneDay = 24 * 60 * 60;
    //expect(votes.id).to.equal(0);
    expect(votes.name).to.equal("test1");
    expect(votes.description).to.equal("justTest1");
    expect(votes.endTime).to.equal(votes.startTime + 5 * oneDay);
    expect(votes.total).to.equal(0);
  });
  it("accpunt1 should be able to remove a voting", async function () {
    await voting.removeVote("0");
    const votes = await voting.getVote("0");
    expect(votes.name).to.equal("");
    expect(votes.description).to.equal("");
    expect(votes.startTime).to.equal(0);
    expect(votes.endTime).to.equal(0);
    expect(votes.total).to.equal(0);
  });

  it("account2 should be able to vote", async function () {
    await voting.connect(account2).vote("0");
    const votes = await voting.getVote("0");
    expect(votes.total).to.equal(1);
  });

});