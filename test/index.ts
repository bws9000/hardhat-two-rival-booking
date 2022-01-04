import { expect, assert } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { TwoRivalBooking } from "../typechain/TwoRivalBooking";

let contract: TwoRivalBooking;

describe("TwoRivalBooking", function () {
  it("Deploy Contract", async function () {
    const TwoRivalBooking = await ethers.getContractFactory("TwoRivalBooking");
    contract = await TwoRivalBooking.deploy();
    await contract.deployed();
    expect(contract.address);
    console.log("deployed to: " + contract.address);
  });
  it("Register User GROUP P", async function () {
    assert(await contract.registerUser("P"));
  });
  it("Check User Registered", async function () {
    expect(await contract.registrationStatus()).to.equal(true);
  });
  it("Book Rooms", async function () {
    assert(await contract.bookRoom(1, 1));
    assert(await contract.bookRoom(2, 1));
    // assert(await contract.bookRoom(2, 1));
    assert(await contract.bookRoom(3, 1));
    assert(await contract.bookRoom(1, 2));
    assert(await contract.bookRoom(2, 3));
    assert(await contract.bookRoom(3, 3));
    assert(await contract.bookRoom(4, 3));
  });
  it("Fail on book same room and hour", async function () {
    await expect(contract.bookRoom(2, 1)).to.be.revertedWith(
      "you already booked this hour"
    );
  });
  it("", async function () {
    console.log("\n-- ROOM COUNT -------------");
    // just test with first 3 rooms
    console.log(await contract.getRoom(1, "P"));
    console.log(await contract.getRoom(2, "P"));
    console.log(await contract.getRoom(3, "P"));
    console.log("-----------------------------");
  });
  it("Un Register", async function () {
    assert(await contract.clearRegistration());
  });
  it("", async function () {
    console.log("\n-- ROOM COUNT -------------");
    // just test with first 3 rooms
    console.log(await contract.getRoom(1, "P"));
    console.log(await contract.getRoom(2, "P"));
    console.log(await contract.getRoom(3, "P"));
    console.log("-----------------------------");
  });
});
