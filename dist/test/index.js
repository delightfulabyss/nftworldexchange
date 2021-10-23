"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const chai_1 = __importStar(require("chai"));
const hardhat_1 = require("hardhat");
const ethereum_waffle_1 = require("ethereum-waffle");
const ethers_1 = require("ethers");
chai_1.default.use(ethereum_waffle_1.solidity);
const { abi: erc20ABI, } = require("../artifacts/contracts/ERC20TokenChild.sol/MetaverseCoinChild.json");
const { abi: erc721ABI, } = require("../artifacts/@openzeppelin/contracts/token/ERC721/IERC721.sol/IERC721.json");
const tokenIds = [
    ethers_1.BigNumber.from("105312291668557186697918027683670432318895095400549111254310977538"),
    ethers_1.BigNumber.from("210624583337114373395836055367340864637790190801098222508621955074"),
    ethers_1.BigNumber.from("2"),
    ethers_1.BigNumber.from("315936875005671560093754083051011296956685286201647333762932932610"),
];
describe("NFTWorldExchange", async function () {
    let exchangeContract;
    before(async function () {
        const NFTWorldExchange = await hardhat_1.ethers.getContractFactory("NFTWorldExchangeImplementationV1");
        const NFTWorldExchangeProxy = await hardhat_1.upgrades.deployProxy(NFTWorldExchange, [
            "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
            ["0x13166638AD246fC02cf2c264D1776aEFC8431B76"],
        ]);
        exchangeContract = await NFTWorldExchangeProxy.deployed();
    });
    //  Owner address should be able to deposit Metaverse Coin
    it("Should allow owner address to approve exchange for deposit", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        await provider.send("hardhat_impersonateAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const metaverseCoin = new ethers_1.Contract("0xcae8304fa1f65bcd72e5605db648ee8d6d889509", erc20ABI, owner);
        exchangeContract = exchangeContract.connect(owner);
        await metaverseCoin.approve(exchangeContract.address, ethers_1.utils.parseEther("10.0"));
        (0, chai_1.expect)(await metaverseCoin.allowance("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e", exchangeContract.address)).to.equal(ethers_1.utils.parseEther("10.0"));
    });
    it("Should allow owner address to deposit Metaverse Coin", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const metaverseCoin = new ethers_1.Contract("0xcae8304fa1f65bcd72e5605db648ee8d6d889509", erc20ABI, owner);
        exchangeContract = exchangeContract.connect(owner);
        await exchangeContract.depositMetaverseCoin(ethers_1.utils.parseEther("10.0"));
        (0, chai_1.expect)(await metaverseCoin.balanceOf(exchangeContract.address)).to.equal(ethers_1.utils.parseEther("10.0"));
    });
    it("Should not allow a user address to deposit Metaverse Coin", async function () {
        //  Another address should not be able to deposit Metaverse Coin
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const [user] = await hardhat_1.ethers.getSigners();
        const metaverseCoin = new ethers_1.Contract("0xcae8304fa1f65bcd72e5605db648ee8d6d889509", erc20ABI, owner);
        await metaverseCoin.transfer(user.address, ethers_1.utils.parseEther("10.0"));
        await provider.send("hardhat_stopImpersonatingAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        exchangeContract = exchangeContract.connect(user);
        await (0, chai_1.expect)(exchangeContract.depositMetaverseCoin(ethers_1.utils.parseEther("10.0"))).to.be.reverted;
    });
    it("Should allow owner address to withdraw Metaverse Coin", async function () {
        //  Another address should not be able to deposit Metaverse Coin
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        await provider.send("hardhat_impersonateAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        const metaverseCoin = new ethers_1.Contract("0xcae8304fa1f65bcd72e5605db648ee8d6d889509", erc20ABI, owner);
        exchangeContract = exchangeContract.connect(owner);
        await exchangeContract.withdrawMetaverseCoin(ethers_1.utils.parseEther("10.0"));
        (0, chai_1.expect)(await metaverseCoin.balanceOf(exchangeContract.address)).to.equal(0);
    });
    //
    // Wearables
    //  Owner address should be able to deposit wearables into the contract
    it("Should allow owner address to approve wearables for deposit", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const wearablesContract = new ethers_1.Contract("0x13166638AD246fC02cf2c264D1776aEFC8431B76", erc721ABI, owner);
        await wearablesContract.approve(exchangeContract.address, tokenIds[0]);
        await wearablesContract.approve(exchangeContract.address, tokenIds[1]);
        await wearablesContract.approve(exchangeContract.address, tokenIds[2]);
        await wearablesContract.approve(exchangeContract.address, tokenIds[3]);
        (0, chai_1.expect)(await wearablesContract.getApproved(tokenIds[0])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.getApproved(tokenIds[1])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.getApproved(tokenIds[2])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.getApproved(tokenIds[3])).to.equal(exchangeContract.address);
    });
    it("Should allow owner address to deposit wearables", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const wearablesContract = new ethers_1.Contract("0x13166638AD246fC02cf2c264D1776aEFC8431B76", erc721ABI, owner);
        exchangeContract = exchangeContract.connect(owner);
        await exchangeContract.depositWearables("Green Dragon", tokenIds);
        (0, chai_1.expect)(await exchangeContract.wearableContracts("Green Dragon")).to.equal(wearablesContract.address);
        (0, chai_1.expect)(await exchangeContract.numberTokensAvailable("Green Dragon")).to.equal(4);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[0])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[1])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[2])).to.equal(exchangeContract.address);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[3])).to.equal(exchangeContract.address);
    });
    //  Owner address should be able to withdraw wearables from the contract
    it("Should alllow owner address to withdraw wearables", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const wearablesContract = new ethers_1.Contract("0x13166638AD246fC02cf2c264D1776aEFC8431B76", erc721ABI, owner);
        const ownerAddress = await owner.getAddress();
        exchangeContract = exchangeContract.connect(owner);
        await exchangeContract.withdrawWearables("Green Dragon", tokenIds);
        (0, chai_1.expect)(await exchangeContract.numberTokensAvailable("Green Dragon")).to.equal(0);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[0])).to.equal(ownerAddress);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[1])).to.equal(ownerAddress);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[2])).to.equal(ownerAddress);
        (0, chai_1.expect)(await wearablesContract.ownerOf(tokenIds[3])).to.equal(ownerAddress);
    });
    //  User address should not be able to deposit wearables into the contract
    it("Should not allow user address to deposit wearables", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const [user] = await hardhat_1.ethers.getSigners();
        const wearablesContract = new ethers_1.Contract("0x13166638AD246fC02cf2c264D1776aEFC8431B76", erc721ABI, owner);
        const ownerAddress = await owner.getAddress();
        exchangeContract = exchangeContract.connect(owner);
        await wearablesContract.transferFrom(ownerAddress, user.address, tokenIds[0]);
        await wearablesContract.transferFrom(ownerAddress, user.address, tokenIds[1]);
        await wearablesContract.transferFrom(ownerAddress, user.address, tokenIds[2]);
        await wearablesContract.transferFrom(ownerAddress, user.address, tokenIds[3]);
        await provider.send("hardhat_stopImpersonatingAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        exchangeContract = exchangeContract.connect(user);
        await (0, chai_1.expect)(exchangeContract.depositWearables("Green Dragon", tokenIds)).to
            .be.reverted;
    });
    //  A user should be able receive a wearable of a certain rarity in exchange for a specified amount of Metaverse Coin
    it("Should allow the exchange of a wearable for the correct amount of Metaverse Coin", async function () {
        const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
        const owner = provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
        const ownerAddress = await owner.getAddress();
        const [user] = await hardhat_1.ethers.getSigners();
        let wearablesContract = new ethers_1.Contract("0x13166638AD246fC02cf2c264D1776aEFC8431B76", erc721ABI, user);
        await wearablesContract.transferFrom(user.address, ownerAddress, 2);
        await provider.send("hardhat_impersonateAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        let metaverseCoin = new ethers_1.Contract("0xcae8304fa1f65bcd72e5605db648ee8d6d889509", erc20ABI, owner);
        wearablesContract = wearablesContract.connect(owner);
        exchangeContract = exchangeContract.connect(owner);
        await wearablesContract.approve(exchangeContract.address, [2]);
        await exchangeContract.depositWearables("Green Dragon", [2]);
        await provider.send("hardhat_stopImpersonatingAccount", [
            "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ]);
        exchangeContract = exchangeContract.connect(user);
        metaverseCoin.approve(exchangeContract.address, ethers_1.utils.parseEther("2.0"));
        await exchangeContract.getWearable("Green Dragon", 0, 2);
        (0, chai_1.expect)(await wearablesContract.ownerOf(2)).to.equal(user.address);
        (0, chai_1.expect)(await metaverseCoin
            .balanceOf(user.address)
            .to.equal(ethers_1.utils.parseEther("8.0")));
        (0, chai_1.expect)(await metaverseCoin
            .balanceOf(exchangeContract.address)
            .to.equal(ethers_1.utils.parseEther("2.0")));
    });
    //  A user should not receive a wearable of a certain rarity if they don't have enough Metaverse Coin
    //  A user should receive a payout of 75% of what they paid in exchange for sending a purchased wearable back to the contract
    //  A user should not be able to send a wearable not originally deposited by Doug to the contract
    //
    // Upgrades
    // Proxy should be able to be upgraded
});
