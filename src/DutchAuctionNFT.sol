// SPDX-License-Identifier: MIT
// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract DutchAuctionNFT is ERC721, IERC2981 {
    error DutchAuctionNFT__NotOwner();
    error DutchAuctionNFT__AuctionNotStarted();
    error DutchAuctionNFT__InsufficientPayment();

    using Address for address payable;

    uint256 public nextTokenId;
    address public owner;
    string private _baseTokenURI;

    // Auction parameters
    uint256 public startTime;
    uint256 public startPrice;
    uint256 public endPrice;
    uint256 public duration;

    // Royalties
    address public royaltyRecipient;
    uint256 public royaltyBps;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert DutchAuctionNFT__NotOwner();
        }
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _duration,
        address _royaltyRecipient,
        uint256 _royaltyBps,
        string memory baseURI_
    ) ERC721(name_, symbol_) {
        owner = msg.sender;
        startPrice = _startPrice;
        endPrice = _endPrice;
        duration = _duration;
        startTime = block.timestamp;
        _baseTokenURI = baseURI_;

        require(_royaltyBps <= 10_000, "Royalty too high");
        royaltyRecipient = _royaltyRecipient;
        royaltyBps = _royaltyBps;
    }

    function mint() external payable {
        if ((block.timestamp < startTime)) {
            revert DutchAuctionNFT__AuctionNotStarted();
        }

        uint256 currentPrice = getCurrentPrice();

        if ((msg.value < currentPrice)) {
            revert DutchAuctionNFT__InsufficientPayment();
        }

        // Refund excess
        if (msg.value > currentPrice) {
            payable(msg.sender).sendValue(msg.value - currentPrice);
        }

        _safeMint(msg.sender, nextTokenId);
        nextTokenId++;
    }

    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp < startTime) return startPrice;
        uint256 elapsed = block.timestamp - startTime;
        if (elapsed >= duration) return endPrice;

        return startPrice - ((startPrice - endPrice) * elapsed) / duration;
    }

    // ERC2981 Royalties
    function royaltyInfo(uint256, uint256 salePrice) external view override returns (address, uint256) {
        return (royaltyRecipient, (salePrice * royaltyBps) / 10_000);
    }

    // Metadata
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Withdraw funds
    function withdraw() external onlyOwner {
        payable(owner).sendValue(address(this).balance);
    }

}
