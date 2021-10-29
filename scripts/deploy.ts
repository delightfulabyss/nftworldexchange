import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const NFTWorldExchange = await ethers.getContractFactory(
    "NFTWorldExchangeImplementationV1",
    deployer
  );

  const NFTWorldExchangeProxy = await upgrades.deployProxy(NFTWorldExchange, [
    "0x70D0Ed9b15F4375e31F372e093513042b1d6a520",
    "0xd5e9ef1cedad0d135d543d286a2c190b16cbb89e",
    [],
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
