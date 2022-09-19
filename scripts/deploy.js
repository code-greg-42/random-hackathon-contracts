async function main() {

  const shuffleContract = await hre.ethers.getContractFactory("LibTest");
  const contract = await shuffleContract.deploy();
  console.log("Deploying contract...");
  await contract.deployed();

  console.log(`Contract deployed to ${contract.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
