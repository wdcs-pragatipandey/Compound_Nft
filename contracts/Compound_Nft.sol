// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import library
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/Compound.sol";

//Contract
contract MyNFT is ERC721 {
    using SafeMath for uint256;
    address public admin;
    IERC20 private token;
    CErc20 private cToken;
    uint256 private _nextTokenId;

    // token & cToken address of underlying asset
    constructor(address _token, address _cToken) ERC721("MyNft", "NFT") {
        token = IERC20(_token);
        cToken = CErc20(_cToken);
        admin = msg.sender;
    }

    // supply 100Dai to mint Nft
    function mint(uint256 _amount) external {
        require(_amount >= 100, "minimum amount is 100 Dai");
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(address(cToken), _amount);
        require(cToken.mint(_amount) == 0, "Failed to mint cToken");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }
    // burn nft to redeem 100Dai
    function burn(uint256 tokenId) external {
        uint256 cTokenBalance = cToken.balanceOf(address(this));
        require(cToken.redeem(cTokenBalance) == 0, "Failed to redeem cToken");
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenBalance);
        _burn(tokenId);
    }

    // only admin can withdraw 
    function withdraw(uint256 cTokenBalance) external {
        require(msg.sender == admin, "only admin can withdraw");
        uint256 interest = calculateInterest(cTokenBalance);
        uint256 adminFee = interest.mul(10).div(100);
        token.transfer(admin, adminFee);
    }
    
    // internal function to calculate interest
    function calculateInterest(
        uint256 cTokenBalance
    ) internal returns (uint256) {
        uint256 exchangeRate = cToken.exchangeRateCurrent();
        uint256 tokenBalance = cTokenBalance.mul(exchangeRate);
        return tokenBalance.sub(100);
    }
}
