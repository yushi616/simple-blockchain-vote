const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting contract", function () {
  let Voting;
  let voting;
  let account1, account2;
  

  beforeEach(async function () {
    [account1, account2] = await ethers.getSigners();
    Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy(account1.address); 
    await voting.connect(account2).Sign_up("tzy", "123");
    await voting.createVote(0,"test","justTest",123,126);//create a voting
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
    //await voting.connect(connect(account1)).createVoting("test","justTest","12.3","12.4");
    const votes = await voting.getVote(0);
    expect(votes.name).to.equal("test");
    expect(votes.description).to.equal("justTest");
    expect(votes.startTime).to.equal(123);
    expect(votes.endTime).to.equal(126);
    expect(votes.total).to.equal(0);
  });
});