const address = '0x9541C499AbD18f0d13EaaEa811BA4c0aF9c9c04a';

const hash = '0x220c71038539401a792d0005466669b74089f95497c6df38aca1943b833a5425';
const v = 27;
const r = '0x1ba40178e886d788826bceea720a916b8b819029348163d897b768fd1090f553';
const s = '0x6d453b5a72f960eb86a43b1ed7b7a9282a536dd6abb0dc4b7b3bac4baaa349d6';

async function main() {
    const contract = await hre.ethers.getContractAt("ShuffleDao", address);
    const sigKey = await contract.VerifyMessage(hash, v, r, s);
    console.log(sigKey);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });