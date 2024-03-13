// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/Compound.sol";

contract NFTCompound is ERC721 {
    using SafeMath for uint256;
    address public admin;
    IERC20 private token;
    CErc20 private cToken;
    uint256 private _nextTokenId;

    uint256 private lastInterestAccrued;

    constructor(
        address _daiAddress,
        address _cDaiAddress
    ) ERC721("NFTCompound", "NFTC") {
        token = IERC20(_daiAddress);
        cToken = CErc20(_cDaiAddress);
        admin = msg.sender;

        lastInterestAccrued = block.timestamp;
    }

    function mintNFT() external {
        require(
            token.transferFrom(msg.sender, address(this), 100),
            "Transfer failed"
        );
        token.approve(address(cToken), 100);

        require(cToken.mint(100) == 0, "Failed to mint cToken");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function burnNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        _burn(tokenId);
        uint256 daiAmount = 100;
        uint256 cDaiBalance = cToken.balanceOf(address(this));
        // require(cToken.redeem(cDaiBalance) == 0, "Failed to redeem cToken");
        uint256 amount = cToken.redeem(cDaiBalance) - daiAmount;
        require(token.transfer(msg.sender, daiAmount), "Transfer failed");
        token.transfer(address(this), amount);
    }

    function withdrawInterest() external {
        require(msg.sender == admin, "only admin can withdraw");
        uint256 interest = calculateInterest();
        require(token.transfer(msg.sender, interest), "Transfer failed");
        lastInterestAccrued = block.timestamp;
    }

    function calculateInterest() internal returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timeElapsed = currentTime - lastInterestAccrued;
        uint256 supplyRate = cToken.supplyRatePerBlock();
        uint256 balance = cToken.balanceOfUnderlying(address(this));
        uint256 accruedInterest = (balance * supplyRate * timeElapsed) /
            (1e18 * 15 seconds);
        return accruedInterest;
    }
}
