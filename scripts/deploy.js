async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Nft = await ethers.getContractFactory("NFTCompound");
  const NFT_Compound = await Nft.deploy("0x6B175474E89094C44Da98b954EedeAC495271d0F", "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643")

  console.log("NFT deployed to:", NFT_Compound.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
