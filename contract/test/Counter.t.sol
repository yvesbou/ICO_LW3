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
}
