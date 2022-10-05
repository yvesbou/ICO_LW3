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

    // keep track of which nft was used to claim CD Tokens
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(
        string memory tokenname,
        string memory symbol,
        address cryptoDevsAddress
    ) ERC20(tokenname, symbol) {
        cryptoDevs = ICryptoDevs(cryptoDevsAddress);
    }

    /**
     * @dev this function allows NFT holders (CryptoDev collection) to
     * get 10 tokens for free (but need to pay the gas of the transaction)
     */
    function claim() external {
        // checks if the user has NFTs
        uint256 nftsOwned = cryptoDevs.balanceOf(msg.sender);
        require(nftsOwned > 0, "You need a CryptoDev NFT to Claim Tokens");

        uint256 nftsUnclaimed = 0;

        // makes sure that every NFT that is claimed is ticked off for eligibility
        for (uint256 index = 0; index < nftsOwned; index++) {
            uint256 tokenId = cryptoDevs.tokenOfOwnerByIndex(msg.sender, index);
            if (!tokenIdsClaimed[tokenId]) {
                nftsUnclaimed += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(nftsUnclaimed > 0, "You have claimed all your NFTs");

        // if e.g 3 NFTs are unclaimed, the user gets 30 CD tokens
        uint256 amountToClaim = tokensPerNFT * nftsUnclaimed;
        uint256 currentSupply = totalSupply();
        require(
            currentSupply + amountToClaim < maxTotalSupply,
            "The maximal supply of the token is 10,000"
        );

        _mint(msg.sender, amountToClaim);
    }

    /**
     * @dev this is the normal function to mint tokens
     * requires the user to send enough ether to cover the
     * price of each CD token of 0.001 ether.
     */
    function mint(uint256 amount) external payable {
        require(amount > 0, "Amount needs to be greater than 0");

        // check if enough ether send
        require(
            tokenPrice * amount >= msg.value,
            "Ether amount for minting tokens is not enough"
        );
        // convert into decimals
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        _mint(msg.sender, amountWithDecimals);
    }
}
