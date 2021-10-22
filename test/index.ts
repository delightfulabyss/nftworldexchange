import chai, { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { solidity } from "ethereum-waffle";
import { Contract } from "ethers";

chai.use(solidity);

describe("NFTWorldExchange", async function () {
  let contract: Contract;
  before(async function () {
    const NFTWorldExchange = await ethers.getContractFactory(
      "NFTWorldExchangeImplementationV1"
    );

    const NFTWorldExchangeProxy = await upgrades.deployProxy(NFTWorldExchange, [
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
      ["0x13166638AD246fC02cf2c264D1776aEFC8431B76"],
    ]);

    contract = await NFTWorldExchangeProxy.deployed();
  });
  //  Doug's address should be able to deposit Metaverse Coin
  it("Should allow owner address to deposit Metaverse Coin", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    await provider.send("hardhat_impersonateAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);
    const signer = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    contract = contract.connect(signer);
    await expect(contract.depositMetaverseCoin(100)).to.not.be.reverted;
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
  //
  // Upgrades
  // Proxy should be able to be upgraded
});
