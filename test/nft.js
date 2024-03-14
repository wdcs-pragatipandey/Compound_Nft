const { assert, expect } = require('chai');
const { ethers, network } = require('hardhat');
require('dotenv').config();

describe('Nft_compound Contract', function () {
  let nftCompound;
  let admin;
  let addr1;
  let addr2;
  let nft;

  beforeEach(async function () {
    nftCompound = "0x21A525BAC2571117f20a373aa8863f967f104a33";
    admin = "0xF622D645865Cbd2A9eF2c35E7eD23c33785A3a82";
    addr1 = "0xE7A4865DC18d168a8F2af6Fe2Cfc0805C8299387";
    addr2 = "0xEEdE33770D09722B8B5Ada6A688c0806Dc5E8611";
    cToken = "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643";

    const Nft_compound = await ethers.getContractFactory("NFTCompound");
    nft = await Nft_compound.attach(nftCompound);
  });

  it("Should create a nft", async function () {
    const addr1Address = await ethers.getSigner(addr1)
    await nft.transferFrom(admin, nftCompound, "100")
    await nft.approve(cToken, "100")
    await nft.connect(addr1Address).mintNFT();
  });

  it("Should burn a nft", async function () {
    const addr1Address = await ethers.getSigner(addr1)
    await nft.connect(addr1Address).burnNFT(1);
  });

  it("Should withdraw a interest", async function () {
    const addrAdmin = await ethers.getSigner(admin)
    await nft.connect(addrAdmin).withdrawInterest();
  });


})
