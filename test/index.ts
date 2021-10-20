import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFTWorldExchange", function () {
  // Metaverse Coin
  //  Doug's address should be able to deposit Metaverse Coin
  //  Another address should not be able to deposit Metaverse Coin
  //
  // Wearables
  //  Doug's address should be able to deposit wearables into the contract
  //  Another address should not be able to deposit wearables into the contract
  //  A user should be able receive a wearable of a certain rarity in exchange for a specified amount of Metaverse Coin
  //  A user should not receive a wearable of a certain rarity if they don't have enough Metaverse Coin
  //  A user should receive a payout of 75% of what they paid in exchange for sending a purchased wearable back to the contract
  //  A user should not be able to send a wearable not originally deposited by Doug to the contract
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
