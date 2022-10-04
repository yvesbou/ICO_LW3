// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 10**18;
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    ICryptoDevs cryptoDevs;

    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(
        string memory tokenname,
        string memory symbol,
        address cryptoDevsAddress
    ) ERC20(tokenname, symbol) {
        cryptoDevs = ICryptoDevs(cryptoDevsAddress);
    }

    function claim() external {
        uint256 nftsOwned = cryptoDevs.balanceOf(msg.sender);
        require(nftsOwned > 0, "You need a CryptoDev NFT to Claim Tokens");

        uint256 nftsUnclaimed = 0;

        for (uint256 index = 0; index < nftsOwned; index++) {
            uint256 tokenId = cryptoDevs.tokenOfOwnerByIndex(msg.sender, index);
            if (!tokenIdsClaimed[tokenId]) {
                nftsUnclaimed += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(nftsUnclaimed > 0, "You have claimed all your NFTs");

        uint256 amountToClaim = tokensPerNFT * nftsUnclaimed;
        uint256 currentSupply = totalSupply();
        require(
            currentSupply + amountToClaim < maxTotalSupply,
            "The maximal supply of the token is 10,000"
        );

        _mint(msg.sender, amountToClaim);
    }

    function mint(uint256 amount) external payable {
        require(amount > 0, "Amount needs to be greater than 0");

        require(
            tokenPrice * amount >= msg.value,
            "Ether amount for minting tokens is not enough"
        );
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        _mint(msg.sender, amountWithDecimals);
    }
}
