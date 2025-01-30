# Dutch Auction NFT with Royalties

An ERC721 NFT contract implementing a Dutch auction pricing mechanism and ERC2981 royalties standard.

## Features

- **Dutch Auction Pricing**:  
  - Price starts at `startPrice` and linearly decreases to `endPrice` over `duration`
  - Real-time price calculation via `getCurrentPrice()`
- **Royalties**: 
  - ERC2981 compliant (5% default royalty)
  - Configurable recipient and percentage
- **Metadata**: 
  - Configurable base URI
  - Auto-incrementing token IDs
- **Security**:
  - Owner-restricted functions
  - Automatic ETH refunds for overpayments

## Installation

1. **Install Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Clone Repository**:
   ```bash
   git clone https://github.com/yourusername/dutch-auction-nft.git
   cd dutch-auction-nft
   ```

3. **Install Dependencies**:
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts
   ```

## Deployment

### 1. Configure Environment
Create `.env` file:
```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=your_wallet_private_key
ETHERSCAN_API_KEY=your_etherscan_key
```

### 2. Deploy to Sepolia
```bash
make deploy ARGS="--network sepolia"
```

## Usage

### Minting NFTs
```solidity
function mint() external payable {
    // Price auto-calculated based on auction timing
    // Excess ETH automatically refunded
}
```

### Key Functions
```solidity
// Get current price
function getCurrentPrice() public view returns (uint256)

// Withdraw collected ETH (owner only)
function withdraw() external

// Update base URI (owner only)
function setBaseURI(string memory baseURI) external
```

## Testing
Run comprehensive test suite:
```bash
forge test -vvv
```

**Test Coverage**:
- Price calculation at different time points
- Minting with exact/insufficient payments
- Royalty distribution checks
- Ownership access control
- Metadata URI handling

## Contract Structure

### Key Parameters
| Variable | Description |
|----------|-------------|
| `startPrice` | Initial price (e.g., 1 ETH) |
| `endPrice` | Final price after `duration` |
| `duration` | Auction duration in seconds |
| `royaltyBps` | Royalty percentage in basis points (500 = 5%) |

### Inheritance
- ERC721 (OpenZeppelin)
- IERC2981 (Royalty standard)

## Security

### Audited Dependencies
- OpenZeppelin Contracts v5.0.2

### Best Practices
- Reentrancy protection via Checks-Effects-Interactions
- Safe ETH transfers with `Address.sendValue()`
- Input validation in constructor

## License
MIT License

## Acknowledgements
- Built with [Foundry](https://getfoundry.sh/)
- Uses [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

> **Warning**  
> This is experimental software. Use at your own risk after thorough auditing.
```

This README provides:
- Clear installation/deployment instructions
- Key feature explanations
- Usage examples
- Security considerations
- Testing guidelines
- Project structure overview

Customize the RPC URLs, deployment commands, and acknowledgements as needed for your specific implementation.
