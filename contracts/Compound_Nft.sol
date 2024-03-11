// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/Compound.sol";

contract MyToken is ERC721 {
    IERC20 public token;
    CErc20 public cToken;
    uint256 private _nextTokenId;
    address owner;

    event Log(string message, uint256 val);

    constructor(address _token, address _cToken) ERC721("NFTSupply", "NFT") {
        token = IERC20(_token);
        cToken = CErc20(_cToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function safeMint(uint256 _amount) public {
        require(_amount == 100, "Please add 100 Dai Token");
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(address(cToken), _amount);

        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit Log("Exchange Rate (scaled up): ", exchangeRateMantissa);

        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit Log("Supply Rate: (scaled up)", supplyRateMantissa);

        require(cToken.mint(_amount) == 0, "mint failed");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function burnToken(uint256 tokenId, uint256 _cTokenAmount) public {
        require(cToken.redeem(_cTokenAmount) == 0, "redeem failed");
        _burn(tokenId);
    }

    function withdrawToken(uint256 _amount) external onlyOwner {
        token.transfer(msg.sender, _amount);
    }
}
