import chai, { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { solidity } from "ethereum-waffle";
import { Contract, BigNumber } from "ethers";

chai.use(solidity);
const {
  abi: erc20ABI,
} = require("../artifacts/contracts/ERC20TokenChild.sol/MetaverseCoinChild.json");
const {
  abi: erc721ABI,
} = require("../artifacts/@openzeppelin/contracts/token/ERC721/IERC721.sol/IERC721.json");
const tokenIds = [
  BigNumber.from(
    "105312291668557186697918027683670432318895095400549111254310977538"
  ),
  BigNumber.from(
    "210624583337114373395836055367340864637790190801098222508621955074"
  ),
  BigNumber.from("2"),
  BigNumber.from(
    "315936875005671560093754083051011296956685286201647333762932932610"
  ),
];

describe("NFTWorldExchange", async function () {
  let exchangeContract: Contract;

  before(async function () {
    const NFTWorldExchange = await ethers.getContractFactory(
      "NFTWorldExchangeImplementationV1"
    );

    const NFTWorldExchangeProxy = await upgrades.deployProxy(NFTWorldExchange, [
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
      ["0x13166638AD246fC02cf2c264D1776aEFC8431B76"],
    ]);

    exchangeContract = await NFTWorldExchangeProxy.deployed();
  });

  //  Doug's address should be able to deposit Metaverse Coin
  it("Should allow owner address to approve exchange for deposit", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    await provider.send("hardhat_impersonateAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    const metaverseCoin = new Contract(
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      erc20ABI,
      owner
    );
    exchangeContract = exchangeContract.connect(owner);
    await metaverseCoin.approve(
      exchangeContract.address,
      BigNumber.from("100")
    );
    expect(
      await metaverseCoin.allowance(
        "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        exchangeContract.address
      )
    ).to.equal(BigNumber.from("100"));
  });

  it("Should allow owner address to deposit Metaverse Coin", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    const metaverseCoin = new Contract(
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      erc20ABI,
      owner
    );
    exchangeContract = exchangeContract.connect(owner);
    await exchangeContract.depositMetaverseCoin(BigNumber.from("100"));
    expect(await metaverseCoin.balanceOf(exchangeContract.address)).to.equal(
      BigNumber.from("100")
    );
  });

  it("Should not allow a user address to deposit Metaverse Coin", async function () {
    //  Another address should not be able to deposit Metaverse Coin
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    const [user] = await ethers.getSigners();
    const metaverseCoin = new Contract(
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      erc20ABI,
      owner
    );
    await metaverseCoin.transfer(user.address, BigNumber.from("100"));
    await provider.send("hardhat_stopImpersonatingAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);
    exchangeContract = exchangeContract.connect(user);
    await expect(exchangeContract.depositMetaverseCoin(BigNumber.from("100")))
      .to.be.reverted;
  });

  it("Should allow owner address to withdraw Metaverse Coin", async function () {
    //  Another address should not be able to deposit Metaverse Coin
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );

    await provider.send("hardhat_impersonateAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);
    const metaverseCoin = new Contract(
      "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
      erc20ABI,
      owner
    );

    exchangeContract = exchangeContract.connect(owner);
    await exchangeContract.withdrawMetaverseCoin(BigNumber.from("100"));
    expect(await metaverseCoin.balanceOf(exchangeContract.address)).to.equal(0);
  });

  //
  // Wearables
  //  Owner address should be able to deposit wearables into the contract
  it("Should allow owner address to approve wearables for deposit", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    const wearablesContract = new Contract(
      "0x13166638AD246fC02cf2c264D1776aEFC8431B76",
      erc721ABI,
      owner
    );
    await wearablesContract.approve(exchangeContract.address, tokenIds[0]);
    await wearablesContract.approve(exchangeContract.address, tokenIds[1]);
    await wearablesContract.approve(exchangeContract.address, tokenIds[2]);
    await wearablesContract.approve(exchangeContract.address, tokenIds[3]);
    expect(await wearablesContract.getApproved(tokenIds[0])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.getApproved(tokenIds[1])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.getApproved(tokenIds[2])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.getApproved(tokenIds[3])).to.equal(
      exchangeContract.address
    );
  });

  it("Should allow owner address to deposit wearables", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    await provider.send("hardhat_impersonateAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);

    const wearablesContract = new Contract(
      "0x13166638AD246fC02cf2c264D1776aEFC8431B76",
      erc721ABI,
      owner
    );

    exchangeContract = exchangeContract.connect(owner);
    await exchangeContract.depositWearables("Green Dragon", tokenIds);
    expect(await exchangeContract.wearableContracts("Green Dragon")).to.equal(
      wearablesContract.address
    );
    expect(await wearablesContract.ownerOf(tokenIds[0])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.ownerOf(tokenIds[1])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.ownerOf(tokenIds[2])).to.equal(
      exchangeContract.address
    );
    expect(await wearablesContract.ownerOf(tokenIds[3])).to.equal(
      exchangeContract.address
    );
  });

  //  Owner address should be able to withdraw wearables from the contract
  it("Should alllow owner address to withdraw wearables", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    await provider.send("hardhat_impersonateAccount", [
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);

    const wearablesContract = new Contract(
      "0x13166638AD246fC02cf2c264D1776aEFC8431B76",
      erc721ABI,
      owner
    );
    const ownerAddress = await owner.getAddress();
    exchangeContract = exchangeContract.connect(owner);
    await exchangeContract.withdrawWearables("Green Dragon", tokenIds);
    expect(await wearablesContract.ownerOf(tokenIds[0])).to.equal(ownerAddress);
    expect(await wearablesContract.ownerOf(tokenIds[1])).to.equal(ownerAddress);
    expect(await wearablesContract.ownerOf(tokenIds[2])).to.equal(ownerAddress);
    expect(await wearablesContract.ownerOf(tokenIds[3])).to.equal(ownerAddress);
  });

  //  User address should not be able to deposit wearables into the contract
  it("Should not allow user address to deposit wearables", async function () {
    const provider = new ethers.providers.JsonRpcProvider(
      "http://127.0.0.1:8545"
    );
    const owner = provider.getSigner(
      "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"
    );
    const [user] = await ethers.getSigners();
    const wearablesContract = new Contract(
      "0x13166638AD246fC02cf2c264D1776aEFC8431B76",
      erc721ABI,
      owner
    );
    const ownerAddress = await owner.getAddress();
    exchangeContract = exchangeContract.connect(owner);
    await wearablesContract.transferFrom(
      ownerAddress,
      user.address,
      tokenIds[0]
    );
    await wearablesContract.transferFrom(
      ownerAddress,
      user.address,
      tokenIds[1]
    );
    await wearablesContract.transferFrom(
      ownerAddress,
      user.address,
      tokenIds[2]
    );
    await wearablesContract.transferFrom(
      ownerAddress,
      user.address,
      tokenIds[3]
    );
    exchangeContract = exchangeContract.connect(user);
    await expect(exchangeContract.depositWearables("Green Dragon", tokenIds)).to
      .be.reverted;
  });
  //  A user should be able receive a wearable of a certain rarity in exchange for a specified amount of Metaverse Coin
  //  A user should not receive a wearable of a certain rarity if they don't have enough Metaverse Coin
  //  A user should receive a payout of 75% of what they paid in exchange for sending a purchased wearable back to the contract
  //  A user should not be able to send a wearable not originally deposited by Doug to the contract
  //
  // Upgrades
  // Proxy should be able to be upgraded
});
