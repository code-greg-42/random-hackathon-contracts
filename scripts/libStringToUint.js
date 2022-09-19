const address = '0xdce3cCe84c84dF0095875c2B2B359170861c0e1E';
const numString = "56";

async function main() {
    const contract = await hre.ethers.getContractAt("LibTest", address);
    const numFromString = await contract.convertToInt(numString);
    console.log(numFromString);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });