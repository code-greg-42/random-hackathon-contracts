const address = '0x19c35843763eC2E9a5570f62Cf84C6687968D71F';
const message = 'allin';
const salt = 'grandersson';
const numString = "42";
const numCheck = 42;
const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message + salt));

async function main() {
    const contract = await hre.ethers.getContractAt("LibTest", address);
    const verified = await contract.TestFunction(hash, message, salt, numString, numCheck);
    console.log(verified);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });