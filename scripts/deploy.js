async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Nft = await ethers.getContractFactory("MyNFT");
  const NFT_Compound = await Nft.deploy(process.env.DAI_ADDRESS, process.env.CDAI_ADDRESS)

  console.log("NFT deployed to:", NFT_Compound.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
