// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";


contract FractionalizedNFT is ERC20, Ownable, ERC20Permit, ERC721Holder {
    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;
    bool public forSale = false;
    uint256 public curatorRedeemFee;
    bool public canRedeem = false;
    
    
    constructor(string memory _tokenName, string memory _tokenAbb) ERC20(_tokenName, _tokenAbb) ERC20Permit(_tokenName) {}

    function initializingToken(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(!initialized, "Already initialized");
        require(_amount > 0, "Amount needs to be more than 0");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialized = true;
        _mint(msg.sender, _amount);
        
    }

    function putForSale(uint256 price) external onlyOwner {
        curatorRedeemFee = price;
        forSale = true;
    }

    function purchase() external payable {
        require(forSale, "Not for sale");
        require(msg.value >= curatorRedeemFee, "Not enough ether sent");
        collection.transferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

    function curatorFeeRedeem() external {
        require(canRedeem, "Redeem not currently Active");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = balanceOf(msg.sender) * totalEther / totalSupply();
        _burn(msg.sender, balanceOf(msg.sender));
        payable(msg.sender).transfer(toRedeem);
    }
}