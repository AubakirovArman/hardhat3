// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const USDT = await hre.ethers.getContractFactory("USDT");
  const usdt = await USDT.deploy();
  await usdt.deployed();
  console.log(usdt.address);
  const YourToken = await hre.ethers.getContractFactory("YourToken");
  const yt = await YourToken.deploy();
  await yt.deployed();
  console.log(yt.address);
  const Staking = await hre.ethers.getContractFactory("Staking");
  const st = await Staking.deploy(usdt.address, yt.address);
  await st.deployed();
  console.log(st.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
