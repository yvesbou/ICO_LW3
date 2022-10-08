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

    function computeEtherNeeded(uint256 amount) public pure returns (uint256) {
        require(amount >= 10**18, "Amount needs to be at least 10**18.");
        require(
            amount % 10**18 == 0,
            "Only full CD tokens are sold, no decimals."
        );
        uint256 numberOfTokens = amount / 10**18;
        return 0.001 ether * numberOfTokens;
    }

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
        // 10 * 10**18 because address owns 1 NFT
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
        // 10 * 10**18 because address owns 1 NFT
        assertEq(mintedTokens, 10 * 10**18);

        vm.prank(nftOwners[0]);
        vm.expectRevert(bytes("You have claimed all your NFTs"));
        cryptoDevToken.claim();
    }

    function testClaimWhenSoldOut() public {
        address someRandomUser = vm.addr(1);
        uint256 moneyNeededToBuyAllTokens = computeEtherNeeded(
            cryptoDevToken.maxTotalSupply()
        );
        emit log_uint(moneyNeededToBuyAllTokens);
        vm.deal(someRandomUser, moneyNeededToBuyAllTokens);

        uint256 currentSupply = cryptoDevToken.totalSupply();
        emit log_uint(currentSupply);
        assertEq(0, currentSupply);
        vm.prank(someRandomUser);
        cryptoDevToken.mint{value: moneyNeededToBuyAllTokens}(
            cryptoDevToken.maxTotalSupply()
        );

        vm.prank(nftOwners[0]);
        vm.expectRevert(bytes("The maximal supply of the token is 10,000"));
        cryptoDevToken.claim();
    }

    function testMint() public {
        address someRandomUser = vm.addr(1);
        uint256 moneyNeededToBuyAllTokens = computeEtherNeeded(
            cryptoDevToken.maxTotalSupply()
        );
        emit log_uint(moneyNeededToBuyAllTokens);
        vm.deal(someRandomUser, moneyNeededToBuyAllTokens);
        vm.prank(someRandomUser);
        // buys all the tokens
        cryptoDevToken.mint{value: moneyNeededToBuyAllTokens}(
            cryptoDevToken.maxTotalSupply()
        );
    }

    /**
        todo 
        - withdraw
        - fuzzing with mint
     */

    function testMintBelowOffer() public {
        address someRandomUser = vm.addr(1);
        vm.deal(someRandomUser, 1 ether);
        vm.prank(someRandomUser);
        vm.expectRevert(bytes("Amount needs to be at least 10**18."));
        cryptoDevToken.mint{value: 0.0001 ether}(10**17);
    }

    function testDecimalToken() public {
        address someRandomUser = vm.addr(1);
        vm.deal(someRandomUser, 1 ether);
        vm.prank(someRandomUser);
        vm.expectRevert(bytes("Only full CD tokens are sold, no decimals."));
        // ICO doesn't sell 5.5 CD Tokens
        cryptoDevToken.mint{value: 0.0001 ether}(55 * 10**17);
    }

    function testMintNotEnoughEtherSent() public {
        uint256 priceForTenTokens = computeEtherNeeded(10 * 10**18);
        emit log_uint(priceForTenTokens);
        address someRandomUser = vm.addr(1);
        // deal not enough such that function fails
        uint256 notEnoughEther = priceForTenTokens - 1;
        vm.deal(someRandomUser, notEnoughEther);
        vm.prank(someRandomUser);
        vm.expectRevert(bytes("Ether amount for minting tokens is not enough"));
        cryptoDevToken.mint{value: notEnoughEther}(10 * 10**18);
    }

    function testExceedingMaxSupply() public {
        address someRandomUser = vm.addr(1);
        uint256 moneyNeededToBuyAllTokens = computeEtherNeeded(
            10 * cryptoDevToken.maxTotalSupply()
        );
        emit log_uint(moneyNeededToBuyAllTokens);
        vm.deal(someRandomUser, moneyNeededToBuyAllTokens);
        vm.prank(someRandomUser);
        // buys all the tokens
        cryptoDevToken.mint{value: moneyNeededToBuyAllTokens}(
            cryptoDevToken.maxTotalSupply()
        );
        vm.prank(someRandomUser);
        // try to buy just one other token
        vm.expectRevert(bytes("Exceeds the max total supply available."));
        cryptoDevToken.mint{value: 1 ether}(10**18);
    }

    function testWithdraw() public {
        uint256 priceForTenTokens = computeEtherNeeded(10 * 10**18);
        emit log_uint(priceForTenTokens);
        address someRandomUser = vm.addr(1);
        // deal not enough such that function fails
        vm.deal(someRandomUser, priceForTenTokens);
        vm.prank(someRandomUser);
        cryptoDevToken.mint{value: priceForTenTokens}(10 * 10**18);

        uint256 balance = address(cryptoDevToken).balance;
        assertEq(balance, 0.01 ether);
        cryptoDevToken.withdraw();

        uint256 balanceEmpty = address(cryptoDevToken).balance;
        assertEq(balanceEmpty, 0);
    }
}
