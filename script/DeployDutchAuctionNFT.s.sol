// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/DutchAuctionNFT.sol";

contract DeployDutchAuctionNFT is Script {
    function run() external {
        vm.startBroadcast();
        address royaltyRecipient = 0x46Ca967e39D13595B71cab6AD69237d13096Eb28; // Replace with actual address
        new DutchAuctionNFT(
            "DutchAuctionNFT",
            "DANFT",
            1 ether,
            0.1 ether,
            7 days,
            royaltyRecipient, // Royalty recipient
            500, // 5% royalty
            "https://api.example.com/token/"
        );
        vm.stopBroadcast();
    }
}
