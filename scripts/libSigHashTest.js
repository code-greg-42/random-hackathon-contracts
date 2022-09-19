const address = '0xdce3cCe84c84dF0095875c2B2B359170861c0e1E';
const message = 'allin';
const salt = 'grandersson';
const fullMessage = message + salt;

async function main() {
    const wallet = ethers.Wallet.createRandom();
    console.log(wallet.address);
    const fullMessageHash = ethers.utils.hashMessage(fullMessage);
    console.log(fullMessageHash);
    const signature = await wallet.signMessage(fullMessage);
    const ogAddress = ethers.utils.verifyMessage(fullMessage, signature);
    console.log(ogAddress === wallet.address);
    const sig = ethers.utils.splitSignature(signature);

    const contract = await hre.ethers.getContractAt("LibTest", address);
    const verified = await contract.verifyEthHashExample(wallet.address, fullMessageHash, sig.v, sig.r, sig.s);
    console.log(verified);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });