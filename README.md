# Pegasys-Stable-AMM

## About Stable-AMM
Pegasys-Stable-AMM is a decentralized automated market maker (AMM) on the Syscoin blockchain, optimized for trading pegged value crypto assets with minimal slippage. Stable-AMM enables cheap, efficient, swift, and low-slippage swaps for traders and high-yield pools for LPs. We believe in collaboration, in building Pegasys as a DeFi lego block, in helping DeFi teams bring AMMs to any blockchain.

## Usage

### Build

```bash
$ forge build
```

### Test

```bash
$ forge test
```

### Deploying contracts to Anvil localhost 

```bash
$ anvil
```

```bash
$ forge script script/deploySwapDeployer.s.sol:MyScript --fork-url http://localhost:8545 \
 --private-key $PRIVATE-KEY --broadcast
```
