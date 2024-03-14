// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/Compound.sol";

contract NFTCompound is ERC721 {
    address public admin;
    IERC20 private dai;
    CErc20 private cDai;
    uint256 private _nextTokenId;
    uint256 private lastInterestAccrued;

    mapping(address => uint256) public userCDAIBalances;

    constructor(address _daiAddress, address _cDaiAddress)
        ERC721("NFTCompound", "NFTC")
    {
        dai = IERC20(_daiAddress);
        cDai = CErc20(_cDaiAddress);
        admin = msg.sender;
        lastInterestAccrued = block.timestamp;
    }

    function mintNFT() external {
        require(
            dai.transferFrom(msg.sender, address(this), 100),
            "Transfer failed"
        );
        require(dai.approve(address(cDai), 100), "Approval failed");
        uint256 cDaiBalanceBefore = cDai.balanceOf(address(this));
        require(cDai.mint(100) == 0, "Mint failed");
        uint256 cDaiBalanceAfter = cDai.balanceOf(address(this));
        uint256 cDaiMinted = cDaiBalanceAfter - cDaiBalanceBefore;
        userCDAIBalances[msg.sender] += cDaiMinted;
        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
    }

    function burnNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        _burn(tokenId);
        uint256 cDaiBalance = userCDAIBalances[msg.sender];
        require(cDaiBalance > 0, "No cDAI to redeem");
        userCDAIBalances[msg.sender] = 0;
        uint256 daiAmount = cDai.redeem(cDaiBalance);
        uint256 amount = daiAmount - 100;
        require(dai.transfer(msg.sender, 100), "Transfer failed");
        dai.transfer(address(this), amount);
    }

    function withdrawInterest() external {
        uint256 interest = calculateInterest();
        require(dai.transfer(msg.sender, interest), "Transfer failed");
        lastInterestAccrued = block.timestamp;
    }

    function calculateInterest() internal returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timeElapsed = currentTime - lastInterestAccrued;
        uint256 supplyRate = cDai.supplyRatePerBlock();
        uint256 balance = cDai.balanceOfUnderlying(address(this));
        uint256 accruedInterest = (balance * supplyRate * timeElapsed) /
            (1e18 * 15 seconds);
        return accruedInterest;
    }
}
