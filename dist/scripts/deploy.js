"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hardhat_1 = require("hardhat");
async function main() {
    const provider = new hardhat_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
    await provider.send("hardhat_impersonateAccount", [
        "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ]);
    const signer = await provider.getSigner("0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e");
    const NFTWorldExchange = await hardhat_1.ethers.getContractFactory("NFTWorldExchangeImplementationV1", signer);
    const NFTWorldExchangeProxy = await hardhat_1.upgrades.deployProxy(NFTWorldExchange, [
        "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
        "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
        ["0x13166638AD246fC02cf2c264D1776aEFC8431B76"],
    ]);
    await NFTWorldExchangeProxy.deployed();
    console.log("NFTWorldExchangeProxy deployed to:", NFTWorldExchangeProxy.address);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
