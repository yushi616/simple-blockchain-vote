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
});