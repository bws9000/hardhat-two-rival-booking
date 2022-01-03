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
  it("Register User", async function () {
    assert(await contract.registerUser("P"));
  });
  it("Check User Registered", async function () {
    expect(await contract.registrationStatus()).to.equal(true);
  });
  it("Total Registered", async function () {
    assert(await contract.totalRegistered());
    const bigNum = await contract.totalRegistered();
    console.log("registered: " + bigNum.toNumber());
  });
  it("Book Room", async function () {
    assert(await contract.bookRoom(1, 1));
    assert(await contract.bookRoom(0, 1));
    assert(await contract.bookRoom(2, 1));
    await expect(contract.bookRoom(2, 1)).to.be.revertedWith(
      "you already booked this hour"
    );
    assert(await contract.bookRoom(2, 2));
    assert(await contract.bookRoom(23, 3));
  });
  it("Total Users Booked", async function () {
    expect(await contract.totalBookings()).to.equal(5);
  });
  it("Unregister", async function () {
    assert(await contract.clearRegistration());
  });
  it("Get Rooms", async function () {
    console.log(await contract.getRoom(1));
    console.log(await contract.getRoom(2));
    console.log(await contract.getRoom(3));
    console.log(await contract.getRoom(4));
    console.log(await contract.getRoom(5));
    console.log(await contract.getRoom(6));
    console.log(await contract.getRoom(7));
    console.log(await contract.getRoom(8));
    console.log(await contract.getRoom(9));
    console.log(await contract.getRoom(10));
  });
});
