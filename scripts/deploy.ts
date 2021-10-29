import { ethers, upgrades } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const NFTWorldExchange = await ethers.getContractFactory(
    "NFTWorldExchangeImplementationV1",
    signer
  );

  const NFTWorldExchangeProxy = await upgrades.deployProxy(NFTWorldExchange, [
    "0x70D0Ed9b15F4375e31F372e093513042b1d6a520",
    "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    ["0x13166638ad246fc02cf2c264d1776aefc8431b76"],
  ]);

  await NFTWorldExchangeProxy.deployed();

  console.log(
    "NFTWorldExchangeProxy deployed to:",
    NFTWorldExchangeProxy.address
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
