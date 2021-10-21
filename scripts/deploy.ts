// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import hre, { ethers, upgrades } from "hardhat";

async function main() {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e"],
  });

  const NFTWorldExchange = await ethers.getContractFactory(
    "NFTWorldExchangeImplmentationV1"
  );

  const NFTWorldExchangeProxy = await upgrades.deployProxy(NFTWorldExchange, [
    "0xcae8304fa1f65bcd72e5605db648ee8d6d889509",
    "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ["0x13166638AD246fC02cf2c264D1776aEFC8431B76"],
  ]);

  await NFTWorldExchangeProxy.deployed();

  console.log(
    "NFTWorldExchangeProxy deployed to:",
    NFTWorldExchangeProxy.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
