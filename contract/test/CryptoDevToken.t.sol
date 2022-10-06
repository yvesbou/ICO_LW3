// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CryptoDevToken.sol";

contract CryptoDevTokenTest is Test {
    CryptoDevToken public cryptoDevToken;
    address cryptoDevNFTCollection = 0x96788D3aA03B6afAE42F15c059934ac53094Aca8;

    address[2] nftOwners = [
        0x26a58e69f3FF059191d5a72764eD795779Cb1221,
        0x23E5BBFD0A97b93EC889C097A3d9C581391603Da
    ];

    uint256 goerliFork;

    address deployerAndOwner;

    /**
     * @dev receive() and fallback() are needed if the test contract is the owner
     * of the deployed token contract, because otherwise withdraw() does not work
     * because every contract needs to have those functions in order to receive ether
     */

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function setUp() public {
        string memory goerli_RPC_URL = vm.envString("GOERLI_RPC_URL");
        goerliFork = vm.createSelectFork(goerli_RPC_URL);
        deployerAndOwner = address(this);
        cryptoDevToken = new CryptoDevToken(
            "CryptoDev Token",
            "CD",
            cryptoDevNFTCollection
        );
    }

    function testClaim() public {
        vm.prank(nftOwners[0]);
        cryptoDevToken.claim();
        uint256 mintedTokens = cryptoDevToken.balanceOf(nftOwners[0]);
        assertEq(mintedTokens, 10 * 10**18);
    }

    function testClaimNotOwningNFT() public {
        address someRandomUser = vm.addr(1);
        vm.prank(someRandomUser);
        vm.expectRevert(bytes("You need a CryptoDev NFT to Claim Tokens"));
        cryptoDevToken.claim();
    }

    function testClaimTryTwiceToClaim() public {
        vm.prank(nftOwners[0]);
        cryptoDevToken.claim();
        uint256 mintedTokens = cryptoDevToken.balanceOf(nftOwners[0]);
        assertEq(mintedTokens, 10 * 10**18);

        vm.prank(nftOwners[0]);
        vm.expectRevert(bytes("You have claimed all your NFTs"));
        cryptoDevToken.claim();
    }

    function testClaimWhenSoldOut() public {
        address someRandomUser = vm.addr(1);
        uint256 moneyNeededToBuyAllTokens = cryptoDevToken.tokenPrice() *
            cryptoDevToken.maxTotalSupply();
        emit log_uint(moneyNeededToBuyAllTokens);
        vm.deal(someRandomUser, moneyNeededToBuyAllTokens);

        uint256 currentSupply = cryptoDevToken.totalSupply();
        emit log_uint(currentSupply);
        assertEq(0, currentSupply);
        vm.prank(someRandomUser);
        cryptoDevToken.mint(cryptoDevToken.maxTotalSupply());

        vm.prank(nftOwners[0]);
        vm.expectRevert(bytes("The maximal supply of the token is 10,000"));
        cryptoDevToken.claim();
    }
}
