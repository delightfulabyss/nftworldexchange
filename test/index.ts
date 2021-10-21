import chai, { expect } from "chai";
import hre, { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";

chai.use(solidity);

describe("NFTWorldExchange", async function () {
  // Metaverse Coin
  //  Doug's address should be able to deposit Metaverse Coin
  it("Should allow owner address to deposit Metaverse Coin", async function () {
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"],
    });
    const signer = await ethers.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    
  });
  //  Another address should not be able to deposit Metaverse Coin
  //
  // Wearables
  //  Doug's address should be able to deposit wearables into the contract
  //  Another address should not be able to deposit wearables into the contract
  //  A user should be able receive a wearable of a certain rarity in exchange for a specified amount of Metaverse Coin
  //  A user should not receive a wearable of a certain rarity if they don't have enough Metaverse Coin
  //  A user should receive a payout of 75% of what they paid in exchange for sending a purchased wearable back to the contract
  //  A user should not be able to send a wearable not originally deposited by Doug to the contract
  it("Should allow owner address to deposit Metaverse Coin", async function () {});
  it("Should not allow a user's address to deposit Metaverse Coin", async function () {});
});
