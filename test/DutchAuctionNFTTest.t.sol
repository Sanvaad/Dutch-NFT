// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/DutchAuctionNFT.sol";

contract DutchAuctionNFTTest is Test {
    DutchAuctionNFT nft;
    address owner = address(0x123);
    address buyer = address(0x456);
    uint256 startPrice = 1 ether;
    uint256 endPrice = 0.1 ether;
    uint256 duration = 7 days;

    function setUp() public {
        vm.prank(owner);
        nft = new DutchAuctionNFT(
            "TestNFT",
            "TNFT",
            startPrice,
            endPrice,
            duration,
            owner,
            500, // 5% royalty
            "https://api.example.com/token/"
        );
    }

    function testPriceDecrease() public {
        vm.warp(nft.startTime() + duration / 2);
        assertEq(nft.getCurrentPrice(), 0.55 ether); // (1 + 0.1)/2 = 0.55
    }

    function testMint() public {
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        nft.mint{value: 1 ether}();
        assertEq(nft.ownerOf(0), buyer);
    }

    function testRoyaltyInfo() public view {
        (address recipient, uint256 amount) = nft.royaltyInfo(0, 1 ether);
        assertEq(recipient, owner);
        assertEq(amount, 0.05 ether); // 5% of 1 ETH
    }



    function testMintBeforeAuctionStart() public {
        vm.warp(nft.startTime() - 1); // Set time before auction starts
        vm.expectRevert(DutchAuctionNFT.DutchAuctionNFT__AuctionNotStarted.selector);
        nft.mint{value: 1 ether}();
    }

    function testPriceAtAuctionStart() public view {
        assertEq(nft.getCurrentPrice(), 1 ether);
    }

    function testPriceAtAuctionEnd() public {
        vm.warp(nft.startTime() + duration);
        assertEq(nft.getCurrentPrice(), 0.1 ether);
    }

    function testPriceBelowEndPrice() public {
        vm.warp(nft.startTime() + duration * 2); // 2x duration
        assertEq(nft.getCurrentPrice(), 0.1 ether); // Shouldn't go below endPrice
    }

    function testMintWithExactPayment() public {
        vm.deal(buyer, 0.55 ether);
        vm.warp(nft.startTime() + duration / 2);

        vm.prank(buyer);
        nft.mint{value: 0.55 ether}();

        assertEq(nft.ownerOf(0), buyer);
    }

    function testInsufficientPayment() public {
        vm.deal(buyer, 0.54 ether);
        vm.warp(nft.startTime() + (duration / 2));

        vm.prank(buyer);
        vm.expectRevert(DutchAuctionNFT.DutchAuctionNFT__InsufficientPayment.selector);
        nft.mint{value: 0.54 ether}();
    }

    function testMultipleMints() public {
        vm.deal(buyer, 2 ether);
        vm.startPrank(buyer);

        // Mint first NFT
        nft.mint{value: 1 ether}();
        assertEq(nft.ownerOf(0), buyer);

        // Mint second NFT after 1 day
        vm.warp(nft.startTime() + 1 days);
        uint256 newPrice = nft.getCurrentPrice();
        nft.mint{value: newPrice}();
        assertEq(nft.ownerOf(1), buyer);

        vm.stopPrank();
    }

    function testRoyaltyEdgeCases() public {
        // Test with different sale price
        (, uint256 amount) = nft.royaltyInfo(0, 2.5 ether);
        assertEq(amount, 0.125 ether); // 2.5 ETH * 5% = 0.125 ETH

        // Test royalty cap
        vm.expectRevert("Royalty too high");
        new DutchAuctionNFT(
            "InvalidNFT",
            "INFT",
            1 ether,
            0.1 ether,
            7 days,
            owner,
            10_001, // 100.01% (invalid)
            "https://api.example.com/token/"
        );
    }

    function testWithdrawFunction() public {
        // Mint an NFT to fund the contract
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        nft.mint{value: 1 ether}();

        // Test owner withdrawal

        vm.prank(owner);
        nft.withdraw();

        assertEq(address(nft).balance, 0);
    }

    function testNonOwnerWithdraw() public {
        vm.prank(buyer);
        vm.expectRevert(DutchAuctionNFT.DutchAuctionNFT__NotOwner.selector);
        nft.withdraw();
    }

    function testNonOwnerSetBaseURI() public {
        vm.prank(buyer);
        vm.expectRevert(DutchAuctionNFT.DutchAuctionNFT__NotOwner.selector);
        nft.setBaseURI("https://hacker.com/");
    }
}
